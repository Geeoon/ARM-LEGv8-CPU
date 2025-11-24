/**
  * @file alu_or.sv
  * @author Geeoon Chung
  * @author Anna Petrbokova
  * @brief performs a bitwise OR
  * @param DATA_WIDTH the data busses.  Defaults to 64
  * @input A the first operand
  * @input B the second operand
  * @output the resulting bitwise OR
  */
`timescale 1ns/10ps

module alu_or #(
  parameter DATA_WIDTH=64
) ( 
  input   logic [DATA_WIDTH-1:0] A,
  input   logic [DATA_WIDTH-1:0] B,
  output  logic [DATA_WIDTH-1:0] result
);

genvar i;
generate
  for(i = 0; i < DATA_WIDTH; i++) 
    begin : bitor
      or #(50) (result[i], A[i], B[i]);
  end
endgenerate

endmodule //alu_or