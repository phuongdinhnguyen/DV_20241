// `include "uvm.sv"

`timescale 1ns/1ps
`include "uart.sv"
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uart_intf.sv"
`include "uart_configuration.sv"
`include "uart_tx_transaction.sv"
`include "uart_tx_sequencer.sv"
`include "uart_tx_driver.sv"
`include "uart_monitor.sv"
`include "uart_tx_agent.sv"
`include "uart_scoreboard.sv"
`include "uart_env.sv"
`include "uart_base_test.sv"

`include "uart_basic_tx_seq.sv"
`include "uart_basic_test.sv"

module uart_top_testbench;
  uart_intf u_intf();
  
  uart uart_0(
     .clk         (u_intf.clk)
    ,.reset_n     (u_intf.reset_n)
    ,.rx          (u_intf.tx)
    ,.cts_n       ('0)
    ,.tx          (u_intf.rx)
    ,.rts_n       (u_intf.cts_n)
    ,.tx_data     ('0)
    ,.data_bit_num(u_intf.data_bit_num)
    ,.stop_bit_num(u_intf.stop_bit_num)
    ,.parity_en   (u_intf.parity_en)
    ,.parity_type (u_intf.parity_type)
    ,.start_tx    ('0)
    ,.rx_data     (u_intf.rx_data)
    ,.tx_done     (u_intf.tx_done)
    ,.rx_done     (u_intf.rx_done)
    ,.parity_error(u_intf.parity_error)
  );

  timeunit 1ns;
  timeprecision 1ns;

  logic clk;
  logic reset_n;

  always #10ns clk = ~clk;

  assign u_intf.clk = clk;
  assign u_intf.reset_n = reset_n;

  initial begin
    clk = 1;
    reset_n = 1;
    #20ns;
    reset_n = 0;
    #40ns;
    reset_n = 1;
  end

  initial begin
    $display("Start UART testbench");
    uvm_config_db#(virtual uart_intf)::set(uvm_root::get(),"","u_intf", u_intf);

    run_test("uart_basic_test");
    #10us;
    $finish;
  end
endmodule : uart_top_testbench