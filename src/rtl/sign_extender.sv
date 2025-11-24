/**
 * @file sign_extender.sv
 * @brief sign extends an input with an optional left shift
 * @param INPUT_WIDTH the width of the input data bus
 * @param OUTPUT_WIDTH the width of the output data bus.  Defaults to 64
 * @param SHAMT the amount to right shift by.  Defaults to 0
 * @param SIGNED whether or not to do a signed or unsigned extend.  Defaults to 1
 * @input input_data the data to be sign extended
 * @output output_data the sign extended data
 * @pre \p OUTPUT_WIDTH is greater than INPUT_WIDTH + SHAMT
 */
module sign_extender #(
  parameter INPUT_WIDTH,
  parameter OUTPUT_WIDTH=64,
  parameter SHAMT=0,
  parameter bit SIGNED=1
) (
  input logic [INPUT_WIDTH-1:0] in,
  output logic [OUTPUT_WIDTH-1:0] out
);
  // signals
  logic extended_bit;

  genvar i;
  generate
    // logic to determine extended bit
    // in the generate to avoid the extra AND gate
    // although in sythesis, it would be sythesized away
    if (SIGNED) assign extended_bit = in[INPUT_WIDTH-1];
    else assign extended_bit = 0;
    for (i = 0; i < OUTPUT_WIDTH; i++)
      begin
        if (i < SHAMT)  // check for shift
          begin
            assign out[i] = 0;
          end
        else if (i < INPUT_WIDTH + SHAMT)
          begin
            assign out[i] = in[i - SHAMT];
          end
        else
          begin
            assign out[i] = extended_bit;
          end
      end  // for
  endgenerate
endmodule  // sign_extender
