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

  covergroup uart_coverage;
    cvp_reset_n: coverpoint intf.reset_n {
      bins reset_high = {1};
    }
    cvp_data_bit_num: coverpoint tx_item.data_bit_num {
      bins data_5bits = {2'b00};
      bins data_6bits = {2'b01};
      bins data_7bits = {2'b10};
      bins data_8bits = {2'b11};
    }
    cvp_stop_bit_num: coverpoint tx_item.stop_bit_num {
      bins one_stop_bit = {1'b0};
      bins two_stop_bits = {1'b1};
    }
    cvp_parity_en: coverpoint tx_item.parity_en {
      bins parity_disabled = {1'b0};
      bins parity_enabled = {1'b1};
    }
    cvp_parity_type: coverpoint tx_item.parity_type {
      bins even_parity = {1'b0};
      bins odd_parity = {1'b1};
    }
    // cvp_rts_n: coverpoint intf.rts_n {
    //   bins active = {1'b0};
    //   bins inactive = {1'b1};
    // }
    cvp_rx_done: coverpoint intf.rx_done;
    cvp_parity_error: coverpoint intf.parity_error {
      bins parity_error_occurred = {1'b1};
      bins no_parity_error = {1'b0};
    }

    cross cvp_parity_en, cvp_parity_type;
    cross cvp_data_bit_num, cvp_stop_bit_num;
    // cross cvp_rts_n, cvp_rx_done;
  endgroup

  function new(string name="uart_monitor", uvm_component parent);
    super.new(name, parent);
    uart_coverage = new();
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
      uart_coverage.sample();
      @(negedge intf.tx);
      #(bit_dly*bit_period);

      // Capture Data bit
      tx_item.data_bit_num = intf.data_bit_num;
      tx_item.stop_bit_num = intf.stop_bit_num;
      tx_item.parity_en    = intf.parity_en;
      tx_item.parity_type  = intf.parity_type;

      for (int i = get_num_bit(tx_item.data_bit_num) - 1; i >= 0 ; i--) begin
        tx_item.tx_serial[i] = intf.tx;
        parity_cal = parity_cal ^ intf.tx;
        #(bit_dly*bit_period);
      end

      // Capture Parity bit
      if (tx_item.parity_en) begin
        capture_parity_bit = intf.tx;
        #(bit_dly*bit_period);
      end

      // Capture Stop bit
      #(bit_dly*bit_period);

      if (tx_item.stop_bit_num == 1'b1)
        #(bit_dly*bit_period);

      wait(intf.rx_done);
      rx_data               = intf.rx_data;
      capture_parity_error  = intf.parity_error;

      $display("----------------------- MONITOR -----------------------");
      //Check parity error
      if (tx_item.parity_en) begin
        if (capture_parity_bit != parity_cal ) begin //|| capture_parity_error
          $display("[Monitor] capture_parity_bit: %b, parity_cal: %b", capture_parity_bit, parity_cal);
          $display("[Monitor] Parity error.");
        end else begin
          $display("[Monitor] capture_parity_bit: %b, parity_cal: %b", capture_parity_bit, parity_cal);
          $display("[Monitor] Parity OK .");
        end
      end
      
      $display("[Monitor] ------------ Capture result ------------");
      tx_item.print_info();
      $display("[Monitor] ----------------------------------------");

      uart_tx_analysis_port.write(tx_item);
    end

  endtask
endclass : uart_monitor