// Filename    : intra_edge_filter.sv
// Author      : Jean-Paul Astal-Stain
// Description : filters either leftCol or aboveRow
// Created     : 24/04/2020
// Changes     : 07/05/20 - updated to the correct 8 sample input
// Todo			: truncation warning on buffer[i - 1]

module intra_edge_filter
#(parameter SIZE = 8,								// numPx
  parameter INTRA_EDGE_TAPS = 5)
(
	input  logic 		 clk,
	input  logic [29:0] referencePixel,
	input  logic [9:0] filter_strength, 	   // between 0 and 3
	input  logic [29:0] input_array	 	[0:7],
	output logic [29:0] filtered_array	[0:7] // returns filtered leftCol or aboveRow
);

// define internal registers
logic [9:0] bufferY 		 [0:SIZE - 1];
logic [9:0] bufferU 		 [0:SIZE - 1];
logic [9:0] bufferV 		 [0:SIZE - 1];

logic [29:0] buffer_out  [0:SIZE - 1];

logic [9:0] filter_edgeY  [0:SIZE - 1];
logic [9:0] filter_edgeU  [0:SIZE - 1];
logic [9:0] filter_edgeV  [0:SIZE - 1];

logic [9:0] sY;
logic [9:0] sU;
logic [9:0] sV;

int i;
int j;
int k;

// define Intra_Edge_Kernel
logic [9:0] Intra_Edge_Kernel [0:2][0:4] = '{ '{10'd0, 10'd4, 10'd8, 10'd4, 10'd0},
															 '{10'd0, 10'd5, 10'd6, 10'd5, 10'd0},
															 '{10'd2, 10'd4, 10'd4, 10'd4, 10'd2}	};

// always_ff
always_ff @(posedge clk)
	begin
		filtered_array <= buffer_out;
	end

// always_comb
always_comb
	begin
		
		i = 0;
		j = 0;
		k = 0;
		
		
		// first check that strength is set, if not return nothing
		if(filter_strength != 1'd0)
			begin
			
				// DEBUGGING:
				//$display("filter strength != 0");
	

				for(i = 0; i < SIZE; i++)
					begin
						bufferY[i] = input_array[i][9:0];
						bufferU[i] = input_array[i][19:10];
						bufferV[i] = input_array[i][29:20];	
					end
				
				
				filter_edgeY[0] = referencePixel[9:0];
				filter_edgeU[0] = referencePixel[19:10];
				filter_edgeV[0] = referencePixel[29:20];
				
				// derive the array edge
				for(i = 1; i < SIZE; i++)
					begin
						filter_edgeY[i] = bufferY[i - 1];
						filter_edgeU[i] = bufferU[i - 1];
						filter_edgeV[i] = bufferV[i - 1];		
					end
				
				// apply filter using Intra_Edge_Kernel
				for(i = 1; i < SIZE; i++)
					begin
						// set s = 0
						sY = 10'd0;
						sU = 10'd0;
						sV = 10'd0;
						
						for(j = 0; j < INTRA_EDGE_TAPS; j++)
							begin
								// set k = clip3(0, sz - 1, i - 2 + j)
								if((i - 2 + j) < 0)
									begin
										k = 10'd0;
									end
								else if((i - 2 + j) > (SIZE - 1))
									begin
										k = SIZE - 1;
									end
								else
									begin 
										k = i - 2 + j;
									end
								
								// increment s
								sY = sY + ((Intra_Edge_Kernel[(filter_strength - 10'd1)][j]) * filter_edgeY[k]);
								sU = sU + ((Intra_Edge_Kernel[(filter_strength - 10'd1)][j]) * filter_edgeU[k]);
								sV = sV + ((Intra_Edge_Kernel[(filter_strength - 10'd1)][j]) * filter_edgeV[k]);
								
							end
							
						bufferY[i - 1] = 10'((sY + 8) >> 4);
						bufferU[i - 1] = 10'((sU + 8) >> 4);
						bufferV[i - 1] = 10'((sV + 8) >> 4);
						
					end
						

				
			end
		else
			begin
				// load input array into output (do nothing)
				// could just prevent this module from being loaded from
				// the higher module
				bufferY = '{10'd0, 10'd0, 10'd0, 10'd0, 10'd0, 10'd0, 10'd0, 10'd0};
				bufferU = '{10'd0, 10'd0, 10'd0, 10'd0, 10'd0, 10'd0, 10'd0, 10'd0};
				bufferV = '{10'd0, 10'd0, 10'd0, 10'd0, 10'd0, 10'd0, 10'd0, 10'd0};
				
				sY = 10'd0;
				sU = 10'd0;
				sV = 10'd0;
				//$display("else statement");
				
			end
			
			//buffer_out = '{bufferY, bufferU, bufferV};
			
			for(i = 0; i < SIZE; i++)
				begin
					buffer_out[i] = {bufferY[i], bufferU[i], bufferV[i]};
				end
		
	end
	
endmodule : intra_edge_filter