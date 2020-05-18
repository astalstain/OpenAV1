// Filename    : tb_smooth.sv
// Author      : Jean-Paul Astal-Stain
// Description : 
// Created     : 26/04/2020
// Changes     : 

`timescale 1ps/1ps

module tb_smooth_mode(
	input 				 clk_tb,
	output logic [9:0] out_tb
);

// define internal registers
logic 	   clk_in;
logic [3:0] mode_in;
logic [9:0] log2W_in;
logic [9:0] log2H_in;
logic [29:0] aboveRow_in [0:7];
logic [29:0] leftCol_in  [0:7];
logic [29:0] result 	   [0:3][0:3];

// instantiate the module
smooth_mode uut(.clk(clk_in),
			  .mode(mode_in),
			  .log2W(log2W_in),
			  .log2H(log2H_in),
			  .aboveRow(aboveRow_in),
			  .leftCol(leftCol_in),
			  .pred(result));


// push data into the module
initial
	begin
	
		// set all inputs to zero
		mode_in     = 4'd0;
		log2W_in    = 10'd0;
		log2H_in    = 10'd0;
		aboveRow_in = '{30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0};
		leftCol_in  = '{30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0};
		
		// wait 100ns
		#100;
		
		// stimulate with test vectors
		mode_in 		= 4'd9;
		log2W_in 	= 10'd3;
		log2H_in    = 10'd2;
		aboveRow_in = '{30'd150, 30'd20, 30'd360, 30'd41, 30'd150, 30'd20, 30'd360, 30'd41};
		leftCol_in  = '{30'd540, 30'd40, 30'd153, 30'd23, 30'd540, 30'd40, 30'd153, 30'd23 };
		
		#100;
		
		// stimulate with test vectors
		mode_in 		= 4'd10;
		log2W_in 	= 10'd3;
		log2H_in    = 10'd2;
		aboveRow_in = '{30'd150, 30'd20, 30'd360, 30'd41, 30'd150, 30'd20, 30'd360, 30'd41};
		leftCol_in  = '{30'd540, 30'd40, 30'd153, 30'd23, 30'd540, 30'd40, 30'd153, 30'd23 };
		
	
	end

// toggle the clock every 5ns
always
	begin
		clk_in = 1'd0;
		#5;
		clk_in = 1'd1;
		#5;
	end

endmodule : tb_smooth_mode