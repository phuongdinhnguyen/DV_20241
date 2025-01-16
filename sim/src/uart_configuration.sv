// UART Configurations
class uart_configuration extends uvm_object;
  `uvm_object_utils(uart_configuration)

  virtual uart_intf intf;
  int baud_rate  = 115200;
  int clock_freq = 50000000;

  function new(string name="uart_configuration");
    super.new(name);
  endfunction
endclass