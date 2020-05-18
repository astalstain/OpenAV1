// Filename    : intra_edge_upsample.sv
// Author      : Jean-Paul Astal-Stain
// Description : upsamples either aboveRow or leftCol from -1 to numPx -1 values to
//					  -2 to 2 * numPx - 2.
// Created     : 23/04/2020 
// Changes     : 08/05/2020 - operates on only an array of either leftCol or aboveRow
//										(two of these modules will be instantiated in above design)
//	To-do     	:[DONE] make sure dir functionality works
//					:[DONE] fix problem with odd prediction values of buff
//					:[DONE] figure out round2 problem with 32 bit truncation	


module intra_edge_upsample
#(parameter NUMPX = 8)									//w, h, or w+h
(
	input  logic 		   clk,
	input  logic [ 9:0]  numPx,
	input  logic [29:0]  referencePixel,
	input  logic [29:0]  input_array         [0:7],
	output logic [29:0]  upsampled_array     [0:(2*NUMPX)]
);

// define internal registers
int i;

logic [13:0] sY;
logic [13:0] sU;
logic [13:0] sV;


logic [9:0] rounded_sY;
logic [9:0] rounded_sU;
logic [9:0] rounded_sV;


logic [13:0] x_inY;
logic [13:0] x_inU;
logic [13:0] x_inV;

logic [29:0] buff[0:(2*NUMPX)];

logic [13:0] dupY  [0:NUMPX + 2];	//numPx +3 elements
logic [13:0] dupU  [0:NUMPX + 2];	//numPx +3 elements
logic [13:0] dupV  [0:NUMPX + 2];	//numPx +3 elements


logic [13:0] buffY [0:(2*NUMPX)];   //2*numPx + 1 elements
logic [13:0] buffU [0:(2*NUMPX)];   //2*numPx + 1 elements
logic [13:0] buffV [0:(2*NUMPX)];   //2*numPx + 1 elements

logic [9:0] input_bufferY [0:7];
logic [9:0] input_bufferU [0:7];
logic [9:0] input_bufferV [0:7];


always_ff @(posedge clk)
	begin
		// push data to output
		upsampled_array <= buff;
		
	end

// generate dup and modify values in buff
always_comb
	begin
		
		for(i = 0; i < 8; i++)
			begin
				input_bufferY[i] = input_array[i][9:0];
				input_bufferU[i] = input_array[i][19:10];
				input_bufferV[i] = input_array[i][29:20];
			end

		// generate dup, indexes shifted to the right by 1 (numPx + 3 large)
		dupY[0] = referencePixel[9:0];
		dupU[0] = referencePixel[19:10];
		dupV[0] = referencePixel[29:20];
		
		dupY[1] = referencePixel[9:0];
		dupU[1] = referencePixel[19:10];
		dupV[1] = referencePixel[29:20];
		
		for(i = 0; i < NUMPX; i++)
			begin
				dupY[i + 2] = input_bufferY[i];
				dupU[i + 2] = input_bufferU[i];
				dupV[i + 2] = input_bufferV[i];
			end
		
		dupY[NUMPX + 2] = input_bufferY[NUMPX - 1];
		dupU[NUMPX + 2] = input_bufferU[NUMPX - 1];
		dupV[NUMPX + 2] = input_bufferV[NUMPX - 1];
		
		
		// generate buff, indexes shifted to the right by 2 (2*numPx large)
		buffY[0] = dupY[0];
		buffU[0] = dupU[0];
		buffV[0] = dupV[0];
		
		for(i = 0; i < NUMPX;  i = i + 1)
			begin
				//needs to be 32-bit to contain summation
				sY = 14'(-dupY[i] + (9 * dupY[i + 1]) + (9 * dupY[i + 2]) - dupY[i + 3]);
				sU = 14'(-dupU[i] + (9 * dupU[i + 1]) + (9 * dupU[i + 2]) - dupU[i + 3]);
				sV = 14'(-dupV[i] + (9 * dupV[i + 1]) + (9 * dupV[i + 2]) - dupV[i + 3]);
				
				//Round2(s, 4)
				rounded_sY = 10'((sY + (1 << (4 - 1))) >> 4);
				rounded_sU = 10'((sU + (1 << (4 - 1))) >> 4);
				rounded_sV = 10'((sV + (1 << (4 - 1))) >> 4);
				
				// offset to account for shift
				buffY[2 * i + 1] = rounded_sY;
				buffU[2 * i + 1] = rounded_sU;
				buffV[2 * i + 1] = rounded_sV;	
				buffY[2 * i + 2] = dupY[i + 2];
				buffU[2 * i + 2] = dupU[i + 2];
				buffV[2 * i + 2] = dupV[i + 2];
				
//				if(i == NUMPX -1)
//					begin
//						buffY[16] = dupY[i + 2];
//						buffU[2 * i + 3] = dupU[i + 2];
//						buffV[2 * i + 3] = dupV[i + 2];
//					end
				
			end
			
//			buffY[16] = dupY[9];
//			buffU[16] = dupU[9];
//			buffV[16] = dupV[9];

			// set last pixel
			
			
			//buff = '{'{buffY}, '{buffU}, '{buffV}};
			
		for(i = 0; i <= 2*NUMPX; i++)
			begin
				buff[i][ 9: 0] = 10'(buffY[i]);
				buff[i][19:10] = 10'(buffU[i]);
				buff[i][29:20] = 10'(buffV[i]);
			end
		
	end

endmodule : intra_edge_upsample