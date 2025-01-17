vlog ../hdl/uart.sv

vlog +incdir+./src ./src/testbench.sv

vsim -c tbench_top -wlf vsim.wlf -do "add wave -r /*; run -all; quit" -voptargs=+acc