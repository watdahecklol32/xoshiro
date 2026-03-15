--!strict
--!native
--!optimize 2
local random: (number, number, number, number, number) -> (number, number, number, number) = @native function(state0: number, state1: number, state2: number, min: number, max: number): (number, number, number, number)
    local t: number = bit32.lshift(state0, 17);
    state1 = bit32.bxor(state0, state1) :: number;
    state2 = bit32.bxor(state2, state0) :: number;
    state0 = bit32.bxor(state0, state1) :: number;
    state1 = bit32.bxor(state1, t) :: number;
    state2 = bit32.lrotate(state2, 45) :: number;
    return bit32.band(min+(bit32.lrotate(state2*5, 7)*9)%max-min+1,0xFFFFFFFF), state0, state1, state2;
end;
local set_seed: (number) -> (number, number, number) = @native function(num: number): (number, number, number)
    local state0: number;
    local state1: number;
    local state2: number;
    do
        state0 = num;
        num += 0x7f4A7C15 :: number;
        num = bit32.bxor(num, bit32.rshift(num, 30)) :: number;
        num = num * 0x1CE4E5B9 :: number;
        num = bit32.bxor(num, bit32.rshift(num, 27)) :: number;
        num = bit32.bxor(num, bit32.rshift(num, 5), 31) :: number;
    end;
    do
        state1 = state0;
        state0 += 0x7f4A7C15 :: number;
        state0 = bit32.bxor(state0, bit32.rshift(state0, 30)) :: number;
        state0 = state0 * 0x1CE4E5B9 :: number;
        state0 = bit32.bxor(state0, bit32.rshift(state0, 27)) :: number;
        state0 = bit32.bxor(state0, bit32.rshift(state0, 5), 31) :: number;
    end;
    do
        state2 = state1;
        state1 += 0x7f4A7C15 :: number;
        state1 = bit32.bxor(state1, bit32.rshift(state1, 30)) :: number;
        state1 = state1 * 0x1CE4E5B9 :: number;
        state1 = bit32.bxor(state1, bit32.rshift(state1, 27)) :: number;
        state1 = bit32.bxor(state1, bit32.rshift(state1, 5), 31) :: number;
    end; 
    return state0, state1, state2;
end;
local state0: number, state1: number, state2: number = set_seed(os.clock() % 0x1CE4E5B9);
