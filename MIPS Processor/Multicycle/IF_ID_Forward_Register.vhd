LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY IF_ID_Forward_Register IS
	port(
		clk					: IN STD_LOGIC;
		Adder_Out	: IN STD_LOGIC_VECTOR(31 downto 0);
		Instruction_Out	: IN STD_LOGIC_VECTOR(31 downto 0);
		Adder_Out_Out	: OUT STD_LOGIC_VECTOR (31 downto 0);
		Instruction_Out_Out	: OUT STD_LOGIC_VECTOR(31 downto 0));
		
end IF_ID_Forward_Register;

Architecture behavioral of IF_ID_Forward_Register is
	begin
	process(clk)
	begin
		if(clk'EVENT and clk = '1') then
			Adder_Out_Out <= Adder_Out;
			Instruction_Out_Out <= Instruction_Out;
		end if;
	end process;
end behavioral;