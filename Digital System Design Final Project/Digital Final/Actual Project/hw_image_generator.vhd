--------------------------------------------------------------------------------
--
--   FileName:         hw_image_generator.vhd
--   Dependencies:     none
--   Design Software:  Quartus II 64-bit Version 12.1 Build 177 SJ Full Version
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 05/10/2013 Scott Larson
--     Initial Public Release
--    
--------------------------------------------------------------------------------
--
-- Altered 10/13/19 - Tyler McCormick 
-- Test pattern is now 8 equally spaced 
-- different color vertical bars, from black (left) to white (right)

-- Altered 11/25/2020 - Jacob Johnson and Jacob Wheeling


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY hw_image_generator IS
  GENERIC(
	
	topBar : INTEGER := 99;
	playField : INTEGER := 450;
	bottomBar : INTEGER := 480;
	positions : INTEGER := 570;
	row_top : INTEGER := 0;
	row_grey_bar : INTEGER := 90;
	row_bar_green : INTEGER := 92;
	row_green_black : INTEGER := 433;
	row_bottom : INTEGER := 480;
	
	letter_fromtop_offset: INTEGER := 5;
	letter_fromleft_offset: integer := 300;
	l_space_between : integer := 10

	);  
  PORT(
    disp_ena :  IN   STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
    row      :  IN   INTEGER;    --row pixel coordinate
    column   :  IN   INTEGER;    --column pixel coordinate
    red      :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
    green    :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
    blue     :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'); --blue magnitude output to DAC
	pos_in	 :  IN   INTEGER;
	pll_OUT_to_vga_controller_IN : IN STD_LOGIC;
	mainClock:	IN	 STD_LOGIC;
	togglePause	: IN STD_LOGIC;
	demoMode	: IN STD_LOGIC);
	
END hw_image_generator;

