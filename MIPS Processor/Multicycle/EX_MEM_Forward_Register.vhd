LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY EX_MEM_Forward_Register is
	PORT(
		clk										: IN STD_LOGIC;
		WB, Branch, MemRead, MemWrite, ALU_Zero							: IN STD_LOGIC;
		Branch_Adder_Out, ALU_Out, Read_Data_2	: IN STD_LOGIC_VECTOR(31 downto 0);
		Destination_Register				: IN STD_LOGIC_VECTOR(4 downto 0);
		WB_Out, Branch_Out, MemRead_Out, MemWrite_Out, ALU_Zero_Out				: OUT STD_LOGIC;
		Branch_Adder_Out_Out, ALU_Out_Out, Read_Data_2_Out	: OUT STD_LOGIC_VECTOR(31 downto 0);
		Destination_Register_Out					: OUT STD_LOGIC_VECTOR(4 downto 0));
end EX_MEM_Forward_Register;

Architecture behaviorlal of EX_MEM_Forward_Register is
	begin
	process(clk)
	begin
		if(clk'EVENT and clk = '1') then
			WB_Out <= WB;
			Branch_Out<= Branch;
			MemRead_Out <= MemRead;
			MemWrite_Out <= MemWrite;
			ALU_Zero_Out <= ALU_Zero;
			Branch_Adder_Out_Out <= Branch_Adder_Out;
			ALU_Out_Out <= ALU_Out;
			Read_Data_2_Out <= Read_Data_2;
			Destination_Register_Out <= Destination_Register;
		end if;
	end process;
end behaviorlal;