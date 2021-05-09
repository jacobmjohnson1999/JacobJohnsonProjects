LIBRARY ieee ;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY Control_Unit is
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

end ENTITY;

Architecture behavioral of Control_Unit is	
	
	SIGNAL RegWriteBuffer	: STD_LOGIC := '0';
	
	begin
	process(Instruction)
	begin
		
		if(Instruction(31 downto 26) = "000000") then --Logic for R-type instructions
			RegDst <= '1';
			Branch <= '0';
			MemRead <= '0';
			MemtoReg <= '0';
			ALUOp <= Instruction(10 downto 0);
			MemWrite <= '0';
			ALUSrc <= '0';
			RegWriteBuffer <= '1';
		elsif(Instruction(31 downto 26) = "000100") then --Logic for branch on equal
			RegDst <= '0';
			Branch <= '1';
			MemRead <= '0';
			MemtoReg <= '0';
			ALUOp <= "00000000001";
			MemWrite <= '0';
			ALUSrc <= '0';
			RegWriteBuffer <= '0';
		elsif(Instruction(31 downto 26) = "011011") then --Logic for store word
			RegDst <= '0';
			Branch <= '0';
			MemRead <= '0';
			MemtoReg <= '0';
			ALUOp <= "00000010000";
			MemWrite <= '1';
			ALUSrc <= '1';
			RegWriteBuffer <= '0';
		else
			RegDst <= '0';
			Branch <= '0';
			MemRead <= '0';
			MemtoReg <= '0';
			ALUOp <= "00000000000";
			MemWrite <= '0';
			ALUSrc <= '0';
			RegWriteBuffer <= '0';
		end if;
		
		--Does logic for branch
		if(Branch_Buffer <= '0') then
			RegWrite <= RegWriteBuffer;
		else
			RegWrite <= '0';
		end if;
		
	end process;
	
end behavioral;