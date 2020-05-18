// Filename    : smooth.sv
// Author      : Jean-Paul Astal-Stain
// Description : 
// Created     : 
// Changes     : 

module smooth_mode
#(parameter W = 8,
  parameter H = 8)
(
	input  logic clk,
	input  logic [3:0] mode,
	input  logic [9:0] log2W,
	input  logic [9:0] log2H,
	input  logic [29:0] aboveRow [0:W-1],
	input  logic [29:0] leftCol  [0:H-1],
	output logic [29:0] pred [0:3][0:3]
);

// define weights - zeros added to makes sure the array has 64 elements
logic [9:0] Sm_Weights_Tx_4x4 [64]   = '{10'd255, 10'd149,  10'd85,  10'd64,   10'd0,   10'd0,   10'd0,  10'd0,
													   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,  10'd0,
													   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,  10'd0,
													   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,  10'd0,
													   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,  10'd0,
													   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,  10'd0,
													   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,  10'd0,
													   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,  10'd0};
logic [9:0] Sm_Weights_Tx_8x8[64]   = '{10'd255, 10'd197, 10'd146, 10'd105,  10'd73,  10'd50,  10'd37,  10'd32,
														10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,  10'd0,
														10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,  10'd0,
														10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,  10'd0,
														10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,  10'd0,
														10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,  10'd0,
														10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,  10'd0,
														10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,  10'd0};
logic [9:0] Sm_Weights_Tx_16x16[64] = '{10'd255, 10'd225, 10'd196, 10'd170, 10'd145, 10'd123, 10'd102,  10'd84, 
													  10'd68,  10'd54,  10'd43,  10'd33,  10'd26,  10'd20,  10'd17,  10'd16,
													   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,  10'd0,
														10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,  10'd0,
														10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,  10'd0,
														10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,  10'd0,
														10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,  10'd0,
														10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,  10'd0};
logic [9:0] Sm_Weights_Tx_32x32[64] = '{10'd255, 10'd240, 10'd225, 10'd210, 10'd196,  10'd82, 10'd169, 10'd157,
													 10'd145, 10'd133, 10'd122, 10'd111, 10'd101,  10'd92,  10'd83,  10'd74,
													  10'd66,  10'd59,  10'd52,  10'd45,  10'd39,  10'd34,  10'd29,  10'd25, 
													  10'd21,  10'd17,  10'd14,  10'd12,  10'd10,   10'd9,   10'd8,   10'd8,
													  	10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,  10'd0,
														10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,  10'd0,
														10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,  10'd0,
														10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,   10'd0,  10'd0};
logic [9:0] Sm_Weights_Tx_64x64[64] = '{10'd255, 10'd248, 10'd240, 10'd233, 10'd225, 10'd218, 10'd210, 10'd203,
													 10'd196, 10'd189, 10'd182, 10'd176, 10'd169, 10'd163, 10'd156, 10'd150,
													 10'd144, 10'd138, 10'd133, 10'd127, 10'd121, 10'd116, 10'd111, 10'd106,
													 10'd101,  10'd96,  10'd91,  10'd86,  10'd82,  10'd77,  10'd73,  10'd69,
													  10'd65,  10'd61,  10'd57,  10'd54,  10'd50,  10'd47,  10'd44,  10'd41, 
													  10'd38,  10'd35,  10'd32,  10'd29,  10'd27,  10'd25,  10'd22,  10'd20, 
													  10'd18,  10'd16,  10'd15,  10'd13,  10'd12,  10'd10,   10'd9,   10'd8,
													   10'd7,   10'd6,   10'd6,   10'd5,   10'd5,   10'd4,   10'd4,   10'd4};

// define internal registers

logic [21:0] smoothPredY;
logic [21:0] smoothPredU;
logic [21:0] smoothPredV;
logic [9:0] rounded_smoothPredY;
logic [9:0] rounded_smoothPredU;
logic [9:0] rounded_smoothPredV;
logic [9:0] buffer_check;
logic [9:0] smWeights 			 [64];
logic [9:0] smWeightsX  		 [64];
logic [9:0] smWeightsY  		 [64];
logic [29:0] buffer_full 		 [0:3][0:3];
logic output_enable;
int i;
int j;

