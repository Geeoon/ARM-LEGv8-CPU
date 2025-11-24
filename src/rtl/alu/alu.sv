/**
  * @file alu.sv
  * @author Geeoon Chung
  * @author Anna Petrbokova
  * @brief ALU with an adder and subtractor as well as bitwise operations
  * @param DATA_WIDTH the width of the input/output data busses
  * @input  A the first operand
  * @input  B the second operand
  * @input  cntrl the operation to do
  * @output result the result of the operation
  * @output negative HIGH if the result is negative
  * @output zero HIGH if the result is zero
  * @output overflow the value of the adder's overflow signal
  * @output carry_out the value of the adder's carry out signal
  */

module alu #(
  parameter DATA_WIDTH=64
)  (
  input   logic [DATA_WIDTH-1:0]  A,
  input   logic [DATA_WIDTH-1:0]  B,
  input   logic [2:0]             cntrl,
  output  logic [DATA_WIDTH-1:0]  result,
  output  logic                   negative,
  output  logic                   zero,
  output  logic                   overflow,
  output  logic                   carry_out
);
  // signals
  logic [DATA_WIDTH-1:0] and_result, adder_result, or_result, xor_result;
  logic [DATA_WIDTH-1:0] result_inputs [0:7];

  // wires
  assign result_inputs[0] = B;
  assign result_inputs[1]	= {DATA_WIDTH{1'bx}};  // unused
  assign result_inputs[2]	=	adder_result;
  assign result_inputs[3]	= adder_result;
  assign result_inputs[4]	=	and_result;
  assign result_inputs[5]	=	or_result;
  assign result_inputs[6]	= xor_result;
  assign result_inputs[7]	=	{DATA_WIDTH{1'bx}};  // unused
  assign negative = result[DATA_WIDTH-1];

  // submodules
  adder #(.DATA_WIDTH(DATA_WIDTH)) alu_adder (.A, .B, .sub(cntrl[0]), .sum(adder_result), .carry_out(carry_out), .overflow(overflow));
  alu_and #(.DATA_WIDTH(DATA_WIDTH)) ander (.A, .B, .result(and_result));
  alu_or #(.DATA_WIDTH(DATA_WIDTH)) orrer (.A, .B, .result(or_result));
  alu_xor #(.DATA_WIDTH(DATA_WIDTH)) xorer (.A, .B, .result(xor_result));
  alu_zero #(.DATA_WIDTH(DATA_WIDTH)) zeroer (.A(result), .is_zero(zero));
  // 8x1 mux for result
  multiplexer #(.SELECT_WIDTH(3), .DATA_WIDTH(DATA_WIDTH)) mux_8x1 (.in(result_inputs), .sel(cntrl), .out(result));
endmodule  // alu

//
//module alu_tb #(
//	parameter DATA_WIDTH=64,
//	parameter CTR_WIDTH=3
//	parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110
//)  ();
//	//inputs