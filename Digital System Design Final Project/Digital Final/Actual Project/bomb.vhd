LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;

ENTITY bomb IS
	GENERIC (
		bottomCartRow	: INTEGER := 446;	-- Position of the bottom row of the third cart
		bombtoplen		: INTEGER := 3;		-- Length for drawing the bomb
		positions		: INTEGER := 570;	-- Positions of the rotary encoder
		frames			: INTEGER := 2		-- How many frames to count before resetting the frame counter
	);
	PORT (
		ROW			: IN INTEGER RANGE 1 to 480 := 1;			-- Use row/col to determine where in the frame we are
		COL			: IN INTEGER RANGE 1 to 640 := 1;
		ENABLE		: IN STD_LOGIC := '0';						-- Whether the bomb is active; 0 for no, 1 for yes
		BUCKET_COL	: IN INTEGER RANGE 0 to positions-1 := 0;	-- Column of where the bucket currently is; bucket width is 70
		LIVES		: IN INTEGER RANGE 0 TO 3 := 3;				-- How many buckets are active
		HALT		: IN STD_LOGIC := '0';						-- Stop everything, but don't clear yet

		DRAW_COLOR	: OUT INTEGER RANGE 0 to 2 := 0;			-- Active when DRAW_COLOR to the frame
		CAUGHT		: OUT STD_LOGIC := '0';						-- Bomb was caught in bucket
		MISSED		: OUT STD_LOGIC := '0'						-- Tell whether the bomb failed to get caught
	);
END bomb;

ARCHITECTURE bomb_arch OF bomb IS
BEGIN

	game_logic : PROCESS (ENABLE, ROW, COL, HALT, BUCKET_COL, LIVES)
		VARIABLE frame_count 	: INTEGER RANGE 0 to frames+10 := 0;
		VARIABLE b_col			: INTEGER RANGE 1 to 640 := 1;
		VARIABLE b_row			: INTEGER RANGE 1 to 480 := 99;
		VARIABLE b_caught		: STD_LOGIC := '0';
		VARIABLE b_missed		: STD_LOGIC := '0';
	BEGIN

		IF RISING_EDGE(ENABLE) THEN
			b_col := COL;	-- Clock the bomb's horizontal position when beginning DRAW_COLOR
		END IF;

		IF (ENABLE = '1') THEN 	-- Bomb is actively falling
			-- Increment the frame counter; do not increment on HALT
			IF (HALT = '0') THEN
				IF (ROW = 1 AND COL = 1) THEN
					frame_count := frame_count + 1;
				END IF;

				IF(frame_count > frames) THEN	-- Divide the clock in half for every count (slower movement)
					frame_count := 0;			-- Reset counter
					b_row := b_row + 1; 		-- Bomb falls +x pixels every count
				END IF;
			ELSIF (HALT = '1') THEN -- Make sure to HALT for 1 frame before disabling
				b_missed := '0';
				b_caught := '0';
			END IF;

			-- For DRAW_COLOR = 2, All R/G/B = 0; For DRAW_COLOR = 1, All R/G/B = 12
			if(ROW = b_row and (COL >= b_col and COL <= b_col+bombtoplen)) then
				DRAW_COLOR <= 2;
			elsif(ROW = b_row+1 and (COL >= b_col+bombtoplen and COL <= b_col+bombtoplen*2)) then
				DRAW_COLOR <= 2;
			elsif((ROW >= b_row+2 and ROW <= b_row+4) and (COL >= b_col+bombtoplen*2 and COL <= b_col+bombtoplen*3)) then
				DRAW_COLOR <= 2;
			elsif(ROW = b_row+5 and (COL >= b_col+bombtoplen and COL <= b_col+bombtoplen*2)) then
				DRAW_COLOR <= 1;
			elsif(ROW = b_row+6 and (COL >= b_col and COL <= b_col+bombtoplen*3)) then
				DRAW_COLOR <= 1;
			elsif((ROW >= b_row+7 and ROW <= b_row+8) and (COL >= b_col and COL <= b_col+bombtoplen*3)) then
				DRAW_COLOR <= 2;
			elsif((ROW >= b_row+9 and ROW <= b_row+11) and (COL >= b_col-2 and COL <= 2+b_col+bombtoplen*3)) then
				DRAW_COLOR <= 2;
			elsif((ROW >= b_row+12 and ROW <= b_row+13) and (COL >= b_col and COL <= b_col+bombtoplen*3)) then
				DRAW_COLOR <= 2;
			elsif(ROW = b_row+14 and (COL >= b_col+bombtoplen and COL <= b_col+bombtoplen*2)) then
				DRAW_COLOR <= 1;
			else
				DRAW_COLOR <= 0;
			end if;

			-- Something about this is an abomination that must be purged
			IF (b_col >= BUCKET_COL AND b_col < (BUCKET_COL + 70)) THEN
				IF (LIVES = 3 AND (b_row >= (bottomCartRow - 75) AND b_row <= bottomCartRow)) THEN
					b_caught := '1';
				ELSIF (LIVES = 2 AND (b_row >= (bottomCartRow - 75) AND b_row <= (bottomCartRow - 46))) THEN
					b_caught := '1';
				ELSIF (LIVES = 1 AND (b_row >= (bottomCartRow - 75) AND b_row <= (bottomCartRow - 17))) THEN
					b_caught := '1';
				ELSE
					b_caught := '0';
				END IF;
			END IF;

			IF (b_row >= bottomCartRow) THEN
				b_missed := '1';
			ELSE
				b_missed := '0';
			END IF;

		END IF;

		MISSED <= b_missed;
		CAUGHT <= b_caught;
	END PROCESS game_logic;
END bomb_arch;