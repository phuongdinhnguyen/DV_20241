// UART Basic sequence
class uart_basic_tx_seq extends uvm_sequence#(uart_tx_transaction);
  `uvm_object_utils(uart_basic_tx_seq)
  `uvm_declare_p_sequencer(uart_tx_sequencer)
  
  uart_tx_transaction item;
  
  function new(string name = "uart_basic_tx_seq");
    super.new(name);
    item = uart_tx_transaction::type_id::create("item");
  endfunction
  
  task body();
    // `uvm_do(item)
    // `uvm_do_with(item, {item.tx_serial== 8'b00001100;})
    #100ns;
    `uvm_do_with(item, {
        item.tx_serial== 8'b10110011;
        item.parity_en == 1'b1;
        item.parity_type == 1'b1;
        item.data_bit_num == 2'b11;
        item.stop_bit_num == 1'b0;
      })

    #300ns;
    `uvm_do_with(item, {
        item.tx_serial== 8'b11001100;
        item.parity_en == 1'b1;
        item.parity_type == 1'b0;
        item.data_bit_num == 2'b11;
        item.stop_bit_num == 1'b0;
      })
  endtask
endclass