// Julian James
// 11/18/2022
// E E 371
// Lab 4 Task 1

// Counts how many ones are in the given 8-bit array, and outputs the count.
// INPUTS:
// 	1-bit: clk - the clk running the module, reset - restarts count 
//				 start- starts count
// 	8-bit: in - the array that is examined for ones
// OUTPUTS:
//		1-bit: done - true when the module is done counting
// 	5-bit: numOnes - the number of ones found in the array
module oneCounter(   input logic        clk, reset, start,
							input logic  [7:0] in, 
							output logic [3:0] numOnes,
							output logic 		 done
							);
							
			
	logic [3:0] result;
	logic [7:0] A;

	enum {s1, s2, s3} ps, ns;	
	
							
	always_comb
		begin
		case (ps)
			s1: // Starting case
				 if (start) ns = s2;
				 else ns = s1;
			s2: // Counting case
				 if (A == 0) ns = s3;
				 else ns = s2;
			s3: // Done Case
				 if (!start) ns = s1;
				 else ns = s3;
		endcase
		end
		
	always_ff @(posedge clk)
		begin
			if (reset)
				begin
					ps <= s1;
					result <= 0;
					done <= 0;
				end
			else
				begin
				if (ps == s1)
					begin
						done <= 0;
						A <= in; // LOAD A in DSM
						result <= 0; //RESULT INITIALIZED TO 0.
					end
				else if (ps == s2) // Counting case
					begin
						if (A[0] == 1)
							begin
								result++;
							end
						A <= A >> 1; //Shifts A over each clock cycle to count 1's.
					end
				else if (ps == s3)
					begin
						done <= 1; // MODULE IS DONE
						numOnes <= result; //RESULT SENT TO OUTPUT
					end
				end
			ps <= ns;
		end

endmodule

// Tests exepected behavior of oneCounter and edge cases (all 0's, all 1's)
module oneCounter_testbench();
	logic 		clk, reset, start;
	logic [7:0] in;
	logic [3:0] numOnes;
	logic 		done;

	oneCounter dut (.*);
	
		
	// Runs the clock that is used in the simulation. FPGA clock is used in application.
	
	parameter clock_period = 100;
	initial 
		begin
			clk <= 0;
			forever #(clock_period / 2) clk <= ~clk;
		end

	initial
		begin
		reset <= 0; start <= 0; in <= 8'b0; repeat(2) @(posedge clk); 
		reset <= 1; repeat(2) @(posedge clk);
		//tests to see if counter starts before start is true
		reset <= 0; in <= 8'b1; repeat (2) @(posedge clk);
		// runs through and counts 00000001. Should remain in s3 until s = 0.							
		start <= 1; repeat(10) @(posedge clk);
		//tests transition from s3 to s1
		start <= 0; repeat(2) @(posedge clk);
		//tries again with 10101010.
		in <= 8'b10101010; start <= 1; repeat(10) @(posedge clk);
		//tests transition from s3 to s1
		start <= 0; repeat(2) @(posedge clk);
		//tries all 0's.
		in <= 8'b0; start <= 1; repeat (10) @(posedge clk);
		//tests transition from s3 to s1
		start <= 0; repeat(2) @(posedge clk);
		//tests all 1's
		in <= 8'b11111111; start <= 1; repeat(12) @(posedge clk);
		
		$stop;
		
		end
	
endmodule