// Filename    : tb_intra_edge_upsample.sv
// Author      : Jean-Paul Astal-Stain
// Description : 
// Created     : 22/04/2020 
// Changes     : 
//	To-do     	: 

`timescale 1ns/1ns

module tb_intra_edge_upsample(
	input 		 clk_tb,
	output logic [31:0] out_tb [0:8]
);

// define internal registers
logic clk_in;
logic [9:0] numPx_in;
logic [29:0] referencePixel_in;
logic [29:0] leftCol_in [0:7];
logic [29:0] result [0:16];


// instantiate the uut
intra_edge_upsample uut (.clk(clk_in),
								 .referencePixel(referencePixel_in), 
								 .numPx(numPx_in),
								 .input_array(leftCol_in), 
								 .upsampled_array(result));

// push data into the module
initial 
	begin
		
		// set all registers to 0
		referencePixel_in = 30'd0;
		numPx_in = 10'd0;
		leftCol_in = '{30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0};
		
		// wait 100ns
		#100;
		
		referencePixel_in = 30'd150;
		leftCol_in = '{30'd15, 30'd50, 30'd23, 30'd4, 30'd15, 30'd50, 30'd23, 30'd4};
		
	end

// toggle the clock every 5ns
always
	begin
		clk_in = 1'b0;
		#5;
		clk_in = 1'b1;
		#5;
	end

endmodule : tb_intra_edge_upsample