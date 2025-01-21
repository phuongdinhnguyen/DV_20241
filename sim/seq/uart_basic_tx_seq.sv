// UART Basic sequence
class uart_basic_tx_seq extends uvm_sequence#(uart_tx_transaction);
  `uvm_object_utils(uart_basic_tx_seq)
  `uvm_declare_p_sequencer(uart_tx_sequencer)
  
  uart_tx_transaction item;

  localparam UART_DATA_BIT_NUM_5 = 2'b00;
  localparam UART_DATA_BIT_NUM_6 = 2'b01;
  localparam UART_DATA_BIT_NUM_7 = 2'b10;
  localparam UART_DATA_BIT_NUM_8 = 2'b11;
  

  function new(string name = "uart_basic_tx_seq");
    super.new(name);
    item = uart_tx_transaction::type_id::create("item");
  endfunction
  
  task body();
    
    // `uvm_do_with(item, {item.tx_serial== 8'b00001100;})
    // #100ns;
    `uvm_do_with(item, {
        item.tx_serial== 8'b10110011;
        item.parity_en == 1'b1;
        item.parity_type == 1'b0;
        item.data_bit_num == UART_DATA_BIT_NUM_8;
        item.stop_bit_num == 1'b0;
      })
    for (int i = 0; i < 1000; i++) begin
      `uvm_do(item)
      #300ns; 
    end

    // #300ns;
    // `uvm_do_with(item, {
    //     item.tx_serial== 8'b11001100;
    //     item.parity_en == 1'b1;
    //     item.parity_type == 1'b0;
    //     item.data_bit_num == UART_DATA_BIT_NUM_8;
    //     item.stop_bit_num == 1'b0;
    //   })

  endtask
endclass