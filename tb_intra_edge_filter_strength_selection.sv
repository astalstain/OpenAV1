// Filename    : tb_intra_edge_filter_strength_selection.sv
// Author      : Jean-Paul Astal-Stain
// Description : 
// Created     : 22/04/2020 
// Changes     : 
//	To-do     	: 

`timescale 1ns/1ns

module tb_intra_edge_filter_strength_selection(
	input  logic       clock,
	output       [7:0] out_tb
);

// define internal registers 
logic 			    clk;
logic 		 [9:0] w_in;
logic 		 [9:0] h_in;
logic 		 [9:0] filterType_in;
logic signed [9:0] delta_in;
logic 		 [9:0] result;

// instantiate the uut
intra_edge_filter_strength_selection uut(.clk(clk), 
													  .w(w_in),
													  .h(h_in), 
													  .filterType(filterType_in),
													  .delta(delta_in), 
													  .filter_strength(result));


initial
	begin
		// set all values to 0
		w_in 			  = 8'd0;
		h_in 			  = 8'd0;
		filterType_in = 8'd0;
		delta_in      = 8'd0;
		result		  = 8'd0;
		
		// wait 100ns
		#100;
		
		// set test vectors
		w_in          = 8'd4;
		h_in          = 8'd4;
		filterType_in = 8'd1;
		delta_in      = 8'd65;
		
	end

always
	begin
		clk = 1'b0;
		#5;
		clk = 1'b1;
		#5;
	end

endmodule : tb_intra_edge_filter_strength_selection