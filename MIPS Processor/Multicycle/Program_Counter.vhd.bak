LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;

ENTITY Program_Counter IS
	
	GENERIC(
		size : INTEGER := 32);
	
	PORT(
		clk			:	IN STD_LOGIC;
		Address_In	:	IN STD_LOGIC_VECTOR(size-1 downto 0) := (OTHERS => '0');
		Address_Out	:	OUT STD_LOGIC_VECTOR(size-1 downto 0) := (OTHERS => '0'));
	
END Program_Counter;

ARCHITECTURE behavioral of Program_Counter IS
		
	begin
	
	process(clk)
	begin
		if (clk'event and clk = '1') then
			--Sets current PC to what is on the input
			Address_Out <= Address_In;
		end if;
	end process;
end behavioral;