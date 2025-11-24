/**
 * @file alu_zero.sv
 * @author Geeoon Chung
 * @author Anna Petrbokova
 * @brief determines if the input is all zeros
 * @param WIDTH the width of the input data bus
 * @input A the signal to check
 * @output is_zero HIGH if the signal is all zeros
 */
`timescale 1ns/10ps

module alu_zero #(
  parameter DATA_WIDTH=64
) (
  input   logic [DATA_WIDTH-1:0]  A,
  output  logic                   is_zero
);
  genvar i;
  generate
    if (DATA_WIDTH == 1)
      begin  // base case
        not #(50) (is_zero, A[0]);
      end
    else
      begin
        logic [(DATA_WIDTH-1)/4:0] zeros;
        for (i = 0; i < DATA_WIDTH; i += 4)
          begin : nors
            if ((DATA_WIDTH-1 - i) == 0)  // it's by itself
              begin
                assign zeros[i/4] = A[i];
              end
            else if ((DATA_WIDTH-1 - i) == 1)  // with another
              begin
                or #(50) (zeros[i/4], A[i], A[i+1]);
              end
            else if ((DATA_WIDTH-1 - i) == 2)  // with two others
              begin
                or #(50) (zeros[i/4], A[i], A[i+1], A[i+2]);
              end
            else  // full nor
              begin
                or #(50) (zeros[i/4], A[i], A[i+1], A[i+2], A[i+3]);
              end
          end
        if (DATA_WIDTH <= 4)
          begin
            not #(50) (is_zero, zeros[0]);
          end
        else
          begin
            alu_zero #(.DATA_WIDTH((DATA_WIDTH-1)/4 + 1)) subzero (zeros, is_zero);
          end
      end
  endgenerate
endmodule  // alu_zero