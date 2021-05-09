Unfortunatly, I was unable to get the testbench to work the way it was intended. Because of this, the method for testing is the following:
1. Compile in quartus.
2. Run RTL simulation.
3. Start simulation -> top level.
4. Choose waveforms you wish to see -> add wave.
5. Delcare Global_Clock as a clock with default settings.
6. Click run for as many cycles as you want.