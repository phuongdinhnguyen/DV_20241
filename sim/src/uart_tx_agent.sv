// UART TX Agent
class uart_tx_agent extends uvm_agent;
  `uvm_component_utils(uart_tx_agent)

  uart_monitor        monitor;
  uart_tx_driver      tx_driver;
  uart_tx_sequencer   tx_sequencer;
  uart_configuration  uart_cfg;

  function new(string name="uart_tx_agent", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor      = uart_monitor::type_id::create("monitor", this);
    tx_driver    = uart_tx_driver::type_id::create("tx_driver", this);
    tx_sequencer = uart_tx_sequencer::type_id::create("tx_sequencer", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    tx_driver.seq_item_port.connect(tx_sequencer.seq_item_export);
  endfunction
endclass