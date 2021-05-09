LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY Top_Level IS
	
	GENERIC(
		size : INTEGER := 32);
	
	PORT(
		Global_Clock	: IN STD_LOGIC);
END Top_Level;

ARCHITECTURE structural of Top_Level is
	
	--Components
	COMPONENT Program_Counter is
		GENERIC(
			size : INTEGER := 32);
		PORT(
		clk			:	IN STD_LOGIC;
		Address_In	:	IN STD_LOGIC_VECTOR(size-1 downto 0) := (OTHERS => '0');
		Address_Out	:	OUT STD_LOGIC_VECTOR(size-1 downto 0) := (OTHERS => '0'));
	end COMPONENT;
	
	
	
	COMPONENT Adder is
		GENERIC(
			size : INTEGER := 32);
		PORT(
		Address_In	:	IN STD_LOGIC_VECTOR(size-1 downto 0);
		Address_Out	:	OUT STD_LOGIC_VECTOR(size-1 downto 0));
	end COMPONENT;
	
	COMPONENT IP_Memory is
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			clock		: IN STD_LOGIC  := '1';
			data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			rden		: IN STD_LOGIC  := '1';
			wren		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	end COMPONENT;
	
	COMPONENT Mux_2_32 is
	
		port(
			sel				: IN STD_LOGIC;
			Reg_Input		: IN STD_LOGIC_VECTOR(31 downto 0);
			Extension_Input : IN STD_LOGIC_VECTOR(31 downto 0);
			Output			: OUT STD_LOGIC_VECTOR(31 downto 0));
			
	end COMPONENT;
	
	COMPONENT alu_1 is

		port(
			s		: IN STD_LOGIC_VECTOR(2 downto 0);
			A,B		: IN STD_LOGIC_VECTOR(31 downto 0);
			F		: Buffer STD_LOGIC_VECTOR(31 downto 0);
			Compare : OUT STD_LOGIC);

	end COMPONENT;
	
	COMPONENT Registers is
		
		port(
			clk									: IN STD_LOGIC;
			Write_en							: IN STD_LOGIC;
			Read_en								: IN STD_LOGIC;
			Read_reg_1, Read_reg_2, Write_reg	: IN STD_LOGIC_VECTOR(4 downto 0);
			Write_data							: IN STD_LOGIC_VECTOR(31 downto 0);
			Read_data_1, Read_data_2			: OUT STD_LOGIC_VECTOR(31 downto 0));
			
	end COMPONENT;
	
	COMPONENT Signed_Extension IS
	
		port(
			Num_In	: IN STD_LOGIC_VECTOR(15 downto 0);
			Num_Out	: OUT STD_LOGIC_VECTOR(31 downto 0));
			
	end COMPONENT;
	
	COMPONENT ALU_Control_Unit is
		PORT(ALUOp		: IN STD_LOGIC_VECTOR(10 downto 0);
			S			: OUT STD_LOGIC_VECTOR(2 downto 0));
	end COMPONENT;
	
	COMPONENT Shift_Left_MIPS is
		port(
			Unshifted_vector	: IN STD_LOGIC_VECTOR(31 downto 0);
			Shifted_vector		: OUT STD_LOGIC_VECTOR(31 downto 0));
			
	end COMPONENT;
	
	COMPONENT Write_Register_Mux is
		port(
			Register_Destination_Select	: IN STD_LOGIC;
			I_Type						: IN STD_LOGIC_VECTOR(4 downto 0);
			R_Type						: IN STD_LOGIC_VECTOR(4 downto 0);
			Output						: OUT STD_LOGIC_VECTOR(4 downto 0));
			
	end COMPONENT;
	
	COMPONENT Adder_32_32 is
		port(
			Shift_Left_In		: IN STD_LOGIC_VECTOR(31 downto 0);
			PC_Adder_In			: IN STD_LOGIC_VECTOR(31 downto 0);
			Branch_Address		: OUT STD_LOGIC_VECTOR(31 downto 0));
			
	end COMPONENT;
	
	COMPONENT Control_Unit is
		PORT(
			Instruction		: IN STD_LOGIC_VECTOR(31 downto 0);
			Branch_Buffer	: IN STD_LOGIC;
			RegDst			: OUT STD_LOGIC;
			Branch			: OUT STD_LOGIC;
			MemRead			: OUT STD_LOGIC;
			MemtoReg		: OUT STD_LOGIC;
			ALUOp			: OUT STD_LOGIC_VECTOR(10 downto 0);
			MemWrite		: OUT STD_LOGIC;
			ALUSrc			: OUT STD_LOGIC;
			RegWrite		: OUT STD_LOGIC);

	end COMPONENT;
	
	COMPONENT And_Gate is
		port(
			A		: IN STD_LOGIC;
			B		: IN STD_LOGIC;
			C		: OUT STD_LOGIC);
			
	end COMPONENT;
	
	COMPONENT Memory is
		GENERIC(
				Memory_Size	: INTEGER := 200);
		PORT(
			clk			: IN STD_LOGIC;
			Address		: IN STD_LOGIC_VECTOR(31 downto 0);
			Data_In		: IN STD_LOGIC_VECTOR(31 downto 0);
			Write_En	: IN STD_LOGIC;
			Read_En		: IN STD_LOGIC;
			Data_Out	: OUT STD_LOGIC_VECTOR(31 downto 0));
			
	end COMPONENT;
	
	COMPONENT NOT_Gate is
		port(
			A	: IN STD_LOGIC;
			B	: OUT STD_LOGIC);
			
	end COMPONENT;
	
	--Signals
	SIGNAL Adder_Out	: STD_LOGIC_VECTOR(size-1 downto 0) := "00000000000000000000000000000000";
	SIGNAL PC_Address_Out	: STD_LOGIC_VECTOR(size-1 downto 0) := "00000000000000000000000000000000";
	SIGNAL Register_Output_2, Signed_Extension_Output, ALU_In_2, ALU_In_1 : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL ALU_Out, Branch_Mux_1		: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL Instruction_Out_Of_Fetch		: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL ALU_Operation				: STD_LOGIC_VECTOR(2 downto 0);
	SIGNAL Adder_2_In					: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL Write_Register				: STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL PC_Address_In				: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL ALUOp						: STD_LOGIC_VECTOR(10 downto 0);
	SIGNAL RegDst, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite	: STD_LOGIC; -- Control unit signals
	SIGNAL Branch_Control				: STD_LOGIC;
	SIGNAL ALU_Zero						: STD_LOGIC;
	SIGNAL Read_Data, Write_Data		: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL NOT_Branch_Control			: STD_LOGIC := '1';
	
	begin
	--Connect components here
	U0: Adder port map(PC_Address_Out, Adder_Out);
	U1: Program_Counter port map(Global_Clock, PC_Address_In, PC_Address_Out);
	U2: IP_Memory port map(PC_Address_Out(7 downto 0), Global_Clock, x"00000000", '1', '0', Instruction_Out_Of_Fetch);
	U3: Mux_2_32 port map(ALUSrc, Register_Output_2, Signed_Extension_Output, ALU_In_2);
	U4: alu_1 port map(ALU_Operation, ALU_In_1, ALU_In_2, ALU_Out, ALU_Zero);
	U5: Registers port map(Global_Clock, RegWrite, NOT_Branch_Control, Instruction_Out_Of_Fetch(25 downto 21), Instruction_Out_Of_Fetch(20 downto 16), Write_Register, Write_Data, ALU_In_1, Register_Output_2);
	U6: ALU_Control_Unit port map(ALUOp, ALU_Operation);
	U7: Signed_Extension port map(Instruction_Out_Of_Fetch(15 downto 0), Signed_Extension_Output);
	U8: Shift_Left_MIPS port map(Signed_Extension_Output, Adder_2_In);
	U9: Write_Register_Mux port map(RegDst, Instruction_Out_Of_Fetch(20 downto 16), Instruction_Out_Of_Fetch(15 downto 11), Write_Register);
	U10: Adder_32_32 port map(Adder_2_In, Adder_Out, Branch_Mux_1);
	U11: Mux_2_32 port map(Branch_Control, Adder_Out, Branch_Mux_1, PC_Address_In);
	U12: Control_Unit port map(Instruction_Out_Of_Fetch(31 downto 0), Branch_Control, RegDst, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite);
	U13: And_Gate port map(Branch, ALU_Zero, Branch_Control);
	U14: Memory port map(Global_Clock, ALU_Out, Register_Output_2, MemWrite, MemRead, Read_Data);
	U15: Mux_2_32 port map(MemtoReg, ALU_Out, Read_Data, Write_Data);
	U16: NOT_Gate port map(Branch_Control, NOT_Branch_Control);
	
	
end structural;