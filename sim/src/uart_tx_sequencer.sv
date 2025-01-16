// UART TX Sequencer
class uart_tx_sequencer extends uvm_sequencer#(uart_tx_transaction);
  `uvm_component_utils(uart_tx_sequencer)

  function new(string name="uart_tx_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction : new
endclass : uart_tx_sequencer