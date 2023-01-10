// Julian James
// 10/24/2022
// E E 371
// Lab 2 Task 2

// Divides the clock by whatever divisor is given.
// INPUTS: 1-bit clk_in
// OUTPUTS: 1-bit clk_out
module clkdivider #(parameter divisor = 28'd50000000) (clk_in, clk_out);

	input logic  clk_in; // input clock on FPGA
	output logic clk_out; // output clock after dividing the input clock by divisor

	logic [27:0] counter = 28'd0;

	always_ff @(posedge clk_in)
		begin
			counter <= counter + 28'd1;
			if (counter >= (divisor - 1) )
				begin
					counter <= 28'd0;
				end
		end
		
	assign clk_out = 1'b((counter < (divisor / 2) ) ? 1'b1 : 1'b0);
endmodule

`timescale 1ns / 1ps
module clkdivider_testbench();
	logic clk_in;
	logic clk_out;

	clkdivider #(28'd2) dut (.clk_in(clk_in), .clk_out(clk_out));
 
	 initial begin
		clk_in = 0;
		forever #10 clk_in = ~clk_in;
	 end
			
endmodule