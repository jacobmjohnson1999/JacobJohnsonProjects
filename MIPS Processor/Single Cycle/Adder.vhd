LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY Adder IS
	
	GENERIC(
		size : INTEGER := 32;
		numToAdd : INTEGER := 1);
	
	PORT(
		Address_In	:	IN STD_LOGIC_VECTOR(size-1 downto 0);
		Address_Out	:	OUT STD_LOGIC_VECTOR(size-1 downto 0));
	
end Adder;

Architecture behavioral of Adder IS
	
	begin
	process(Address_In)
	begin
		Address_Out <= std_logic_vector(to_unsigned(to_integer(unsigned(Address_In))+numToAdd, size));
	end process;
end behavioral;