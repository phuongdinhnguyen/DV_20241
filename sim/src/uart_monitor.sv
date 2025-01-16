// UART Monitor
class uart_monitor extends uvm_monitor;
  `uvm_component_utils(uart_monitor)

  uart_configuration uart_cfg;

  uvm_analysis_port #(uart_tx_transaction) uart_tx_analysis_port;

  function new(string name="uart_monitor", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uart_tx_analysis_port = new("uart_tx_analysis_port", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  task run_phase(uvm_phase phase);
  endtask
endclass : uart_monitor