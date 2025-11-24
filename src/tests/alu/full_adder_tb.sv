/**
 * @file full_adder_tb.sv
 * @author Geeoon Chung
 * @author Anna Petrbokova
 * @brief tests the full_adder module
 */
`timescale 1ns/10ps

module full_adder_tb ();
  // inputs
  logic A_in, B_in, carry_in;
  
  // output
  logic sum, carry_out;

  // interal
  logic [1:0] true_sum;

  full_adder dut (
    .A_in,
    .B_in,
    .carry_in,
    .sum,
    .carry_out
  );
  
  initial
    begin
      // setup
      A_in = 0;
      B_in = 0;
      carry_in = 0;

      // testing all possible inputs
      for (int i = 0; i <= 3'b111; i++)
        begin
          A_in = i[0];
          B_in = i[1];
          carry_in = i[2];
          #5000;

          // compute true sum using ints
          true_sum = A_in + B_in + carry_in;
          // assert sum is correct
          assert(true_sum[0] == sum);
          // assert carry_out is correct
          assert(true_sum[1] == carry_out);
        end

      $stop();
    end  // initial
  
endmodule  // full_adder_tb
