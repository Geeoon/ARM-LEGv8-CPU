/**
 * @file bitwise_and_tb.sv
 * @author Geeoon Chung
 * @author Anna Petrbokova
 * @brief tests the bitwise_and module
 * @param WIDTH the width of AND module to test.  Defaults to 64
 */
`timescale 1ns/10ps

module bitwise_and_tb #(
  parameter WIDTH=64
) ();
  // inputs
  logic [WIDTH-1:0] A, B;
  
  // output
  logic [WIDTH-1:0] result;
  
  alu_and #(
    .DATA_WIDTH(WIDTH)
  ) dut (
    .A,
    .B,
    .result
  );
  
  initial
    begin
      // setup
      A = 0;
      B = 0;

      // test AND with bits enabled from 0 to WIDTH-1
      for (int i = 0; i < WIDTH; i++)
        begin
          A[i] = 1;
          for (int j = 0; j < WIDTH; j++)
            begin
              B[j] = 1;
              #5000;
              assert(result == (A & B));
            end  // for
          B = 0;
        end  // for

      A = '1;
      B = '1;
      // test AND with bits disabled from 0 to WIDTH-1
      for (int i = 0; i < WIDTH; i++)
        begin
          A[i] = 0;
          for (int j = 0; j < WIDTH; j++)
            begin
              B[j] = 0;
              #5000;
              assert(result == (A & B));
            end  // for
          B = '1;
        end  // for
      $stop();
    end  // initial
  
endmodule  // bitwise_and_tb
