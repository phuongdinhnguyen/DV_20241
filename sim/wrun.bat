

vlog +incdir+./seq +incdir+./src +incdir+./test +incdir+../hdl +cover=bcefs -nocoverfec uart_tb.sv

vsim -c uart_top_testbench -wlf vsim.wlf -voptargs=+acc -sva -assertdebug -fsmdebug -coverage -do "coverage save -onexit -code bcefs -directive -assert -cvg ucdb/coverage.ucdb; add wave -r /*; run -all; quit" 
