entity proj4 is
	port(analogVal : in STD_LOGIC);
end proj4;

architecture behav of proj4 is
	
	--Insert game code here

	process(analogVal)
	
	#Yet to be determined
	variable maxVal := 10;
	variable halfVal := maxVal / 2;
	begin
		if analogVal > halfVal then
			--Move right/left
		else
			--Move left/right
		end if;
	end process;
end architecture;