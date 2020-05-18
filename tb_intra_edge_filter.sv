// Filename    : tb_intra_edge_filter.sv
// Author      : Jean-Paul Astal-Stain
// Description : 
// Created     : 29/04/2020
// Changes     : 

`timescale 1ns/1ns

module tb_intra_edge_filter(
	input 				 clk_tb,
	output logic [9:0] out_tb
);

// define internal registers
logic 		clk_in;	
logic [29:0] referencePixel_in;
logic [9:0] filter_strength_in; 	   
logic [29:0] aboveRow_in 		   [0:7];
logic [29:0] result					[0:7];

// instantiate the module
intra_edge_filter uut(.clk(clk_in), 
							 .referencePixel(referencePixel_in),
							 .filter_strength(filter_strength_in), 
							 .input_array(aboveRow_in),
							 .filtered_array(result));
							 
// push data into the module
initial
	begin
		
		// set all inputs to 0
		referencePixel_in	 = 30'd0;
		filter_strength_in = 10'd0;
		aboveRow_in			 = '{30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0};
		
		
		// wait 100ns
		#100;
		
		// push test vectors into module
		referencePixel_in	 = {10'd150, 10'd150, 10'd150};
		filter_strength_in = 10'd2;
		aboveRow_in			 = '{ 30'd12, 30'd500, 30'd16, 30'd290, 30'd12, 30'd500, 30'd16, 30'd290};
		
	end

// toggle the clock every 5ns
always
	begin
		clk_in = 1'd0;
		#5;
		clk_in = 1'd1;
		#5;
	end

endmodule : tb_intra_edge_filter