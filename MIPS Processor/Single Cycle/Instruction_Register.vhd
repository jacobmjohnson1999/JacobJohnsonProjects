LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY Instruction_Register IS
	
	GENERIC(
		size : INTEGER := 32);
	
	PORT(
		clk					:	IN STD_LOGIC;
		Address_In			:	IN STD_LOGIC_Vector(size-1 downto 0);
		Data_In				:	IN STD_LOGIC_Vector(size-1 downto 0);
		Address_Out			:	OUT STD_LOGIC_Vector(7 downto 0);
		Instruction_Output	:	OUT STD_LOGIC_Vector(size-1 downto 0));
		
end Instruction_Register;

Architecture behavioral of Instruction_Register IS
	
	begin
	process(clk)
	begin
		if (clk'event and clk = '1') then
			Address_Out <= Address_In(7 downto 0);
			Instruction_Output <= Data_In;
		end if;
		
	end process;
	
end behavioral;