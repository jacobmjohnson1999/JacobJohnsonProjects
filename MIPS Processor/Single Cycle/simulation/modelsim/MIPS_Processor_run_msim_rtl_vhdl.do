transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/Users/acure/Desktop/Computer Design Project/Single Cycle/Memory.vhd}
vcom -93 -work work {C:/Users/acure/Desktop/Computer Design Project/Single Cycle/ALU_Control_Unit.vhd}
vcom -93 -work work {C:/Users/acure/Desktop/Computer Design Project/Single Cycle/Control_Unit.vhd}
vcom -93 -work work {C:/Users/acure/Desktop/Computer Design Project/Single Cycle/And_Gate.vhd}
vcom -93 -work work {C:/Users/acure/Desktop/Computer Design Project/Single Cycle/Adder_32_32.vhd}
vcom -93 -work work {C:/Users/acure/Desktop/Computer Design Project/Single Cycle/Mux_2_32.vhd}
vcom -93 -work work {C:/Users/acure/Desktop/Computer Design Project/Single Cycle/Wriite_Register_Mux.vhd}
vcom -93 -work work {C:/Users/acure/Desktop/Computer Design Project/Single Cycle/Shift_Left.vhd}
vcom -93 -work work {C:/Users/acure/Desktop/Computer Design Project/Single Cycle/Registers.vhd}
vcom -93 -work work {C:/Users/acure/Desktop/Computer Design Project/Single Cycle/ALU.vhd}
vcom -93 -work work {C:/Users/acure/Desktop/Computer Design Project/Single Cycle/Signed_Extension.vhd}
vcom -93 -work work {C:/Users/acure/Desktop/Computer Design Project/Single Cycle/Top_Level.vhd}
vcom -93 -work work {C:/Users/acure/Desktop/Computer Design Project/Single Cycle/Program_Counter.vhd}
vcom -93 -work work {C:/Users/acure/Desktop/Computer Design Project/Single Cycle/Adder.vhd}
vcom -93 -work work {C:/Users/acure/Desktop/Computer Design Project/Single Cycle/IP_Memory.vhd}
vcom -93 -work work {C:/Users/acure/Desktop/Computer Design Project/Single Cycle/not_gate.vhd}

