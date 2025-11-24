module cpu #(
  parameter DATA_WIDTH=64
) (
   input logic clk
	,input logic reset
);

	logic             alu_zero;
   logic             cbz_zero;
   logic             overflow;
   logic             negative;
   logic             Reg2Loc;
	logic             Mem2Reg;
   logic             Shift2Reg;
   logic             RegWren;
   logic             Imm2ALU;
   logic             ALU_Src;
   logic             SetFlags;
   logic             MemWren;
   logic             UncondBr;
   logic             BrTaken;
   logic   [2:0]     ALU_Op;
	logic   [31:0]    instruction;
   logic   [25:0]    Imm26;
   logic   [18:0]    Imm19;
   logic   [11:0]    Imm12;
   logic   [8:0]     Imm9;
   logic   [5:0]     Shamt;
   logic   [4:0]     Rd;
	logic   [4:0]     Rd2;
   logic   [4:0]     Rm;
   logic   [4:0]     Rn;
   logic   [1:0]     forward_Da;
   logic   [1:0]     forward_Db;

	
	
	cpu_controlpath  #(
      .DATA_WIDTH(DATA_WIDTH)
   ) cpu_cntrl (
   // INPUTS
   .clk,
   .reset,
   .instruction,
   .alu_zero,
   .cbz_zero,
   .overflow,
   .negative,

	 // OUTPUTS
   .Reg2Loc,
   .Shift2Reg,
   .Mem2Reg,
   .RegWren,
   .Imm2ALU,
   .ALU_Src,
   .SetFlags,
   .MemWren,
   .UncondBr,
   .BrTaken,
   .ALU_Op,
   .Imm26,
   .Imm19,
   .Imm12,
   .Imm9,
   .Shamt,
   .Rd,
   .Rd2,
   .Rm,
   .Rn,
   .forward_Da,
   .forward_Db
  );
	
	cpu_datapath  #(
    .DATA_WIDTH(DATA_WIDTH)
	) cpu_data (
	// INPUTS
   .clk,
   .reset,
   .Reg2Loc,
   .Shift2Reg,
   .RegWren,
   .Mem2Reg,
   .Imm2ALU,
   .ALU_Src,
   .SetFlags,
   .MemWren,
   .UncondBr,
   .BrTaken,
   .ALU_Op,
   .Imm26,
   .Imm19,
   .Imm12,
   .Imm9,
   .Shamt,
   .Rd,
   .Rd2,
	.Rm, 
	.Rn,
   .forward_Da,
   .forward_Db,

   // OUTPUTS
   .instruction,
   .alu_zero,
   .cbz_zero,
   .overflow,
   .negative
  );
				
endmodule
