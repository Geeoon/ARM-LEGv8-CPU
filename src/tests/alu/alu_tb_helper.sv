/**
 * @file alu_tb_helper.sv
 * @author Geeoon Chung
 * @author Anna Petrbokova
 * @brief a collection of functions for the ALU testbenches.
 * @param WIDTH the width of the DUT.  Defaults to 64
 */

package alu_tb_helper;
  class alu_tb_helper_class #(parameter WIDTH=64);
    static function void randomize_vec(ref logic unsigned [WIDTH-1:0] vec);
      for (int i = 0; i < $bits(vec); i++)
        begin
          vec[i] = $random % 2;
        end
    endfunction  // randomize_vec

    static function automatic real abs(int val);
      if (val < 0) return -val;
      return val;
    endfunction   // abs

    static function automatic bit test_alu(logic unsigned [WIDTH-1:0] A, logic unsigned [WIDTH-1:0] B, logic [2:0] ctrl, logic unsigned [WIDTH-1:0] result, logic alu_overflow, logic alu_negative, logic alu_carry_out, logic alu_zero, bit ignore_flags=0);
      bit out = 1;
      bit c_out_expected, c_out_passed;
      bit negative_expected, negative_passed;
      bit zero_expected, zero_passed;
      logic [WIDTH-1:0] sum_expected;
      bit sum_passed;
      bit overflow_expected, overflow_passed;

      if (ctrl == 3'b000)  // pass_b
        begin
          out = out & (result == B);
        end
      else if (~ignore_flags & ((ctrl == 3'b010) | (ctrl == 3'b011)))  // alu add and sub
        begin
          overflow_expected = is_overflow(A, B, ctrl[0]);
          overflow_passed = alu_overflow == overflow_expected;
          out = out & overflow_passed;
          if (~overflow_passed) $display("%t: Failed overflow test, was %b expected %b", $time, alu_overflow, overflow_expected);

          c_out_expected = is_carry_out(A, B, ctrl[0]);
          c_out_passed = alu_carry_out == c_out_expected;
          out = out & c_out_passed;
          if (~c_out_passed) $display("%t: Failed carry_out test, was %b expected %b", $time, alu_carry_out, c_out_expected);

          sum_expected = compute_sum(A, B, ctrl[0]);
          sum_passed = result == sum_expected;
          out = out & sum_passed;
          if (~sum_passed) $display("%t: Failed sum test, was %d expected %d", $time, result, sum_expected);
        end
      else if (ctrl == 3'b100)  // and
        begin
          out = out & (result == (A & B));
        end
      else if (ctrl == 3'b101)  // or
        begin
          out = out & (result == (A | B));
        end
      else if (ctrl == 3'b110)  // xor
        begin
          out = out & (result == (A ^ B));
        end
      else
        begin
          $display("INVALID CTRL SIGNAL: %b", ctrl);
          return 0;
        end

      if (~ignore_flags) begin
        negative_expected = result[WIDTH-1];
        negative_passed = alu_negative == negative_expected;
        out = out & negative_passed;
        if (~negative_passed) $display("%t: Failed negative test, was %b expected %b", $time, alu_negative, negative_expected);

        zero_expected = result == 0;
        zero_passed = alu_zero == zero_expected;
        out = out & zero_passed;
        if (~zero_passed) $display("%t: Failed zero test, was %b expected %b\n\t%b", $time, alu_zero, zero_expected, result);
      end
      return out;
    endfunction  // test_alu

    static function automatic bit test_adder(logic unsigned [WIDTH-1:0] A, logic unsigned [WIDTH-1:0] B, logic sub, logic unsigned [WIDTH-1:0] sum, logic alu_overflow, logic alu_carry_out);
      bit out = 1;
      bit c_out_expected;
      bit c_out_passed;
      logic [WIDTH-1:0] sum_expected;
      bit sum_passed;

      bit overflow_expected = is_overflow(A, B, sub);
      bit overflow_passed = alu_overflow == overflow_expected;
      out = out & overflow_passed;
      if (~overflow_passed) $display("%t: Failed overflow test, was %b expected %b", $time, alu_overflow, overflow_expected);

      c_out_expected = is_carry_out(A, B, sub);
      c_out_passed = alu_carry_out == c_out_expected;
      out = out & c_out_passed;
      if (~c_out_passed) $display("%t: Failed carry_out test, was %b expected %b", $time, alu_carry_out, c_out_expected);

      sum_expected = compute_sum(A, B, sub);
      sum_passed = sum == sum_expected;
      out = out & sum_passed;
      if (~sum_passed) $display("%t: Failed sum test, was %d expected %d", $time, sum, sum_expected);
      return out;
    endfunction  // test_adder

    static function automatic bit is_overflow(logic unsigned [WIDTH-1:0] A, logic unsigned [WIDTH-1:0] B, logic sub);
      logic c_in_expected;
      logic unsigned [WIDTH:0] out;

      if (sub) B = ~B;
      out = {1'b0, A} + {1'b0, B};
      if (sub) out = out + 1;

      return (A[WIDTH-1] & B[WIDTH-1] & ~(out[WIDTH-1]) & out[WIDTH]) | (~(A[WIDTH-1]) & B[WIDTH-1] & out[WIDTH-1] & out[WIDTH]) | (~(A[WIDTH-1]) & ~(B[WIDTH-1]) & out[WIDTH-1] & ~(out[WIDTH]));
    endfunction  // is_overflow

    static function automatic bit is_negative(logic unsigned [WIDTH-1:0] A, logic unsigned [WIDTH-1:0] B, logic sub);
      logic unsigned [WIDTH:0] out;
      if (sub) B = -B;
      out = A + B;
      return out[WIDTH-1];
    endfunction  // is_negative

    static function automatic bit is_carry_out(logic unsigned [WIDTH-1:0] A, logic unsigned [WIDTH-1:0] B, logic sub);
      logic unsigned [WIDTH:0] out;
      if (sub) B = ~B;
      out = A + B;
      if (sub) out = out + 1;
      return out[WIDTH];
    endfunction   // is_carry_out

    static function automatic bit is_zero(logic unsigned [WIDTH-1:0] A, logic unsigned [WIDTH-1:0] B, logic sub);
      logic unsigned [WIDTH:0] out;
      if (sub) B = -B;
      out = A + B;
      return out[WIDTH-1:0] == 0;
    endfunction  // is_zero

    static function automatic logic [WIDTH-1:0] compute_sum(logic unsigned [WIDTH-1:0] A, logic unsigned [WIDTH-1:0] B, logic sub);
      logic unsigned [WIDTH:0] out;
      if (sub) B = -B;
      out = A + B;
      return out[WIDTH-1:0];
    endfunction  // compute_sum
  endclass  // alu_tb_helper_class
  
endpackage  // alu_tb_helper
