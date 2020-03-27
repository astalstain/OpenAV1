//`timescale 1ns/1ns

// test bench
module tb;

	// define inputs to the uut
	reg [127:0] A;
	reg [127:0] B;
	
	// define outputs from the uut
	wire [127:0] C;
	
	// instantiate the unit under test
	OpenAV1_forward_DCT uut(.A(A), .B(B), .C(C));
		
	// push test data into module
	initial
		begin
		
		// apply inputs
		A = 0;
		B = 0;
		#100;
		
		// initialise the arrays with test values
		A = {8'd0, 8'd1, 8'd0, 8'd2,
			  8'd0, 8'd0, 8'd2, 8'd4,
			  8'd0, 8'd4, 8'd3, 8'd1,
			  8'd0, 8'd0, 8'd8, 8'd5};
			  
	   B = {8'd4, 8'd5, 8'd6, 8'd7,
			  8'd1, 8'd3, 8'd0, 8'd0,
			  8'd1, 8'd0, 8'd2, 8'd6,
			  8'd6, 8'd4, 8'd4, 8'd5};
				
		end
		


endmodule