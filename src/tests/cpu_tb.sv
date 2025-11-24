/**
 * @file cpu_tb.sv
 * @author Geeoon Chung
 * @author Anna Petrbokova
 * @brief runs the benchmark loaded in the instruction memory
 */

`timescale 1ns/10ps
module cpu_tb #(
  parameter MAX_CYCLES=10000,
  parameter DATA_WIDTH=64,
  parameter delay=10000
) ();
  logic clk, reset;

  // CLOCK SETUP
  initial begin
		clk <= 0;
		forever #(delay/2) clk <= ~clk;
	end

  cpu #(.DATA_WIDTH(DATA_WIDTH)) dut (.clk, .reset);
  // TESTBENCH
  initial begin
    reset = 1;
    @(posedge clk);
    reset = 0;
    for (int i = 0; i < MAX_CYCLES; i++) begin
      i++;
      @(posedge clk);
    end
    $stop;
  end
endmodule  // cpu_tb
