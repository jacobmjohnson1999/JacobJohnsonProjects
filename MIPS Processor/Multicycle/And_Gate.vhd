LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE ieee.std_logic_unsigned.all ;

ENTITY And_Gate is
	port(
		A		: IN STD_LOGIC;
		B		: IN STD_LOGIC;
		C		: OUT STD_LOGIC);
		
end And_Gate;

Architecture And_It of And_Gate is
	begin
	process(A,B)
	begin
		C <= A and B;
	end process;
	
end And_It;