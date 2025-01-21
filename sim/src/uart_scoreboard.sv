// UART Scoreboard
class uart_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(uart_scoreboard)

  uart_configuration  uart_cfg;
  uart_tx_transaction tx_item;

  uvm_analysis_imp #(uart_tx_transaction, uart_scoreboard) uart_analysis_imp;

  function new(string name="uart_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uart_analysis_imp = new("uart_analysis_imp", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase

  function void write(uart_tx_transaction tx_item);
  // In thông tin transaction nhận được
    
    `uvm_info("uart_scoreboard", $sformatf("RECIEVED FROM MONITOR"), UVM_MEDIUM);
    $display("----------------------- SCOREBOARD -----------------------");
    tx_item.print_info();
    $display("----------------------------------------------------------");

  endfunction : write
endclass