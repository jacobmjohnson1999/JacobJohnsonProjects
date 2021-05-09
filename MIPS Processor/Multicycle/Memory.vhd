LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.Numeric_Std.all;

ENTITY Memory is
	GENERIC(
			Memory_Size	: INTEGER := 200);
	PORT(
		clk			: IN STD_LOGIC;
		Address		: IN STD_LOGIC_VECTOR(31 downto 0);
		Data_In		: IN STD_LOGIC_VECTOR(31 downto 0);
		Write_En	: IN STD_LOGIC;
		Read_En		: IN STD_LOGIC;
		Data_Out	: OUT STD_LOGIC_VECTOR(31 downto 0));
		
end ENTITY;

architecture behavioral of Memory is

	--Creates a matrix type which is an integer indexed array of STD_LOGIC_VECTOR(31 downto 0)
	TYPE Memory is array(0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL myMemory : Memory := (others => (others => '0'));
		
	begin
	--Does logic for the write portion of the register
	process(Write_en, clk)
	begin
		if(clk'EVENT and clk = '1') then
			if(Write_En = '1') then
				myMemory(to_integer(unsigned(Address))) <= Data_In;
			end if;
		end if;
	end process;
	
	--Does logic for the read portion of the register
	process(address, Read_En)
	begin
		if(Read_En = '1') then
			Data_Out <= myMemory(to_integer(unsigned(address)));
		end if;
	end process;
	
end behavioral;