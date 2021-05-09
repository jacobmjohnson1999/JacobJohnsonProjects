LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.Numeric_Std.all;

Entity Shift_Left_MIPS is
	port(
		Unshifted_vector	: IN STD_LOGIC_VECTOR(31 downto 0);
		Shifted_vector		: OUT STD_LOGIC_VECTOR(31 downto 0) := (others => '0'));
		
end Entity;

Architecture behavioral of Shift_Left_MIPS is
	begin
	process(Unshifted_vector)
	begin
		Shifted_vector <= STD_LOGIC_VECTOR(shift_left(unsigned(Unshifted_vector), 0));
	end process;
	
end behavioral;