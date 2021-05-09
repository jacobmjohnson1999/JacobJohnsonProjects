LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY Adder_32_32 is
	port(
		Shift_Left_In		: IN STD_LOGIC_VECTOR(31 downto 0);
		PC_Adder_In			: IN STD_LOGIC_VECTOR(31 downto 0);
		Branch_Address		: OUT STD_LOGIC_VECTOR(31 downto 0));
		
end Adder_32_32;

Architecture Adder of Adder_32_32 is
	
	SIGNAL Addition : unsigned(31 downto 0);
	
	begin
	process(Shift_Left_In, PC_Adder_In)
	begin
		Branch_Address <= STD_LOGIC_VECTOR(signed(Shift_Left_In) + signed(PC_Adder_In));
	end process;
end Adder;