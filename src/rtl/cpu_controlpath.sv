/**
 * EE 469 Lab 3
 * @file cpu_controlpath.sv
 * @brief this file defines the control path of the CPU
 * @author Geeoon Chung     (2264035)
 * @author Anna Petrbokova  (2263140)
 */
 
/**
 * @param input     clk the clock to drive the sequential logic
 * @param input     instruction defines what type of instruction the CPU is performing
 * @param input     alu_zero means that the output of the alu is zero
 * @param input     overflow means that there is overflow in the alu
 * @param input     negative means that the alu output is negative
 * @param output    Reg2Loc is the control signal for the  2:1 mux dictating if Rd or Rm is read into the register file
 * @param output    Shift2Reg is the control signal for the 2:1 mux dictating input Dw of register file
 * @param output    RegWren is control signal for Data Memory 
 * @param output    Imm2ALU is control signal deciding between Imm12 and Imm9 (possible input to ALU) 
 * @param output    ALU_Src is the final control signal decitating one of the inputs to ALU (either Imm2ALU or Db from reg file)
 * @param output    SetFlags is output that dictates if a certain instruction should set negative or overflow flags.
 * @param output    MemWren is output dictating the write enable for the Data memory
 * @param output    UncondBr is control for 2:1 mux choosing between SE by 2 of Imm26 or SE by 2 for Imm19
 * @param output    BrTaken is final control signal before the adder that takes in either 4 or UncondBr
 * @param output    ALU_Op decides the operation done by the ALU
 * @param output    Imm26 is type of instruction
 * @param output    Imm19 is type of instruction
 * @param output    Imm12 is type of instruction
 * @param output    Imm9 is type of instruction
 * @param output    Shamt is shift amount?
 * @param output    Rd is input to the register file
 * @param output    Rm is input to register file
 * @param output    Rn is input to register file
 */

module cpu_controlpath #(
  parameter DATA_WIDTH=64
) (
	 input     logic           clk,
    input     logic           reset,
	 input  	  logic   [31:0]  instruction,
    input  	  logic           alu_zero,
	 input     logic           cbz_zero,
    input  	  logic           overflow,
    input  	  logic           negative,

    output    logic           Reg2Loc,
	 output    logic           Mem2Reg,
    output    logic           Shift2Reg,
    output    logic           RegWren,
    output    logic           Imm2ALU,
    output    logic           ALU_Src,
    output    logic           SetFlags,
    output    logic           MemWren,
    output    logic           UncondBr,
    output    logic           BrTaken,
    output    logic   [2:0]   ALU_Op,
    output    logic   [25:0]  Imm26,
    output    logic   [18:0]  Imm19,
    output    logic   [11:0]  Imm12,
    output    logic   [8:0]   Imm9,
    output    logic   [5:0]   Shamt,
    output    logic   [4:0]   Rd,
	 output    logic   [4:0]   Rd2,
    output    logic   [4:0]   Rm,
    output    logic   [4:0]   Rn,
	 output    logic   [1:0]   forward_Da,
	 output    logic   [1:0] 	forward_Db
);

// ======================== SIGNALS ========================
// saved instruction
logic [31:0] saved_instruction;

// decoded controlpath signals
logic decoder_Reg2Loc, decoder_ALU_Src, decoder_Mem2Reg;
logic decoder_RegWrite, decoder_MemWrite;
logic decoder_BrTaken, decoder_UncondBranch;
logic [2:0] decoder_ALUOp;
logic decoder_SetFlags, decoder_Shift2Reg, decoder_Imm2ALU;
logic [4:0] decoder_Rd, decoder_Rm, decoder_Rn;
logic [25:0] decoder_Imm26;
logic [18:0] decoder_Imm19;
logic [11:0] decoder_Imm12;
logic [8:0]  decoder_Imm9;
logic [5:0]  decoder_Shamt;
  
