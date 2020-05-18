// Filename    : paeth_mode.sv
// Author      : Jean-Paul Astal-Stain
// Description : 
// Created     : 
// Changes     : 

module paeth_mode
#(parameter W = 8,
  parameter H = 8)
(
	input  logic       clk,
	//input  logic [9:0] w,
	//input  logic [9:0] h,
	input  logic [29:0] referencePixel, 
	input  logic [29:0] aboveRow [0:W-1],
	input  logic [29:0] leftCol  [0:H-1],
	output logic [29:0] pred     [0:(W/2)-1][0:(H/2)-1]
);

// define internal registers
int i;
int j;
logic        [9:0] baseY;
logic        [9:0] baseU;
logic        [9:0] baseV;
logic 		 [9:0] abs_pLeftY;
logic 		 [9:0] abs_pLeftU;
logic 		 [9:0] abs_pLeftV;
logic        [9:0] abs_pTopY;
logic        [9:0] abs_pTopU;
logic        [9:0] abs_pTopV;
logic			 [9:0] abs_pTopLeftY;
logic			 [9:0] abs_pTopLeftU;
logic			 [9:0] abs_pTopLeftV;
logic signed [9:0] pLeftY;
logic signed [9:0] pLeftU;
logic signed [9:0] pLeftV;
logic signed [9:0] pTopY;
logic signed [9:0] pTopU;
logic signed [9:0] pTopV;
logic signed [9:0] pTopLeftY;
logic signed [9:0] pTopLeftU;
logic signed [9:0] pTopLeftV;

logic 		 [29:0] buffer   [0:(W/2)-1][0:(H/2)-1];


// always_ff
always_ff @(posedge clk)
	begin
		pred <= buffer;
	end

// always_comb
always_comb
	begin
		
		i = 0;
		j = 0;
		
		baseY = 10'd0;
		baseU = 10'd0;
		baseV = 10'd0;
		abs_pLeftY = 10'd0;
		abs_pLeftU = 10'd0;
		abs_pLeftV = 10'd0;
		
		abs_pTopY = 10'd0;
		abs_pTopU = 10'd0;
		abs_pTopV = 10'd0;
		
		abs_pTopLeftY = 10'd0;
		abs_pTopLeftU = 10'd0;
		abs_pTopLeftV = 10'd0;
		
		pLeftY = 10'd0;
		pLeftU = 10'd0;
		pLeftV = 10'd0;
		
		pTopY = 10'd0;
		pTopU = 10'd0;
		pTopV = 10'd0;
		
		pTopLeftY = 10'd0;
		pTopLeftU = 10'd0;
		pTopLeftV = 10'd0;
		
		
		for(i = 0; i < H/2; i++)
			begin
				for(j = 0; j < W/2; j++)
					begin
						
						// set base for Y, U and V
						baseY = aboveRow[j][9:0] + leftCol[i][9:0] - referencePixel[9:0];
						baseU = aboveRow[j][19:10] + leftCol[i][19:10] - referencePixel[19:10];
						baseV = aboveRow[j][29:20] + leftCol[i][29:20] - referencePixel[29:20];
						
						
						// set abs(pLeft) for Y, U and V
						pLeftY = baseY - leftCol[i][9:0];
						pLeftU = baseU - leftCol[i][19:10];
						pLeftV = baseV - leftCol[i][29:20];
						
						if(pLeftY > 0)
							begin
								abs_pLeftY = pLeftY;
							end
						else
							begin
								abs_pLeftY = -pLeftY;
							end
							
						if(pLeftU > 0)
							begin
								abs_pLeftU = pLeftU;
							end
						else
							begin
								abs_pLeftU = -pLeftU;
							end
						if(pLeftV > 0)
							begin
								abs_pLeftV = pLeftV;
							end
						else
							begin
								abs_pLeftV = -pLeftV;
							end
							
						
						// set abs(pTop) for Y, U and V
						pTopY = baseY - aboveRow[j][9:0];
						pTopU = baseU - aboveRow[j][19:10];
						pTopV = baseV - aboveRow[j][29:20];
						
						if(pTopY > 0)
							begin
								abs_pTopY = pTopY;
							end
						else
							begin
								abs_pTopY = -pTopY;
							end
						if(pTopU > 0)
							begin
								abs_pTopU = pTopU;
							end
						else
							begin
								abs_pTopU = -pTopU;
							end
						if(pTopV > 0)
							begin
								abs_pTopV = pTopV;
							end
						else
							begin
								abs_pTopV = -pTopV;
							end
					
						
						// set abs(pTopLeft) for Y, U and V
						pTopLeftY = baseY - referencePixel[9:0];
						pTopLeftU = baseU - referencePixel[19:10];
						pTopLeftV = baseV - referencePixel[29:20];
						
						
						if(pTopLeftY > 0)
							begin
								abs_pTopLeftY = pTopLeftY;
							end
						else
							begin
								abs_pTopLeftY = -pTopLeftY;
							end
						if(pTopLeftU > 0)
							begin
								abs_pTopLeftU = pTopLeftU;
							end
						else
							begin
								abs_pTopLeftU = -pTopLeftU;
							end
						if(pTopLeftV > 0)
							begin
								abs_pTopLeftV = pTopLeftV;
							end
						else
							begin
								abs_pTopLeftV = -pTopLeftV;
							end
							
						
						// set pred[i][j] for Y plane
						if((abs_pLeftY <= abs_pTopY) && (abs_pLeftY <= abs_pTopLeftY))
							begin
								buffer[i][j][9:0] = leftCol[i][9:0];
							end
						
						else if (abs_pTopY <= abs_pTopLeftY)
							begin
								buffer[i][j][9:0] = aboveRow[j][9:0];
							end
							
						else
							begin
								buffer[i][j][9:0] = referencePixel[9:0];
							end
							
							
						// set pred[i][j] for U plane	
						if((abs_pLeftU <= abs_pTopU) && (abs_pLeftU <= abs_pTopLeftU))
							begin
								buffer[i][j][19:10] = leftCol[i][19:10];
							end
										
						else if (abs_pTopU <= abs_pTopLeftU)
							begin
								buffer[i][j][19:10] = aboveRow[j][19:10];
							end	
						
						else
							begin
								buffer[i][j][19:10] = referencePixel[19:10];
							end
							
							
							
						// set pred[i][j] for V plane	
						if((abs_pLeftV <= abs_pTopV) && (abs_pLeftV <= abs_pTopLeftV))
							begin
								buffer[i][j][29:20] = leftCol[i][29:20];
							end
							
						else if (abs_pTopV <= abs_pTopLeftV)
							begin
								buffer[i][j][29:20] = aboveRow[j][29:20];
							end	
							
						else
							begin
								buffer[i][j][29:20] = referencePixel[29:20];
							end
						
					end
			end
	end


endmodule : paeth_mode