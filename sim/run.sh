rm -rf work

vlog +incdir+./seq +incdir+./src +incdir+./test +incdir+../hdl uart_tb.sv

vsim -c uart_top_testbench -wlf vsim.wlf -do "add wave -r /*; run -all; quit" -voptargs=+acc