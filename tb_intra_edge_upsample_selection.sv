// Filename    : tb_intra_edge_upsample_selection.sv
// Author      : Jean-Paul Astal-Stain
// Description : 
// Created     : 22/04/2020 
// Changes     : 
//	To-do     	: 

`timescale 1ns/1ns

module tb_intra_edge_upsample_selection(
	input 				 tb_clk,
	output logic [9:0] out_tb
);

// define internal registers
logic 				 clk;
logic       		 filterType_in;
logic 		 [9:0] w_in;
logic 		 [9:0] h_in;
logic signed [9:0] delta_in;
logic 	   		 result;


// instantiate the uut
intra_edge_upsample_selection uut(.clk(clk),
											 .w(w_in), 
											 .h(h_in), 
											 .filterType(filterType_in), 
											 .delta(delta_in),
											 .useUpsample(result));

// push data into the module
initial
	begin
		// set all registers to 0
		w_in 			  = 10'd0;
		h_in 			  = 10'd0;
		filterType_in = 1'd0;
		delta_in		  = 10'd0;
		
		// wait 100ns
		w_in = 10'd4;
		h_in = 10'd4;
		filterType_in = 1'd0;
		delta_in = 10'd39;

	end

// always toggle clock every 5ns
always
	begin
		clk = 1'b0;
		#5;
		clk = 1'b1;
		#5;
	end
endmodule : tb_intra_edge_upsample_selection