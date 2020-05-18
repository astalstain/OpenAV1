// Filename    : tb_intra_control.sv
// Author      : Jean-Paul Astal-Stain
// Description : 
// Created     : 09/05/2020
// Changes     :
 
// MODE DEFINITIONS:
//
//			0			 : 					 DC PREDICTION
//			1			 :				 VERTICAL PREDICTION
// 		2			 : 		  HORIZONTAL PREDICTION
//			3			 :	  	 45 DIRECTIONAL PREDICTION
//			4			 :		135 DIRECTIONAL PREDICTION
//			5 			 : 	113 DIRECTIONAL PREDICTION
//			6 			 :		157 DIRECTIONAL PREDICTION
//			7			 :		203 DIRECTIONAL PREDICTION
//			8 			 : 	67  DIRECTIONAL PREDICTION
// 		9			 :					SMOOTH PREDICTION
//	     10			 :			    SMOOTH_V PREDICTION
//		  11			 : 			 SMOOTH_H PREDICTION
//		  12			 : 			    PAETH PREDICTION 

`timescale 1ps/1ps

module tb_intra_control(
	input 				 clk_tb,
	output logic [9:0] out_tb [0:3][0:3]
);

// define internal registers
logic clk_in;
logic plane_in;
logic haveLeft_in;
logic haveAbove_in;
logic haveAboveRight_in;
logic haveBelowLeft_in;
logic use_filter_intra_in;
logic [9:0] AngleDeltaY_in;
logic [9:0] AngleDeltaUV_in;
logic [9:0] base_angle_in;
logic [3:0] mode_in;
logic [9:0] log2W_in;
logic [9:0] log2H_in;
logic [15:0] x_in;
logic [15:0] y_in;
logic [9:0] result [0:3][0:3];

// instantiate the module
intra_control uut(.clk(clk_in),
						.plane(plane_in),
						.haveLeft(haveLeft_in),
						.haveAbove(haveAbove_in),
						.use_filter_intra(use_filter_intra_in),
						.AngleDeltaY(AngleDeltaY_in),
						.AngleDeltaUV(AngleDeltaUV_in),
						.base_angle(base_angle_in),
						.mode(mode_in),
						.log2W(log2W_in),
						.log2H(log2H_in),
						.x(x_in),
						.y(y_in),
						.pred_out(result));

// push data into the module
initial
	begin
	
		#100;
	
		plane_in					= 1'd0;
		haveLeft_in				= 1'd0;
		haveAbove_in   		= 1'd0;
		use_filter_intra_in  = 1'd1;
		AngleDeltaY_in			= 10'd0;
		AngleDeltaUV_in		= 10'd0;
		base_angle_in			= 10'd135;
		mode_in					= 10'd4;
		log2W_in					= 10'd2;
		log2H_in					= 10'd2;		
		x_in						= 16'd4;
		y_in						= 16'd4;
		
		#100;
		
		plane_in					= 1'd0;
		haveLeft_in				= 1'd1;
		haveAbove_in   		= 1'd0;
		use_filter_intra_in  = 1'd1;
		AngleDeltaY_in			= 10'd0;
		AngleDeltaUV_in		= 10'd0;
		base_angle_in			= 10'd45;
		mode_in					= 10'd4;
		log2W_in					= 10'd2;
		log2H_in					= 10'd2;		
		x_in						= 16'd4;
		y_in						= 16'd4;
//		
		
	end

// toggle the clock every 5ns
always
	begin
		clk_in = 1'd0;
		#5;
		clk_in = 1'd1;
		#5;
		out_tb <= result;
		
		// set haveAbove, haveLeft, haveAboveRight, haveBelowLeft
		if(x_in == 10'd0)
			begin
				haveLeft_in = 1'd0;
			end
		else
			begin
				haveLeft_in = 1'd1;
			end
			
		if(y_in == 10'd0)
			begin
				haveAbove_in = 1'd0;
			end
		else
			begin
				haveAbove_in = 1'd1;
			end
			
		if((x_in == 10'd1920) || (y_in == 10'd0))
			begin
				haveAboveRight_in = 1'd0;
			end
		else
			begin
				haveAboveRight_in = 1'd1;
			end
			
		if((x_in == 10'd0) || (y_in == 10'd1080))
			begin
				haveBelowLeft_in = 1'd0;
			end
		else
			begin
				haveBelowLeft_in = 1'd1;
			end
		
		// set referencePixel
		if((haveAbove_in == 1'd1) && (haveLeft_in = 1'd1))
			begin
				//referencePixel = csvread[x-1][y-1];
			end
		else if((haveAbove_in == 1'd1) && (haveLeft_in = 1'd0))
			begin
				//referencePixel = csvread[x][y-1];
			end
		else if((haveAbove_in = 1'd0) && (haveLeft_in = 1'd1))
			begin
				//referencePixel = csvread[x-1][y];
			end
		else
			begin
				//referencePixel = 30'd512;
			end
		
	end
	
endmodule : tb_intra_control