// always_ff
always_ff @(posedge clk)
	begin
	
		// check to see if buffer has been filled
		if(buffer_check == 10'd16)
			begin
				// push buffer to output
				pred <= buffer_full;
			end
		
		$display("output_enable: %d", output_enable);

	end

// always_comb
always_comb
	begin
		
		// initialise to zero to prevent latching
		i 						 = 0;
		j 						 = 0;
		smoothPredY			 = 10'd0;
		smoothPredU			 = 10'd0;
		smoothPredV			 = 10'd0;
		
		rounded_smoothPredY = 10'd0;
		rounded_smoothPredU = 10'd0;
		rounded_smoothPredV = 10'd0;
		
		smWeights 			 = '{default:0};
		smWeightsX 			 = '{default:0};
		smWeightsY 			 = '{default:0};
		buffer_full 		 = '{default:0};
		buffer_check = 10'd0;
		//output_enable = 1'd1;
		// SMOOTH_PRED = 9
		// SMOOTH_V_PRED = 10
		// SMOOTH_H_PRED = 11
		
		//buffer_check = 10'd0;
		
		// if intra mode set to SMOOTH_PRED, do the following
		if(mode == 4'd9)
			begin
			
				output_enable = 1'd1;
				
				$display("correct area");
				for(i = 0; i < H/2; i++)
					begin
						for(j = 0; j < W/2; j ++)
							begin
							
								// set smWeightsX depending on log2W
								if(log2W == 10'd2)
									begin
										smWeightsX = Sm_Weights_Tx_4x4;
									end
								else if(log2W == 10'd3)
									begin
										smWeightsX = Sm_Weights_Tx_8x8;
									end
								else if(log2W == 10'd4)
									begin
										smWeightsX = Sm_Weights_Tx_16x16;
									end
								else if(log2W == 10'd5)
									begin
										smWeightsX = Sm_Weights_Tx_32x32;
									end
								else if (log2W == 10'd6)
									begin
										smWeightsX = Sm_Weights_Tx_64x64;
									end
								
								// set smWeightsY depending on log2H
								if(log2H == 10'd2)
									begin
										smWeightsY = Sm_Weights_Tx_4x4;
									end
								else if(log2H == 10'd3)
									begin
										smWeightsY = Sm_Weights_Tx_8x8;
									end
								else if(log2H == 10'd4)
									begin
										smWeightsY = Sm_Weights_Tx_16x16;
									end
								else if(log2H == 10'd5)
									begin
										smWeightsY = Sm_Weights_Tx_32x32;
									end
								else if(log2H == 10'd6)
									begin
										smWeightsY = Sm_Weights_Tx_64x64;
									end
																		
								// calculate smoothPred for Y, U and V
								smoothPredY = 10'(smWeightsY[i] * aboveRow[j][9:0] +
												 (10'd256 - smWeightsY[i]) * leftCol[(H/2) - 1][9:0] +
												 smWeightsX[j] * leftCol[i][9:0] +
												 (10'd256 - smWeightsX[j]) * aboveRow[(W/2) - 1][9:0]);
								smoothPredU = 10'(smWeightsY[i] * aboveRow[j][19:10] +
												(10'd256 - smWeightsY[i]) * leftCol[(H/2) - 1][19:10] +
												smWeightsX[j] * leftCol[i][19:10] +
												(10'd256 - smWeightsX[j]) * aboveRow[(W/2) - 1][19:10]);
								smoothPredV = 10'(smWeightsY[i] * aboveRow[j][29:20] +
												 (10'd256 - smWeightsY[i]) * leftCol[(H/2) - 1][29:20] +
												 smWeightsX[j] * leftCol[i][29:20] +
												 (10'd256 - smWeightsX[j]) * aboveRow[(W/2) - 1][29:20]);
												 
								 //Round2(smoothPred, 9)
								 rounded_smoothPredY = 10'((smoothPredY + (1 << (9 - 1))) >> 9);
								 rounded_smoothPredU = 10'((smoothPredU + (1 << (9 - 1))) >> 9);
								 rounded_smoothPredV = 10'((smoothPredV + (1 << (9 - 1))) >> 9);
								 
								 // set buffer_full to rounded_smoothPred
								 buffer_full[i][j] = {rounded_smoothPredY, rounded_smoothPredU, rounded_smoothPredV};
								 
								 //$display("buffer_full[%d][%d]: %d",i,j, buffer_full[i][j]);
								 
								 buffer_check = buffer_check + 1;
								 //$display(buffer_check);
		

							end
					end
					
			end
			
		// if intra mode set to SMOOTH_V_PRED, do the following
		if(mode == 4'd10)
			begin
				for(i = 0; i < H/2; i++)
					begin
						for(j = 0; j < W/2; j ++)
							begin
							
								// set smWeights depending on log2H
								if(log2H == 10'd2)
									begin
										smWeights = Sm_Weights_Tx_4x4;
									end
								else if(log2H == 10'd3)
									begin
										smWeights = Sm_Weights_Tx_8x8;
									end
								else if(log2H == 10'd4)
									begin
										smWeights = Sm_Weights_Tx_16x16;
									end
								else if(log2H == 10'd5)
									begin
										smWeights = Sm_Weights_Tx_32x32;
									end
								else if(log2H == 10'd6)
									begin
										smWeights = Sm_Weights_Tx_64x64;
									end
							

								// calculate smoothPred
								smoothPredY = 10'(smWeights[i] * aboveRow[j][9:0] +
												 (10'd256 - smWeights[i]) * leftCol[(H/2) - 1][9:0]);
								smoothPredU = 10'(smWeights[i] * aboveRow[j][19:10] +
												 (10'd256 - smWeights[i]) * leftCol[(H/2) - 1][19:10]);
								smoothPredV = 10'(smWeights[i] * aboveRow[j][29:20] +
												 (10'd256 - smWeights[i]) * leftCol[(H/2) - 1][29:20]);
												 
								 //Round2(smoothPred, 8)
								 rounded_smoothPredY = 10'((smoothPredY + (1 << (8 - 1))) >> 8);
								 rounded_smoothPredU = 10'((smoothPredU + (1 << (8 - 1))) >> 8);
								 rounded_smoothPredV = 10'((smoothPredV + (1 << (8 - 1))) >> 8);
								 
								 // set buffer_full to rounded_smoothPred
								 buffer_full[i][j] = {rounded_smoothPredY, rounded_smoothPredU, rounded_smoothPredV};
								 
								  buffer_check = buffer_check + 1;
							end
					end
					
			end
			
		// if intra mode set to SMOOTH_H_PRED, do the following
		if(mode == 4'd11)
			begin
				for(i = 0; i < H/2; i++)
					begin
						for(j = 0; j < W/2; j ++)
							begin
							
								// set smWeights depending on log2H
								if(log2W == 10'd2)
									begin
										smWeights = Sm_Weights_Tx_4x4;
									end
								else if(log2W == 10'd3)
									begin
										smWeights = Sm_Weights_Tx_8x8;
									end
								else if(log2W == 10'd4)
									begin
										smWeights = Sm_Weights_Tx_16x16;
									end
								else if(log2W == 10'd5)
									begin
										smWeights = Sm_Weights_Tx_32x32;
									end
								else if(log2W == 10'd6)
									begin
										smWeights = Sm_Weights_Tx_64x64;
									end
							

								// calculate smoothPred
								smoothPredY = 10'(smWeights[j] * leftCol[i][9:0] +
												 (10'd256 - smWeights[j]) * aboveRow[(W/2) - 1][9:0]);
								smoothPredU = 10'(smWeights[j] * leftCol[i][19:10] +
												 (10'd256 - smWeights[j]) * aboveRow[(W/2) - 1][19:10]);
								smoothPredV = 10'(smWeights[j] * leftCol[i][29:20] +
												 (10'd256 - smWeights[j]) * aboveRow[(W/2) - 1][29:20]);
												 
								 //Round2(smoothPred, 8)
								 rounded_smoothPredY = 10'((smoothPredY + (1 << (8 - 1))) >> 8);
								 rounded_smoothPredU = 10'((smoothPredU + (1 << (8 - 1))) >> 8);
								 rounded_smoothPredV = 10'((smoothPredV + (1 << (8 - 1))) >> 8);
								 
								 // set buffer_full to rounded_smoothPred
								 buffer_full[i][j] = {rounded_smoothPredY, rounded_smoothPredU, rounded_smoothPredV};
								 
								  buffer_check = buffer_check + 1;
								 
							end
					end

			end

	end


endmodule : smooth_mode