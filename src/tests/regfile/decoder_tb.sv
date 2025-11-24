/**
 * @file decoder_tb
 * @author Geeoon Chung
 * @author Anna Petrbokova
 * @brief comprehensively tests the decoder module
 * @param INPUT_WIDTH the width of the decoder input to test
 */
`timescale 1ns/10ps

module decoder_tb #(
  parameter INPUT_WIDTH=5
) ();
  // inputs
  logic                       en;
  logic [INPUT_WIDTH-1:0]     in;
  
  // outputs
  logic [2**INPUT_WIDTH-1:0]  out;
  
  decoder #(.INPUT_WIDTH(INPUT_WIDTH)) dut (.en, .in, .out);
  
  initial
    begin
      // check if all off when not enabled
      en = 0;
      for (int i = 0; i <= {INPUT_WIDTH{1'b1}}; i++) begin
        in = i; #150;
        // check if the only the correct bit is HIGH and the rest are LOW
        assert(out == 0);
      end
      
      // check behavior when enabled
      en = 1;
      for (int i = 0; i <= {INPUT_WIDTH{1'b1}}; i++) begin
        in = i; #150;
        // check if the only the correct bit is HIGH and the rest are LOW
        assert(out[i]);
        assert($onehot(out));
      end
      $stop();
    end  // initial
endmodule  // decoder_tb
