// Julian James
// 10/23/2022
// E E 371
// Lab 2 Task 2

// Counts up to  31, then goes back again.
// This is used to scroll through a 32x4 memory file.
// INPUT: 1-bit clk, reset
// OUTPUT: 4-bit out, the address.
module addr_scroller (clk, reset, out);
	input logic clk, reset;
	output logic [4:0] out;
	
	logic [4:0] count;
		
	always_ff @(posedge clk) 
		begin
			if (reset) count <= 5'b0;
			else if (count < 5'b11111) count <= count + 1;
			else count <= 5'b0;
		end
	
	assign out = count;

endmodule

//This module tests the behavior of the module.
module addrScroller_testbench();
	logic clk, reset;
	logic [4:0] out;
	
	addr_scroller dut (.clk, .reset, .out);
	
	// Sets up the clock for use in the simulation.
	
	parameter clock_period = 100;
	initial begin
		clk <= 0;
		forever #(clock_period / 2) clk <= ~clk;
	end
	

	
	initial begin
		reset <= 1; repeat(2) @(posedge clk);
		reset <= 0; repeat(34) @(posedge clk);
		reset <= 1; repeat(3)  @(posedge clk);
		reset <= 0; repeat(3)  @(posedge clk);

	$stop;
	end
	
endmodule