LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY lfsr8 IS
	PORT (
		clk			: IN STD_LOGIC;		-- Clock input
		lfsr_out	: OUT INTEGER RANGE 0 to 255 := 1 );	-- Integer output for use in RNG applications
--		lfsr_out	: OUT STD_LOGIC_VECTOR(7 downto 0) );	-- Testing output; only uncomment one at a time, see below
END lfsr8;

ARCHITECTURE behavioral OF lfsr8 IS
	SIGNAL shift	: UNSIGNED(7 downto 0) := "00000001"; -- Variable for the LFSR output
	CONSTANT delay	: INTEGER := 833333; -- Delay in clock cycles for the register to finish operating. Value is 50000000/60
BEGIN
	PROCESS (clk)
	VARIABLE next_val	: STD_LOGIC;	-- Store the value to be shifted in
	VARIABLE count		: INTEGER := 0;	-- Number of clock cycles that have passed
	BEGIN
		IF RISING_EDGE(clk) THEN
			count := count + 1;
			IF (count >= delay) THEN
				count := 0;
				
				next_val := shift(0) XOR shift(2) XOR shift(3) XOR shift(4);	-- Galois LFSR algorithm
				shift <= shift_right(shift, 1);	-- Shift all values right
				shift(7) <= next_val;			-- Load in the calculated next value
				lfsr_out <= to_integer(shift);	-- Output
--				lfsr_out <= std_logic_vector(shift);	-- Testing output; only uncomment one at a time, see entity outputs
			END IF;
		END IF;
	END PROCESS;
END behavioral;