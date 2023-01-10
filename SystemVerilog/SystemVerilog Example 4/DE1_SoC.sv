// Julian James
// 11/18/2022
// E E 371
// Lab 4 Task 2

// This  is the Top-level module of the program, and is the place where
// the program and FPGA communicate. This DE1_SoC is loaded with a binary
// search module which searches a RAM for an 8-bit number
// entered on SW 7-0.
// INPUTS: 
//		1-bit: CLOCK_50 - 50MHz clock that is internal to the FPGA
//		4-bit: KEY - 4 keys at the bottom of the board, pressed = false
//		10-bit: SW - 10 switches at the bottom of the board, up = true
// OUTPUTS: 
//		7-bit: HEX - the 6 hex displays on the bottom of the board, far right is 0.
//		10-bit: LEDR- the 10 LEDs above the switches at the bottom of the board. True = on
`timescale 1 ps / 1 ps
module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);
	input logic CLOCK_50;
	input logic   [3:0] KEY;
	input logic   [9:0] SW;
	output logic  [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic  [9:0] LEDR;
	
	// HEX 2-5 are not used, so they are turned off.
	assign HEX2 = 7'b1111111;
	assign HEX3 = 7'b1111111;
	assign HEX4 = 7'b1111111;
	assign HEX5 = 7'b1111111;
   
	// Wires used for signals to and from binary search module.
	
	logic reset;
	logic start;
	logic [7:0] A;
	logic found;
	logic notfound;
	logic [4:0] L;
	
	// Reset is KEY0, inverted because KEYs are false when pressed.
	
	assign reset = !KEY[0];  
	
	assign A = SW[7:0];
		
	assign LEDR[9] = found;
	
	assign LEDR[8] = notfound;
	
	
	//Implements synchronus start. Reset passed to all other modules.
	
	stabilizer sync (.clk(CLOCK_50), .reset(1'b0), .in(SW[9]), .out(start));
	
	// Values passed from board to counter and from counter to display.
	
	binarySearch binsearch (.clk(CLOCK_50), .reset, .start, .A, .L, .found, .notfound);
	
	HEXADisplay display0 (.clk(CLOCK_50), .reset, .data((L[4])), .HEX(HEX1)); //15's place
	HEXADisplay display1 (.clk(CLOCK_50), .reset, .data((L[3:0])), .HEX(HEX0)); // 1's place
	
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
		// Start enabled. Tests for 0. HEX0 should read "0" and LEDR9 should come on.
		SW[9] <= 1; SW[7:0] <= 8'b00000000; repeat(25) @(posedge clk);
		SW[9] <= 0; repeat(2) @(posedge clk);
		// Tests 2. HEX0 should read "1" and LEDR9 should come on.
		SW[9] <= 1; SW[7:0] <= 8'b00000010; repeat (20) @(posedge clk);
		SW[9] <= 0; repeat(2) @(posedge clk);
		// Tests 62. HEX0 should read "1F" and LEDR9 should come on.
		SW[9] <= 1; SW[7:0] <= 8'b00111110; repeat(20) @(posedge clk);
		SW[9] <= 0; repeat(2) @(posedge clk);
		// Tests 3. HEX0 should read "0" and LEDR8 should come on. Not found case
		SW[9] <= 1; SW[7:0] <= 8'b00000011; repeat(20) @(posedge clk);
		SW[9] <= 0; repeat(2) @(posedge clk);

		$stop;
	end
endmodule