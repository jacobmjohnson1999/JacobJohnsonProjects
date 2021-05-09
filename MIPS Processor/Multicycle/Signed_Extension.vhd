LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;

entity Signed_Extension IS
	
	port(
		Num_In	: IN STD_LOGIC_VECTOR(15 downto 0);
		Num_Out	: OUT STD_LOGIC_VECTOR(31 downto 0));
		
end Signed_Extension;

ARCHITECTURE Sign_Ext of Signed_Extension IS
	
	begin
	process(Num_In)
	begin
		if (Num_In(15) = '1') then
			Num_Out <= "1111111111111111" & Num_In;
		ELSE
			Num_Out <= "0000000000000000" & Num_In;
		end if;
	end process;
end Sign_Ext;