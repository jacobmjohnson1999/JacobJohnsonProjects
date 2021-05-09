LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY MEM_WB_Forward_Register is
	PORT(
		clk, WB						: IN STD_LOGIC;
		Read_Data, ALU_Out			: IN STD_LOGIC_VECTOR(31 downto 0);
		Register_Destination		: IN STD_LOGIC_VECTOR(4 downto 0);
		WB_Out						: OUT STD_LOGIC;
		Read_Data_Out, ALU_Out_Out	: OUT STD_LOGIC_VECTOR(31 downto 0);
		Register_Destination_Out	: OUT STD_LOGIC_VECTOR(4 downto 0));
end MEM_WB_Forward_Register;

Architecture behavioral of MEM_WB_Forward_Register is
	begin
	process(clk)
	begin
		if(clk'EVENT and clk = '1') then
			WB_Out <= WB;
			Read_Data_Out <= Read_Data;
			ALU_Out_Out <= ALU_Out;
			Register_Destination_Out <= Register_Destination;
		end if;
	end process;
end behavioral;