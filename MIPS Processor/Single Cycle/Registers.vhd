LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.Numeric_Std.all;

entity Registers is
	
	port(
		clk									: IN STD_LOGIC;
		Write_en							: IN STD_LOGIC;
		Read_en								: IN STD_LOGIC;
		Read_reg_1, Read_reg_2				: IN STD_LOGIC_VECTOR(4 downto 0);
		Write_reg							: IN STD_LOGIC_VECTOR(4 downto 0);
		Write_data							: IN STD_LOGIC_VECTOR(31 downto 0);
		Read_data_1, Read_data_2			: OUT STD_LOGIC_VECTOR(31 downto 0));
		
end Registers;

architecture Reg_Function of Registers is

	--Creates a matrix type which is an integer indexed array of STD_LOGIC_VECTOR(31 downto 0)
	TYPE matrix is array(0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL Registers : matrix := (8 => ("00000000000000000000000000000011"), --$t0 = 3
								9 => ("00000000000000000000000000000011"), --$t1 = 3
								10 => ("00000000000000000000000000000011"), --$t2 = 4
								16 => ("00000000000000000000000000001010"), --$s0 = 10
								17 => ("00000000000000000000000000001000"), --$s1 = 8
								18 => ("00000000000000000000000000001000"), --$s2 = 0
								others => (others => '0'));
		
	begin
	--Does logic for the write portion of the register
	process(Write_en, clk)
	begin
		if(Write_en = '1' and clk = '0') then
			Registers(to_integer(unsigned(Write_reg))) <= Write_data;
		end if;
	end process;
	
	--Does logic for the read portion of the register
	process(Read_reg_1, Read_reg_2, Read_en)
	begin
		if(Read_en = '1') then
			Read_data_1 <= Registers(to_integer(unsigned(Read_reg_1)));
			Read_data_2 <= Registers(to_integer(unsigned(Read_reg_2)));
		-- else
			-- Read_data_1 <= "00000000000000000000000000000000";
			-- Read_data_2 <= "00000000000000000000000000000000";
		end if;
	end process;
	
end Reg_Function;