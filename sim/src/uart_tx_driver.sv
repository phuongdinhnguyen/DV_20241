// UART TX Driver
class uart_tx_driver extends uvm_driver#(uart_tx_transaction);
  `uvm_component_utils(uart_tx_driver)

  uart_tx_transaction tx_item;
  uart_configuration  uart_cfg;
  virtual uart_intf   intf;

  int baud_rate;
  int clk_freq;
  int bit_period;
  bit parity_bit;
  real bit_dly;

  localparam UART_DATA_BIT_NUM_5 = 2'b00;
  localparam UART_DATA_BIT_NUM_6 = 2'b01;
  localparam UART_DATA_BIT_NUM_7 = 2'b10;
  localparam UART_DATA_BIT_NUM_8 = 2'b11;

  function new(string name="uart_tx_driver", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //intf = uart_cfg.intf;
    uart_cfg = new("uart_cfg");
    if (!uvm_config_db#(virtual uart_intf)::get(this, "*", "u_intf", intf)) begin
      `uvm_error("uart_tx", "Cannot get UART interface")
    end
  endfunction

  function int get_num_bit(logic [1:0] num_bit_coded);
    case (tx_item.data_bit_num)
      UART_DATA_BIT_NUM_5 : return 5;
      UART_DATA_BIT_NUM_6 : return 6;
      UART_DATA_BIT_NUM_7 : return 7;
      UART_DATA_BIT_NUM_8 : return 8;
      default : return 5;
    endcase
  endfunction

  task run_phase(uvm_phase phase);
    bit_period = 1000000000/uart_cfg.clock_freq;  // = 20ns: 10^-9 
    bit_dly    = (uart_cfg.clock_freq*1.0)/uart_cfg.baud_rate; // Divisor

    $display("UART DRIVER: bit_dly = %f", bit_dly);
    
    intf.tx <= 1'b1;
    @(negedge intf.reset_n); //1 -> 0
    @(posedge intf.reset_n); // 0 ->1
      
    forever begin
      seq_item_port.get_next_item(tx_item);  //blocking 
      parity_bit = 0;

      intf.data_bit_num <= tx_item.data_bit_num;
      intf.stop_bit_num <= tx_item.stop_bit_num;
      intf.parity_en    <= tx_item.parity_en;
      intf.parity_type  <= tx_item.parity_type;

      wait(intf.cts_n == 0);
      @(negedge intf.clk);

      `uvm_info("uart_tx", "Start UART TX transaction", UVM_MEDIUM)
      $display("[------------------------ DRIVER ------------------------]");

      tx_item.print_info();

      // Start bit
      intf.tx <= 1'b0;
      #(bit_dly*bit_period);

      // Data bit
      for (int i = 0; i < get_num_bit(tx_item.data_bit_num); i++) begin
        parity_bit = parity_bit ^ tx_item.tx_serial[i];  // XOR 
        intf.tx <= tx_item.tx_serial[i];
        $display("[%10t] [UART TX] Drive bit %0b", $time(), tx_item.tx_serial[i]);
        #(bit_dly*bit_period);
      end

      // Parity bit
      if (tx_item.parity_en == 1'b1) begin
        if (~tx_item.parity_type) begin
          intf.tx <= ~parity_bit;
          $display("[%10t] [UART TX] Drive odd parity_bit %0b", $time(), ~parity_bit);
        end
        else begin
          intf.tx <= parity_bit;
          $display("[%10t] [UART TX] Drive even parity_bit %0b", $time(), parity_bit);
        end
        #(bit_dly*bit_period);
      end

      // Stop bit
      intf.tx <= 1'b1;
      #(bit_dly*bit_period);
      if (tx_item.stop_bit_num == 1'b1) begin
        intf.tx <= 1'b1;
        #(bit_dly*bit_period);
      end
      `uvm_info("uart_tx", "Done rx transaction. Waiting for rx_done...", UVM_MEDIUM)

      wait(intf.rx_done);
      `uvm_info("uart_tx", "rx_done = 1", UVM_MEDIUM)
      `uvm_info("uart_tx", $sformatf("Data received: %8b", intf.rx_data), UVM_MEDIUM)
      $display("[---------------------- END DRIVER ----------------------]");
      seq_item_port.item_done();
    end

  endtask
endclass : uart_tx_driver