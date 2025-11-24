/**
 * @file adder.sv
 * @author Geeoon Chung
 * @author Anna Petrbokova
 * @brief implements a parameterized
 * @param   WIDTH the width of values to add.  Defaults to 64
 * @input   A the first value to sum
 * @input   B the second value to sum
 * @input   sub whether or not to negate \input B.  (i.e., subtract \input A_in
 *          by \input B.)
 * @output  sum the resulting sum
 * @output  carry_out the last full adder's carry out value
 * @output  overflow whether or not the operation overflowed
 */
`timescale 1ns/10ps

module adder #(
  parameter DATA_WIDTH=64
) (
  input   logic [DATA_WIDTH-1:0]  A,
  input   logic [DATA_WIDTH-1:0]  B,
  input   logic                   sub,
  output  logic [DATA_WIDTH-1:0]  sum,
  output  logic                   carry_out,
  output  logic                   overflow
);
  // signals
  logic carrys [0:DATA_WIDTH];

  // wires
  // the first carry is equal to sub
  assign carrys[0] = sub;
  assign carry_out = carrys[DATA_WIDTH];

  // gates
  xor #(50) (overflow, carry_out, carrys[DATA_WIDTH-1]);

  // submodules
  genvar i;
  generate
    for (i = 0; i < DATA_WIDTH; i++)
      begin : full_adder_chain
        logic B_xor_sum;
        xor #(50) (B_xor_sum, B[i], sub);
        full_adder full_adder_i (
          .A_in(A[i]),
          .B_in(B_xor_sum),
          .carry_in(carrys[i]),
          .sum(sum[i]),
          .carry_out(carrys[i+1])
        );
      end  // full_adder_chain
  endgenerate
endmodule  // bitwise_xor
