/**
 * @file multiplexer.sv
 * @author Geeoon Chung
 * @author Anna Petrbokova
 * @brief a parameterized multiplexer
 * @param SELECT_WIDTH the width of the select bus
 * @param DATA_WIDTH the width of input and output data
 * @input inputs to the mux
 * @input selects for the mux
 * @output out the selected input
 */
`timescale 1ns/10ps

module multiplexer #(
  parameter SELECT_WIDTH=5,
  parameter DATA_WIDTH=64
) (
  input  logic [DATA_WIDTH-1:0]   in [0:(2**SELECT_WIDTH)-1],
  input  logic [SELECT_WIDTH-1:0] sel,
  output logic [DATA_WIDTH-1:0]   out
);
  genvar j;
  generate
    if (SELECT_WIDTH == 1)
      begin : WIDTH_eq_1
        for (j = 0; j < DATA_WIDTH; j++)
          begin : bitwise_selects
            logic not_sel;
            logic i1_and_sel, i0_and_not_sel;
            
            not #(50) (not_sel, sel);
            
            and #(50) (i1_and_sel, in[1][j], sel);
            and #(50) (i0_and_not_sel, in[0][j], not_sel);
            
            or #(50) (out[j], i1_and_sel, i0_and_not_sel);
          end
       end  //WIDTH_eq_1
    else
      begin : WIDTH_gt_1
        logic [DATA_WIDTH-1:0] mux_1_out, mux_2_out;
        logic [DATA_WIDTH-1:0] mux_outs [0:1];
        assign mux_outs[0] = mux_1_out;
        assign mux_outs[1] = mux_2_out;
        multiplexer #(.SELECT_WIDTH(SELECT_WIDTH-1)) mux1 (.in(in[0:2**(SELECT_WIDTH-1)-1]), .sel(sel[SELECT_WIDTH-2:0]), .out(mux_1_out));
        multiplexer #(.SELECT_WIDTH(SELECT_WIDTH-1)) mux2 (.in(in[2**(SELECT_WIDTH-1):2**(SELECT_WIDTH)-1]), .sel(sel[SELECT_WIDTH-2:0]), .out(mux_2_out));
        multiplexer #(.SELECT_WIDTH(1))              mux3 (.in(mux_outs), .sel(sel[SELECT_WIDTH-1]), .out);
      end  //WIDTH_gt_1
    endgenerate
  
endmodule  // multiplexer
