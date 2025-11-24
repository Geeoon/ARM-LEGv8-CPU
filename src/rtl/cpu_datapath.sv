/**
 * @file cpu_datapath.sv
 * @brief the datapath for the ARM processor
 * @param   DATA_WIDTH the width of the data registers
 * @input   clk the clock driving the sequential logic
 * @input   REST_OF_INPUTS the signals from the control path
 * @output  instruction the current instruction
 * @output  zero the current zero flag from the ALU
 * @output  overflow the overflow flag from the last operation
 * @output  negative the negative flag from the last operation
 * @see Datapath block diagram
 */
module cpu_datapath #(
    parameter DATA_WIDTH=64,
    parameter NUM_REGS=32,
    parameter MEM_ADDR_WIDTH=10
) (
    input   logic                       clk,
    input   logic                       Reg2Loc,
    input   logic                       Shift2Reg,
    input   logic                       RegWren,
    input   logic                       Imm2ALU,
    input   logic                       ALU_Src,
    input   logic                       SetFlags,
    input   logic                       MemWren,
    input   logic                       Mem2Reg,
    input   logic                       UncondBr,
    input   logic                       BrTaken,
    input   logic                       reset,
    input   logic   [2:0]               ALU_Op,
    input   logic   [25:0]              Imm26,
    input   logic   [18:0]              Imm19,
    input   logic   [11:0]              Imm12,
    input   logic   [8:0]               Imm9,
    input   logic   [5:0]               Shamt,
    input   logic   [4:0]               Rd,
    input   logic   [4:0]               Rd2,
    input   logic   [4:0]               Rm,
    input   logic   [4:0]               Rn,

    // forwarding signals
    input   logic   [1:0]               forward_Da,
    input   logic   [1:0]               forward_Db,

    output  logic   [31:0]              instruction,
    output  logic                       alu_zero,
    output  logic                       cbz_zero,
    output  logic                       overflow,
    output  logic                       negative
);
    // SIGNALS
    // data memory
    logic [DATA_WIDTH-1:0] data_memory_out;

    // regfile Ab input mux
    logic [$clog2(NUM_REGS)-1:0] Ab_mux_in [0:1];
    logic [$clog2(NUM_REGS)-1:0] Ab_mux_out;

    // regfile output
    logic [DATA_WIDTH-1:0] Da;  // CUT THIS (END OF ID)
    logic [DATA_WIDTH-1:0] Da_cut;  // END OF ID CUT
    logic [DATA_WIDTH-1:0] Db;  // CUT THIS (END OF ID)
    logic [DATA_WIDTH-1:0] Db_cut;  // END OF ID CUT; CUT THIS (END OF EX)
    logic [DATA_WIDTH-1:0] Db_cut_cut;  // END OF EX CUT

    // alu_src mux
    logic [DATA_WIDTH-1:0] ALU_Src_mux_in [0:1];
    logic [DATA_WIDTH-1:0] ALU_Src_mux_out;  // CUT THIS (END OF ID)
    logic [DATA_WIDTH-1:0] ALU_Src_mux_out_cut;  // END OF ID CUT

    // Imm2ALU mux
    logic [DATA_WIDTH-1:0] Imm2ALU_mux_in [0:1];
    logic [DATA_WIDTH-1:0] Imm2ALU_mux_out;

    // Imm12ZE
    logic [DATA_WIDTH-1:0] Imm12ZE;

    // Imm9SE
    logic [DATA_WIDTH-1:0] Imm9SE;

    // ALU flags
    logic [3:0] ALU_flags;
    logic [3:0] ALU_flags_reg;

    // ALU flag mux (forwarding-esque)
    logic [3:0] ALU_flags_mux_in [0:1];
    logic [3:0] ALU_flags_mux_out;

    // ALU result
    logic [DATA_WIDTH-1:0] ALU_result;

    // shifter
    logic [DATA_WIDTH-1:0] shift_out;

    // Shift2Reg Mux
    logic [DATA_WIDTH-1:0] Shift2Reg_mux_in [0:1];
    logic [DATA_WIDTH-1:0] Shift2Reg_mux_out;  // CUT THIS (END OF EX)
    logic [DATA_WIDTH-1:0] Shift2Reg_mux_out_cut;  // END OF EX CUT

    // Mem2Reg Mux
    logic [DATA_WIDTH-1:0] Mem2Reg_mux_in [0:1];
    logic [DATA_WIDTH-1:0] Mem2Reg_mux_out;  // CUT THIS (END OF MEM)
    logic [DATA_WIDTH-1:0] Mem2Reg_mux_out_cut;  // END OF MEM CUT

    // Program Counter Register
    logic [DATA_WIDTH-1:0] PC_reg_out;

    // Program Counter Register Old
    logic [DATA_WIDTH-1:0] PC_reg_out_old;

    // PC Mux
    logic [DATA_WIDTH-1:0] PC_mux_in [0:1];
    logic [DATA_WIDTH-1:0] PC_mux_out;

    // Program Counter Adder
    logic [DATA_WIDTH-1:0] PC_adder_out;

    // Branch Taken Mux
    logic [DATA_WIDTH-1:0] BrTaken_mux_in [0:1];
    logic [DATA_WIDTH-1:0] BrTaken_mux_out;

    // Unconditional Branch Mux
    logic [DATA_WIDTH-1:0] UncondBr_mux_in [0:1];
    logic [DATA_WIDTH-1:0] UncondBr_mux_out;

    // Sign Extend and Shift Imm26
    logic [DATA_WIDTH-1:0] Imm26SES2_out;

    // Sign Extend and Shift Imm19
    logic [DATA_WIDTH-1:0] Imm19SES2_out;

    // forwarding muxes
    logic [DATA_WIDTH-1:0] forward_Da_in [0:3];
    logic [DATA_WIDTH-1:0] forward_Da_out;

    logic [DATA_WIDTH-1:0] forward_Db_in [0:3];
    logic [DATA_WIDTH-1:0] forward_Db_out;

    // WIRES
    // regfile Ab input mux
    assign Ab_mux_in[0] = Rd;
    assign Ab_mux_in[1] = Rm;

    // alu_src mux
    assign ALU_Src_mux_in[0] = Imm2ALU_mux_out;
    assign ALU_Src_mux_in[1] = forward_Db_out;

    // Imm2ALU mux
    assign Imm2ALU_mux_in[0] = Imm9SE;
    assign Imm2ALU_mux_in[1] = Imm12ZE;

    // ALU flags
    assign alu_zero = ALU_flags_mux_out[1];
    assign negative = ALU_flags_mux_out[0];
    assign overflow = ALU_flags_mux_out[2];

    // Shift2Reg Mux
    assign Shift2Reg_mux_in[0] = ALU_result;
    assign Shift2Reg_mux_in[1] = shift_out;

    // Mem2Reg Mux
    assign Mem2Reg_mux_in[0] = data_memory_out;
    assign Mem2Reg_mux_in[1] = Shift2Reg_mux_out_cut;

    // saved PC
    // when doing a conditional branch, we should use the old value of the PC, so mux between
    // the old one or the new one
    assign PC_mux_in[0] = PC_reg_out;
    assign PC_mux_in[1] = PC_reg_out_old;

    // BrTaken Mux
    assign BrTaken_mux_in[0] = 4;
    assign BrTaken_mux_in[1] = UncondBr_mux_out;

    // UncondBr Mux
    assign UncondBr_mux_in[0] = Imm19SES2_out;
    assign UncondBr_mux_in[1] = Imm26SES2_out;

    assign forward_Da_in[0] = Da;  // no forwarding
    assign forward_Da_in[1] = Mem2Reg_mux_out;  // from mem
    assign forward_Da_in[2] = Shift2Reg_mux_out;  // from ex
    assign forward_Da_in[3] = Shift2Reg_mux_out;  // from ex

    assign forward_Db_in[0] = Db;  // no forwarding
    assign forward_Db_in[1] = Mem2Reg_mux_out;  // from mem
    assign forward_Db_in[2] = Shift2Reg_mux_out;  // from ex
    assign forward_Db_in[3] = Shift2Reg_mux_out;  // from ex

    // ALU Flags Mux
    assign ALU_flags_mux_in[0] = ALU_flags_reg;
    assign ALU_flags_mux_in[1] = ALU_flags;

    // SUBMODULES
    // Immediate 26 Sign Extend and << 2
    sign_extender #(
        .INPUT_WIDTH(26),
        .OUTPUT_WIDTH(DATA_WIDTH),
        .SHAMT(2)
    ) Imm26SES2 (
        .in(Imm26),
        .out(Imm26SES2_out)
    );

    // Immediate 19 Sign Extend and << 2
    sign_extender #(
        .INPUT_WIDTH(19),
        .OUTPUT_WIDTH(DATA_WIDTH),
        .SHAMT(2)
    ) Imm19SES2 (
        .in(Imm19),
        .out(Imm19SES2_out)
    );

    // Unconditional Branch Mux
    multiplexer #(
        .SELECT_WIDTH(1),
        .DATA_WIDTH(DATA_WIDTH)
    ) UncondBr_mux (
        .in(UncondBr_mux_in),
        .sel(UncondBr),
        .out(UncondBr_mux_out)
    );
    // Branch Taken Mux
    multiplexer #(
        .SELECT_WIDTH(1),
        .DATA_WIDTH(DATA_WIDTH)
    ) BrTaken_mux (
        .in(BrTaken_mux_in),
        .sel(BrTaken),
        .out(BrTaken_mux_out)
    );

    // PC Adder
    adder #(
        .DATA_WIDTH(DATA_WIDTH)
    ) PC_adder (
        .A(PC_mux_out),
        .B(BrTaken_mux_out),
        .sub(1'b0),
        .sum(PC_adder_out),
        .carry_out(),
        .overflow()
    );

    // Instruction Memory
    instructmem instruction_memory (
        .address({{DATA_WIDTH-MEM_ADDR_WIDTH{1'b0}}, PC_reg_out[9:0]}),
        .instruction,
        .clk
	);

    // Program Counter Register
    register #(
        .WIDTH(DATA_WIDTH)  // fixed by instructmem module
    ) PC_reg (
        .clk,
        .reset,
        .en(1'b1),  // always on
        .d(PC_adder_out),
        .q(PC_reg_out)
    );

    register #(
        .WIDTH(DATA_WIDTH)
    ) PC_reg_old (
        .clk,
        .reset,
        .en(1'b1),  // always on
        .d(PC_reg_out),
        .q(PC_reg_out_old)
    );

    // Program Counter Mux
    multiplexer #(
        .SELECT_WIDTH(1),
        .DATA_WIDTH(DATA_WIDTH)
    ) PC_mux (
        .in(PC_mux_in),
        .out(PC_mux_out),
        .sel(BrTaken)
    );

    // Mem2Reg Mux
    multiplexer #(
        .SELECT_WIDTH(1),
        .DATA_WIDTH(DATA_WIDTH)
    ) mem2reg_mux (
        .in(Mem2Reg_mux_in),
        .sel(Mem2Reg),
        .out(Mem2Reg_mux_out)
    );

    // Data Memory
    datamem data_memory (
        .address({{DATA_WIDTH-MEM_ADDR_WIDTH{1'b0}}, Shift2Reg_mux_out_cut[9:0]}),
	    .write_enable(MemWren),
	    .read_enable(1'b1),  // always read???
	    .write_data(Db_cut_cut),
	    .clk,
	    .xfer_size(4'd8),
	    .read_data(data_memory_out)
    );

    // Shift2Reg Mux
    multiplexer #(
        .SELECT_WIDTH(1),
        .DATA_WIDTH(DATA_WIDTH)
    ) shift2reg_mux (
        .in(Shift2Reg_mux_in),
        .sel(Shift2Reg),
        .out(Shift2Reg_mux_out)
    );

    // shifter
    shifter regshift (
        .value(Da_cut),
        .direction(1'b1),
        .distance(Shamt),
        .result(shift_out)
    );

    // ALU flag register
    register #(
        .WIDTH(4)
    ) alu_reg (
        .clk,
        .reset,  // intentionally disconnected
        .en(SetFlags),
        .d(ALU_flags),
        .q(ALU_flags_reg)
    );

    // Imm12 Zero Extender
    sign_extender #(
        .INPUT_WIDTH(12),
        .OUTPUT_WIDTH(DATA_WIDTH),
        .SIGNED(0)
    ) Imm12_Ex (
        .in(Imm12),
        .out(Imm12ZE)
    );

    // Imm9 Sign Extender
    sign_extender #(
        .INPUT_WIDTH(9),
        .OUTPUT_WIDTH(DATA_WIDTH)
    ) Imm9_Ex (
        .in(Imm9),
        .out(Imm9SE)
    );

    // Imm2ALU mux
    multiplexer #(
        .SELECT_WIDTH(1),
        .DATA_WIDTH(DATA_WIDTH)
    ) Imm2ALU_Mux (
        .in(Imm2ALU_mux_in),
        .sel(Imm2ALU),
        .out(Imm2ALU_mux_out)
    );

    // ALU_Src mux
    multiplexer #(
        .SELECT_WIDTH(1),
        .DATA_WIDTH(DATA_WIDTH)
    ) ALU_Src_Mux (
        .in(ALU_Src_mux_in),
        .sel(ALU_Src),
        .out(ALU_Src_mux_out)
    );

    // Ab mux
    multiplexer #(
        .SELECT_WIDTH(1),
        .DATA_WIDTH($clog2(NUM_REGS))
    ) Ab_mux (
        .in(Ab_mux_in),
        .sel(Reg2Loc),
        .out(Ab_mux_out)
    );

    // Register File
    regfile #(
        .REG_WIDTH(DATA_WIDTH),
        .NUM_REGS(NUM_REGS)
    ) reg_file (
        .clk(~clk),
        .reset,  // intentionally disconnected
        .RegWrite(RegWren),
        .ReadRegister1(Rn),  // Aa
        .ReadRegister2(Ab_mux_out),  // Ab
        .WriteRegister(Rd2),  // Aw
        .WriteData(Mem2Reg_mux_out_cut),  // Dw
        .ReadData1(Da),  // Da
        .ReadData2(Db)  // Db
    );

    // ALU
    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) cpu_alu (
        .A(Da_cut),
        .B(ALU_Src_mux_out_cut),
        .cntrl(ALU_Op),
        .result(ALU_result),
        .negative(ALU_flags[0]),
        .zero(ALU_flags[1]),
        .overflow(ALU_flags[2]),
        .carry_out(ALU_flags[3])
    );

    // ID CUTSET
    // Da
    register #(
        .WIDTH(DATA_WIDTH)
    ) ID_Da_Reg (
        .clk,
        .reset,
        .en(1'b1),
        .d(forward_Da_out),
        .q(Da_cut)
    );
    
    // Db
    register #(
        .WIDTH(DATA_WIDTH)
    ) ID_Db_Reg (
        .clk,
        .reset,
        .en(1'b1),
        .d(forward_Db_out),
        .q(Db_cut)
    );

    // ALU_Src_out
    register #(
        .WIDTH(DATA_WIDTH)
    ) ID_ALU_Src_Reg (
        .clk,
        .reset,
        .en(1'b1),
        .d(ALU_Src_mux_out),
        .q(ALU_Src_mux_out_cut)
    );
    
    // EX CUTSET
    // Db_cut
    register #(
        .WIDTH(DATA_WIDTH)
    ) EX_Db_Reg (
        .clk,
        .reset,
        .en(1'b1),
        .d(Db_cut),
        .q(Db_cut_cut)
    );
    
    // Shift2Reg
    register #(
        .WIDTH(DATA_WIDTH)
    ) EX_Shift2Reg_Reg (
        .clk,
        .reset,
        .en(1'b1),
        .d(Shift2Reg_mux_out),
        .q(Shift2Reg_mux_out_cut)
    );

    // MEM CUTSET
    // data_memory_out_cut
    register #(
        .WIDTH(DATA_WIDTH)
    ) Mem2Reg_Memory_Reg (
        .clk,
        .reset,
        .en(1'b1),
        .d(Mem2Reg_mux_out),
        .q(Mem2Reg_mux_out_cut)
    );

    // CBZ Accelerated Branch Zero
    alu_zero #(
        .DATA_WIDTH(DATA_WIDTH)
    ) Zero_Check (
        .A(forward_Db_out),
        .is_zero(cbz_zero)
    );

    // forwarding muxes
    // input of 2'b11 is the same as 2'b10
    multiplexer #(
        .SELECT_WIDTH(2)
    ) forward_mux_Da (
        .in(forward_Da_in),  // no forwarding, forwarding mem, forwarding ex, forwarding ex
        .out(forward_Da_out),  // to Da_cut
        .sel(forward_Da)
    );

    multiplexer #(
        .SELECT_WIDTH(2)
    ) forward_mux_Db (
        .in(forward_Db_in),
        .out(forward_Db_out),  // alu_src input
        .sel(forward_Db)
    );

    multiplexer #(
        .SELECT_WIDTH(1),
        .DATA_WIDTH(4)
    ) ALU_flags_mux (
        .in(ALU_flags_mux_in),
        .out(ALU_flags_mux_out),
        .sel(SetFlags)
    );

endmodule  // cpu_datapath
