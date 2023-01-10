// Julian James
// 11/17/2022
// E E 371
// Lab 4 Task 2

// Searches an internal memory for an 8 bit array in using recursive binary search.
// INPUTS:
// 	1-bit: clk - the clock the logic runs off of, reset- resets the search to the starting point.
//				 start - starts counting. nothing happens when start = 0.
// 	8-bit: A - the number we are searching for.
// OUTPUTS:
//		1-bit: found - 1 if A was found, notfound - 1 if A was not found.
// 	5-bit: L - the address of A when found
`timescale 1 ps / 1 ps
module binarySearch (
								input logic clk, reset, start,
								input logic [7:0] A,
								output logic [4:0] L,
								output logic found, notfound
								
								);
		
	logic [7:0] in;
	
	logic [4:0] high;
	logic [4:0] mid;
	logic [4:0] low;
	logic [7:0] q;
	
	// Internal 32x8 RAM memory.
	 
	ram32x8 ram (.address(mid), .clock(clk), .data(8'b00000000), .wren(1'b0), .q);
	
	// Loads the memory with sorted 8 bit arrays.
		
	enum {s1, s2, s3, s4, s5} ps, ns;
	
	
	
	always_comb
		begin
			case (ps)
				s1: // start state
					if (start) 				ns = s2;
					else 						ns = s1;
				s2: // checking state
					if (q == in) 			ns = s4;
					else if (low > high) ns = s5;
					else 						ns = s3;
				s3: // indexing state
												ns = s2;

				s4: // found state
					if (!start) 			ns = s1;
					else 						ns = s4;
				s5: // not found state
					if (!start) 			ns = s1;
					else 						ns = s5;
			endcase
		end
	
	always_ff @(posedge clk)
		begin
			if (reset)	
				begin
					high <= 31;
					mid <= 15;
					low <= 0;
					found <= 0;
					notfound <= 0;
					ps <= s1;
					L <= 5'b00000;
				end
			else
				begin
					if (ps == s1)
						begin
							in <= A; // in is loaded
							high <= 31;
							mid <= 15;
							low <= 0;
							found <= 0;
							notfound <= 0;
							L <= 5'b00000;
						end
					else if (ps == s2 && ns != s4)
						begin
							mid <= (low + high) / 2; // MIDDLE OF ARRAY
						end
					else if (ps == s3)
						begin							
							begin
									if (in > q) low <= mid+1; // A is on right side
									else if (in < q) high <= mid-1; // A is on left side
							end
						end
					else if (ps == s4) 
						begin
							found <= 1'b1;
							L <= mid; // Array is sent to output.
						end
					else if (ps == s5) 
						notfound <= 1'b1;
				end
			ps <= ns;
		end
								
endmodule


// Tests:
// Value in the middle.
// Value in range 0-14
// Value in range 15-31
// Unable to find a value not in the list
module binarySearch_testbench();
	logic clk, reset, start;
	logic [7:0] A;
	logic [4:0] L;
	logic found, notfound;
	
	binarySearch dut (.*);
	
	
	//Sets up the clock for use in the simulation.
	
	parameter clock_period = 100;
	initial begin
		clk <= 0;
		forever #(clock_period / 2) clk <= ~clk;
	end
	
	// Memory is full of even data starting at addr 1.
	initial
		begin
			reset <= 1; start <= 0; A <= 8'd30; repeat (2) @(posedge clk);
			// Tests value at addr 15.
			reset <= 0; start <= 1; repeat(4) @(posedge clk);
			start <= 0; repeat(3) @(posedge clk);
			// Tests value at addr 0.
			A <= 8'b00000000; start <= 1; repeat(22) @(posedge clk);
			start <= 0; repeat(3) @(posedge clk);
			// Tests value at addr 31.
			A <= 8'd62; start <= 1; repeat(22) @(posedge clk);
			start <= 0; repeat(3) @(posedge clk);
			// Tests odd value not in the memory.
			A <= 8'd17; start <= 1; repeat(22) @(posedge clk);
			start <= 0; repeat(3) @(posedge clk);
			// Tests value > values in memory.
			A <= 8'd300; start <= 1; repeat(22) @(posedge clk);
			start <= 0; repeat(3) @(posedge clk);
			// Tests value < values in memory.
			A <= 8'd1; start <= 1; repeat(25) @(posedge clk);
			start <= 0; repeat(3) @(posedge clk);
			
			$stop;
		end			
endmodule