/**
 * @file multiplexer_tb.sv
 * @author Geeoon Chung
 * @author Anna Petrbokova
 * @brief comprehensively tests the multiplexer
 * @param SELECT_WIDTH the select bus width for the mux to test
 * @param DATA_WIDTH the width of the inputs and output of the mux to test
 */
`timescale 1ns/10ps

module multiplexer_tb #(
  parameter SELECT_WIDTH=5,
  parameter DATA_WIDTH=64
) ();
  logic [DATA_WIDTH-1:0]   in [0:(2**SELECT_WIDTH)-1];
  logic [SELECT_WIDTH-1:0] sel;
  logic [DATA_WIDTH-1:0]   out;
  
  multiplexer #(.SELECT_WIDTH(SELECT_WIDTH), .DATA_WIDTH(DATA_WIDTH)) dut (.in, .sel, .out);
  
  initial
    begin
      sel = 0;
      // initial input to a unique value
      for (int i = 0; i < 2**SELECT_WIDTH; i++)
        begin
          in[i] = i;
        end
      #1000;
      
      // try every select
      for (int i = 0; i < 2**SELECT_WIDTH; i++)
        begin
          sel = i; #1000;
          assert(out == i);
        end
      $stop();    
    end  // initial
endmodule  // multiplexer_tb
