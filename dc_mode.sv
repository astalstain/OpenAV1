// Filename: dc_mode.sv
// Author: Jean-Paul Astal-Stain
// Created: 14/04/20
// Descripton: calculates the DC average of the available blocks around the input macroblock (MB) 
//					and uses this to output prediction values to the prediction block (PB).
// Changes: 14/05/20 - updated to 30-bit YUV

module dc_mode(
	input  logic 		  clk,
	input  logic        haveLeft,
	input  logic  		  haveAbove,
	input  logic [ 9:0]  w,
	input  logic [ 9:0]  h,
	input  logic [ 9:0]  log2W,
	input  logic [ 9:0]  log2H,
	input  logic [29:0] leftCol  	 [0:7],
	input  logic [29:0] aboveRow 	 [0:7],
	output logic [29:0] pred		 [0:3][0:3]

);

// internal variables
logic [ 9:0] leftAvgY;
logic [ 9:0] leftAvgU;
logic [ 9:0] leftAvgV;
logic [ 9:0] aboveAvgY;
logic [ 9:0] aboveAvgU;
logic [ 9:0] aboveAvgV;
logic [ 9:0] bothAvgY;
logic [ 9:0] bothAvgU;
logic [ 9:0] bothAvgV;
logic [11:0] sumY;
logic [11:0] sumU;
logic [11:0] sumV;
logic [29:0] leftCol_in	 [0:3];
logic [29:0] aboveRow_in [0:3];
logic [29:0] buffer 	    [0:3][0:3];

int i, j;	

always_ff @(posedge clk)
	begin
	
		pred <= buffer;
		
	end
	
// do the following when leftCol or aboveRow changes
always_comb
	begin
		 
		// set other internal variavles to 0
		i = 0;
		j = 0;
		
		sumY     = 12'd0;
		sumU 		= 12'd0;
		sumV		= 12'd0;
		
		leftAvgY = 10'd0;
		leftAvgU = 10'd0;
		leftAvgV = 10'd0;
		
		aboveAvgY = 10'd0;
		aboveAvgU = 10'd0;
		aboveAvgV = 10'd0;
		
		bothAvgY = 10'd0;
		bothAvgU = 10'd0;
		bothAvgV = 10'd0;		

		// if only leftCol is available
		if (haveLeft == 1'd1 && haveAbove == 1'd0)
			begin
			
				// reset sum variables
				sumY	  = 12'd0;
				sumU	  = 12'd0;
				sumV	  = 12'd0;
				
				// reset average variables	
				leftAvgY = 10'd0;
				leftAvgU = 10'd0;
				leftAvgV = 10'd0;
				
				// sum all leftCol values in Y, U and V for leftCol
				for(i = 0; i < 4; i++)
					begin
						sumY = sumY + leftCol[i][9:0];
						sumU = sumU + leftCol[i][19:10];
						sumV = sumV + leftCol[i][29:20];
					end
					
					
				// calculate the pixel value for each of the pixels in the macroblock
				leftAvgY = 10'(( sumY + (4 >> 1) ) >> log2H); 
				leftAvgU = 10'(( sumU + (4 >> 1) ) >> log2H);
				leftAvgV = 10'(( sumV + (4 >> 1) ) >> log2H);
				
				i = 0;
				j = 0;
				
				// set all of the pixels in the macroblock to this value
				for(i = 0; i < 4; i++)
					begin
						for(j = 0; j < 4; j++)
							begin
								buffer[i][j] = {leftAvgY, leftAvgU, leftAvgV};		
							end
					end
			end
			
		// if only aboveRow is available
		else if (haveLeft == 1'd1 && haveAbove == 1'd1)
			begin
			
				// reset sum and average variables
				sumY	  = 12'd0;
				sumU	  = 12'd0;
				sumV	  = 12'd0;
				
				// reset average variables	
				aboveAvgY = 10'd0;
				aboveAvgU = 10'd0;
				aboveAvgV = 10'd0;
			
				// sum all aboveRow values in Y, U and V for aboveRow
				for(i = 0; i < 4; i++)
					begin
						sumY = sumY + aboveRow[i][9:0];
						sumU = sumU + aboveRow[i][19:10];
						sumV = sumV + aboveRow[i][29:20];
					end
				
				// calculate the value for each of the pixels in the macroblock
				aboveAvgY = 10'(( sumY + (4 >> 1) ) >> log2W); 
				aboveAvgU = 10'(( sumU + (4 >> 1) ) >> log2W);
				aboveAvgV = 10'(( sumV + (4 >> 1) ) >> log2W);
				
				// set all of the pixels in the macroblock to this value
				for(i = 0; i < 4; i++)
					begin
						for(j = 0; j < 4; j++)
							begin
								// concatenate averages onto output buffer
								buffer[i][j] = {aboveAvgY, aboveAvgU, aboveAvgV};		
							end
					end
			end
			
		// if both leftCol and aboveRow are available
		else if (haveLeft == 1'd1 && haveAbove == 1'd1)
			begin
			
				// reset sum and average variables
				sumY	  = 12'd0;
				sumU	  = 12'd0;
				sumV	  = 12'd0;
				
				// reset average variables	
				bothAvgY = 10'd0;
				bothAvgU = 10'd0;
				bothAvgV = 10'd0;			

				// sum all aboveRow values in Y, U and V for aboveRow and leftCol
				for(i = 0; i < 4; i++)
					begin
						sumY = sumY + aboveRow[i][ 9: 0] + leftCol[i][ 9: 0];
						sumU = sumU + aboveRow[i][19:10] + leftCol[i][19:10];
						sumV = sumV + aboveRow[i][29:20] + leftCol[i][29:20];
					end

				
				// calculate average
				sumY += 10'((4 + 4) >> 1);
				sumU += 10'((4 + 4) >> 1);
				sumV += 10'((4 + 4) >> 1);
				
				bothAvgY = 10'(sumY / (4 + 4));
				bothAvgU = 10'(sumU / (4 + 4));
				bothAvgV = 10'(sumV / (4 + 4));
				
				// set all of the pixels in the macroblock to this value
				for(i = 0; i < 4; i++)
					begin
						for(j = 0; j < 4; j++)
							begin
								// concatenate averages onto output buffer
								buffer[i][j] = {bothAvgY, bothAvgU, bothAvgV};
							end
					end
			end
			
		// if neither are available
		else
			begin
			
				// set all of the pixels in the macroblock to this value
				for(i = 0; i < 4; i++)
					begin
						for(j = 0; j < 4; j++)
							begin
								buffer[i][j] = {10'd128, 10'd128, 10'd128};
							end
					end
			end
	end

endmodule : dc_mode





