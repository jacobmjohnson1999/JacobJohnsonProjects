LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE ieee.std_logic_unsigned.all ;

ENTITY alu_1 IS
	PORT ( s : IN STD_LOGIC_VECTOR(2 DOWNTO 0) ;
			A, B : IN STD_LOGIC_VECTOR(31 DOWNTO 0) ;
			F : Buffer STD_LOGIC_VECTOR(31 DOWNTO 0) ;
			Compare: OUT STD_logic ) ;
END alu_1 ;

ARCHITECTURE Behavior OF alu_1 IS
	BEGIN
	PROCESS ( s, A, B )
	BEGIN
		CASE s IS
			WHEN "000" =>
				F <= x"00000000" ;
			WHEN "001" =>
				F <= B - A ;
			WHEN "010" =>
				F <= A - B ;
			WHEN "011" =>
				F <= A + B ;
			WHEN "100" =>
				F <= A XOR B ;
			WHEN "101" =>
				F <= A OR B ;
			WHEN "110" =>
				F <= A AND B ;
			WHEN "111" =>
				F <= A NOR B ;
			WHEN OTHERS =>
				F <= x"11111111" ;
			--Compare <= '0';
		END CASE ;
	END PROCESS ;

	process(F,s)
	begin
		if (F = x"00000000" and s = "100") then
			Compare <= '1';
		else
			Compare <= '0';
		end if;
	end process;
END Behavior;