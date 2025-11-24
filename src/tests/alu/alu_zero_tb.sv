/**
 * @file alu_zero_tb.sv
 * @author Geeoon Chung
 * @author Anna Petrbokova
 * @brief tests the alu_zero module
 * @param WIDTH the width of zero module to test.  Defaults to 64
 * @param RAND_TRIALS the number of random trials to do.  Defaults to 10000
 */
`timescale 1ns/10ps

import alu_tb_helper::*;

module alu_zero_tb #(
  parameter DATA_WIDTH=64,
  parameter RAND_TRIALS=10000
) ();
  // inputs
  logic [DATA_WIDTH-1:0]  A;
  
  // output
  logic is_zero;
  
  alu_zero #(
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .A,
    .is_zero
  );

  alu_tb_helper_class #(.WIDTH(DATA_WIDTH)) helper;
  
  initial
    begin
      // setup
      A = 0;

      // test zero
      #5000;
      assert(is_zero);

      for (int i = 0; i < DATA_WIDTH; i++)
        begin
          A[i] = 1;
          #5000;
          assert(is_zero == (A == 0));
        end

      for (int i = DATA_WIDTH-1; i >= 0; i--)
        begin
          A[i] = 0;
          #5000;
          assert(is_zero == (A == 0));
        end

      for (int i = 0; i < RAND_TRIALS; i++)
        begin
          helper.randomize_vec(A);
          #5000;
          assert(is_zero == (A == 0));
        end

      $stop();
    end  // initial
  
endmodule  // alu_zero_tb
