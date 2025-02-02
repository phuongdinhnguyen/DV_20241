// UART Monitor
class uart_monitor extends uvm_monitor;
  `uvm_component_utils(uart_monitor)

  uart_configuration  uart_cfg;
  virtual uart_intf   intf;
  uart_tx_transaction tx_item;

  bit capture_parity_error;
  bit capture_parity_bit;
  logic [7:0] rx_data;

  int baud_rate;
  int clk_freq;
  int bit_period;
  bit parity_bit;
  real bit_dly;

  uvm_analysis_port #(uart_tx_transaction) uart_tx_analysis_port;


  covergroup cg_uart();
    CVP_UART_DATA_BIT_NUM : coverpoint intf.data_bit_num {
      bins num_data_bit_5 = {2'b00};
      bins num_data_bit_6 = {2'b01};
      bins num_data_bit_7 = {2'b10};
      bins num_data_bit_8 = {2'b11};
    }
  endgroup : cg_uart


  function new(string name="uart_monitor", uvm_component parent);
    super.new(name, parent);
    cg_uart = new();
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uart_cfg = new("uart_cfg");
    uart_tx_analysis_port = new("uart_tx_analysis_port", this);

    if (!uvm_config_db#(virtual uart_intf)::get(this, "*", "u_intf", intf)) begin
      `uvm_error("uart_tx", "Cannot get UART interface")
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  localparam UART_DATA_BIT_NUM_5 = 2'b00;
  localparam UART_DATA_BIT_NUM_6 = 2'b01;
  localparam UART_DATA_BIT_NUM_7 = 2'b10;
  localparam UART_DATA_BIT_NUM_8 = 2'b11;

  // task: get number of data bits based on input code
  function int get_num_bit(logic [1:0] num_bit_coded);
    case (num_bit_coded)
      UART_DATA_BIT_NUM_5 : return 5;
      UART_DATA_BIT_NUM_6 : return 6;
      UART_DATA_BIT_NUM_7 : return 7;
      UART_DATA_BIT_NUM_8 : return 8;
      default : return 5;
    endcase
  endfunction

  task run_phase(uvm_phase phase);
    bit parity_cal = 0;

    bit_period = 1000000000/uart_cfg.clock_freq; // ns = 10^-9, = 20 ns
    bit_dly    = (uart_cfg.clock_freq*1.0)/uart_cfg.baud_rate; // divisor * 16

    tx_item = new("tx_item");

    @(negedge intf.reset_n); // 1 -> 0
    @(posedge intf.reset_n); // 0 -> 1

    forever begin
      // Detect Start bit
      @(negedge intf.tx);
      // $display("[%10t][Monitor] Start capturing data", $time());
      #(bit_dly*bit_period);

      cg_uart.sample();

      // Capture Data bit
      parity_cal = 0;
      
      tx_item.data_bit_num = intf.data_bit_num;
      tx_item.stop_bit_num = intf.stop_bit_num;
      tx_item.parity_en    = intf.parity_en;
      tx_item.parity_type  = intf.parity_type;

      #(bit_dly*bit_period/2); // UART: Sampling at 8th BCLK cycle
      for (int i = 0; i < get_num_bit(tx_item.data_bit_num); i++) begin
        // $display("[%10t][Monitor] Capture bit %0d", $time(), i);

        tx_item.tx_serial[i] = intf.tx;
        parity_cal = parity_cal ^ intf.tx;
        #(bit_dly*bit_period);
      end

      // Capture Parity bit
      // $display("[%10t][Monitor] Capture parity bit", $time());
      if (tx_item.parity_en) begin
        capture_parity_bit = intf.tx;
        #(bit_dly*bit_period);
      end

      // Capture Stop bit
      // Wait for rx_done
      wait(intf.rx_done);
      
      rx_data               = intf.rx_data;
      capture_parity_error  = intf.parity_error;

      // Check parity error
      if (tx_item.parity_en) begin
        if (capture_parity_bit == parity_cal || capture_parity_error) begin
          $display("[Monitor] Parity error.");
        end
      end
      
      $display("[Monitor] ------ Capture result ------");
      tx_item.print_info();
      $display("[Monitor] ----------------------------");
      // $display("[%10t][Monitor] Capture done", $time());
    end
  endtask
endclass : uart_monitor