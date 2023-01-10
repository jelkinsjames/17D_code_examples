// Julian James
// 11/18/2022
// E E 371
// Lab 4 Task 1

// This  is the Top-level module of the program, and is the place where
// the program and FPGA communicate. This module is set up to count how many ones
// are in SW7-0 and display it on HEX0.
// INPUTS: 
//		1-bit: CLOCK_50 - 50MHz clock that is internal to the FPGA
//		4-bit: KEY - 4 keys at the bottom of the board, pressed = false
//		10-bit: SW - 10 switches at the bottom of the board, up = true
// OUTPUTS: 
//		7-bit: HEX - the 6 hex displays on the bottom of the board, far right is 0.
//		10-bit: LEDR- the 10 LEDs above the switches at the bottom of the board. True = on
module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);
	input logic CLOCK_50;
	input logic   [3:0] KEY;
	input logic   [9:0] SW;
	output logic  [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic  [9:0] LEDR;
	
	// HEX 1-5 are not used, so they are turned off.
	assign HEX1 = 7'b1111111;
	assign HEX2 = 7'b1111111;
	assign HEX3 = 7'b1111111;
	assign HEX4 = 7'b1111111;
	assign HEX5 = 7'b1111111;
   
	// Wires used for signals to and from counter.
	
	logic reset;
	logic start;
	logic [7:0] in;
	logic [3:0] numOnes;
	logic done;
	
	// Reset is KEY0, inverted because KEYs are false when pressed.
	
	assign start = SW[9];
	
	assign in = SW[7:0];
	
	assign LEDR[9] = done;
	
	
	//Implements synchronus reset. Reset passed to all other modules.
	
	stabilizer sync (.clk(CLOCK_50), .reset(1'b0), .in(!KEY[0]), .out(reset));
	
	// Values passed from board to counter and from counter to display.
	
	oneCounter counter (.clk(CLOCK_50), .reset, .start, .in, .numOnes, .done);
	
	HEXADisplay display (.clk(CLOCK_50), .reset, .data(numOnes), .HEX(HEX0));
	
endmodule

//This module tests both normal behavior and edgecases of the DE1_SOC top-level module.
// Tests in = 00000001, 11111111, 00000000, 10101010.
module DE1_SoC_testbench();
	logic clk;
	logic  [3:0] KEY;
	logic  [9:0] SW;
	logic  [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic  [9:0] LEDR;

	DE1_SoC dut (.CLOCK_50(clk), .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .LEDR, .SW);
		
	// Runs the clock that is used in the simulation. Just runs a regular clock, igoring the 
	// actual module being run by a KEY.
	
	parameter clock_period = 100;
	initial begin
		clk <= 0;
		forever #(clock_period / 2) clk <= ~clk;
	end

	
	integer i;
	initial begin
		// Everything set to 0 to start.
		SW[9:0] <= 0; KEY[0] <= 0; repeat(2)  @(posedge clk);
		// Reset taken off. Shows that it does not start when start = false.
		KEY[0] <=1; repeat(2) @(posedge clk);
		// Start enabled. Tests 00000001. HEX0 should read "1" and LEDR9 should come on.
		SW[9] <= 1; SW[7:0] <= 8'b00000001; repeat(12) @(posedge clk);
		SW[9] <= 0; @(posedge clk);
		// Tests 00000000. HEX0 should read "0" and LEDR9 should come on.
		SW[9] <= 1; SW[7:0] <= 8'b00000000; repeat (12) @(posedge clk);
		SW[9] <= 0; @(posedge clk);
		// Tests 11111111. HEX0 should read "8" and LEDR9 should come on.
		SW[9] <= 1; SW[7:0] <= 8'b11111111; repeat(12) @(posedge clk);
		SW[9] <= 0; @(posedge clk);
		// Tests 10101010. HEX0 should read "4" and LEDR9 should come on.
		SW[9] <= 1; SW[7:0] <= 8'b10101010; repeat(12) @(posedge clk);
		SW[9] <= 0; @(posedge clk);

		$stop;
	end
endmodule