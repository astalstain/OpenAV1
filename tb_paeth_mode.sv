// Filename    : tb_paeth_mode.sv
// Author      : Jean-Paul Astal-Stain
// Description : 
// Created     : 29/04/2020
// Changes     : 

`timescale 1ns/1ns

module tb_paeth_mode(
	input 				 clk_tb,
	output logic [9:0] out_tb
);

// define internal registers
logic 		clk_in;
logic [9:0] w_in;
logic [9:0] h_in;
logic [29:0] referencePixel_in; 
logic [29:0] aboveRow_in		  [0:7];
logic [29:0] leftCol_in  		  [0:7];
logic [29:0] result       		  [0:3][0:3];

// instantiate the module
paeth_mode uut(.clk(clk_in),
					.referencePixel(referencePixel_in),
					.aboveRow(aboveRow_in),
					.leftCol(leftCol_in),
					.pred(result));

// push data into the module
initial
	begin
		
		// set all inputs to 0
		w_in 			   	= 10'd0;
		h_in 			      = 10'd0;
		referencePixel_in = 30'd0;
		aboveRow_in 		= '{30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0};
		leftCol_in 			= '{30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0};
		
		// wait 100ns
		#100;
		
		// push test vectors into uut
		w_in 					= 10'd4;
		h_in 					= 10'd4;
		referencePixel_in = 30'd150;
		aboveRow_in 		= '{30'd140, 30'd235, 30'd101, 30'd56, 30'd140, 30'd235, 30'd101, 30'd56};
		leftCol_in 			= '{	30'd5, 30'd170,  30'd12, 30'd230, 30'd140, 30'd235, 30'd101, 30'd56};
		
	end

// toggle the clock every 5ns
always
	begin
		clk_in = 1'd0;
		#5;
		clk_in = 1'd1;
		#5;
	end

endmodule : tb_paeth_mode