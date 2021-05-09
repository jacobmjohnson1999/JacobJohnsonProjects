LIBRARY ieee ;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY ALU_Control_Unit is
	PORT(ALUOp			: IN STD_LOGIC_VECTOR(10 downto 0);
		S				: OUT STD_LOGIC_VECTOR(2 downto 0));
end ALU_Control_Unit;

ARCHITECTURE Behavior of ALU_Control_Unit IS
	
	SIGNAL Last_6		: STD_LOGIC_VECTOR(5 downto 0);
	SIGNAL Shift_Amount	: STD_LOGIC_VECTOR(4 downto 0);
	
	BEGIN	
	PROCESS(ALUOp)
	BEGIN
		Last_6 <= ALUOp(5 downto 0);
		Shift_Amount <= ALUOp(10 downto 6);
		case ALUOp(5 downto 0) IS
			WHEN "010000" => --Add
				S <= "011"; 
			WHEN "010010" => --Subtract
				S <= "010";
			WHEN "010001" => --Add unsigned
				S <= "011";
			WHEN "100011" => --Subtract unsigned
				S <= "010";
			WHEN "010100" => --AND
				S <= "110";
			WHEN "001000" => --Jump register
				S <= "110";
			WHEN "010111" => --NOR
				S <= "111";
			WHEN "010101" => --OR
				S <= "101";
			WHEN "000001" => --XOR is not an instruction but is used as a proprietary way to do branch compare
				S <= "100";
			WHEN others => 
				S <= "000";
			end case;
		
	end process;

end Behavior;