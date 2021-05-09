LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.Numeric_Std.all;

ENTITY Write_Register_Mux is
	port(
		Register_Destination_Select	: IN STD_LOGIC;
		I_Type						: IN STD_LOGIC_VECTOR(4 downto 0);
		R_Type						: IN STD_LOGIC_VECTOR(4 downto 0);
		Output						: OUT STD_LOGIC_VECTOR(4 downto 0));
		
end ENTITY;

Architecture behavioral of Write_Register_Mux is
	begin
	process(Register_Destination_Select, I_Type, R_Type)
	begin
		if(Register_Destination_Select = '0') then
			Output <= I_Type;
		else
			Output <= R_Type;
		end if;
	end process;
end behavioral;