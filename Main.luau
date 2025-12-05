--!strict
--!native
--!optimize 2

local shift = {state = nil :: buffer?};
local number_limit: number = 0xFFFFFFFF;

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
	local result: number = (bit32.lrotate(buffer.readu32(state, 1)*5, 7) * 9);

	local t: number = bit32.lshift(buffer.readu32(state, 1), 17);
	buffer.writeu32(state, 2, bit32.bxor(buffer.readu32(state, 1), buffer.readu32(state, 2)));

	buffer.writeu32(state, 3, bit32.bxor(buffer.readu32(state, 3), buffer.readu32(state, 1)));
	buffer.writeu32(state, 1, bit32.bxor(buffer.readu32(state, 1), buffer.readu32(state, 2)));

	buffer.writeu32(state, 2, bit32.bxor(buffer.readu32(state, 2), t));
	buffer.writeu32(state, 3, bit32.lrotate(buffer.readu32(state, 3), 45));

	return result;
end;

@native function shift.newseed(seed: number): ()
	shift.state = shift.start(seed) :: buffer;
	return;
end;
@native function shift.random(min: number, max: number): number
	local range: number = (max - min + 1);
	if (range <= 0) then
		return min;
	end;
	
	local result: number = shift.random_int();
	result = (bit32.band(result, number_limit));
	
	
	return (min + (result % range));
end;

shift.newseed(os.clock());
