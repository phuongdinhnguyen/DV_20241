class uart_basic_test extends uart_base_test;
  `uvm_component_utils(uart_basic_test)

  uart_basic_tx_seq tx_seq = new("tx_seq");
  
  function new(string name="uart_basic_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uart_cfg.baud_rate  = 115200;
    uart_cfg.clock_freq = 50000000;
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
      tx_seq.start(env.agent.tx_sequencer);
    phase.drop_objection(this);
  endtask
endclass