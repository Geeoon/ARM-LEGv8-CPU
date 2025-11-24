/**
 * @file register.sv
 * @author Geeoon Chung
 * @author Anna Petrbokova
 * @brief a simple parameterized register made of D Flip Flops
 * @param WIDTH the width of the D and Q bus.  Defaults to 64
 * @input clk the clock driving the sequential logic
 * @input reset an active HIGH reset
 * @input en an active HIGH enable signal
 * @input d the input to the register
 * @output q the output of the register
 */ 
`timescale 1ns/10ps

module register #(
  parameter WIDTH=64
) (
  input   logic             clk,
  input   logic             reset,
  input   logic             en,
  input   logic [WIDTH-1:0] d,
  output  logic [WIDTH-1:0] q
);
  genvar i;
  generate
    for (i = 0; i < WIDTH; i++)
      begin : ffs
        logic in_ff;
        logic concatonated [0:1];
        assign concatonated[0] = q[i];
        assign concatonated[1] = d[i];
        
        multiplexer #(.SELECT_WIDTH(1), .DATA_WIDTH(1)) DQMux (.in(concatonated), .sel(en), .out(in_ff));
        D_FF FF (.q(q[i]), .d(in_ff), .reset, .clk);
      end  // ffs
  endgenerate
endmodule  // register
