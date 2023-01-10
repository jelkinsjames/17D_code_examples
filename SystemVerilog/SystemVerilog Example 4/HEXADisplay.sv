// Julian James
// 11/18/2022
// E E 371
// Lab 4 Task 2

// Displays a given 4 bit number in hexadecimal format on a HEX display.
// INPUTS: 
//		1-bit: clk - the clock that the HEX runs off
//		4-bit: data - the 4 bit number to be displayed
// OUPUTS: 
//		7-bit: HEX - the 7-bit hexadecimal display array
module HEXADisplay (clk, reset, data, HEX);
	input logic clk, reset;
	input logic [3:0] data;
	output logic [6:0] HEX;
	
	//Assigns 4-bit data to the 7-bit HEX display icon of it.
	//Default is HEX display off.
	
	always_ff @(posedge clk) 
		begin
			if (reset) HEX = 7'b1001100; // r, for reset
			else
				begin
					case (data)
						0:  HEX = 7'b1000000;
						1:  HEX = 7'b1111001;
						2:  HEX = 7'b0100100;
						3:  HEX = 7'b0110000;
						4:  HEX = 7'b0011001;
						5:  HEX = 7'b0010010;
						6:  HEX = 7'b0000010;
						7:  HEX = 7'b1111000;
						8:  HEX = 7'b0000000;
						9:  HEX = 7'b0010000;
						10: HEX = 7'b0001000; // A
						11: HEX = 7'b0000011; // B
						12: HEX = 7'b1000110; // C
						13: HEX = 7'b0100001; // D
						14: HEX = 7'b0000110; // E
						15: HEX = 7'b0001110; // F
						default HEX = 7'b1111111; // off
					endcase
				end
		end

endmodule

// Test to see if all 4-bit numbers in hexadecimal are displayed correctly on the HEX displays
// by HEXDisplay
module HEXADisplay_testbench();
	logic clk;
	logic [3:0] data;
	logic [6:0] HEX;
	
	// Sets up the module to be tested in the testbench.
	
	HEXADisplay dut (.clk, .data, .HEX);
	
	// Sets up the clock for use in the simulation.
	
	parameter clock_period = 100;
	initial begin
		clk <= 0;
		forever #(clock_period / 2) clk <= ~clk;
	end
	
	//Tests all possible outputs of module.
	
	initial 
		begin
			// Increments through all possible data.
			data <= 4'b0000; @(posedge clk); //0
			data <= 4'b0001; @(posedge clk); //1
			data <= 4'b0010; @(posedge clk); //2
			data <= 4'b0011; @(posedge clk); //3
			data <= 4'b0100; @(posedge clk); //4
			data <= 4'b0101; @(posedge clk); //5
			data <= 4'b0110; @(posedge clk); //6
			data <= 4'b0111; @(posedge clk); //7
			data <= 4'b1000; @(posedge clk); //8
			data <= 4'b1001; @(posedge clk); //9
			data <= 4'b1010; @(posedge clk); //A
			data <= 4'b1011; @(posedge clk); //B
			data <= 4'b1100; @(posedge clk); //C
			data <= 4'b1101; @(posedge clk); //D
			data <= 4'b1110; @(posedge clk); //E
			data <= 4'b1111; @(posedge clk); //F
			// Try a few non-incremental data inputs to see if it still works.
			data <= 4'b1001; @(posedge clk);
			data <= 4'b1100; @(posedge clk);
			data <= 4'b0010; @(posedge clk);
			// Sets input to zero and holds to see if it stays on.
			data <= 4'b0000; repeat(5) @(posedge clk); //0, stays on
			// Stops simulation.
			$stop;
		end
endmodule