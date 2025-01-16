// UART Base Test
class uart_base_test extends uvm_test;
  `uvm_component_utils(uart_base_test)

  uart_configuration  uart_cfg;
  uart_env            env;
  virtual uart_intf   intf;

  function new(string name="uart_base_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("uart_tx", "TEST buid_phase", UVM_MEDIUM)
    env      = uart_env::type_id::create("env", this);
    uart_cfg = uart_configuration::type_id::create("uart_cfg");

    uvm_config_db#(uart_configuration)::set(this, "*", "uart_cfg", uart_cfg);
  endfunction
endclass