ARCHITECTURE behavior OF hw_image_generator IS
component tdigits is
	port(		
		numselect: in std_logic_vector (3 downto 0);
		myrow: in std_logic_vector (3 downto 0);
		colarray: out std_logic_vector (7 downto 0)
	);
	end component tdigits;
	
	
	
	COMPONENT lfsr8 IS
		PORT (
			clk			: IN STD_LOGIC;		-- Clock input
			lfsr_out	: OUT INTEGER RANGE 0 to 255 := 1 );	-- Integer output for use in RNG applications
	END COMPONENT;
	
	--All signals for the bombs
	SIGNAL cartPOS : INTEGER;
	SIGNAL bomb1 : INTEGER := 700;
	SIGNAL bomb1row : INTEGER := topBar-8;
	SIGNAL bomb2 : INTEGER := 700;
	SIGNAL bomb2row : INTEGER := topBar-8;
	SIGNAL bomb3 : INTEGER := 700;
	SIGNAL bomb3row : INTEGER := topBar-8;
	SIGNAL bomb4 : INTEGER := 700;
	SIGNAL bomb4row : INTEGER := topBar-8;
	SIGNAL bomb5 : INTEGER := 700;
	SIGNAL bomb5row : INTEGER := topBar-8;
	SIGNAL bomb6 : INTEGER := 700;
	SIGNAL bomb6row : INTEGER := topBar-8;
	SIGNAL bomb7 : INTEGER := 700;
	SIGNAL bomb7row : INTEGER := topBar-8;
	SIGNAL bomb8 : INTEGER := 700;
	SIGNAL bomb8row : INTEGER := topBar-8;
	SIGNAL bomb9 : INTEGER := 700;
	SIGNAL bomb9row : INTEGER := topBar-8;
	SIGNAL bomb10 : INTEGER := 700;
	SIGNAL bomb10row : INTEGER := topBar-8;
	
	signal bomb1RowCounter : integer := 0;
	signal bomb1ColumnConter : integer := 0;
	signal bomb2RowCounter : integer := 0;
	signal bomb2ColumnConter : integer := 0;
	signal bomb3RowCounter : integer := 0;
	signal bomb3ColumnConter : integer := 0;
	signal bomb4RowCounter : integer := 0;
	signal bomb4ColumnConter : integer := 0;
	signal bomb5RowCounter : integer := 0;
	signal bomb5ColumnConter : integer := 0;
	signal bomb6RowCounter : integer := 0;
	signal bomb6ColumnConter : integer := 0;
	signal bomb7RowCounter : integer := 0;
	signal bomb7ColumnConter : integer := 0;
	signal bomb8RowCounter : integer := 0;
	signal bomb8ColumnConter : integer := 0;
	signal bomb9RowCounter : integer := 0;
	signal bomb9ColumnConter : integer := 0;
	signal bomb10RowCounter : integer := 0;
	signal bomb10ColumnConter : integer := 0;

	SIGNAL topOfHat			: integer := 320;

	signal direction		: integer := 0;
	signal Lives			: integer := 3;
	
	--Signals for the carts
	signal bottomCartRow : INTEGER := 446;
	signal middleCartRow : INTEGER := 417;
	signal topCartRow	   : INTEGER := 388;
	
	--Signal for a clock divider
	signal clockSlow : STD_LOGIC;
	
	signal randNum : STD_LOGIC;
	SIGNAL shift	: UNSIGNED(7 downto 0) := "00000001";
	
	
	signal numBombs : integer := 0;
	
	signal score : integer := 0;
	signal numpos0: std_logic_vector(3 downto 0) := "0000";
	signal numpos1: std_logic_vector(3 downto 0) := "0000";
	signal numpos2: std_logic_vector(3 downto 0) := "0000";
	signal numpos3: std_logic_vector(3 downto 0) := "0000";
	signal rowstd,rowstd1: std_logic_vector(3 downto 0) := "0000";
   signal colarray0,colarray1,colarray2,colarray3: std_logic_vector(7 downto 0) := "00000000";
	signal colarray01,colarray11,colarray21,colarray31: std_logic_vector(7 downto 0) := "00000000";

	signal truefalse: integer := 0;
	signal inumpos0,inumpos1,inumpos2,inumpos3 : integer := 0;
	signal buzzerpin,buzzerclock,slowclock: std_logic := '0';
	
	signal Factor : integer;
	signal bombFallSpeed :integer;
	signal manMoveSpeed : integer;
	signal Level : integer;
	signal bombNums : integer := 0;

	signal slowclocke : STD_LOGIC;
	signal pause : STD_LOGIC := '0';
	signal reset : STD_LOGIC := '0';

	BEGIN
	
	u00: tdigits port map(numpos0,rowstd, colarray0);
	u10: tdigits port map(numpos1,rowstd, colarray1);
	u20: tdigits port map(numpos2,rowstd, colarray2);
	u30: tdigits port map(numpos3,rowstd, colarray3);
	
	slowerclock: process(pll_OUT_to_vga_controller_IN)

	variable counter: integer := 0;
	
	begin
		if(pll_OUT_to_vga_controller_IN = '1' and pll_OUT_to_vga_controller_IN'event) then
			counter := counter + 1;
			if (counter > 100000) then
			if (slowclocke = '1') then
				slowclocke <= '0';
			else
				slowclocke <= '1';
			end if;
			counter := 0 ;
			end if;
		end if;
	
	end process;
	
	counter: process(slowclocke)
	variable counter: integer := 0;
	variable div1, div2, div3 : integer := 0;
	begin
			
			-- idea for making score have animation, make a counter count down the amount earned until it is 0. the counter will be set to counter = counter + whatever score to allow for fast scorers to not loose out on score
			
			--Doing the score here breaks the cart movement
			div1 := pos_in mod 1000;
			div2 := div1 mod 100;
			div3 := div2 mod 10;
			
			
			numpos0 <= std_logic_vector(to_unsigned((pos_in / 1000),4)); 
			numpos1 <= std_logic_vector(to_unsigned((div1 / 100 ),4));
			numpos2 <= std_logic_vector(to_unsigned((div2 / 10),4));
			numpos3 <= std_logic_vector(to_unsigned((div3),4));
		
	end process;
	
	

--BEGIN
	

	
	PROCESS(disp_ena, row, column,colarray0,colarray1,colarray2,colarray3,truefalse)
	
	variable colarrayval0, colarrayval1, colarrayval2, colarrayval3 : std_logic;
	variable colarrayval01, colarrayval11, colarrayval21, colarrayval31 : std_logic;
	
	VARIABLE col_val, row_val, redVal, greenVal, blueVal : INTEGER ;
	VARIABLE manStartHeight : INTEGER := 31;

	--Variables to help draw theman
	VARIABLE topOfHatLength : INTEGER := 8;
	VARIABLE fatHat : INTEGER := topOfHat-4;
	VARIABLE fatHatLength : INTEGER := 16;
	VARIABLE mask : INTEGER := fatHat-4;
	VARIABLE maskLength : INTEGER := 24;
	VARIABLE eyeHole : INTEGER := mask + 6;
	VARIABLE eyeHoleLength: INTEGER := 4;
	VARIABLE nose : INTEGER := topOfHat+2;
	VARIABLE noseLength : INTEGER := 4;

	--Creates the bombs
	--If value = 700, bomb is not visable
	VARIABLE bombtoplen : INTEGER := 3;

	--Draws the carts
	VARIABLE cartLen : INTEGER := 70;

--Creating TNTech ECE 
	-- 3 excess bits on top
	-- 1 excess bit on bottom
	VARIABLE startWord : INTEGER := 190;
	VARIABLE rowHeight : INTEGER := 9; -- will have 3 rows
	VARIABLE colLength : INTEGER := 9; -- will have 3 col
	VARIABLE row_A_top : INTEGER := playField+2;
	VARIABLE row_A_bot : INTEGER := row_A_top+8;  
	VARIABLE row_B_top : INTEGER := row_A_bot+1;
	VARIABLE row_B_bot : INTEGER := row_B_top+8;  
	VARIABLE row_C_top : INTEGER := row_B_bot+1;
	VARIABLE row_C_bot : INTEGER := row_C_top+8;

	-- Letter Tops
	VARIABLE T1topStart : INTEGER := startWord;
	VARIABLE T1topEnd : INTEGER := T1topStart + 3*colLength;
	VARIABLE NLtopStart : INTEGER := T1topEnd+3; -- N may be a bit complicated
	VARIABLE NLtopEnd : INTEGER := NLtopStart+colLength;
	VARIABLE NRtopStart: INTEGER := NLtopEnd+colLength;
	VARIABLE NRtopEnd : INTEGER := NRtopStart+colLength;
	VARIABLE T2topStart : INTEGER := NRtopEnd+3;
	VARIABLE T2topEnd : INTEGER := T2topStart + 3*colLength;
	VARIABLE E1topStart : INTEGER := T2topEnd+3;
	VARIABLE E1topEnd : INTEGER := E1topStart + 3*colLength;
	VARIABLE C1topStart : INTEGER := E1topEnd+3;
	VARIABLE C1topEnd : INTEGER := C1topStart + 3*colLength;
	VARIABLE HLtopStart : INTEGER := C1topEnd+3;
	VARIABLE HLtopEnd : INTEGER := HLtopStart + colLength;
	VARIABLE HRtopStart : INTEGER := HLtopEnd+colLength;
	VARIABLE HRtopEnd : INTEGER := HRtopStart+colLength;
	VARIABLE E2topStart : INTEGER := HRtopEnd+15;
	VARIABLE E2topEnd : INTEGER := E2topStart+3*colLength;
	VARIABLE C2topStart : INTEGER := E2topEnd+3;
	VARIABLE C2topEnd : INTEGER := C2topStart+3*colLength;
	VARIABLE E3topStart : INTEGER := C2topEnd+3;
	VARIABLE E3topEnd : INTEGER := E3topStart+3*colLength;

	-- Letter Mids
	VARIABLE T1midStart : INTEGER := startWord+colLength;
	VARIABLE T1midEnd: INTEGER := T1midStart+colLength;
	VARIABLE NLmidStart: INTEGER := T1midEnd+3+colLength;
	VARIABLE NLmidEnd: INTEGER := NLmidStart+colLength;
	VARIABLE NRmidStart: INTEGER := NLmidEnd+colLength;
	VARIABLE NRmidEnd: INTEGER := NRmidStart+colLength;
	-- N's midsection will be handled later
	VARIABLE T2midStart : INTEGER := NRmidEnd+3+colLength;
	VARIABLE T2midEnd: INTEGER := T2midStart+colLength;
	VARIABLE E1midStart: INTEGER := T2midEnd+3+colLength;
	VARIABLE E1midEnd: INTEGER := E1midStart+2*colLength;
	VARIABLE C1midStart: INTEGER := E1midEnd+3+colLength;
	VARIABLE C1midEnd: INTEGER := C1midStart+colLength; 
	VARIABLE HmidStart: INTEGER := C1midEnd+3+2*colLength;
	VARIABLE HmidEnd: INTEGER := HmidStart+3*colLength;
	VARIABLE E2midStart: INTEGER := HmidEnd+15;
	VARIABLE E2midEnd: INTEGER := E2midStart+2*colLength;
	VARIABLE C2midStart: INTEGER := E2midEnd+3+colLength;
	VARIABLE C2midEnd: INTEGER := C2midStart+colLength;
	VARIABLE E3midStart: INTEGER := C2midEnd+3+2*colLength;
	VARIABLE E3midEnd: INTEGER := E3midStart+2*colLength;
	
	
	BEGIN	
	
	--For drawing the top of hat
	if((row = manStartHeight+1 or row = manStartHeight+2) and column >= fatHat + direction and column <= fatHat + fatHatLength + direction) then
		redVal := 9;
		greenVal := 4;
		blueVal := 1;
	--For the different shade of the wide part of hat
	elsif(row = manStartHeight+3 and column >= fatHat + direction and column <= fatHat + fatHatLength + direction) then
		redVal := 3;
		greenVal := 3;
		blueVal := 3;
	--For drawing the mask
	elsif((row = manStartHeight+4 or row = manStartHeight+5 or row = manStartHeight+6) and column >= mask + direction and column <= mask + maskLength + direction and not (column >= eyeHole + direction and column <= eyeHole + eyeHoleLength + direction) and not (column >= eyeHole + 9 + direction and column <= eyeHole + eyeHoleLength + 9 + direction)) then
		redVal := 3;
		greenVal := 3;
		blueVal := 3;
	elsif(row = manStartHeight+7 and column >= mask + direction and column <= mask + maskLength + direction) then
		redVal := 3;
		greenVal := 3;
		blueVal := 3;
	--Draws the top of the man with skin color
	elsif(row = manStartHeight+8 and column >= mask + direction and column <= mask + maskLength + direction and not (column >= nose + direction + direction + direction + direction and column <= nose + noseLength + direction)) then
		redVal := 14;
		greenVal := 11;
		blueVal := 11;
	--Draws face with nose hole
	elsif((row >= manStartHeight + 9 and row <= manStartHeight+11) and column >= fatHat + direction and column <= fatHat + fatHatLength + direction and not (column >= nose + direction and column <= nose + noseLength + direction)) then
		redVal := 14;
		greenVal := 11;
		blueVal := 11;
	--Draws lines between nose and mouth
	elsif((row >= manStartHeight + 12 and row <= manStartHeight+15) and column >= fatHat + direction and column <= fatHat + fatHatLength + direction) then
		redVal := 14;
		greenVal := 11;
		blueVal := 11;
	--Draws top of mouth
	elsif((row >= manStartHeight+16 and row <= manStartHeight+17) and column >= fatHat + direction and column <= fatHat + fatHatLength + direction and not (column >= nose + direction and column <= nose + noseLength + direction)) then
		redVal := 14;
		greenVal := 11;
		blueVal := 11;
	elsif((row >= manStartHeight+18 and row <= manStartHeight+19) and column >= fatHat + direction and column <= fatHat + fatHatLength + direction and not (column >= eyeHole + direction and column <= eyeHole + eyeHoleLength + direction) and not (column >= eyeHole + 8 + direction and column <= eyeHole + eyeHoleLength + 9 + direction)) then
		redVal := 14;
		greenVal := 11;
		blueVal := 11;
	elsif((row >= manStartHeight+20 and row <= manStartHeight+23) and column >= topOfHat + direction and column <= topOfHat + topOfHatLength + direction) then
		redVal := 14;
		greenVal := 11;
		blueVal := 11;
	
	--Draws the striped shirt
	elsif((row >= manStartHeight+24 and row <= manStartHeight+25) and column >= topOfHat + direction and column <= topOfHat + topOfHatLength + direction) then
		redVal := 8;
		greenVal := 8;
		blueVal := 8;
	elsif((row >= manStartHeight+26 and row <= manStartHeight+27) and column >= fatHat + direction and column <= fatHat + fatHatLength + direction) then
		redVal := 9;
		greenVal := 9;
		blueVal := 9;
	elsif((row >= manStartHeight+28 and row <= manStartHeight+29) and column >= mask + direction and column <= mask + maskLength + direction) then
		redVal := 8;
		greenVal := 8;
		blueVal := 8;
	elsif((row >= manStartHeight+30 and row <= manStartHeight+31) and column >= mask + direction and column <= mask + maskLength + direction) then
		redVal := 9;
		greenVal := 9;
		blueVal := 9;
	elsif((row >= manStartHeight+32 and row <= manStartHeight+33) and column >= mask + direction and column <= mask + maskLength + direction) then
		redVal := 8;
		greenVal := 8;
		blueVal := 8;
	elsif((row >= manStartHeight+34 and row <= manStartHeight+35) and column >= mask + direction and column <= mask + maskLength + direction) then
		redVal := 9;
		greenVal := 9;
		blueVal := 9;
	elsif((row >= manStartHeight+36 and row <= manStartHeight+37) and column >= mask + direction and column <= mask + maskLength + direction) then
		redVal := 8;
		greenVal := 8;
		blueVal := 8;
	elsif((row >= manStartHeight+38 and row <= manStartHeight+39) and column >= mask + direction and column <= mask + maskLength + direction) then
		redVal := 9;
		greenVal := 9;
		blueVal := 9;
	elsif((row >= manStartHeight+40 and row <= manStartHeight+41) and column >= mask + direction and column <= mask + maskLength + direction) then
		redVal := 8;
		greenVal := 8;
		blueVal := 8;
	elsif((row >= manStartHeight+42 and row <= manStartHeight+43) and column >= mask + direction and column <= mask + maskLength + direction) then
		redVal := 9;
		greenVal := 9;
		blueVal := 9;
	elsif((row >= manStartHeight+44 and row <= manStartHeight+45) and column >= mask + direction and column <= mask + maskLength + direction) then
		redVal := 8;
		greenVal := 8;
		blueVal := 8;
	elsif((row >= manStartHeight+46 and row <= manStartHeight+47) and column >= mask + direction and column <= mask + maskLength + direction) then
		redVal := 9;
		greenVal := 9;
		blueVal := 9;
	elsif((row >= manStartHeight+48 and row <= manStartHeight+49) and column >= mask + direction and column <= mask + maskLength + direction) then
		redVal := 8;
		greenVal := 8;
		blueVal := 8;
	elsif((row >= manStartHeight+50 and row <= manStartHeight+51) and column >= mask + direction and column <= mask + maskLength + direction) then
		redVal := 9;
		greenVal := 9;
		blueVal := 9;
	elsif((row >= manStartHeight+52 and row <= manStartHeight+53) and column >= mask + direction and column <= mask + maskLength + direction) then
		redVal := 8;
		greenVal := 8;
		blueVal := 8;
	elsif((row >= manStartHeight+54 and row <= manStartHeight+55) and column >= mask + direction and column <= mask + maskLength + direction) then
		redVal := 9;
		greenVal := 9;
		blueVal := 9;
	elsif((row >= manStartHeight+56 and row <= manStartHeight+57) and column >= mask + direction and column <= mask + maskLength + direction) then
		redVal := 8;
		greenVal := 8;
		blueVal := 8;
	elsif((row >= manStartHeight+58 and row <= manStartHeight+59) and column >= mask + direction and column <= mask + maskLength + direction) then
		redVal := 9;
		greenVal := 9;
		blueVal := 9;
	elsif((row >= manStartHeight+60 and row <= manStartHeight+61) and column >= mask + direction and column <= mask + maskLength + direction) then
		redVal := 8;
		greenVal := 8;
		blueVal := 8;
	elsif((row >= manStartHeight+62 and row <= manStartHeight+63) and column >= mask + direction and column <= mask + maskLength + direction) then
		redVal := 9;
		greenVal := 9;
		blueVal := 9;
	elsif((row >= manStartHeight+64 and row <= manStartHeight+65) and column >= mask + direction and column <= mask + maskLength + direction) then
		redVal := 8;
		greenVal := 8;
		blueVal := 8;
	elsif((row >= manStartHeight+66 and row <= manStartHeight+69) and column >= mask + direction and column <= mask + maskLength + direction and not (column >= mask+6 + direction and column <= mask + maskLength - 6 + direction)) then
		redVal := 14;
		greenVal := 11;
		blueVal := 11;
	elsif((row >= manStartHeight+70 and row <= manStartHeight+71) and column >= mask+6 + direction and column <= mask + maskLength-6 + direction and not (column >= mask+12 + direction and column <= mask + maskLength - 12 + direction)) then
		redVal := 14;
		greenVal := 11;
		blueVal := 11;
		
	--Draws bomb1
	elsif(row = bomb1row + bomb1RowCounter and (column >= bomb1+bomb1ColumnConter and column <= bomb1+bombtoplen+bomb1ColumnConter)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb1row+1 + bomb1RowCounter and (column >= bomb1+bombtoplen+bomb1ColumnConter and column <= bomb1+bomb1ColumnConter+bombtoplen*2)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb1row+2 + bomb1RowCounter and row <= bomb1row+4+ bomb1RowCounter) and (column >= bomb1+bomb1ColumnConter+bombtoplen*2 and column <= bomb1+bomb1ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb1row+5+ bomb1RowCounter and (column >= bomb1+bomb1ColumnConter+bombtoplen and column <= bomb1+bomb1ColumnConter+bombtoplen*2)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;
	elsif(row = bomb1row+6+ bomb1RowCounter and (column >= bomb1+bomb1ColumnConter and column <= bomb1+bomb1ColumnConter+bombtoplen*3)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;
	elsif((row >= bomb1row+7+ bomb1RowCounter and row <= bomb1row+8+ bomb1RowCounter) and (column >= bomb1+bomb1ColumnConter and column <= bomb1+bomb1ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb1row+9+ bomb1RowCounter and row <= bomb1row+11+ bomb1RowCounter) and (column >= bomb1-2+bomb1ColumnConter and column <= 2+bomb1+bomb1ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb1row+12+ bomb1RowCounter and row <= bomb1row+13+ bomb1RowCounter) and (column >= bomb1+bomb1ColumnConter and column <= bomb1+bomb1ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb1row+14+ bomb1RowCounter and (column >= bomb1+bombtoplen+bomb1ColumnConter and column <= bomb1+bomb1ColumnConter+bombtoplen*2)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;
		
	--Draws bomb2
	elsif(row = bomb2row + bomb2RowCounter and (column >= bomb2+bomb2ColumnConter and column <= bomb2+bombtoplen+bomb2ColumnConter)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb2row+1 + bomb2RowCounter and (column >= bomb2+bombtoplen+bomb2ColumnConter and column <= bomb2+bomb2ColumnConter+bombtoplen*2)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb2row+2 + bomb2RowCounter and row <= bomb2row+4+ bomb2RowCounter) and (column >= bomb2+bomb2ColumnConter+bombtoplen*2 and column <= bomb2+bomb2ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb2row+5+ bomb2RowCounter and (column >= bomb2+bomb2ColumnConter+bombtoplen and column <= bomb2+bomb2ColumnConter+bombtoplen*2)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;
	elsif(row = bomb2row+6+ bomb2RowCounter and (column >= bomb2+bomb2ColumnConter and column <= bomb2+bomb2ColumnConter+bombtoplen*3)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;
	elsif((row >= bomb2row+7+ bomb2RowCounter and row <= bomb2row+8+ bomb2RowCounter) and (column >= bomb2+bomb2ColumnConter and column <= bomb2+bomb2ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb2row+9+ bomb2RowCounter and row <= bomb2row+11+ bomb2RowCounter) and (column >= bomb2-2+bomb2ColumnConter and column <= 2+bomb2+bomb2ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb2row+12+ bomb2RowCounter and row <= bomb2row+13+ bomb2RowCounter) and (column >= bomb2+bomb2ColumnConter and column <= bomb2+bomb2ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb2row+14+ bomb2RowCounter and (column >= bomb2+bombtoplen+bomb2ColumnConter and column <= bomb2+bomb2ColumnConter+bombtoplen*2)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;

	--Draws bomb3
	elsif(row = bomb3row + bomb3RowCounter and (column >= bomb3+bomb3ColumnConter and column <= bomb3+bombtoplen+bomb3ColumnConter)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb3row+1 + bomb3RowCounter and (column >= bomb3+bombtoplen+bomb3ColumnConter and column <= bomb3+bomb3ColumnConter+bombtoplen*2)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb3row+2 + bomb3RowCounter and row <= bomb3row+4+ bomb3RowCounter) and (column >= bomb3+bomb3ColumnConter+bombtoplen*2 and column <= bomb3+bomb3ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb3row+5+ bomb3RowCounter and (column >= bomb3+bomb3ColumnConter+bombtoplen and column <= bomb3+bomb3ColumnConter+bombtoplen*2)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;
	elsif(row = bomb3row+6+ bomb3RowCounter and (column >= bomb3+bomb3ColumnConter and column <= bomb3+bomb3ColumnConter+bombtoplen*3)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;
	elsif((row >= bomb3row+7+ bomb3RowCounter and row <= bomb3row+8+ bomb3RowCounter) and (column >= bomb3+bomb3ColumnConter and column <= bomb3+bomb3ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb3row+9+ bomb3RowCounter and row <= bomb3row+11+ bomb3RowCounter) and (column >= bomb3-2+bomb3ColumnConter and column <= 2+bomb3+bomb3ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb3row+12+ bomb3RowCounter and row <= bomb3row+13+ bomb3RowCounter) and (column >= bomb3+bomb3ColumnConter and column <= bomb3+bomb3ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb3row+14+ bomb3RowCounter and (column >= bomb3+bombtoplen+bomb3ColumnConter and column <= bomb3+bomb3ColumnConter+bombtoplen*2)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;

	--Draws bomb4
	elsif(row = bomb4row + bomb4RowCounter and (column >= bomb4+bomb4ColumnConter and column <= bomb4+bombtoplen+bomb4ColumnConter)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb4row+1 + bomb4RowCounter and (column >= bomb4+bombtoplen+bomb4ColumnConter and column <= bomb4+bomb4ColumnConter+bombtoplen*2)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb4row+2 + bomb4RowCounter and row <= bomb4row+4+ bomb4RowCounter) and (column >= bomb4+bomb4ColumnConter+bombtoplen*2 and column <= bomb4+bomb4ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb4row+5+ bomb4RowCounter and (column >= bomb4+bomb4ColumnConter+bombtoplen and column <= bomb4+bomb4ColumnConter+bombtoplen*2)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;
	elsif(row = bomb4row+6+ bomb4RowCounter and (column >= bomb4+bomb4ColumnConter and column <= bomb4+bomb4ColumnConter+bombtoplen*3)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;
	elsif((row >= bomb4row+7+ bomb4RowCounter and row <= bomb4row+8+ bomb4RowCounter) and (column >= bomb4+bomb4ColumnConter and column <= bomb4+bomb4ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb4row+9+ bomb4RowCounter and row <= bomb4row+11+ bomb4RowCounter) and (column >= bomb4-2+bomb4ColumnConter and column <= 2+bomb4+bomb4ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb4row+12+ bomb4RowCounter and row <= bomb4row+13+ bomb4RowCounter) and (column >= bomb4+bomb4ColumnConter and column <= bomb4+bomb4ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb4row+14+ bomb4RowCounter and (column >= bomb4+bombtoplen+bomb4ColumnConter and column <= bomb4+bomb4ColumnConter+bombtoplen*2)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;

	--Draws bomb5
	elsif(row = bomb5row + bomb5RowCounter and (column >= bomb5+bomb5ColumnConter and column <= bomb5+bombtoplen+bomb5ColumnConter)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb5row+1 + bomb5RowCounter and (column >= bomb5+bombtoplen+bomb5ColumnConter and column <= bomb5+bomb5ColumnConter+bombtoplen*2)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb5row+2 + bomb5RowCounter and row <= bomb5row+4+ bomb5RowCounter) and (column >= bomb5+bomb5ColumnConter+bombtoplen*2 and column <= bomb5+bomb5ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb5row+5+ bomb5RowCounter and (column >= bomb5+bomb5ColumnConter+bombtoplen and column <= bomb5+bomb5ColumnConter+bombtoplen*2)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;
	elsif(row = bomb5row+6+ bomb5RowCounter and (column >= bomb5+bomb5ColumnConter and column <= bomb5+bomb5ColumnConter+bombtoplen*3)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;
	elsif((row >= bomb5row+7+ bomb5RowCounter and row <= bomb5row+8+ bomb5RowCounter) and (column >= bomb5+bomb5ColumnConter and column <= bomb5+bomb5ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb5row+9+ bomb5RowCounter and row <= bomb5row+11+ bomb5RowCounter) and (column >= bomb5-2+bomb5ColumnConter and column <= 2+bomb5+bomb5ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb5row+12+ bomb5RowCounter and row <= bomb5row+13+ bomb5RowCounter) and (column >= bomb5+bomb5ColumnConter and column <= bomb5+bomb5ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb5row+14+ bomb5RowCounter and (column >= bomb5+bombtoplen+bomb5ColumnConter and column <= bomb5+bomb5ColumnConter+bombtoplen*2)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;

	--Draws bomb6
	elsif(row = bomb6row + bomb6RowCounter and (column >= bomb6+bomb6ColumnConter and column <= bomb6+bombtoplen+bomb6ColumnConter)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb6row+1 + bomb6RowCounter and (column >= bomb6+bombtoplen+bomb6ColumnConter and column <= bomb6+bomb6ColumnConter+bombtoplen*2)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb6row+2 + bomb6RowCounter and row <= bomb6row+4+ bomb6RowCounter) and (column >= bomb6+bomb6ColumnConter+bombtoplen*2 and column <= bomb6+bomb6ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb6row+5+ bomb6RowCounter and (column >= bomb6+bomb6ColumnConter+bombtoplen and column <= bomb6+bomb6ColumnConter+bombtoplen*2)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;
	elsif(row = bomb6row+6+ bomb6RowCounter and (column >= bomb6+bomb6ColumnConter and column <= bomb6+bomb6ColumnConter+bombtoplen*3)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;
	elsif((row >= bomb6row+7+ bomb6RowCounter and row <= bomb6row+8+ bomb6RowCounter) and (column >= bomb6+bomb6ColumnConter and column <= bomb6+bomb6ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb6row+9+ bomb6RowCounter and row <= bomb6row+11+ bomb6RowCounter) and (column >= bomb6-2+bomb6ColumnConter and column <= 2+bomb6+bomb6ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb6row+12+ bomb6RowCounter and row <= bomb6row+13+ bomb6RowCounter) and (column >= bomb6+bomb6ColumnConter and column <= bomb6+bomb6ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb6row+14+ bomb6RowCounter and (column >= bomb6+bombtoplen+bomb6ColumnConter and column <= bomb6+bomb6ColumnConter+bombtoplen*2)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;

	--Draws bomb7
	elsif(row = bomb7row + bomb7RowCounter and (column >= bomb7+bomb7ColumnConter and column <= bomb7+bombtoplen+bomb7ColumnConter)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb7row+1 + bomb7RowCounter and (column >= bomb7+bombtoplen+bomb7ColumnConter and column <= bomb7+bomb7ColumnConter+bombtoplen*2)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb7row+2 + bomb7RowCounter and row <= bomb7row+4+ bomb7RowCounter) and (column >= bomb7+bomb7ColumnConter+bombtoplen*2 and column <= bomb7+bomb7ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb7row+5+ bomb7RowCounter and (column >= bomb7+bomb7ColumnConter+bombtoplen and column <= bomb7+bomb7ColumnConter+bombtoplen*2)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;
	elsif(row = bomb7row+6+ bomb7RowCounter and (column >= bomb7+bomb7ColumnConter and column <= bomb7+bomb7ColumnConter+bombtoplen*3)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;
	elsif((row >= bomb7row+7+ bomb7RowCounter and row <= bomb7row+8+ bomb7RowCounter) and (column >= bomb7+bomb7ColumnConter and column <= bomb7+bomb7ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb7row+9+ bomb7RowCounter and row <= bomb7row+11+ bomb7RowCounter) and (column >= bomb7-2+bomb7ColumnConter and column <= 2+bomb7+bomb7ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb7row+12+ bomb7RowCounter and row <= bomb7row+13+ bomb7RowCounter) and (column >= bomb7+bomb7ColumnConter and column <= bomb7+bomb7ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb7row+14+ bomb7RowCounter and (column >= bomb7+bombtoplen+bomb7ColumnConter and column <= bomb7+bomb7ColumnConter+bombtoplen*2)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;

	--Draws bomb8
	elsif(row = bomb8row + bomb8RowCounter and (column >= bomb8+bomb8ColumnConter and column <= bomb8+bombtoplen+bomb8ColumnConter)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb8row+1 + bomb8RowCounter and (column >= bomb8+bombtoplen+bomb8ColumnConter and column <= bomb8+bomb8ColumnConter+bombtoplen*2)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb8row+2 + bomb8RowCounter and row <= bomb8row+4+ bomb8RowCounter) and (column >= bomb8+bomb8ColumnConter+bombtoplen*2 and column <= bomb8+bomb8ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb8row+5+ bomb8RowCounter and (column >= bomb8+bomb8ColumnConter+bombtoplen and column <= bomb8+bomb8ColumnConter+bombtoplen*2)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;
	elsif(row = bomb8row+6+ bomb8RowCounter and (column >= bomb8+bomb8ColumnConter and column <= bomb8+bomb8ColumnConter+bombtoplen*3)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;
	elsif((row >= bomb8row+7+ bomb8RowCounter and row <= bomb8row+8+ bomb8RowCounter) and (column >= bomb8+bomb8ColumnConter and column <= bomb8+bomb8ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb8row+9+ bomb8RowCounter and row <= bomb8row+11+ bomb8RowCounter) and (column >= bomb8-2+bomb8ColumnConter and column <= 2+bomb8+bomb8ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb8row+12+ bomb8RowCounter and row <= bomb8row+13+ bomb8RowCounter) and (column >= bomb8+bomb8ColumnConter and column <= bomb8+bomb8ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb8row+14+ bomb8RowCounter and (column >= bomb8+bombtoplen+bomb8ColumnConter and column <= bomb8+bomb8ColumnConter+bombtoplen*2)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;

	--Draws bomb9
	elsif(row = bomb9row + bomb9RowCounter and (column >= bomb9+bomb9ColumnConter and column <= bomb9+bombtoplen+bomb9ColumnConter)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb9row+1 + bomb9RowCounter and (column >= bomb9+bombtoplen+bomb9ColumnConter and column <= bomb9+bomb9ColumnConter+bombtoplen*2)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb9row+2 + bomb9RowCounter and row <= bomb9row+4+ bomb9RowCounter) and (column >= bomb9+bomb9ColumnConter+bombtoplen*2 and column <= bomb9+bomb9ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb9row+5+ bomb9RowCounter and (column >= bomb9+bomb9ColumnConter+bombtoplen and column <= bomb9+bomb9ColumnConter+bombtoplen*2)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;
	elsif(row = bomb9row+6+ bomb9RowCounter and (column >= bomb9+bomb9ColumnConter and column <= bomb9+bomb9ColumnConter+bombtoplen*3)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;
	elsif((row >= bomb9row+7+ bomb9RowCounter and row <= bomb9row+8+ bomb9RowCounter) and (column >= bomb9+bomb9ColumnConter and column <= bomb9+bomb9ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb9row+9+ bomb9RowCounter and row <= bomb9row+11+ bomb9RowCounter) and (column >= bomb9-2+bomb9ColumnConter and column <= 2+bomb9+bomb9ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb9row+12+ bomb9RowCounter and row <= bomb9row+13+ bomb9RowCounter) and (column >= bomb9+bomb9ColumnConter and column <= bomb9+bomb9ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb9row+14+ bomb9RowCounter and (column >= bomb9+bombtoplen+bomb9ColumnConter and column <= bomb9+bomb9ColumnConter+bombtoplen*2)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;

	--Draws bomb10
	elsif(row = bomb10row + bomb10RowCounter and (column >= bomb10+bomb10ColumnConter and column <= bomb10+bombtoplen+bomb10ColumnConter)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb10row+1 + bomb10RowCounter and (column >= bomb10+bombtoplen+bomb10ColumnConter and column <= bomb10+bomb10ColumnConter+bombtoplen*2)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb10row+2 + bomb10RowCounter and row <= bomb10row+4+ bomb10RowCounter) and (column >= bomb10+bomb10ColumnConter+bombtoplen*2 and column <= bomb10+bomb10ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb10row+5+ bomb10RowCounter and (column >= bomb10+bomb10ColumnConter+bombtoplen and column <= bomb10+bomb10ColumnConter+bombtoplen*2)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;
	elsif(row = bomb10row+6+ bomb10RowCounter and (column >= bomb10+bomb10ColumnConter and column <= bomb10+bomb10ColumnConter+bombtoplen*3)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;
	elsif((row >= bomb10row+7+ bomb10RowCounter and row <= bomb10row+8+ bomb10RowCounter) and (column >= bomb10+bomb10ColumnConter and column <= bomb10+bomb10ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb10row+9+ bomb10RowCounter and row <= bomb10row+11+ bomb10RowCounter) and (column >= bomb10-2+bomb10ColumnConter and column <= 2+bomb10+bomb10ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif((row >= bomb10row+12+ bomb10RowCounter and row <= bomb10row+13+ bomb10RowCounter) and (column >= bomb10+bomb10ColumnConter and column <= bomb10+bomb10ColumnConter+bombtoplen*3)) then
		redVal := 12;
		greenVal := 12;
		blueVal := 12;
	elsif(row = bomb10row+14+ bomb10RowCounter and (column >= bomb10+bombtoplen+bomb10ColumnConter and column <= bomb10+bomb10ColumnConter+bombtoplen*2)) then
		redVal := 0;
		greenVal := 0;
		blueVal := 0;

	--Draws the bottom cart
	elsif((row >= bottomCartRow and row <= bottomCartRow + 2) and (column >= cartPos and column <= cartPos + cartLen)) then
		redVal := 7;
		greenVal := 4;
		blueVal := 1;
	elsif((row >= bottomCartRow-2 and row <= bottomCartRow-1 ) and (column >= cartPos and column <= cartPos + cartLen) and not((column >= cartPos+10 and column <= cartPos+20) or (column >= cartPos+30 and column <= cartPos+40) or (column >= cartPos+50 and column <= cartPos+60))) then
		redVal := 7;
		greenVal := 4;
		blueVal := 1;
	elsif((row >= bottomCartRow-7 and row <= bottomCartRow-3 ) and (column >= cartPos and column <= cartPos + cartLen) and not((column >= cartPos+10 and column <= cartPos+20) or (column >= cartPos+30 and column <= cartPos+40) or (column >= cartPos+50 and column <= cartPos+60))) then
		redVal := 12;
		greenVal := 6;
		blueVal := 2;
	elsif((row >= bottomCartRow-12 and row <= bottomCartRow-8 ) and (column >= cartPos and column <= cartPos + cartLen) and not((column >= cartPos+10 and column <= cartPos+20) or (column >= cartPos+30 and column <= cartPos+40) or (column >= cartPos+50 and column <= cartPos+60))) then
		redVal := 15;
		greenVal := 8;
		blueVal := 2;
	elsif((row >= bottomCartRow-15 and row <= bottomCartRow-13 ) and (column >= cartPos+10 and column <= cartPos+49)) then
		redVal := 9;
		greenVal := 8;
		blueVal := 14;
	elsif((row >= bottomCartRow-17 and row <= bottomCartRow-16) and (column >= cartPos+10 and column <= cartPos+59)) then
		redVal := 12;
		greenVal := 8;
		blueVal := 8;
		
	--Draws the middle cart
	elsif((row >= middleCartRow and row <= middleCartRow + 2) and (column >= cartPos and column <= cartPos + cartLen)) then
		redVal := 7;
		greenVal := 4;
		blueVal := 1;
	elsif((row >= middleCartRow-2 and row <= middleCartRow-1 ) and (column >= cartPos and column <= cartPos + cartLen) and not((column >= cartPos+10 and column <= cartPos+20) or (column >= cartPos+30 and column <= cartPos+40) or (column >= cartPos+50 and column <= cartPos+60))) then
		redVal := 7;
		greenVal := 4;
		blueVal := 1;
	elsif((row >= middleCartRow-7 and row <= middleCartRow-3 ) and (column >= cartPos and column <= cartPos + cartLen) and not((column >= cartPos+10 and column <= cartPos+20) or (column >= cartPos+30 and column <= cartPos+40) or (column >= cartPos+50 and column <= cartPos+60))) then
		redVal := 12;
		greenVal := 6;
		blueVal := 2;
	elsif((row >= middleCartRow-12 and row <= middleCartRow-8 ) and (column >= cartPos and column <= cartPos + cartLen) and not((column >= cartPos+10 and column <= cartPos+20) or (column >= cartPos+30 and column <= cartPos+40) or (column >= cartPos+50 and column <= cartPos+60))) then
		redVal := 15;
		greenVal := 8;
		blueVal := 2;
	elsif((row >= middleCartRow-15 and row <= middleCartRow-13 ) and (column >= cartPos+10 and column <= cartPos+49)) then
		redVal := 9;
		greenVal := 8;
		blueVal := 14;
	elsif((row >= middleCartRow-17 and row <= middleCartRow-16) and (column >= cartPos+10 and column <= cartPos+59)) then
		redVal := 12;
		greenVal := 8;
		blueVal := 8;
		
	--Draws the top cart
	elsif((row >= topCartRow and row <= topCartRow + 2) and (column >= cartPos and column <= cartPos + cartLen)) then
		redVal := 7;
		greenVal := 4;
		blueVal := 1;
	elsif((row >= topCartRow-2 and row <= topCartRow-1 ) and (column >= cartPos and column <= cartPos + cartLen) and not((column >= cartPos+10 and column <= cartPos+20) or (column >= cartPos+30 and column <= cartPos+40) or (column >= cartPos+50 and column <= cartPos+60))) then
		redVal := 7;
		greenVal := 4;
		blueVal := 1;
	elsif((row >= topCartRow-7 and row <= topCartRow-3 ) and (column >= cartPos and column <= cartPos + cartLen) and not((column >= cartPos+10 and column <= cartPos+20) or (column >= cartPos+30 and column <= cartPos+40) or (column >= cartPos+50 and column <= cartPos+60))) then
		redVal := 12;
		greenVal := 6;
		blueVal := 2;
	elsif((row >= topCartRow-12 and row <= topCartRow-8 ) and (column >= cartPos and column <= cartPos + cartLen) and not((column >= cartPos+10 and column <= cartPos+20) or (column >= cartPos+30 and column <= cartPos+40) or (column >= cartPos+50 and column <= cartPos+60))) then
		redVal := 15;
		greenVal := 8;
		blueVal := 2;
	elsif((row >= topCartRow-15 and row <= topCartRow-13 ) and (column >= cartPos+10 and column <= cartPos+49)) then
		redVal := 9;
		greenVal := 8;
		blueVal := 14;
	elsif((row >= topCartRow-17 and row <= topCartRow-16) and (column >= cartPos+10 and column <= cartPos+59)) then
		redVal := 12;
		greenVal := 8;
		blueVal := 8;
		
	-- For drawing TNTech ECE
	-- Row_A -------------------------------------------------------------------------------------------
	--T1
	elsif((row >= row_A_top and row <= row_A_bot) and (column >= T1topStart and column <= T1topEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--Na	
	elsif((row >= row_A_top and row <= row_A_bot) and (column >= NLtopStart and column <=NLtopEnd)) then
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--Nb
	elsif((row >= row_A_top and row <= row_A_bot) and (column >= NRtopStart and column <= NRtopEnd )) then
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--T2
	elsif((row >= row_A_top and row <= row_A_bot) and (column >= T2topStart and column <= T2topEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--E1
	elsif((row >= row_A_top and row <= row_A_bot) and (column >= E1topStart and column <= E1topEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--C
	elsif((row >= row_A_top and row <= row_A_bot) and (column >= C1topStart and column <= C1topEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--Ha
	elsif((row >= row_A_top and row <= row_A_bot) and (column >= HLtopStart and column <= HLtopEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--Hb
	elsif((row >= row_A_top and row <= row_A_bot) and (column >= HRtopStart and column <= HRtopEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--E2
	elsif((row >= row_A_top and row <= row_A_bot) and (column >= E2topStart and column <= E2topEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--C
	elsif((row >= row_A_top and row <= row_A_bot) and (column >= C2topStart and column <= C2topEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--E3
	elsif((row >= row_A_top and row <= row_A_bot) and (column >= E3topStart and column <= E3topEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
		
	--Row_B -------------------------------------------------------------------------------------------
	--T1
	elsif((row >= row_B_top and row <= row_B_bot) and (column >= T1midStart and column <= T1midEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--Na
	elsif((row >= row_B_top and row <= row_B_bot) and (column >= NLmidStart and column <= NLmidEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--Nmid1
	elsif((row >= row_B_top-3 and row <= row_B_bot-3) and (column >= NLmidEnd and column <= NLmidEnd+3)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--Nmid2
	elsif((row >= row_B_top and row <= row_B_bot) and (column >= NLmidEnd+3 and column <= NLmidEnd+6)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--Nmid3
	elsif((row >= row_B_top+3 and row <= row_B_bot+3) and (column >= NLmidEnd+6 and column <= NLmidEnd+9)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;	
	--Nb
	elsif((row >= row_B_top and row <= row_B_bot) and (column >= NRmidStart and column <= NRmidEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--T2
	elsif((row >= row_B_top and row <= row_B_bot) and (column >= T2midStart and column <= T2midEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--E1
	elsif((row >= row_B_top and row <= row_B_bot) and (column >= E1midStart and column <= E1midStart+9)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--E1mid
	elsif((row > row_B_top and row < row_B_bot) and (column >= E1midStart+9 and column <= E1midEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--C1
	elsif((row >= row_B_top and row <= row_B_bot) and (column >= C1midStart and column <= C1midEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--H
	elsif((row >= row_B_top and row <= row_B_bot) and (column >= HmidStart and column <= HmidEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--E2
	elsif((row >= row_B_top and row <= row_B_bot) and (column >= E2midStart and column <= E2midStart+9)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--E2mid
	elsif((row > row_B_top and row < row_B_bot) and (column >= E2midStart+9 and column <= E2midEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--C2
	elsif((row >= row_B_top and row <= row_B_bot) and (column >= C2midStart and column <= C2midEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--E3
	elsif((row >= row_B_top and row <= row_B_bot) and (column >= E3midStart and column <= E3midStart+9)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--E3mid	
	elsif((row > row_B_top and row < row_B_bot) and (column >= E3midStart+9 and column <= E3midEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;


	-- Row_C -------------------------------------------------------------------------------------------
	--T1
	elsif((row >= row_C_top and row <= row_C_bot) and (column >= T1midStart and column <= T1midEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;	
	--Na
	elsif((row >= row_C_top and row <= row_C_bot) and (column >= NLtopStart and column <= NLtopEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--Nb
	elsif((row >= row_C_top and row <= row_C_bot) and (column >= NRtopStart and column <= NRtopEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--T2
	elsif((row >= row_C_top and row <= row_C_bot) and (column >= T2midStart and column <= T2midEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--E1
	elsif((row >= row_C_top and row <= row_C_bot) and (column >= E1topStart and column <= E1topEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--C1
	elsif((row >= row_C_top and row <= row_C_bot) and (column >= C1topStart and column <= C1topEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;	
	--Ha
	elsif((row >= row_C_top and row <= row_C_bot) and (column >= HLtopStart and column <= HLtopEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--Hb
	elsif((row >= row_C_top and row <= row_C_bot) and (column >= HRtopStart and column <= HRtopEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--E2
	elsif((row >= row_C_top and row <= row_C_bot) and (column >= E2topStart and column <= E2topEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--C2
	elsif((row >= row_C_top and row <= row_C_bot) and (column >= C2topStart and column <= C2topEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
	--E3
	elsif((row >= row_C_top and row <= row_C_bot) and (column >= E3topStart and column <= E3topEnd)) then 
		redVal := 15;
		greenVal := 13;
		blueVal := 0;
		
		
	--Draws the background
	elsif(row < topBar) then
		redVal := 11;
		greenVal := 11;
		blueVal := 11;
	elsif(row >= topBar and row < playField) then
		redVal := 5;
		greenVal := 7;
		blueVal := 2;
	elsif(row >= playField and row < bottomBar) then
		redVal := 6;
		greenVal := 3;
		blueVal := 9;
	end if;

	--Draws the score
	rowstd <= std_logic_vector(to_unsigned((row - letter_fromtop_offset),4));
		
		if(row > letter_fromtop_offset and row < letter_fromtop_offset + 16) then
			if(column > letter_fromleft_offset and column < letter_fromleft_offset + 8) then
				colarrayval0 := colarray0(8-(column-letter_fromleft_offset));
				if(colarrayval0 = '1') then
					redVal := 15;
					greenVal := 13;
					blueVal := 0;
				end if;
			end if;
			if(column > letter_fromleft_offset + l_space_between and column < letter_fromleft_offset + l_space_between + 8) then
				colarrayval1 := colarray1(8-(column-(letter_fromleft_offset + l_space_between)));
				if(colarrayval1 = '1') then
					redVal := 15;
					greenVal := 13;
					blueVal := 0;
				end if;
			end if;
			if(column > letter_fromleft_offset + l_space_between + l_space_between and column < letter_fromleft_offset + l_space_between + l_space_between + 8) then
				colarrayval2 := colarray2(8-(column-(letter_fromleft_offset + l_space_between + l_space_between)));
				if(colarrayval2 = '1') then
					redVal := 15;
					greenVal := 13;
					blueVal := 0;
				end if;
			end if;
			if(column > letter_fromleft_offset + l_space_between + l_space_between + l_space_between and column < letter_fromleft_offset + l_space_between + l_space_between + l_space_between + 8) then
				colarrayval3 := colarray3(8-(column-(letter_fromleft_offset + l_space_between + l_space_between + l_space_between)));
				if(colarrayval3 = '1') then
					redVal := 15;
					greenVal := 13;
					blueVal := 0;
				end if;
			end if;
		end if;	
	if(disp_ena = '1') THEN
		red <= std_logic_vector(to_unsigned(redVal, red'length));
		green <= std_logic_vector(to_unsigned(greenVal, green'length));
		blue <= std_logic_vector(to_unsigned(blueVal, blue'length));
	else
		red <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		green <= (OTHERS => '0');
	end if;
  
	end process; 
	
	--Moves the cart
	process(pos_in)
	variable counter : integer := 0;
	begin
		if(pause = '0' and demoMode /= '1') then
			cartPos <= pos_in;
		elsif(pause = '0' and demoMode = '1') then
			if(mainClock = '1' and mainClock'event) then
				counter := counter + 1;
				if (counter > manMoveSpeed-100 and pause = '0') then
					if (clockSlow = '1') then
						clockSlow <= '0';
					else
						clockSlow <= '1';
					end if;
					--Do stuff here
					case randNum is
						when '0' => cartPOS <= cartPOS + 1;
						when '1' => cartPOS <= cartPOS - 1;
					end case;
					
					if(cartPOS = (570) and randNum = '0') then
						cartPOS <= cartPOS;
					elsif(cartPOS = 0 and randNum = '1') then
						cartPOS <= cartPOS;
				end if;
				
				counter := 0 ;
            end if;
			
        end if;
		end if;
	end process;
	
	--Makes the man move logic
	process(mainClock)
    variable counter: integer := 0;
    begin
        if(mainClock = '1' and mainClock'event) then
            counter := counter + 1;
            if (counter > manMoveSpeed and pause = '0') then
            if (clockSlow = '1') then
                clockSlow <= '0';
            else
                clockSlow <= '1';
            end if;
			--Do stuff here
			case randNum is
				when '0' => direction <= direction + 1;
				when '1' => direction <= direction - 1;
			end case;
			
			if(direction = (303) and randNum = '0') then
				direction <= direction;
			elsif(direction = -306 and randNum = '1') then
				direction <= direction;
			end if;
			
            counter := 0 ;
            end if;
			
        end if;
    
    end process;
	
	--Makes bomb logic (fall, score keeping, and miss logic)
	process(mainClock)

    variable counter: integer := 0;
	variable myLatch1 : integer := 0;
	variable myLatch2 : integer := 0;
	variable myLatch3 : integer := 0;
	variable myLatch4 : integer := 0;
	variable myLatch5 : integer := 0;
	variable myLatch6 : integer := 0;
	variable myLatch7 : integer := 0;
	variable myLatch8 : integer := 0;
	variable myLatch9 : integer := 0;
	variable myLatch10 : integer := 0;
	variable colOffset : integer := 375;
    
    begin
        if(mainClock = '1' and mainClock'event) then
            counter := counter + 1;
            if (counter > bombFallSpeed and pause = '0') then
            if (clockSlow = '1') then
                clockSlow <= '0';
            else
                clockSlow <= '1';
            end if;
			--Do stuff here
			if(numBombs > 0) then
				myLatch1 := 1;
			end if;
			
			if(numBombs > 1 and myLatch1 = 1) then
				myLatch2 := 1;
			end if;
			
			if(numBombs > 2 and myLatch2 = 1) then
				myLatch3 := 1;
			end if;
			
			if(numBombs > 3 and myLatch3 = 1) then
				myLatch4 := 1;
			end if;
			
			if(numBombs > 4 and myLatch4 = 1) then
				myLatch5 := 1;
			end if;
			
			if(numBombs > 5 and myLatch5 = 1) then
				myLatch6 := 1;
			end if;
			
			if(numBombs > 6 and myLatch6 = 1) then
				myLatch7 := 1;
			end if;
			
			if(numBombs > 7 and myLatch7 = 1) then
				myLatch8 := 1;
			end if;
			
			if(numBombs > 8 and myLatch8 = 1) then
				myLatch9 := 1;
			end if;
			
			if(numBombs > 9 and myLatch9 = 1) then
				myLatch10 := 1;
			end if;
			
			if(myLatch1 = 1) then
				bomb1RowCounter <= bomb1RowCounter + 1;
			end if;
			if(bomb1RowCounter = 335 and myLatch1 = 1) then
				bomb1RowCounter <= 0;
			end if;
			if(bomb1RowCounter = 0 and myLatch1 = 1) then
				bombNums <= bombNums + 1;
				bomb1ColumnConter <= direction-colOffset;
			end if;
			
			if(myLatch2 = 1) then
				bomb2RowCounter <= bomb2RowCounter + 1;
			end if;
			if(bomb2RowCounter = 335 and myLatch2 = 1) then
				bomb2RowCounter <= 0;
			end if;
			if(bomb2RowCounter = 0 and myLatch2 = 1) then
				bombNums <= bombNums + 1;
				bomb2ColumnConter <= direction-colOffset;
			end if;
			
			if(myLatch3 = 1) then
				bomb3RowCounter <= bomb3RowCounter + 1;
			end if;
			if(bomb3RowCounter = 335 and myLatch3 = 1) then
				bomb3RowCounter <= 0;
			end if;
			if(bomb3RowCounter = 0 and myLatch3 = 1) then
				bombNums <= bombNums + 1;
				bomb3ColumnConter <= direction-colOffset;
			end if;
			
			if(myLatch4 = 1) then
				bomb4RowCounter <= bomb4RowCounter + 1;
			end if;
			if(bomb4RowCounter = 335 and myLatch4 = 1) then
				bomb4RowCounter <= 0;
			end if;
			if(bomb4RowCounter = 0 and myLatch4 = 1) then
				bombNums <= bombNums + 1;
				bomb4ColumnConter <= direction-colOffset;
			end if;
			
			if(myLatch5 = 1) then
				bomb5RowCounter <= bomb5RowCounter + 1;
			end if;
			if(bomb5RowCounter = 335 and myLatch5 = 1) then
				bomb5RowCounter <= 0;
			end if;
			if(bomb5RowCounter = 0 and myLatch5 = 1) then
				bombNums <= bombNums + 1;
				bomb5ColumnConter <= direction-colOffset;
			end if;
			
			if(myLatch6 = 1) then
				bomb6RowCounter <= bomb6RowCounter + 1;
			end if;
			if(bomb6RowCounter = 335 and myLatch6 = 1) then
				bomb6RowCounter <= 0;
			end if;
			if(bomb6RowCounter = 0 and myLatch6 = 1) then
				bombNums <= bombNums + 1;
				bomb6ColumnConter <= direction-colOffset;
			end if;
			
			if(myLatch7 = 1) then
				bomb7RowCounter <= bomb7RowCounter + 1;
			end if;
			if(bomb7RowCounter = 335 and myLatch7 = 1) then
				bomb7RowCounter <= 0;
			end if;
			if(bomb7RowCounter = 0 and myLatch7 = 1) then
				bombNums <= bombNums + 1;
				bomb2ColumnConter <= direction-colOffset;
			end if;
			
			if(myLatch8 = 1) then
				bomb8RowCounter <= bomb8RowCounter + 1;
			end if;
			if(bomb8RowCounter = 335 and myLatch8 = 1) then
				bomb8RowCounter <= 0;
			end if;
			if(bomb8RowCounter = 0 and myLatch8 = 1) then
				bombNums <= bombNums + 1;
				bomb8ColumnConter <= direction-colOffset;
			end if;
			
			if(myLatch9 = 1) then
				bomb9RowCounter <= bomb9RowCounter + 1;
			end if;
			if(bomb9RowCounter = 335 and myLatch9 = 1) then
				bomb9RowCounter <= 0;
			end if;
			if(bomb9RowCounter = 0 and myLatch9 = 1) then
				bombNums <= bombNums + 1;
				bomb9ColumnConter <= direction-colOffset;
			end if;
			
			if(myLatch10 = 1) then
				bomb10RowCounter <= bomb10RowCounter + 1;
			end if;
			if(bomb10RowCounter = 335 and myLatch10 = 1) then
				bomb10RowCounter <= 0;
			end if;
			if(bomb10RowCounter = 0 and myLatch10 = 1) then
				bombNums <= bombNums + 1;
				bomb10ColumnConter <= direction-colOffset;
			end if;
			
			--Decrements the lives
			if(bomb1RowCounter = 334) then
				Lives <= Lives -1;
			elsif(bomb2RowCounter = 334) then
				Lives <= Lives -1;
			elsif(bomb3RowCounter = 334) then
				Lives <= Lives -1;
			elsif(bomb4RowCounter = 334) then
				Lives <= Lives -1;
			elsif(bomb5RowCounter = 334) then
				Lives <= Lives -1;
			elsif(bomb6RowCounter = 334) then
				Lives <= Lives -1;
			elsif(bomb7RowCounter = 334) then
				Lives <= Lives -1;
			elsif(bomb8RowCounter = 334) then
				Lives <= Lives -1;
			elsif(bomb9RowCounter = 334) then
				Lives <= Lives -1;
			elsif(bomb10RowCounter = 334) then
				Lives <= Lives -1;
			elsif(Lives <= 0) then
				Score <= 0;
				Lives <= 3;
			end if;
							
			
			if(Lives = 3) then
				if((bomb1row+14+ bomb1RowCounter > topCartRow-19) and (bomb1row+14+ bomb1RowCounter < bottomCartRow) and (bomb1-2+bomb1ColumnConter > cartPos) and (bomb1-2+bomb1ColumnConter < cartPos + 70)) then
					bomb1RowCounter <= 0;
					bomb1ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;
				
				if((bomb2row+14+ bomb2RowCounter > topCartRow-19) and (bomb2row+14+ bomb2RowCounter < bottomCartRow) and (bomb2-2+bomb2ColumnConter > cartPos) and (bomb2-2+bomb2ColumnConter < cartPos + 70)) then
					bomb2RowCounter <= 0;
					bomb2ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;
				
				if((bomb3row+14+ bomb3RowCounter > topCartRow-19) and (bomb3row+14+ bomb3RowCounter < bottomCartRow) and (bomb3-2+bomb3ColumnConter > cartPos) and (bomb3-2+bomb3ColumnConter < cartPos + 70)) then
					bomb3RowCounter <= 0;
					bomb3ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;
				
				if((bomb4row+14+ bomb4RowCounter > topCartRow-19) and (bomb4row+14+ bomb4RowCounter < bottomCartRow) and (bomb4-2+bomb4ColumnConter > cartPos) and (bomb4-2+bomb4ColumnConter < cartPos + 70)) then
					bomb4RowCounter <= 0;
					bomb4ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;

				if((bomb5row+14+ bomb5RowCounter > topCartRow-19) and (bomb5row+14+ bomb5RowCounter < bottomCartRow) and (bomb5-2+bomb5ColumnConter > cartPos) and (bomb5-2+bomb5ColumnConter < cartPos + 70)) then
					bomb5RowCounter <= 0;
					bomb5ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;
				
				if((bomb6row+14+ bomb6RowCounter > topCartRow-19) and (bomb6row+14+ bomb6RowCounter < bottomCartRow) and (bomb6-2+bomb6ColumnConter > cartPos) and (bomb6-2+bomb6ColumnConter < cartPos + 70)) then
					bomb6RowCounter <= 0;
					bomb6ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;
				
				if((bomb7row+14+ bomb7RowCounter > topCartRow-19) and (bomb7row+14+ bomb7RowCounter < bottomCartRow) and (bomb7-2+bomb7ColumnConter > cartPos) and (bomb7-2+bomb7ColumnConter < cartPos + 70)) then
					bomb7RowCounter <= 0;
					bomb7ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;
				
				if((bomb8row+14+ bomb8RowCounter > topCartRow-19) and (bomb8row+14+ bomb8RowCounter < bottomCartRow) and (bomb8-2+bomb8ColumnConter > cartPos) and (bomb8-2+bomb8ColumnConter < cartPos + 70)) then
					bomb8RowCounter <= 0;
					bomb8ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;
				
				if((bomb9row+14+ bomb9RowCounter > topCartRow-19) and (bomb9row+14+ bomb9RowCounter < bottomCartRow) and (bomb9-2+bomb9ColumnConter > cartPos) and (bomb9-2+bomb9ColumnConter < cartPos + 70)) then
					bomb9RowCounter <= 0;
					bomb9ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;
				
				if((bomb10row+14+ bomb10RowCounter > topCartRow-19) and (bomb10row+14+ bomb10RowCounter < bottomCartRow) and (bomb10-2+bomb10ColumnConter > cartPos) and (bomb10-2+bomb10ColumnConter < cartPos + 70)) then
					bomb10RowCounter <= 0;
					bomb10ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;
			end if;
			
			if(Lives = 2) then
				if((bomb1row+14+ bomb1RowCounter > topCartRow-19) and (bomb1row+14+ bomb1RowCounter < middleCartRow) and (bomb1-2+bomb1ColumnConter > cartPos) and (bomb1-2+bomb1ColumnConter < cartPos + 70)) then
					bomb1RowCounter <= 0;
					bomb1ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;
				
				if((bomb2row+14+ bomb2RowCounter > topCartRow-19) and (bomb2row+14+ bomb2RowCounter < middleCartRow) and (bomb2-2+bomb2ColumnConter > cartPos) and (bomb2-2+bomb2ColumnConter < cartPos + 70)) then
					bomb2RowCounter <= 0;
					bomb2ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;
				
				if((bomb3row+14+ bomb3RowCounter > topCartRow-19) and (bomb3row+14+ bomb3RowCounter < middleCartRow) and (bomb3-2+bomb3ColumnConter > cartPos) and (bomb3-2+bomb3ColumnConter < cartPos + 70)) then
					bomb3RowCounter <= 0;
					bomb3ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;
				
				if((bomb4row+14+ bomb4RowCounter > topCartRow-19) and (bomb4row+14+ bomb4RowCounter < middleCartRow) and (bomb4-2+bomb4ColumnConter > cartPos) and (bomb4-2+bomb4ColumnConter < cartPos + 70)) then
					bomb4RowCounter <= 0;
					bomb4ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;

				if((bomb5row+14+ bomb5RowCounter > topCartRow-19) and (bomb5row+14+ bomb5RowCounter < middleCartRow) and (bomb5-2+bomb5ColumnConter > cartPos) and (bomb5-2+bomb5ColumnConter < cartPos + 70)) then
					bomb5RowCounter <= 0;
					bomb5ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;
				
				if((bomb6row+14+ bomb6RowCounter > topCartRow-19) and (bomb6row+14+ bomb6RowCounter < middleCartRow) and (bomb6-2+bomb6ColumnConter > cartPos) and (bomb6-2+bomb6ColumnConter < cartPos + 70)) then
					bomb6RowCounter <= 0;
					bomb6ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;
				
				if((bomb7row+14+ bomb7RowCounter > topCartRow-19) and (bomb7row+14+ bomb7RowCounter < middleCartRow) and (bomb7-2+bomb7ColumnConter > cartPos) and (bomb7-2+bomb7ColumnConter < cartPos + 70)) then
					bomb7RowCounter <= 0;
					bomb7ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;
				
				if((bomb8row+14+ bomb8RowCounter > topCartRow-19) and (bomb8row+14+ bomb8RowCounter < middleCartRow) and (bomb8-2+bomb8ColumnConter > cartPos) and (bomb8-2+bomb8ColumnConter < cartPos + 70)) then
					bomb8RowCounter <= 0;
					bomb8ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;
				
				if((bomb9row+14+ bomb9RowCounter > topCartRow-19) and (bomb9row+14+ bomb9RowCounter < middleCartRow) and (bomb9-2+bomb9ColumnConter > cartPos) and (bomb9-2+bomb9ColumnConter < cartPos + 70)) then
					bomb9RowCounter <= 0;
					bomb9ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;
				
				if((bomb10row+14+ bomb10RowCounter > topCartRow-19) and (bomb10row+14+ bomb10RowCounter < middleCartRow) and (bomb10-2+bomb10ColumnConter > cartPos) and (bomb10-2+bomb10ColumnConter < cartPos + 70)) then
					bomb10RowCounter <= 0;
					bomb10ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;
			end if;
			
			if(Lives = 1) then
				if((bomb1row+14+ bomb1RowCounter > topCartRow-19) and (bomb1row+14+ bomb1RowCounter < middleCartRow) and (bomb1-2+bomb1ColumnConter > cartPos) and (bomb1-2+bomb1ColumnConter < cartPos + 70)) then
					bomb1RowCounter <= 0;
					bomb1ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;
				
				if((bomb2row+14+ bomb2RowCounter > topCartRow-19) and (bomb2row+14+ bomb2RowCounter < topCartRow) and (bomb2-2+bomb2ColumnConter > cartPos) and (bomb2-2+bomb2ColumnConter < cartPos + 70)) then
					bomb2RowCounter <= 0;
					bomb2ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;
				
				if((bomb3row+14+ bomb3RowCounter > topCartRow-19) and (bomb3row+14+ bomb3RowCounter < topCartRow) and (bomb3-2+bomb3ColumnConter > cartPos) and (bomb3-2+bomb3ColumnConter < cartPos + 70)) then
					bomb3RowCounter <= 0;
					bomb3ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;
				
				if((bomb4row+14+ bomb4RowCounter > topCartRow-19) and (bomb4row+14+ bomb4RowCounter < topCartRow) and (bomb4-2+bomb4ColumnConter > cartPos) and (bomb4-2+bomb4ColumnConter < cartPos + 70)) then
					bomb4RowCounter <= 0;
					bomb4ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;

				if((bomb5row+14+ bomb5RowCounter > topCartRow-19) and (bomb5row+14+ bomb5RowCounter < topCartRow) and (bomb5-2+bomb5ColumnConter > cartPos) and (bomb5-2+bomb5ColumnConter < cartPos + 70)) then
					bomb5RowCounter <= 0;
					bomb5ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;
				
				if((bomb6row+14+ bomb6RowCounter > topCartRow-19) and (bomb6row+14+ bomb6RowCounter < topCartRow) and (bomb6-2+bomb6ColumnConter > cartPos) and (bomb6-2+bomb6ColumnConter < cartPos + 70)) then
					bomb6RowCounter <= 0;
					bomb6ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;
				
				if((bomb7row+14+ bomb7RowCounter > topCartRow-19) and (bomb7row+14+ bomb7RowCounter < topCartRow) and (bomb7-2+bomb7ColumnConter > cartPos) and (bomb7-2+bomb7ColumnConter < cartPos + 70)) then
					bomb7RowCounter <= 0;
					bomb7ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;
				
				if((bomb8row+14+ bomb8RowCounter > topCartRow-19) and (bomb8row+14+ bomb8RowCounter < topCartRow) and (bomb8-2+bomb8ColumnConter > cartPos) and (bomb8-2+bomb8ColumnConter < cartPos + 70)) then
					bomb8RowCounter <= 0;
					bomb8ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;
				
				if((bomb9row+14+ bomb9RowCounter > topCartRow-19) and (bomb9row+14+ bomb9RowCounter < topCartRow) and (bomb9-2+bomb9ColumnConter > cartPos) and (bomb9-2+bomb9ColumnConter < cartPos + 70)) then
					bomb9RowCounter <= 0;
					bomb9ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;
				
				if((bomb10row+14+ bomb10RowCounter > topCartRow-19) and (bomb10row+14+ bomb10RowCounter < topCartRow) and (bomb10-2+bomb10ColumnConter > cartPos) and (bomb10-2+bomb10ColumnConter < cartPos + 70)) then
					bomb10RowCounter <= 0;
					bomb10ColumnConter <= direction - colOffset;
					score <= score + Factor;
				end if;
			end if;
			
            counter := 0 ;
            end if;
			
			
        end if;
    
    end process;
	
	--Makes the man drop the bombs at a constant seperate rate
	process(mainClock)

    variable counter: integer := 0;
	variable bombDropRate : integer := 5000000;
    
    begin
        if(mainClock = '1' and mainClock'event) then
            counter := counter + 1;
            if (counter > bombDropRate and pause = '0') then
            if (clockSlow = '1') then
                clockSlow <= '0';
            else
                clockSlow <= '1';
            end if;
			
			numBombs <= numBombs + 1;
			
            counter := 0 ;
            end if;
			
        end if;
    
    end process;
	
	--Generates a pseudo-random number using an lfsr
	PROCESS (mainClock)
	VARIABLE next_val	: STD_LOGIC;	-- Store the value to be shifted in
	VARIABLE count		: INTEGER := 0;	-- Number of clock cycles that have passed
	CONSTANT delay		: INTEGER := 17000000;
	BEGIN
		IF RISING_EDGE(mainClock) THEN
			count := count + 1;
			IF (count >= delay and pause = '0') THEN
				count := 0;
				
				next_val := shift(0) XOR shift(2) XOR shift(3) XOR shift(4);	-- Galois LFSR algorithm
				shift <= shift_right(shift, 1);	-- Shift all values right
				shift(7) <= next_val;			-- Load in the calculated next value
				randNum <= shift(7);	-- Output
			END IF;
		END IF;
	END PROCESS;
	
	--Does logic fo the levelchange, level logic, and lives
	process(pll_OUT_to_vga_controller_IN)
	begin
	
	if(bombNums < 10) then
		Level <= 1;
	elsif(bombNums < 25) then
		Level <= 2;
	elsif(bombNums < 50) then
		Level <= 3;
	elsif(bombNums < 75) then
		Level <= 4;
	else
		Level <= 5;
	end if;
	
	if(Level = 1) then
		Factor <= 1;
		bombFallSpeed <= 500000;
		manMoveSpeed <= 300000;
	elsif(Level = 2) then
		Factor <= 2;
		bombFallSpeed <= 450000;
		manMoveSpeed <= 250000;
	elsif(Level = 3) then
		Factor <= 3;
		bombFallSpeed <= 400000;
		manMoveSpeed <= 200000;
	elsif(Level = 4) then
		Factor <= 4;
		bombFallSpeed <= 350000;
		manMoveSpeed <= 150000;
	elsif(Level = 5) then
		Factor <= 5;
		bombFallSpeed <= 300000;
		manMoveSpeed <= 100000;
	end if;
	
	
	if(Lives = 3) then
		bottomCartRow <= 446;
		middleCartRow <= 417;
		topCartRow <= 388;
	elsif(Lives = 2) then
		bottomCartRow <= 700;
		middleCartRow <= 417;
		topCartRow <= 388;
	elsif(Lives = 1) then
		bottomCartRow <= 700;
		middleCartRow <= 700;
		topCartRow <= 388;
	end if;
	
	end process;
	
	--Does the pasuing logic
	process(mainClock)
	begin
	if(RISING_EDGE(togglePause)) then
		case pause is
			when '1'  => pause <= '0';
			when '0'  => pause <= '1';
		end case;
	end if;
	end process;
	
	
END behavior;