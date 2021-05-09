This project's intetion is to create a MIPS architecture in VHDL for use with a DE10 FPGA.
The project was split into 3 phases and has a report on each phase inside the corrosponding foler. 
To run, quartus prime lite is used to compile and modelsim is used to test the functioality.

The project was assigned as part of ECE 4120 at Tennessee Technological University. The professor is Dr. Syed Rafay Hasan.

Unfortunatly, I was unable to get the testbench to work the way it was intended. Because of this, the method for testing is the following:
1. Compile in quartus.
2. Run RTL simulation.
3. Start simulation -> top level.
4. Choose waveforms you wish to see -> add wave.
5. Delcare Global_Clock as a clock with default settings.
6. Click run for as many cycles as you want.