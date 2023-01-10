// Julian James
// 10/24/2022
// E E 371
// Lab 2 Task 1

// Implements both the internal RAM and controls the HEX displays.
// INPUTS: 1-bit clk, write. 4-bits wr_data, addr
// OUTPUTS: 7-bit addrHEX1, addrHEX2, wrHEX, reHEX.
module RAMSystem (clk, wr_en, addr, wr_data, addrHEX1, addrHEX0, wrHEX, reHEX);
	input logic clk, wr_en;
	input logic [4:0] addr;
	input logic [3:0] wr_data;
	output logic [6:0] addrHEX1, addrHEX0, wrHEX, reHEX;
	
	// The data read from the given address by the RAM module. Passed to the Display.
	
	logic [3:0] dataRead;
	
	// Wires passed to the RAM and display modules.
	
	RAM ram (.clk, .wr_en, .addr, .wr_data, .read_out(dataRead));

	RAMDisplay display (.clk, .addr, .dataToWrite(wr_data), .dataRead, 
							 .addrHEX1, .addrHEX0, .wrHEX, .reHEX);
	
endmodule


//Tests all the expected behavior of this module.
module RAMSystem_testbench();
	logic clk, wr_en;
	logic [4:0] addr;
	logic [3:0] wr_data;
	logic [6:0] addrHEX1, addrHEX0, wrHEX, reHEX;
	
	RAMSystem dut (.clk, .wr_en, .addr, .wr_data, .addrHEX1, .addrHEX0, .wrHEX, .reHEX);

	//Sets up the clock for use in the simulation.
	
	parameter clock_period = 100;
	initial begin
		clk <= 0;
		forever #(clock_period / 2) clk <= ~clk;
	end
	
	//Tests proper function of module.
	
	initial begin
		addr <= 5'b00000; wr_data <= 4'b0000; wr_en <= 0; @(posedge clk);
		// Writing data to address
		wr_en <= 1; wr_data <= 4'b0001; repeat(2) @(posedge clk); //hex should read 0 then 1
		// trying to write data to address when write <= 0
		wr_en <= 0; addr <= 5'b0001; wr_data <= 4'b1000; repeat(2) @(posedge clk);
		//reading our old data
		addr <= 5'b00000; @(posedge clk); // hex should read 1
		//changing old data again
		wr_en <= 1; repeat(3) @(posedge clk);
		// Iterating through addresses.
		wr_en <= 0; 
		repeat(5) addr++; @(posedge clk)
		// Changing data. 
		repeat(5) wr_data++; @(posedge clk)
		
		$stop;
		
	end
endmodule