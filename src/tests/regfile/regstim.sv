// Test bench for Register file
`timescale 1ns/10ps

module regstim #(
  parameter REG_WIDTH=64,
  parameter NUM_REGS=32,
  parameter ClockDelay=5000
) ();

	// inputs
  logic                         clk;
  logic                         reset;
  logic                         RegWrite;
  logic [$clog2(NUM_REGS)-1:0]  ReadRegister1;
  logic [$clog2(NUM_REGS)-1:0]  ReadRegister2;
  logic [$clog2(NUM_REGS)-1:0]  WriteRegister;
  logic [REG_WIDTH-1:0]         WriteData;
  
  // outputs
  logic [REG_WIDTH-1:0] ReadData1;
  logic [REG_WIDTH-1:0] ReadData2;

	// Your register file MUST be named "regfile".
	// Also you must make sure that the port declarations
	// match up with the module instance in this stimulus file.
	regfile #(
    .REG_WIDTH(REG_WIDTH), .NUM_REGS(NUM_REGS)
  ) dut (
    .ReadData1,
    .ReadData2,
    .WriteData, 
		.ReadRegister1,
    .ReadRegister2,
    .WriteRegister,
		.RegWrite,
    .reset,
    .clk
  );

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end

	initial begin
    // reset
    reset = 1;
    RegWrite = 0;
    ReadRegister1 = 0;
    ReadRegister2 = 0;
    WriteRegister = 0;
    WriteData = 0;
    @(posedge clk);
    reset = 0;
    
    // read all registers on both ports
    for (int i = 0; i < NUM_REGS; i++)
      begin
        ReadRegister1 = i;
        ReadRegister2 = NUM_REGS - i - 1;
        repeat(2) @(posedge clk);
        assert(ReadData1 == 0);
        assert(ReadData2 == 0);
      end  // for
    
    RegWrite = 1;
    // write to all registers
    for (int i = 0; i < NUM_REGS; i++)
      begin
        WriteRegister = i;
        WriteData = i;
        repeat(2) @(posedge clk);
      end  // for
    
    
    RegWrite = 0;
    
    // special case for reading X31
    ReadRegister1 = 0;
    ReadRegister2 = NUM_REGS - 1;
    repeat(2) @(posedge clk);
    assert(ReadData1 == 0);
    assert(ReadData2 == 0);
    
    // read all registers on both ports
    for (int i = 1; i < NUM_REGS - 1; i++)
      begin
        ReadRegister1 = i;
        ReadRegister2 = NUM_REGS - i - 1;
        repeat(2) @(posedge clk);
        assert(ReadData1 == i);
        assert(ReadData2 == NUM_REGS - i - 1);
      end  // for
      
    // special case for reading X31
    ReadRegister1 = NUM_REGS - 1;
    ReadRegister2 = 0;
    repeat(2) @(posedge clk);
    assert(ReadData1 == 0);
    assert(ReadData2 == 0);
    
    
      
		// Try to write the value 0xA0 into register 31.
		// Register 31 should always be at the value of 0.
		RegWrite <= 5'd0;
		ReadRegister1 <= 5'd0;
		ReadRegister2 <= 5'd0;
		WriteRegister <= 5'd31;
		WriteData <= 64'h00000000000000A0;
		@(posedge clk);
		
		$display("%t Attempting overwrite of register 31, which should always be 0", $time);
		RegWrite <= 1;
		@(posedge clk);

		// Write a value into each  register.
		$display("%t Writing pattern to all registers.", $time);
		for (int i=0; i<31; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= i*64'h0000010204080001;
			@(posedge clk);
			
			RegWrite <= 1;
			@(posedge clk);
		end

		// Go back and verify that the registers
		// retained the data.
		$display("%t Checking pattern.", $time);
		for (int i=0; i<32; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= i*64'h0000000000000100+i;
			@(posedge clk);
		end
    
		$stop;
	end
endmodule  // regstim
