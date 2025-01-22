// UART TX Transaction
class uart_tx_transaction extends uvm_sequence_item;
  `uvm_object_utils(uart_tx_transaction)

  rand logic [7:0] tx_serial;
  rand logic [1:0] data_bit_num;
  rand logic       stop_bit_num;
  rand logic       parity_en;
  rand logic       parity_type;

  localparam UART_DATA_BIT_NUM_5 = 2'b00;
  localparam UART_DATA_BIT_NUM_6 = 2'b01;
  localparam UART_DATA_BIT_NUM_7 = 2'b10;
  localparam UART_DATA_BIT_NUM_8 = 2'b11;

  // constraint default_transaction {
  //   soft data_bit_num == 2'b00;
  //   soft stop_bit_num == 1'b0;
  //   soft parity_en == 1'b1;
  //   soft parity_type == 1'b0;
  // }

  function new(string name="uart_tx_transaction");
    super.new(name);
  endfunction
  
  function void print_info();
    automatic int num_bit;
    // Parity bit
    case (data_bit_num)
      UART_DATA_BIT_NUM_5 : num_bit = 5;
      UART_DATA_BIT_NUM_6 : num_bit = 6;
      UART_DATA_BIT_NUM_7 : num_bit = 7;
      UART_DATA_BIT_NUM_8 : num_bit = 8;
      default : /* default */;
    endcase

    $write("TX serial: ");
    for (int i = num_bit - 1 ; i >= 0 ; i--)
      $write("%0b ", tx_serial[i]);
    $write("\n");

    $display("Data bit num = %2b", data_bit_num);
    $display("Stop bit num = %b", stop_bit_num);
    $display("Parity en    = %b", parity_en);
    $display("Parity type  = %b", parity_type);
  endfunction
endclass