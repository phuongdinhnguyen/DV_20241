// Interface
interface uart_intf;
  logic clk;
  logic reset_n;
  logic rx;
  logic cts_n;
  logic [7:0] tx_data;
  logic [1:0] data_bit_num;
  logic stop_bit_num;
  logic parity_en;
  logic parity_type;
  logic start_tx;

  logic tx;
  logic rts_n;
  logic rx_done;
  logic tx_done;
  logic [7:0] rx_data;
  logic parity_error;
endinterface : uart_intf