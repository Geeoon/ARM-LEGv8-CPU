/**
 * EE 469 Lab 3
 * @file cpu_controlpath.sv
 * @brief this file defines the instructiond ecoder used by the control path for the CPU
 * @author Geeoon Chung     (2264035)
 * @author Anna Petrbokova  (2263140)
 */
/**
 * @file    instruction_decoder.sv
 * @brief   Instruction decoder decides what the instruction is by mapping opcode to the instruction
 * @details Generates control signals for datapath based on instruction type.
 * @param input	instruction is the 32-bit instruction
 * @param output	Reg2Loc selects Rt or Rm as second register source
 * @param output	ALU_Src 1 = use immediate, 0 = use register
 * @param output	MemtoReg 1 = load from memory, 0 = ALU result
 * @param output	MemRead enables data memory read
 * @param output  MemWrite enables register file write
 * @param output  Branch enables branch
 * @param output  BranchCond for conditional branch (CBZ, B.LT)
 * @param output  UncondBranch for unconditional branch (B)
 * @param output  ALU_Op for the ALU operation code
 * @param output  SetFlags for updating the flags for ADDS or SUBS
 */

module instruction_decoder #(
parameter DATA_WIDTH=64
) (
  input  logic [31:0]           instruction,
  input  logic                  negative,
  input  logic                  overflow,
  input  logic                  cbz_zero,

  output logic                  Reg2Loc,
  output logic                  ALU_Src,
  output logic                  Mem2Reg,
  output logic                  RegWrite,   
  output logic                  MemWrite,
  output logic                  BrTaken,
  output logic                  UncondBranch,
  output logic [2:0]            ALU_Op,
  output logic                  SetFlags,
  output logic                  Shift2Reg,
  output logic                  Imm2ALU,
  output logic [4:0] 	      	  Rd,
  output logic [4:0] 	      	  Rm,
  output logic [4:0] 	      	  Rn,
  output logic [5:0]            Shamt,
  output logic [25:0]           Imm26,
  output logic [18:0]           Imm19,
  output logic [11:0]           Imm12,
  output logic [8:0]            Imm9
);

  // Extract the opcode 
  logic [10:0] opcode;
  assign opcode = instruction[31:21];
  //assign instructions
  assign Rd     = instruction[4:0];
  assign Rn     = instruction[9:5];
  assign Rm     = instruction[20:16];
  assign Shamt  = instruction[15:10];
  assign Imm12  = instruction[21:10];
  assign Imm9   = instruction[20:12];
  assign Imm19  = instruction[23:5];
  assign Imm26  = instruction[25:0];

  always_comb begin
    Reg2Loc      = 0;
    ALU_Src      = 0;
    Mem2Reg      = 0;
    RegWrite     = 0;
    MemWrite     = 0;
    BrTaken      = 0;
    UncondBranch = 0;
    ALU_Op       = 3'd0;
    SetFlags     = 0;
    Shift2Reg    = 0;
    Imm2ALU      = 0;

    if (opcode[10:1] == 10'b1001000100) begin
      // ADDI
      ALU_Op    = 3'b010;      
      RegWrite  = 1;
      Mem2Reg   = 1;
      Imm2ALU   = 1;

    end else if (opcode == 11'b10101011000) begin
      // ADDS
      ALU_Op   = 3'b010;
      ALU_Src  = 1;
      RegWrite = 1;
      Reg2Loc  = 1;
      SetFlags = 1;
      Mem2Reg  = 1;

    end else if (opcode == 11'b11101011000) begin
      // SUBS
      ALU_Op   = 3'b011;
      ALU_Src  = 1;
      RegWrite = 1;
      Reg2Loc  = 1;
      SetFlags = 1;
      Mem2Reg = 1;

    end else if (opcode == 11'b10001010000) begin
      // AND
      ALU_Op   = 3'b100;
      ALU_Src  = 1;
      RegWrite = 1;
      Reg2Loc  = 1;
      Mem2Reg  = 1;
 
    end else if (opcode == 11'b11001010000) begin
      // EOR
      ALU_Op   = 3'b110;
      ALU_Src  = 1;
      RegWrite = 1;
      Reg2Loc  = 1;
      Mem2Reg  = 1;

    end else if (opcode == 11'b11010011010) begin
      // LSR
      RegWrite  = 1;
      Mem2Reg   = 1;
      Shift2Reg = 1;

    end else if (opcode == 11'b11111000010) begin
      // LDUR
      ALU_Op  	 = 3'b010;
      RegWrite  = 1;

    end else if (opcode == 11'b11111000000) begin
      // STUR
      ALU_Op    = 3'b010;
      MemWrite  = 1;   
		
    end else if (opcode[10:5] == 6'b000101) begin
      // B 
      BrTaken      = 1;
      UncondBranch = 1;

    end else if (opcode[10:3] == 8'b01010100) begin
      // B.LT 
      BrTaken       = (negative != overflow);

    end else if (opcode[10:3] == 8'b10110100) begin
      // CBZ 
      BrTaken = 1;  // changed to from cbz_zero to 1, will be taken care of in the accelerated branching
      ALU_Op = 3'b001;  // changed from ALU_Src to ALU_Op

    end
  end
endmodule