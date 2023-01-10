// Julian James
// 10/24/2022
// E E 371
// Lab 2 Task 2


// Divides the clock by placing it into a very large array that counts up one by one.
// This slows down a very fast clock into something manageable.
// INPUT: 1-bit clock
// OUTPUT: 32-bit divided_clocks
module clock_divider (clock, divided_clocks);
	/* divided_clocks[0] = 25MHz, [1] = 12.5Mhz, ... 
	  [23] = 3Hz, [24] = 1.5Hz, [25] = 0.75Hz, ... */
	 input logic clock;
	 output logic [31:0] divided_clocks = 0;

	 always_ff @(posedge clock) begin
		divided_clocks <= divided_clocks + 1;
	 end

endmodule 