/**
 * @file full_adder.sv
 * @author Geeoon Chung
 * @author Anna Petrbokova
 * @input   A_in the first input number
 * @input   B_in the second input number
 * @input   carry_in the carry in
 * @output  carry_out the carry out
 * @output  sum the sum
 */
`timescale 1ns/10ps

module full_adder (
  input   logic A_in,
  input   logic B_in,
  input   logic carry_in,
  output  logic carry_out,
  output  logic sum
);
  // signals
  logic A_and_Cin, A_and_B, B_and_Cin;

  // gates
  // intermediate
  and #(50) (A_and_Cin, A_in, carry_in);
  and #(50) (A_and_B, A_in, B_in);
  and #(50) (B_and_Cin, B_in, carry_in);

  // output
  xor #(50) (sum, A_in, B_in, carry_in);
  or #(50) (carry_out, A_and_Cin, A_and_B, B_and_Cin); 
endmodule  // full_adder
