// Julian James
// 11/18/2022
// E E 371
// Lab 4 Task 1

// A Double D Flip Flop implementation used to elminate possible metastability in the 
// inputs. Output is input updated every clock cycle. Uses a counter to implement.
// INPUTS:
// 	1-bit: in - the input signal, reset - sets D FF to 0, clk - clock that D ff runs off of.
// OUPUTS:
//		1-bit: out - the stabilized output signal.
module stabilizer (clk, reset, in, out);
	input logic clk, reset, in;
	output logic out;
	
	logic count_true;
	logic count_false;
	
	always_ff @(posedge clk) // Output updates every positive edge of the clock.
		begin
			if (reset)
				begin
					out <= 0;
					count_false <= 0;
					count_true <= 0;
				end
			else
				begin
					if (in) 
						begin
							count_false <= 0;
							count_true <= 1;
							if (count_true) out <= 1;
						end
					else
						begin
							count_true <= 0;
							count_false <= 1;
							if (count_false) out <= 0;
						end
				end
		end

endmodule

// This is a testbench for the stabilizer module.
// EXPECTED BEHAVIOR:
// 	RESET = 1, out = 0.
// 	RESET = 0, in = 0, out = 0 next two clock cycles.
// 				  in = 1, out = 1 next two clock cycles.
module stabilizer_testbench();
	logic in, clk, reset;
	logic out;
	
	stabilizer dut (.*); // Stabilizer
	
	// Sets up a simulated clock to toggle (from low to high or high to low)
	// every 50 time steps.
	parameter CLOCK_PERIOD=100;
	initial begin
   		clk <= 0;
   		forever #(CLOCK_PERIOD/2) clk <= ~clk;//toggle the clock indefinitely
	end 
	
	initial begin
									reset <= 1;								@(posedge clk);
									reset <= 0; in	<= 0;	  repeat(3)	@(posedge clk);
									in <= 1;					  repeat(3) @(posedge clk);
									in <= 0;		#10;
									in <= 1; 				  repeat(3) @(posedge clk);
									in <= 0; 				  repeat(3) @(posedge clk);
									$stop;
	end
endmodule
	