//pipeline control registers
// IF_ID STAGE
logic                   if_id_Reg2Loc;  // used in ID
logic                   if_id_Mem2Reg;
logic                   if_id_Shift2Reg;
logic                   if_id_Imm2ALU;  // used in ID
logic                   if_id_ALU_Src;  // used in ID
logic                   if_id_SetFlags;
logic                   if_id_MemWren;
logic                   if_id_UncondBr;  // used in ID
logic                   if_id_BrTaken;  // used in ID
logic [2:0]             if_id_ALU_Op;
logic [25:0]            if_id_Imm26;  // used in IF, would be needed in ID for conditional branches
logic [18:0]            if_id_Imm19;  // used in IF, would be needed in ID for conditional branches
logic [11:0]            if_id_Imm12;  // used in ID
logic [8:0]             if_id_Imm9;  // used in ID
logic [5:0]             if_id_Shamt;
logic [4:0]  				if_id_Rd, if_id_Rm, if_id_Rn;  // used in ID, but continues to EX
logic [4:0]  				if_id_Rd2;
logic                   if_id_RegWren;

// ID_EX STAGE
logic                   id_ex_Shift2Reg;  // used in EX
logic                   id_ex_Mem2Reg;
logic                   id_ex_SetFlags;  // used in EX
logic                   id_ex_MemWren;
logic [2:0]             id_ex_ALU_Op;  // used in EX
logic [5:0]             id_ex_Shamt;  // used in EX
logic [4:0]  				id_ex_Rd2;
logic                   id_ex_RegWren;

// EX_MEM STAGE
logic                   ex_mem_Mem2Reg;  // used in MEM
logic                   ex_mem_MemWren;  // used in MEM
logic [4:0]  				ex_mem_Rd2;
logic                   ex_mem_RegWren;

// MEM_WB STAGE
logic [4:0]  				mem_wb_Rd2;  // used in WB
logic                   mem_wb_RegWren;  // used in WB

// ======================== SUBMODULES ========================
instruction_decoder #(.DATA_WIDTH(DATA_WIDTH)) decoder_inst (
    //inputs
    .instruction   (saved_instruction),
    .negative      (negative),
    .overflow      (overflow),
    .cbz_zero      (cbz_zero),
    //outputs
    .Reg2Loc       (decoder_Reg2Loc),
    .ALU_Src       (decoder_ALU_Src),
    .Mem2Reg       (decoder_Mem2Reg),
    .RegWrite      (decoder_RegWrite),
    .MemWrite      (decoder_MemWrite),
    .BrTaken       (decoder_BrTaken),
    .UncondBranch  (decoder_UncondBranch),
    .ALU_Op        (decoder_ALUOp),
    .SetFlags      (decoder_SetFlags),
    .Shift2Reg     (decoder_Shift2Reg),
    .Imm2ALU       (decoder_Imm2ALU),
    .Rd            (decoder_Rd),
    .Rm            (decoder_Rm),
    .Rn            (decoder_Rn),
    .Shamt         (decoder_Shamt),
    .Imm26         (decoder_Imm26),
    .Imm19         (decoder_Imm19),
    .Imm12         (decoder_Imm12),
    .Imm9          (decoder_Imm9)
  );

// ======================== WIRES ========================
// ID
assign UncondBr 	= if_id_UncondBr;
assign Imm26 		  = if_id_Imm26;
assign Imm19 		  = if_id_Imm19;
assign Reg2Loc    = if_id_Reg2Loc;
assign Imm2ALU    = if_id_Imm2ALU;
assign ALU_Src    = if_id_ALU_Src;
assign Imm12      = if_id_Imm12;
assign Imm9       = if_id_Imm9;
assign Rm         = if_id_Rm;
assign Rn         = if_id_Rn;
assign Rd         = if_id_Rd;

// EX
assign Shift2Reg  = id_ex_Shift2Reg;
assign SetFlags   = id_ex_SetFlags;
assign ALU_Op     = id_ex_ALU_Op;
assign Shamt      = id_ex_Shamt;

// MEM
assign Mem2Reg    = ex_mem_Mem2Reg;
assign MemWren    = ex_mem_MemWren;

// WB
assign RegWren    = mem_wb_RegWren;
assign Rd2        = mem_wb_Rd2;
// branching realted

