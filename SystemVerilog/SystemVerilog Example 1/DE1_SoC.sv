// Julian James
// 10/24/2022
// E E 371
// Lab 2

//This  is the Top-level module of the program, and is the place where
//the program and FPGA communicate. 
//INPUTS: CLOCK_50 (organic to FPGA), 10 bit SW, 4-bit KEY
//OUTPUTS: HEX display
module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);
	input logic CLOCK_50;
	input logic   [3:0] KEY;
	input logic   [9:0] SW;
	output logic  [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic  [9:0] LEDR;
	
	// KEY0 is used for all clock inputs.
   logic clk;
   assign clk = !KEY[0];
	
	// HEX3 and 1 are not used, so they are turned off.
	assign HEX3 = 7'b1111111;
	assign HEX1 = 7'b1111111;
   
	// Switches for the address and data are passed into our RAM system here.
	// SW9 is the write enable, SW 8-4 are the address, SW 3-0 is the data to be put at the address,
	// HEX5-4 displays the active address, HEX2 displays the data to be written,
	// HEX0 displays the data currently at the address.
	
	RAMSystem RAMsystem (.clk, .wr_en(SW[9]), .addr(SW[8:4]), .wr_data(SW[3:0]), 
						      .addrHEX1(HEX5), .addrHEX0(HEX4), .wrHEX(HEX2), .reHEX(HEX0));

endmodule

//This module tests both normal behavior and edgecases of the DE1_SOC top-level module.
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
		SW[9:0] <= 10'b0; @(posedge clk); // Everything set to 0 to start.
		SW[9] <= 1; @(posedge clk); 		 // Write enabled
		// putting 2 in address 1, display should still read 0 for data
		// for two cycles.
		SW[8:4] <= 4'b0001; SW[3:0] <= 4'b0010; repeat(3) @(posedge clk);
		// putting 9 in address 10, display should read 0 for data for 2 cycles.
		SW[8:4] <= 4'b1010; SW[3:0] <= 4'b1001; repeat (3) @(posedge clk);
		// Write diabled, display should now show our 2 that we put in address 1.
		SW[9] <= 0; SW[8:4] <= 4'b0001; repeat(2) @(posedge clk);
		// Write enabled, display now should show 9 again.
		SW[9] <= 1; repeat(3) @(posedge clk);
		$stop;
	end
endmodule