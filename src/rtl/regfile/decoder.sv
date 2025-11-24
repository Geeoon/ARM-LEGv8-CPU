/**
 * @file    decoder.sv
 * @author  Geeoon Chung
 * @author  Anna Petrbokova
 * @brief   a simple parameterized decoder
 * @param   INPUT_WIDTH the width of the binary input.  Defaults to 5
 * @input   en an active HIGH enable
 * @input   in the input to decode
 * @output  out the output of the decoder
 */
`timescale 1ns/10ps

module decoder #(
  parameter INPUT_WIDTH=5
) (
  input   logic                         en,
  input   logic [INPUT_WIDTH-1:0]       in,
  output  logic [(2**INPUT_WIDTH)-1:0]  out
);
  // signals
  logic not_in, en_and_not_in, en_and_in;
  
  // gates
  not #(50) (not_in, in[INPUT_WIDTH-1]);
  and #(50) (en_and_not_in, en, not_in);
  and #(50) (en_and_in, en, in[INPUT_WIDTH-1]);
  
  generate
    if (INPUT_WIDTH == 1)
      begin : WIDTH_eq_1
        assign out[0] = en_and_not_in;
        assign out[1] = en_and_in;
      end  // WIDTH_eq_1
    else
      begin : WIDTH_gt_1
        decoder #(.INPUT_WIDTH(INPUT_WIDTH-1)) decoder_1 (.en(en_and_not_in), .in(in[INPUT_WIDTH-2:0]), .out(out[(2**(INPUT_WIDTH-1))-1:0]));
        decoder #(.INPUT_WIDTH(INPUT_WIDTH-1)) decoder_2 (.en(en_and_in), .in(in[INPUT_WIDTH-2:0]), .out(out[(2**INPUT_WIDTH)-1:2**(INPUT_WIDTH-1)]));
      end  // WIDTH_gt_1
  endgenerate

endmodule  // decoder
