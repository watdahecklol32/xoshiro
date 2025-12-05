--!strict
--!native
--!optimize 2

local shift = {state = nil :: buffer?};
local switch_seed: boolean = false;

local split = @native function(state: number): buffer
	local state_bfr: buffer = buffer.create(10);
	buffer.writeu32(state_bfr, 1, state + 0x7f4A7C15);

	buffer.writeu32(state_bfr, 2, bit32.bxor(buffer.readu32(state_bfr, 1), bit32.rshift(buffer.readu32(state_bfr, 1), 30)));
	buffer.writeu32(state_bfr, 3, buffer.readu32(state_bfr, 2) * 0x1CE4E5B9);


	buffer.writeu32(state_bfr, 4, bit32.bxor(buffer.readu32(state_bfr, 3), bit32.rshift(buffer.readu32(state_bfr, 3), 27)));
	buffer.writeu32(state_bfr, 5,  buffer.readu32(state_bfr, 4) * 0x133111EB);

	buffer.writeu32(state_bfr, 6, bit32.bxor(buffer.readu32(state_bfr, 4), bit32.rshift(buffer.readu32(state_bfr, 5), 31)));
	return state_bfr;
end;

@native function shift.start(seed: number): buffer
	local state: buffer = buffer.create(12);
	buffer.writeu32(state, 1, buffer.readu32(split(seed), 6));

	buffer.writeu32(state, 2, buffer.readu32(split(buffer.readu32(state, 1)), 6));
	buffer.writeu32(state, 3, buffer.readu32(split(buffer.readu32(state, 2)), 6));

	return state;
end;

@native function shift.random_int(): number
	local state: buffer = (shift.state or shift.start(os.clock()))
	--warn(buffer.readu32(state, 1) * 5);

	local result: number = (bit32.lrotate(buffer.readu32(state, 1)*5, 7) * 9);
	local t: number = bit32.lshift(buffer.readu32(state, 1), 17);
	--warn("what am i doing wrong", result);

	buffer.writeu32(state, 2, bit32.bxor(buffer.readu32(state, 1), buffer.readu32(state, 2)));
	buffer.writeu32(state, 3, bit32.bxor(buffer.readu32(state, 3), buffer.readu32(state, 1)));
	buffer.writeu32(state, 1, bit32.bxor(buffer.readu32(state, 1), buffer.readu32(state, 2)));

	buffer.writeu32(state, 2, bit32.bxor(buffer.readu32(state, 2), t));
	buffer.writeu32(state, 3, bit32.lrotate(buffer.readu32(state, 3), 45));
	
	--[[if (switch_seed) then
		shift.newseed(os.clock()); -- meh
	end;]]
	return result;
end;

@native function shift.newseed(seed: number): ()
	shift.state = shift.start(seed) :: buffer;
	return;
end;
@native function shift.random(min: number, max: number): number
	return (min + shift.random_int() % max);
end;

local demo_options: {[string]: any} = {
	random_num = false;
	loop_num = 100;
	math_random = true;
};

print("Starting demo");
shift.newseed(os.clock());

--print("wtf", shift.state);

if (demo_options.random_num) then
	for i: number = 1, demo_options.loop_num do
		warn("random num", shift.random_int());
	end;
elseif (demo_options.math_random) then
	for i: number = 1, (demo_options.loop_num) do
		warn("math.random test", shift.random(1, 100));
	end;
end;