always_comb begin
  if_id_Reg2Loc         = decoder_Reg2Loc;
  if_id_Mem2Reg         = decoder_Mem2Reg;
  if_id_Shift2Reg       = decoder_Shift2Reg;
  if_id_RegWren         = decoder_RegWrite;
  if_id_Imm2ALU         = decoder_Imm2ALU;
  if_id_ALU_Src         = decoder_ALU_Src;
  if_id_SetFlags        = decoder_SetFlags;
  if_id_MemWren         = decoder_MemWrite;
  if_id_UncondBr        = decoder_UncondBranch;
  if_id_BrTaken         = decoder_BrTaken;
  if_id_ALU_Op          = decoder_ALUOp;
  if_id_Imm26           = decoder_Imm26;
  if_id_Imm19           = decoder_Imm19;
  if_id_Imm12           = decoder_Imm12;
  if_id_Imm9            = decoder_Imm9;
  if_id_Shamt           = decoder_Shamt;
  if_id_Rd              = decoder_Rd;
  if_id_Rd2             = decoder_Rd;
  if_id_Rm              = decoder_Rm;
  if_id_Rn              = decoder_Rn;

  BrTaken = if_id_BrTaken;
  // accelerated branching
  if (~if_id_UncondBr & if_id_BrTaken) begin
    // we're doing a conditional branch
    if (saved_instruction[31:24] == 8'b01010100) BrTaken = 1;
    else BrTaken = cbz_zero;
  end
end  // always_comb

always_ff @(posedge clk) begin
 if (reset) begin
    saved_instruction           <= 0;
  end else begin
	  // IF_ID STAGE
    saved_instruction     <= instruction;
	
	  // ID_EX STAGE
	  id_ex_Shift2Reg       <= if_id_Shift2Reg;
	  id_ex_Mem2Reg         <= if_id_Mem2Reg;
	  id_ex_SetFlags        <= if_id_SetFlags;
	  id_ex_MemWren         <= if_id_MemWren;
	  id_ex_ALU_Op          <= if_id_ALU_Op;
	  id_ex_Shamt           <= if_id_Shamt;
	  id_ex_Rd2             <= if_id_Rd2;
	  id_ex_RegWren         <= if_id_RegWren;
	  
	  // EX_MEM STAGE
	  ex_mem_Mem2Reg        <= id_ex_Mem2Reg;
	  ex_mem_MemWren        <= id_ex_MemWren;
	  ex_mem_Rd2            <= id_ex_Rd2;
	  ex_mem_RegWren        <= id_ex_RegWren;

	  // MEM_WB STAGE
	  mem_wb_Rd2            <= ex_mem_Rd2;
	  mem_wb_RegWren        <= ex_mem_RegWren;
	end
end //always_ff

//forwarding logic
always_comb begin
	//default (ID/EX)
	forward_Da = 2'b00;
	forward_Db = 2'b00;

	//EX/MEM from previous instruction // only if not MEM/WB
	if(id_ex_RegWren && (id_ex_Rd2 != 31) && (id_ex_Rd2 == if_id_Rn))
		forward_Da = 2'b10;
	if(id_ex_RegWren && (id_ex_Rd2 != 31) && (id_ex_Rd2 == if_id_Rm) && (if_id_Reg2Loc == 1))
		forward_Db = 2'b10;
	if(id_ex_RegWren && (id_ex_Rd2 != 31) && (id_ex_Rd2 == if_id_Rd) && (if_id_Reg2Loc == 0))
		forward_Db  = 2'b10;
	
	//MEM/WB from 2 instructions before
	if((forward_Da == 2'b00) && ex_mem_RegWren && (ex_mem_Rd2 != 31) && (ex_mem_Rd2 == if_id_Rn))
		forward_Da  = 2'b01;
	if((forward_Db == 2'b00) && ex_mem_RegWren && (ex_mem_Rd2 != 31) && (ex_mem_Rd2 == if_id_Rm) && (if_id_Reg2Loc == 1))
		forward_Db  = 2'b01;
	if((forward_Db == 2'b00) && ex_mem_RegWren && (ex_mem_Rd2 != 31) && (ex_mem_Rd2 == if_id_Rd) && (if_id_Reg2Loc == 0))
		forward_Db  = 2'b01;
    
	
end

endmodule
