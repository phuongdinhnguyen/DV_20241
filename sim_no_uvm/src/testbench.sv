//-------------------------------------------------------------------------
//        www.verificationguide.com   testbench.sv
//-------------------------------------------------------------------------
//tbench_top or testbench top, this is the top most file, in which DUT(Design Under Test) and Verification environment are connected. 
//-------------------------------------------------------------------------
`timescale 1ns/1ps
//including interfcae and testcase files
`include "interface.sv"

//-------------------------[NOTE]---------------------------------
//Particular testcase can be run by uncommenting, and commenting the rest
`include "random_test.sv"
//`include "directed_test.sv"
//----------------------------------------------------------------

module tbench_top;  
  
  //creatinng instance of interface, inorder to connect DUT and testcase
  intf u_intf();
  
  //Testcase instance, interface handle is passed to test as an argument
  test t1(u_intf);
  
  //DUT instance, interface signals are connected to the DUT ports
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
  
  logic clk;
  logic reset_n;

  always #10ns clk = ~clk;

  assign u_intf.clk = clk;
  assign u_intf.reset_n = reset_n;
  
  initial begin
    $display("Start testbench");
    clk = 1;
    reset_n = 1;
    #20ns;
    reset_n = 0;
    #40ns;
    reset_n = 1;
  end
  
  initial begin
//    #10us;
//     $finish;
  end
  
  //enabling the wave dump
  initial begin 
    $dumpfile("dump.vcd"); $dumpvars;
  end
endmodule