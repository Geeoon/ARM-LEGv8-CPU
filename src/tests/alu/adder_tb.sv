/**
 * @file adder_tb.sv
 * @author Geeoon Chung
 * @author Anna Petrbokova
 * @brief tests the adder module
 * @param DATA_WIDTH the width of the ALU to test.  Defaults to 64
 * @param RAND_TRIALS the number of random trials to do.  Defaults to 10000
 */
`timescale 1ns/10ps

import alu_tb_helper::*;

module adder_tb #(
  parameter DATA_WIDTH=64,
  parameter RAND_TRIALS=10000
) ();
  // inputs
  logic [DATA_WIDTH-1:0]  A;
  logic [DATA_WIDTH-1:0]  B;
  logic             sub;

  // outputs
  logic [DATA_WIDTH-1:0]  sum;
  logic                   carry_out;
  logic                   overflow;

  int overflows = 0;

  adder dut (
    .A,
    .B,
    .sub,
    .sum,
    .carry_out,
    .overflow
  );

  alu_tb_helper_class #(.WIDTH(DATA_WIDTH)) helper;
  
  initial
    begin
      // setup
      A = 0;
      B = 0;
      sub = 0;
      #50000;

      // 0
      $display("%t: testing 0 add", $time);
      #50000;
      assert(helper.test_adder(A, B, sub, sum, overflow, carry_out));
      $display("%t: testing 0 subtract", $time);
      sub = 1;
      #50000;
      assert(helper.test_adder(A, B, sub, sum, overflow, carry_out));

      // +MAX and +MAX
      $display("%t: testing +MAX and +MAX (add)", $time);
      A = {1'b0, {DATA_WIDTH-1{1'b1}}};
      B = {1'b0, {DATA_WIDTH-1{1'b1}}};
      sub = 1;
      #50000;
      assert(helper.test_adder(A, B, sub, sum, overflow, carry_out));

      $display("%t: testing +MAX and +MAX (subtract)", $time);
      sub = 1;
      #50000;
      assert(helper.test_adder(A, B, sub, sum, overflow, carry_out));

      // +MAX and -MAX
      $display("%t: testing +MAX and -MAX (add)", $time);
      A = {1'b0, {DATA_WIDTH-1{1'b1}}};
      B = {1'b1, {DATA_WIDTH-1{1'b0}}};
      sub = 0;
      #50000;
      assert(helper.test_adder(A, B, sub, sum, overflow, carry_out));

      $display("%t: testing +MAX and -MAX (subtract)", $time);
      sub = 1;
      #50000;
      assert(helper.test_adder(A, B, sub, sum, overflow, carry_out));

      // -MAX and +MAX
      $display("%t: testing -MAX and +MAX (add)", $time);
      A = {1'b1, {DATA_WIDTH-1{1'b0}}};
      B = {1'b0, {DATA_WIDTH-1{1'b1}}};
      sub = 0;
      #50000;
      assert(helper.test_adder(A, B, sub, sum, overflow, carry_out));

      $display("%t: testing -MAX and +MAX (subtract)", $time);
      sub = 1;
      #50000;
      assert(helper.test_adder(A, B, sub, sum, overflow, carry_out));

      // -MAX and -MAX
      $display("%t: testing -MAX and -MAX (add)", $time);
      A = {1'b1, {DATA_WIDTH-1{1'b0}}};
      B = {1'b1, {DATA_WIDTH-1{1'b0}}};
      sub = 0;
      #50000;
      assert(helper.test_adder(A, B, sub, sum, overflow, carry_out));

      $display("%t: testing -MAX and -MAX (subtract)", $time);
      sub = 1;
      #50000;
      assert(helper.test_adder(A, B, sub, sum, overflow, carry_out));

      $display("%t: testing overflow", $time);
      sub = 0;
      A = {1'b1, {DATA_WIDTH-1{1'b0}}};
      B = {1'b1, {DATA_WIDTH-1{1'b0}}};
      #50000;
      assert(helper.test_adder(A, B, sub, sum, overflow, carry_out));

      sub = 0;
      A = {2'b01, {DATA_WIDTH-2{1'b0}}};
      B = {2'b01, {DATA_WIDTH-2{1'b0}}};
      #50000;
      assert(helper.test_adder(A, B, sub, sum, overflow, carry_out));

      $display("%t: testing add", $time);
      // testing add
      A = 0;
      B = 0;
      sub = 0;
      for (int i = 0; i < DATA_WIDTH; i++)
        begin
          A[i] = 1;
          B = 0;
          for (int j = 0; j < DATA_WIDTH; j++) begin
            B[j] = 1;
            #50000;
            assert(helper.test_adder(A, B, sub, sum, overflow, carry_out));
          end
        end

      $display("%t: testing sub", $time);
      // testing sub
      A = 0;
      B = 0;
      sub = 1;
      for (int i = 0; i < DATA_WIDTH; i++)
        begin
          A[i] = 1;
          B = 0;
          for (int j = 0; j < DATA_WIDTH; j++) begin
            B[j] = 1;
            #50000;
            assert(helper.test_adder(A, B, sub, sum, overflow, carry_out));
          end
        end

      $display("%t: testing random", $time);
      // testing random
      for (int i = 0; i < RAND_TRIALS; i++)
        begin
          helper.randomize_vec(A);
          helper.randomize_vec(B);
          sub = $random % 2;
          #50000;
          assert(helper.test_adder(A, B, sub, sum, overflow, carry_out));
          if (overflow) overflows += 1;
        end
      $display("Total overflows: %d / %d", overflows, RAND_TRIALS);
      $stop();
    end  // initial
  
endmodule  // adder_tb
