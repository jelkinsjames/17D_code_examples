// A D Flip Flip implementation used to elminate possible metastability in the 
// inputs. Output is input updated every clock cycle.
// INPUTS:
// 	IN - the input signal
//		reset - resets the D FF to FALSE.
//		clk - clock used to clock the FF.
// OUPUTS:
//		OUT - the stabilized output signal.
module d_ff (in, reset, clk, out);
	input logic in, reset, clk;
	output logic out;
	
	always_ff @(posedge clk) begin // Output updates every positive edge of the clock.
		if (in) 
			out <= 1;
		else 
			out <= 0;
	end

endmodule

// This is a testbench for the D FF module.
// EXPECTED BEHAVIOR:
// 	RESET = 1, out = 0.
// 	RESET = 0, in = 0, out = 0 next clock cycle.
// 				  in = 1, out = 1 next clock cycle.
module d_ff_testbench();
	logic in, clk, reset;
	logic out;
	
	d_ff dut (in, reset, clk, out); // D Flip Flop Tested.
	
	// Sets up a simulated clock to toggle (from low to high or high to low)
	// every 50 time steps.
	parameter CLOCK_PERIOD=100;
	initial begin
   		clk <= 0;
   		forever #(CLOCK_PERIOD/2) clk <= ~clk;//toggle the clock indefinitely
	end 
	
	initial begin
									reset <= 1;								@(posedge clk);
									reset <= 0; in	<= 0;	  repeat(2)	@(posedge clk);
									in <= 1;					  repeat(2) @(posedge clk);
									in <= 0;		#10;
									in <= 1; 				  repeat(2) @(posedge clk);
	end
endmodule
	