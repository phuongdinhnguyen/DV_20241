// UART Environment
class uart_env extends uvm_env;
  `uvm_component_utils(uart_env)

  uart_tx_agent       agent;
  uart_scoreboard     scoreboard;
  uart_configuration  uart_cfg;

  function new(string name="uart_env", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("uart_tx", "ENV buid_phase", UVM_MEDIUM)
    agent       = uart_tx_agent::type_id::create("agent", this);
    scoreboard  = uart_scoreboard::type_id::create("scoreboard", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.monitor.uart_tx_analysis_port.connect(scoreboard.uart_analysis_imp);
  endfunction
endclass