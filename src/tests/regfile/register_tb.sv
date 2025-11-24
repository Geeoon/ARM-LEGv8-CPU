/**
 * @file register_tb.sv
 * @author Geeoon Chung
 * @author Anna Petrbokova
 * @brief a comprehensive test of the register
 * @param WIDTH the width of the D and Q buses for the register to test
 * @param CLOCK_PERIOD the period of the simulated clock in picoseconds
 */
`timescale 1ns/10ps

module register_tb #(
  parameter WIDTH=64,
  parameter CLOCK_PERIOD=500
) ();
  // inputs
  logic             clk, reset, en;
  logic [WIDTH-1:0] d;
  
  // output
  logic [WIDTH-1:0] q;
  
  register #(.WIDTH(WIDTH)) dut (.*);
  
  // clock setup
  initial
    begin
      clk <= 0;
      forever begin 
        #(CLOCK_PERIOD/2) clk <= ~clk;
      end  // forever
    end  // initial
  
  initial
    begin
      // reset
      d = 0;
      en = 0;
      reset = 1;
      repeat(2) @(posedge clk);
      assert(q == 0);
      
      // when not enabled
      reset = 0;
      d = 0;
      for (int i = 0; i <= WIDTH; i += 1)
        begin
          if (i != 0) d[i-1] = 1;
          repeat(2) @(posedge clk);
          assert(q == 0);
        end
      
      // testing enabled
      en = 1;
      d = 0;
      for (int i = 0; i <= WIDTH; i += 1)
        begin
          if (i != 0) d[i-1] = 1;
          repeat(2) @(posedge clk);
          assert(q == d);
        end
      
      // testing not enabled again
      en = 0;
      d = 1;
      @(posedge clk);
      for (int i = 0; i <= WIDTH; i += 1)
        begin
          if (i != 0) d[i-1] = 1;
          repeat(2) @(posedge clk);
          assert(q == {WIDTH{1'b1}});
        end
        
      // testing reset again
      d = 0;
      en = 0;
      reset = 1;
      repeat(2) @(posedge clk);
      assert(q == 0);
      $stop();
    end  // initial
endmodule  // register_tb
