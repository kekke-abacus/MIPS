`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design	: MIPS Processor
// Module 	: Testbench
//////////////////////////////////////////////////////////////////////////////////

`define STRLEN 32
`define HalfClockPeriod 60
`define ClockPeriod `HalfClockPeriod * 2

module PipelinedProcTest_v;

	task automatic passTest(input logic [31:0] actualOut, expectedOut, input [`STRLEN*8:0] testType,inout [7:0] passed);
		if(actualOut == expectedOut) begin 
			$display ("%s passed", testType); 
			passed = passed + 1; 
		end
		else 
			$display ("%s failed: 0x%x should be 0x%x", testType, actualOut, expectedOut);
	endtask
	
	task automatic allPassed(input logic [7:0] passed, input logic [7:0] numTests);
		if(passed == numTests) 
			$display ("All tests passed");
		else 
			$display("Some tests failed: %d of %d passed", passed, numTests);
	endtask
	
	// Inputs
	logic CLK;
	logic Reset_L;
	logic [31:0] startPC;
	logic [7:0] passed;
	// Outputs
	logic [31:0] dMemOut;
	//book keeping
	logic [31:0] cc_counter;
	
	always_ff @(negedge CLK)
		if(~Reset_L)
			cc_counter <= 0;
		else
			cc_counter <= cc_counter+1;
		
	initial 
	begin
		CLK= 1'b0;
	end
	
	/*generate clock signal*/
	always begin
		#`HalfClockPeriod CLK = ~CLK;
		#`HalfClockPeriod CLK = ~CLK;
	end
	
	// Instantiate the Unit Under Test (UUT)
	PipelinedProc uut (
		.CLK(CLK),
		.Reset_L(Reset_L),
		.startPC(startPC),
		.dMemOut(dMemOut)
	);

	initial 
	begin
		// Initialize Inputs
		Reset_L = 1;
		startPC = 0;
		passed = 0;
		
		// Wait for global reset
		#(1 * `ClockPeriod);
		
		// Program 1
		#1;
		Reset_L = 0; startPC = 32'h0;
		#(1 * `ClockPeriod);
		Reset_L = 1;
		#(46 * `ClockPeriod);
		passTest(dMemOut, 120, "Results of Program 1", passed);
		
		// Program 2
		#(1 * `ClockPeriod);
		Reset_L = 0; startPC = 32'h60;
		#(1 * `ClockPeriod);
		Reset_L = 1;
		#(34 * `ClockPeriod);
		passTest(dMemOut, 2, "Results of Program 2", passed);
		
		// Program 3
		#(1 * `ClockPeriod);
		Reset_L = 0; startPC = 32'hA0;
		#(1 * `ClockPeriod);
		Reset_L = 1;
		#(29 * `ClockPeriod);
		passTest(dMemOut, 32'hfeedbeef, "Result 1 of Program 3", passed);
		#(1 * `ClockPeriod);
		passTest(dMemOut, 32'hfeedb48f, "Result 2 of Program 3", passed);
		#(1 * `ClockPeriod);
		passTest(dMemOut, 32'hfeeeb48f, "Result 3 of Program 3", passed);
		#(1 * `ClockPeriod);
		passTest(dMemOut, 32'h0000b4a0, "Result 4 of Program 3", passed);
		#(1 * `ClockPeriod);
		passTest(dMemOut, 32'hddb7dde0, "Result 5 of Program 3", passed);
		#(1 * `ClockPeriod);
		passTest(dMemOut, 32'h07f76df7, "Result 6 of Program 3", passed);
		#(1 * `ClockPeriod);
		passTest(dMemOut, 32'hfff76df7, "Result 7 of Program 3", passed);
		#(1 * `ClockPeriod);
		passTest(dMemOut, 1, "Result 8 of Program 3", passed);
		#(1 * `ClockPeriod);
		passTest(dMemOut, 0, "Result 9 of Program 3", passed);
		#(1 * `ClockPeriod);
		passTest(dMemOut, 0, "Result 10 of Program 3", passed);
		#(1 * `ClockPeriod);
		passTest(dMemOut, 1, "Result 11 of Program 3", passed);
		#(1 * `ClockPeriod);
		passTest(dMemOut, 32'hfeed4b4f, "Result 12 of Program 3", passed);
		// Done
		
		allPassed(passed, 14);
		$finish;
	end
endmodule
