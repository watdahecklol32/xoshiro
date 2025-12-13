--!strict
--!native
--!optimize 2
local split: (num: number) -> number = @native function(num: number): number
	num += 0x7f4A7C15 :: number;
	num = bit32.bxor(num, bit32.rshift(num, 30)) :: number;
	
	num = num * 0x1CE4E5B9 :: number;
	num = bit32.bxor(num, bit32.rshift(num, 27)) :: number;
	
	num = bit32.bxor(num, bit32.rshift(num, 5), 31) :: number;
	return num;
end;

local generate_int: (prng_state: buffer) -> number =  @native function(prng_state: buffer): number
	local state0: number = buffer.readu32(prng_state, 0);
	local state1: number = buffer.readu32(prng_state, 1);
	
	local state2: number = buffer.readu32(prng_state, 2);
	local t: number = bit32.lshift(state0, 17);

	state1 = bit32.bxor(state0, state1) :: number;
	state2 = bit32.bxor(state2, state0) :: number;
	
	state0 = bit32.bxor(state0, state1) :: number;
	state1 = bit32.bxor(state1, t) :: number;
	
	state2 = bit32.lrotate(state2, 45) :: number;
	buffer.writeu32(prng_state, 0, state0);
	
	buffer.writeu32(prng_state, 1, state1);
	buffer.writeu32(prng_state, 2, state2);
	
	local result: number = (bit32.lrotate(state2*5, 7) * 9);
	return result;
end;
local random: (prng_state: buffer, min: number, max: number) -> number = @native function(prng_state: buffer, min: number, max: number): number
	local result: number = generate_int(prng_state);
	return bit32.band(min + result % max-min+1, 0xFFFFFFFF);
end;

local seed: (operand: number) -> buffer = @native function(operand: number): buffer
	local prng_state: buffer = buffer.create(12);
	buffer.writeu32(prng_state, 0, split(operand));
	
	buffer.writeu32(prng_state, 1, split(buffer.readu32(prng_state, 0)));
	buffer.writeu32(prng_state, 2, split(buffer.readu32(prng_state, 1)));
	
	return prng_state;
end

return table.freeze({
	generate_int = generate_int;
	random = random;
	seed = seed;
});
