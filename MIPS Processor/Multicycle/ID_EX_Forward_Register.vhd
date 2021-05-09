LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY ID_EX_Forward_Register is
	port(
		clk		: IN STD_LOGIC;
		WB		: IN STD_LOGIC;
		Branch_ctl	: IN STD_LOGIC;
		Mem_Read	: IN STD_LOGIC;
		Mem_Write	: IN STD_LOGIC;
		RegDst	: IN STD_LOGIC;
		ALUOp	: IN STD_LOGIC_VECTOR(10 downto 0);
		ALUSrc	: IN STD_LOGIC;
		Adder_Out : IN STD_LOGIC_VECTOR(31 downto 0);
		Read_Data_1, Read_Data_2	: IN STD_LOGIC_VECTOR(31 downto 0);
		Signed_Extension	: IN STD_LOGIC_VECTOR(31 downto 0);
		Instruction_20_16, Instruction_15_11	: IN STD_LOGIC_VECTOR(4 downto 0);
		WB_Out	: OUT STD_LOGIC;
		Branch_ctl_out	: OUT STD_LOGIC;
		Mem_Read_out	: OUT STD_LOGIC;
		Mem_Write_out	: OUT STD_LOGIC;
		RegDst_Out	: OUT STD_LOGIC;
		ALUOp_Out	: OUT STD_LOGIC_VECTOR(10 downto 0);
		ALUSrc_Out	: OUT STD_LOGIC;
		Adder_Out_Out : OUT STD_LOGIC_VECTOR(31 downto 0);
		Read_Data_1_Out, Read_Data_2_Out	: OUT STD_LOGIC_VECTOR(31 downto 0);
		Signed_Extension_Out	: OUT STD_LOGIC_VECTOR(31 downto 0);
		Instruction_20_16_Out, Instruction_15_11_Out	: OUT STD_LOGIC_VECTOR(4 downto 0));
end ID_EX_Forward_Register;

Architecture behavioral of ID_EX_Forward_Register is
	begin
	process(clk)
	begin
		if(clk'EVENT and clk = '1') then
			WB_Out <= WB;
			
			Branch_ctl_out <= Branch_ctl;
			Mem_Read_out <= Mem_Read;
			Mem_Write_out <= Mem_Write;
			
			RegDst_Out <= RegDst;
			ALUOp_Out <= ALUOp;
			ALUSrc_Out <= ALUSrc;
			Adder_Out_Out <= Adder_Out;
			Read_Data_1_Out <= Read_Data_1;
			Read_Data_2_Out <= Read_Data_2;
			Signed_Extension_Out <= Signed_Extension;
			Instruction_20_16_Out <= Instruction_20_16;
			Instruction_15_11_Out <= Instruction_15_11;
		end if;
	end process;
end behavioral;