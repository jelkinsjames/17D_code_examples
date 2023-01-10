// Julian James
// 10/24/2022
// E E 371
// Lab 2 Task 1

// Displays the address, data being written to, and data being read off of a RAM.
// Values for address, read and write data must be given to work. 32-bit address
// data is displayed on two hexes, addr HEX1 and HEX2.
// Supports up to 32 addresses.
// INPUTS: 1-bit clk, 4-bit addr, dataWrite, dataRead
// OUTPUTS: 7-bit hexadecimal addrHEX1, addrHEX2, writeHEX, readHEX.
module RAMDisplay (clk, reset, wr_addr, wr_data, re_addr, re_data, 
						 re_addrHEX1, re_addrHEX0, wr_addrHEX1, wr_addrHEX0, wr_dataHEX, re_dataHEX);
	input clk, reset;
	input [4:0] wr_addr, re_addr;
	input [3:0] wr_data, re_data;
	output [6:0] re_addrHEX1, re_addrHEX0, wr_addrHEX1, wr_addrHEX0, wr_dataHEX, re_dataHEX;
	
	// To display up to 32 addresses, addr is split into first and second
	// HEXA bit.
	
	logic [3:0] re_addrbit1;
	logic [3:0] re_addrbit0;
	
	logic [3:0] wr_addrbit1;
	logic [3:0] wr_addrbit0;
	
	assign re_addrbit1 = re_addr[4];
	assign re_addrbit0 = re_addr[3:0];
	
	assign wr_addrbit1 = wr_addr[4];
	assign wr_addrbit0 = wr_addr[3:0];
	
	// First and second bits of address are split here.
	
	HEXADisplay displayReAddr1 (.clk, .reset, .data(4'(re_addrbit1)), .HEX(re_addrHEX1));
	
	HEXADisplay displayReAddr0 (.clk, .reset, .data(4'(re_addrbit0)), .HEX(re_addrHEX0));
	
	HEXADisplay displayWrAddr1 (.clk, .reset, .data(4'(wr_addrbit1)), .HEX(wr_addrHEX1));
	
	HEXADisplay displayWrAddr0 (.clk, .reset, .data(4'(wr_addrbit0)), .HEX(wr_addrHEX0));
	
	// Data that is read and written is sent to be displayed here.
	
	HEXADisplay displayWrData (.clk, .reset, .data(wr_data), .HEX(wr_dataHEX));
	
	HEXADisplay displayReData (.clk, .reset, .data(re_data), .HEX(re_dataHEX));
	
endmodule

// Tests to see if all of the given numbers are displayed correctly by RAMDisplay
module RAMDisplay_testbench();
	logic clk, reset;
	logic [4:0] wr_addr, re_addr;
	logic [3:0] wr_data, re_data;
	logic [6:0] re_addrHEX1, re_addrHEX0, wr_addrHEX1, wr_addrHEX0, wr_dataHEX, re_dataHEX;
	
	RAMDisplay dut (.*);
	
	// Sets up the clock for use in the simulation.
	
	parameter clock_period = 100;
	initial 
		begin
			clk <= 0;
			forever #(clock_period / 2) clk <= ~clk;
		end
	
	// Both of these are used to iterate variables in for loops later.
	
	logic [4:0] i;
	logic [3:0] j;
	//Tests all possible outputs of module.
	initial 
		begin
			// Set all to 0
			reset <= 1; repeat(2) @(posedge clk);
			reset <= 0; 
			wr_addr <= 5'b00000; wr_data = 4'b0000; re_addr = 5'b00000; re_data = 4'b0000; @(posedge clk);
			
			// Increases writing address input up to 31.
			
			for (i = 5'b00000; i < 5'b11111; i++) 
				begin
					wr_addr++; @(posedge clk);
				end
			wr_addr <= 5'b0; @(posedge clk);
			
			// Increases writing data up to 15.
			
			for (j = 4'b0; j < 4'b1111; j++) 
				begin
				  wr_data++; @(posedge clk);
				end
			wr_data <= 4'b0; @(posedge clk);
			
			// Increases reading address input up to 31.
			
			for (i = 5'b00000; i < 5'b11111; i++) 
				begin
					re_addr++; @(posedge clk);
				end
			re_addr <= 5'b0; @(posedge clk);
				
			// Increases reading data up to 15.
			
			for (j = 4'b0; j < 4'b1111; j++) 
				begin
					re_data++; @(posedge clk);
				end
			re_data <= 4'b0;	@(posedge clk);	

			// Tests multiple different values displayed at the same time.
		   // OUTPUTS: addrHEX1 = 7'b1111001, addrHEX0 = 00100101, dataWrite = 1111001, dataRead = 0011001
			
			wr_addr <= 5'b11111; wr_data <= 4'b0001; re_addr <= 5'b11010; re_data <= 4'b1110; repeat(2) @(posedge clk);																								
			
			//Stops simulation.
			
			$stop;
		end
endmodule