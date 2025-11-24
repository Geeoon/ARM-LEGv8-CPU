// Test bench for ALU
`timescale 1ns/10ps

// Meaning of signals in and out of the ALU:

// Flags:
// negative: whether the result output is negative if interpreted as 2's comp.
// zero: whether the result output was a 64-bit zero.
// overflow: on an add or subtract, whether the computation overflowed if the inputs are interpreted as 2's comp.
// carry_out: on an add or subtract, whether the computation produced a carry-out.

// cntrl			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant

import alu_tb_helper::*;

module alustim #(
  parameter delay=10000,
  parameter DATA_WIDTH=64,
  parameter RAND_TRIALS=10000
) ();

  // inputs
  logic [63:0]  A, B;
  logic [2:0]   cntrl;

  // outputs
  logic [63:0]  result;
  logic         negative, zero, overflow, carry_out;

  parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110;

  logic [2:0] controls [6];
  assign controls[0] = ALU_PASS_B;
  assign controls[1] = ALU_ADD;
  assign controls[2] = ALU_SUBTRACT;
  assign controls[3] = ALU_AND;
  assign controls[4] = ALU_OR;
  assign controls[5] = ALU_XOR;

  alu #(
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .A,
    .B,
    .cntrl,
    .result,
    .negative,
    .zero,
    .overflow,
    .carry_out
  );

  alu_tb_helper_class #(.WIDTH(DATA_WIDTH)) helper;

  // Force %t's to print in a nice format.
  initial $timeformat(-9, 2, " ns", 10);

  initial begin
    foreach (controls[i])
      begin
        if (controls[i] == ALU_PASS_B) $display("%t: Testing PASS_B", $time);
        else if (controls[i] == ALU_ADD) $display("%t: Testing ALU_ADD", $time);
        else if (controls[i] == ALU_SUBTRACT) $display("%t: Testing ALU_SUBTRACT", $time);
        else if (controls[i] == ALU_AND) $display("%t: Testing ALU_AND", $time);
        else if (controls[i] == ALU_OR) $display("%t: Testing ALU_OR", $time);
        else if (controls[i] == ALU_XOR) $display("%t: Testing ALU_XOR", $time);
        else
          begin
            $display("%t: INVALID CONTROL SIGNAL, %b", $time, controls[i]);
            assert(0);
          end
        // zero
        cntrl = controls[i];
        A = 0;
        B = 0;
        #(delay);
        assert(helper.test_alu(A, B, cntrl, result, overflow, negative, carry_out, zero));

        // test all bits
        for (int i = 0; i < DATA_WIDTH; i++)
          begin
            B = 0;
            A[i] = 1;
            for (int j = 0; j < DATA_WIDTH; j++)
              begin
                B[j] = 1;
                #(delay);
                assert(helper.test_alu(A, B, cntrl, result, overflow, negative, carry_out, zero));
              end
          end
        
        // test random
        for (int i = 0; i < RAND_TRIALS; i++)
          begin
            helper.randomize_vec(A);
            helper.randomize_vec(B);
            #(delay);
            assert(helper.test_alu(A, B, cntrl, result, overflow, negative, carry_out, zero));
          end
      end
  end  // initial
endmodule  // alustim
