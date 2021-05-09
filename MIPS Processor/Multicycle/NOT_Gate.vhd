LIBRARY ieee ;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY NOT_Gate is
	port(
		A	: IN STD_LOGIC;
		B	: OUT STD_LOGIC);
		
end NOT_Gate;

Architecture behavioral of NOT_Gate is
	begin
	process(A)
	begin
		B <= not A;
	end process;
end behavioral;