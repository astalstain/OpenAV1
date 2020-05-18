// Filename    : tb_control_directional_mode.sv
// Author      : Jean-Paul Astal-Stain
// Description : 
// Created     : 
// Changes     : 

`timescale 1ns/1ns

module tb_control_directional_mode(
	input 				 clk_tb,
	output logic [9:0] out_tb
);

// define internal registers
logic 				  clk_in;
logic 				  plane_in;
logic 				  haveLeft_in;
logic 				  haveAbove_in;
logic 		 [3:0]  mode_in;
logic					  enable_intra_edge_filter_in;
logic 		 [15:0] maxX_in;
logic 		 [15:0] maxY_in;
logic 		 [9:0]  w_in;
logic 		 [9:0]  h_in;
logic 		 [15:0] x_in;
logic 		 [15:0] y_in;
logic 		 [29:0]  referencePixel_in;
logic signed [9:0]  AngleDeltaY_in;
logic signed [9:0]  AngleDeltaUV_in;
logic signed [9:0]  base_angle_in;
logic 		 [29:0]  aboveRow_in 		[0:7];
logic 		 [29:0]  leftCol_in  		[0:7];
logic 		 [29:0]  result 				[0:3][0:3];

// instantiate the module
control_directional_mode uut(.clk(clk_in),
									  .plane(plane_in),
									  .haveLeft(haveLeft_in),
									  .haveAbove(haveAbove_in),
									  .mode(mode_in),
									  .AngleDeltaY(AngleDeltaY_in),
									  .AngleDeltaUV(AngleDeltaUV_in),
									  .referencePixel(referencePixel_in),
									  .enable_intra_edge_filter(enable_intra_edge_filter_in),
									  .maxX(maxX_in),
									  .maxY(maxY_in),
									  .base_angle(base_angle_in),
									  .w(w_in),
									  .h(h_in),
									  .x(x_in),
									  .y(y_in),
									  .aboveRow(aboveRow_in),
									  .leftCol(leftCol_in),
									  .pred(result));


// push data into the module
initial
	begin
	
		// initialise all input data to 0
		plane_in 		 				 = 1'd0;
		haveLeft_in 	 				 = 1'd0;
		haveAbove_in 	 				 = 1'd0;
		mode_in 		    				 = 4'd0;
		enable_intra_edge_filter_in = 1'd0;
		referencePixel_in           = 30'd0;
		AngleDeltaY_in  				 = 10'd0;
		AngleDeltaUV_in 			 	 = 10'd0;
		maxX_in 	       				 = 10'd0;
		maxY_in 			 				 = 10'd0;
		base_angle_in 	 				 = 10'd0;
		w_in 			    				 = 10'd0;
		h_in 				 				 = 10'd0;
		x_in 				 				 = 10'd0;
		y_in 			    				 = 10'd0;
		aboveRow_in 	 				 = '{30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0};
		leftCol_in 	    				 = '{30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0};
		
		// wait 100ns
		#100;
		
		// push data into module
		plane_in 		 				 = 1'd0;
		haveLeft_in 	 				 = 1'd0;
		haveAbove_in 	 				 = 1'd1;
		mode_in 		    				 = 4'd0;
		enable_intra_edge_filter_in = 1'd1;
		referencePixel_in 			 = 30'd200;
		AngleDeltaY_in  				 = 10'd0;
		AngleDeltaUV_in 			 	 = 10'd0;
		maxX_in 	       				 = 10'd500;
		maxY_in 			 				 = 10'd20;
		base_angle_in 	 				 = 10'd45;
		w_in 			    				 = 10'd4;
		h_in 				 				 = 10'd4;
		x_in 				 				 = 10'd4;
		y_in 			    				 = 10'd4;
		leftCol_in  	 				 = '{30'd32537631, 30'd32537631, 30'd32537631, 30'd32537631, 30'd32537631, 30'd32537631, 30'd32537631, 30'd32537631};
		aboveRow_in			 			 = '{30'd32537631, 30'd32537631, 30'd32537631, 30'd32537631, 30'd32537631, 30'd32537631, 30'd32537631, 30'd32537631};
		
		
	end

// toggle the clock every 5ns
always
	begin
		clk_in = 1'd0;
		#5;
		clk_in = 1'd1;
		#5;
	end

endmodule : tb_control_directional_mode