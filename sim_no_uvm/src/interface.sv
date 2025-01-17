//-------------------------------------------------------------------------
//            www.verificationguide.com
//-------------------------------------------------------------------------
interface intf();
  
  //declaring the signals
//   logic       valid;
//   logic [3:0] a;
//   logic [3:0] b;
//   logic [6:0] c;
  
  logic clk;
  logic reset_n;
  // Signals connecting betweem two UART
  logic tx;
  logic rx;
  logic cts_n;
  logic rts_n;

  // Signals controlling single UART function
  logic [7:0] tx_data;
  logic [1:0] data_bit_num;
  logic stop_bit_num;
  logic parity_en;
  logic parity_type;
  logic start_tx;
  logic rx_done;
  logic tx_done;
  logic [7:0] rx_data;
  logic parity_error;
  
endinterface