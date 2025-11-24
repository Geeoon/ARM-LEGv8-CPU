/**
 * @file regfile.sv
 * @author Geeoon Chung
 * @author Anna Petrbokova
 * @brief implements a parameterized regsiter file
 * @param REG_WIDTH the width of each register in bits
 * @param NUM_REGS the number of registers in the register file
 */
`timescale 1ns/10ps

module regfile #(
  parameter REG_WIDTH=64,
  parameter NUM_REGS=32
) (
  input   logic                         clk,
  input   logic                         reset,
  input   logic                         RegWrite,
  input   logic [$clog2(NUM_REGS)-1:0]  ReadRegister1,
  input   logic [$clog2(NUM_REGS)-1:0]  ReadRegister2,
  input   logic [$clog2(NUM_REGS)-1:0]  WriteRegister,
  input   logic [REG_WIDTH-1:0]         WriteData,
  output  logic [REG_WIDTH-1:0]         ReadData1,
  output  logic [REG_WIDTH-1:0]         ReadData2
);
  // signals
  logic [NUM_REGS-1:0] decoder_out;
  logic [REG_WIDTH-1:0] register_out [0:NUM_REGS-1];
  
  // submodules
  decoder #(.INPUT_WIDTH($clog2(NUM_REGS))) RegWriteDecoder (.en(RegWrite), .in(WriteRegister), .out(decoder_out));
  multiplexer #(.SELECT_WIDTH($clog2(NUM_REGS)), .DATA_WIDTH(REG_WIDTH)) mux1 (.in(register_out), .sel(ReadRegister1), .out(ReadData1));
  multiplexer #(.SELECT_WIDTH($clog2(NUM_REGS)), .DATA_WIDTH(REG_WIDTH)) mux2 (.in(register_out), .sel(ReadRegister2), .out(ReadData2));
  
  // connections
  // assign X31 to read all zeros
  assign register_out[NUM_REGS-1] = 0;
  
  // TODO: mux to set output equal to write value when writing/reading the same register
  genvar i;
  generate
    for (i = 0; i < NUM_REGS-1; i++)
      begin : real_regs  // the registers that actually store values with DFFs
        register #(.WIDTH(REG_WIDTH)) _register (.clk, .reset, .en(decoder_out[i]), .d(WriteData), .q(register_out[i]));
      end  // real_regs
  endgenerate
endmodule  // regfile
