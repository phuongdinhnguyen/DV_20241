// UART Monitor
class uart_monitor extends uvm_monitor;
  `uvm_component_utils(uart_monitor)

  uart_configuration  uart_cfg;
  virtual uart_intf   intf;
  uart_tx_transaction tx_item;

  bit capture_parity_error;
  bit capture_parity_bit;
  bit capture_rts_n;
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
      bins reset_low = {0};
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
    cvp_rts_n: coverpoint intf.cts_n;
    cvp_rx_done: coverpoint intf.rx_done;
    cvp_parity_error: coverpoint intf.parity_error {
      bins parity_error_occurred = {1'b1};
      bins no_parity_error = {1'b0};
    }

    cross cvp_parity_en, cvp_parity_type;
    cross cvp_data_bit_num, cvp_stop_bit_num;
    cross cvp_rts_n, cvp_rx_done {
      bins done = binsof(cvp_rts_n) &&
                binsof(cvp_rx_done) intersect {1'b1};
      ignore_bins hehe = binsof(cvp_rts_n) &&
                binsof(cvp_rx_done) intersect {1'b0};
    }
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
    uart_coverage.sample();
    @(posedge intf.reset_n); // 0 -> 1

    forever begin
      // Detect Start bit
      parity_cal = 0; // reset_parity_cal
      @(negedge intf.tx);
      #(bit_dly*bit_period);
      
      uart_coverage.sample();

      // Capture Data bit
      tx_item.data_bit_num = intf.data_bit_num;
      tx_item.stop_bit_num = intf.stop_bit_num;
      tx_item.parity_en    = intf.parity_en;
      tx_item.parity_type  = intf.parity_type;

      #((bit_dly*bit_period)/2.0);

      for (int i = 0; i < get_num_bit(tx_item.data_bit_num); i++) begin
        tx_item.tx_serial[i] = intf.tx;
        parity_cal = parity_cal ^ intf.tx;
        #(bit_dly*bit_period);
      end

      // Capture Parity bit
      if (tx_item.parity_en) begin
        if (~tx_item.parity_type) begin
          parity_cal = ~parity_cal;
        end 
        capture_parity_bit = intf.tx;
        #(bit_dly*bit_period);
      end

      wait(intf.rx_done);
      uart_coverage.sample();
      rx_data               = intf.rx_data;
      capture_parity_error  = intf.parity_error;
      capture_rts_n         = intf.rts_n;

      $display("[----------------------- MONITOR -----------------------]");
      //Check parity error
      if (tx_item.parity_en) begin
        if (capture_parity_bit != parity_cal || capture_parity_error) begin // capture_parity_error
          $display("[Monitor] capture_parity_bit: %b, parity_cal: %b, DUT_parity_err: %b", capture_parity_bit, parity_cal, capture_parity_error);
          $display("[Monitor] Parity error.");
        end else begin
          $display("[Monitor] capture_parity_bit: %b, parity_cal: %b, DUT_parity_err: %b", capture_parity_bit, parity_cal, capture_parity_error);
          $display("[Monitor] Parity OK.");
        end
      end else begin
        assert (capture_parity_error == 0) else begin
          $display("[Monitor] Assertion parity_disabled_check failed!");
        end
      end
      
      $display("[Monitor] -------------- Capture result --------------");

      tx_item.print_info();
      assert (tx_item.tx_serial == rx_data) begin
        $display("[Monitor] Data Driven: %8b, DUT Recieved: %8b", tx_item.tx_serial, rx_data);
      end else begin
        $display("[Monitor] Data error.");
        $display("[Monitor] Data Driven: %8b, DUT Recieved: %8b", tx_item.tx_serial, rx_data);
      end

      $display("[Monitor] --------------------------------------------");
      $display("[--------------------- END MONITOR ---------------------]");
      uart_tx_analysis_port.write(tx_item);
    end

  endtask
endclass : uart_monitor