//-------------------------------------------------------------------------
//            www.verificationguide.com
//-------------------------------------------------------------------------
//gets the packet from generator and drive the transaction paket items into interface (interface is connected to DUT, so the items driven into interface signal will get driven in to DUT) 

class driver;
  
  //used to count the number of transactions
  int no_transactions;
  
  //creating virtual interface handle
  virtual intf vif;
  
  //creating mailbox handle
  mailbox gen2driv;
  
  // UART related parameters
  int baud_rate = 115200;
  int clk_freq = 50000000;
  int bit_period;
  bit parity_bit;
  real bit_dly;
  
  localparam UART_DATA_BIT_NUM_5 = 2'b00;
  localparam UART_DATA_BIT_NUM_6 = 2'b01;
  localparam UART_DATA_BIT_NUM_7 = 2'b10;
  localparam UART_DATA_BIT_NUM_8 = 2'b11;
  
  //constructor
  function new(virtual intf vif,mailbox gen2driv);
    //getting the interface
    this.vif = vif;
    //getting the mailbox handles from  environment 
    this.gen2driv = gen2driv;
  endfunction
  
  //Reset task, Reset the Interface signals to default/initial values
  task reset;
    no_transactions = 0;
    vif.tx <= 1'b1;
    @(negedge vif.reset_n);
    $display("[ DRIVER ] ----- Reset Started -----");
    @(posedge vif.reset_n);
    $display("[ DRIVER ] ----- Reset Ended   -----");
    
    bit_period = 1000000000/clk_freq;
    bit_dly    = (clk_freq*1.0)/baud_rate;
  endtask
  
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
  
  //drivers the transaction items to interface signals
  task main;
    forever begin
      transaction tx_item;
      gen2driv.get(tx_item);
      $display("[%10t] [UART TX] ----- Getting new transaction -----", $time);

      tx_item.print_info();

      parity_bit = 0;
      vif.data_bit_num <= tx_item.data_bit_num;
      vif.stop_bit_num <= tx_item.stop_bit_num;
      vif.parity_en    <= tx_item.parity_en;
      vif.parity_type  <= tx_item.parity_type;
      
      wait(vif.cts_n == 0);
      @(negedge vif.clk);
      
      $display("[%10t] [UART TX] ----- Start UART TX transaction -----", $time);
      
      // Start bit
      vif.tx <= 1'b0;
      #(bit_dly*bit_period);

      // Data bit
      for (int i = 0; i < get_num_bit(tx_item.data_bit_num); i++) begin
        parity_bit = parity_bit ^ tx_item.tx_serial[i];
        vif.tx <= tx_item.tx_serial[i];
        $display("[%10t] [UART TX] Drive bit %0b", $time, tx_item.tx_serial[i]);
        #(bit_dly*bit_period);
      end

      // Parity bit
      if (tx_item.parity_en == 1'b1) begin
        if (~tx_item.parity_type) begin
          vif.tx <= parity_bit;
          $display("[%10t] [UART TX] Drive odd parity_bit %0b", $time, parity_bit);
        end
        else begin
          vif.tx <= ~parity_bit;
          $display("[%10t] [UART TX] Drive even parity_bit %0b", $time, ~parity_bit);
        end
        #(bit_dly*bit_period);
      end

      // Stop bit
      vif.tx <= 1'b1;
      #(bit_dly);
      if (tx_item.stop_bit_num == 1'b1) begin
        vif.tx <= 1'b1;
        #(bit_dly*bit_period);
      end
      $display("[%10t] [UART TX] Done rx transaction. Waiting for rx_done...", $time);

      wait(vif.rx_done);
      
      $display("[%10t] [UART TX] rx_done = 1", $time);
      $display("[%10t] [UART TX] Data received: %8b", $time, vif.rx_data);
      no_transactions++;
    end
  endtask
  
endclass