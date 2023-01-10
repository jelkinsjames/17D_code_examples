// Julian James
// 10/24/2022
// E E 371
// Lab 2 Task 1

// The RAM module, which stores all of the RAM data in the central 4x32 array and 
// performs all the changes in the array.
// INPUTS: 1-bit clk, wr_en, 4-bit addr, wrdata
// OUTPUT: 4-bit read_out
module RAM (clk, wr_en, addr, wr_data, read_out);
	input logic clk, wr_en;
	input logic [4:0] addr;
	input logic [3:0] wr_data;
	output logic [3:0] read_out;
	
	// 32x4 Array that acts as the storage area for the RAM data.
	
	logic [3:0] memory_array [31:0];

	always_ff @(posedge clk) begin
		if (wr_en) memory_array[addr] <= wr_data;
	end
	
	assign read_out = memory_array[addr];

endmodule

//This tests all expected behavior of the RAM module.
module RAM_testbench();
	logic clk, wr_en;
	logic [4:0] addr;
	logic [3:0] wr_data;
	logic [3:0] read_out;
	
	RAM dut (.clk, .wr_en, .addr, .wr_data, .read_out);

	//Sets up the clock for use in the simulation.
	
	parameter clock_period = 100;
	initial begin
		clk <= 0;
		forever #(clock_period / 2) clk <= ~clk;
	end
	
	// Tests regular function of module.
	initial begin
		addr <= 5'b00000; wr_data <= 4'b0000; wr_en <= 0; @(posedge clk);
		// Writing data to address
		wr_en <= 1; wr_data <= 4'b0001; repeat(2) @(posedge clk); // read_out should read 0000 then 0001
		// Trying to write data to another address when wr_en <= 0
		wr_en <= 0; addr <= 5'b00001; wr_data <= 4'b1000; repeat(2) @(posedge clk);
		// Reading our old data
		addr <= 5'b0000; repeat(2) @(posedge clk);
		
		$stop;
		
	end
endmodule