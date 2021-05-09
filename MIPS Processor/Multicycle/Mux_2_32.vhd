LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;

entity Mux_2_32 is
	
	port(
		sel				: IN STD_LOGIC;
		Reg_Input		: IN STD_LOGIC_VECTOR(31 downto 0);
		Extension_Input : IN STD_LOGIC_VECTOR(31 downto 0);
		Output			: OUT STD_LOGIC_VECTOR(31 downto 0));
		
end Mux_2_32;

architecture Mux of Mux_2_32 is
	
	begin
	Output <= Reg_Input WHEN sel = '0' else	Extension_Input;
end Mux;