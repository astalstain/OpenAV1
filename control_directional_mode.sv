// Filename    : control_directional_mode.sv
// Author      : Jean-Paul Astal-Stain
// Description : 
// Created     : 26/04/2020
// Changes     : 04/05/2020 - modules connected up without access to RAM
//					: 08/05/2020 - two modules created for both filtering and upsampling
//									 - for aboveRow and leftCol

module control_directional_mode
// define parameters
#(parameter ANGLE_STEP = 3,
  parameter UPSAMPLING_SIZE = 9,
  parameter WIDTH = 4,
  parameter HEIGHT = 4)
// define inputs and outputs
(
	input  logic clk,
	input  logic plane,
	input  logic haveLeft,
	input  logic haveAbove,
	input  logic [3:0] mode,
	input  logic enable_intra_edge_filter,
	input  logic [9:0] AngleDeltaY,
	input  logic [9:0] AngleDeltaUV,
	input  logic [15:0] maxX,
	input  logic [15:0] maxY,
	input  logic [9:0] base_angle,
	input  logic [29:0] referencePixel,
	input  logic [9:0] w,
	input  logic [9:0] h,
	input  logic [15:0] x,
	input  logic [15:0] y,
	input  logic [29:0] aboveRow [0:7],
	input  logic [29:0] leftCol  [0:7],
	output logic [29:0] pred 	 [0:3][0:3]
);

// define test register (replaces memory access)

logic left;
logic upsampleAbove;
logic upsampleLeft;

logic left_out;
logic [29:0] truncated_pred [0:3][0:3];

// define buffer registers to clocked sub-modules
logic [29:0] referencePixel_buffer;

logic left_buffer;

logic [29:0] prediction_input_leftCol [0:16];
logic [29:0] prediction_input_aboveRow [0:16];


logic dir_buffer;
logic [29:0] pred_buffer [0:3][0:3];
logic [9:0] numPx_buffer;

logic filterType;
logic filter_leftCol_enable;
logic filter_aboveRow_enable;
logic filterType_buffer;
logic [9:0] aboveRow_filter_strength;
logic [9:0] leftCol_filter_strength; 
logic [29:0] filtered_array [0:7];
logic [9:0] filter_strength_buffer;
logic [29:0] filtered_leftCol [0:7];
logic [29:0] filtered_aboveRow[0:7];
logic [29:0] filtered_aboveRow_result[0:7];
logic [29:0] filtered_leftCol_result[0:7];
logic [29:0] filter_aboveRow_buffer [0:7];
logic [29:0] filter_leftCol_buffer [0:7];
logic [29:0] filtered_array_result [0:7];

logic [29:0] upsample_in_leftCol [0:7];
logic [29:0] upsample_in_aboveRow [0:7];
logic [29:0] upsampled_leftCol [0:16];
logic [29:0] upsampled_aboveRow [0:16];
logic [29:0] upsample_aboveRow_buffer [0:7];
logic [29:0] upsample_leftCol_buffer [0:7];
logic upsample_leftCol_enable;
logic upsample_aboveRow_enable;
logic [29:0] upsampled_array_result [0:16]; // dynamically assign NUMPX value

logic dir_out;
logic [9:0] w_buffer;
logic [9:0] h_buffer;
logic signed [9:0] delta_leftCol_buffer;
logic signed [9:0] delta_aboveRow_buffer;
logic signed [9:0] delta_leftCol_upsample_buffer;
logic signed [9:0] delta_aboveRow_upsample_buffer;
logic leftCol_strength_selection_enable;
logic aboveRow_strength_selection_enable;
logic aboveRow_upsample_selection_enable;
logic leftCol_upsample_selection_enable;


// define internal registers
logic [9:0] angleDelta;
logic [9:0] pAngle;
logic [9:0] numPx;
logic [9:0] numPy;
logic [9:0] dx;
logic [9:0] dy;
logic signed [31:0] idx;
logic signed [31:0] idy;
logic signed [31:0] base;
logic signed [31:0] shift;
logic signed [31:0] maxBaseX;
logic [9:0] secondTerm;
logic [9:0] minimum;

logic signed [9:0] round2_bufferY;
logic signed [9:0] round2_bufferU;
logic signed [9:0] round2_bufferV;

logic [9:0] dr_intra_derivative [0:89] = '{10'd0,   10'd0,  10'd0,   10'd1023, 10'd0,   10'd0,  10'd547, 10'd0,   10'd0,  10'd372, 
								                   10'd0,   10'd0,  10'd0,   10'd0,    10'd273, 10'd0,  10'd0,   10'd215, 10'd0,  10'd0, 
														 10'd178, 10'd0,  10'd0,   10'd151,  10'd0,   10'd0,  10'd132, 10'd0,   10'd0,  10'd116, 
														 10'd0,   10'd0,  10'd102, 10'd0,    10'd0,   10'd0,  10'd90,  10'd0,   10'd0,  10'd80, 
														 10'd0,   10'd0,  10'd71,  10'd0,    10'd0,   10'd64, 10'd0,   10'd0,   10'd57, 10'd0, 
														 10'd0,   10'd51, 10'd0,   10'd0,    10'd45,  10'd0,  10'd0,   10'd0,   10'd40, 10'd0,
														 10'd0,   10'd35, 10'd0,   10'd0,    10'd31,  10'd0,  10'd0,   10'd27,  10'd0,  10'd0, 
														 10'd23,  10'd0,  10'd0,   10'd19,   10'd0,   10'd0,  10'd15,  10'd0,   10'd0,  10'd0, 
														 10'd0,   10'd11, 10'd0,   10'd0,    10'd7,   10'd0,  10'd0,   10'd3,   10'd0,  10'd0};
int i;
int j;

// instantiate the necessary modules
intra_edge_filter 										leftCol_filter(.clk(clk),
																					.referencePixel(referencePixel_buffer),
																					.filter_strength(filter_strength_buffer),
																					.input_array(filter_leftCol_buffer),
																					.filtered_array(filtered_leftCol_result));
								 
intra_edge_filter 									  aboveRow_filter(.clk(clk),
																					.referencePixel(referencePixel_buffer),
																					.filter_strength(filter_strength_buffer),
																					.input_array(filter_aboveRow_buffer),
																					.filtered_array(filtered_aboveRow_result));								 
								 
intra_edge_upsample 									 leftCol_upsample(.clk(clk),
																					.referencePixel(referencePixel_buffer),
																					.numPx(numPx_buffer),
																					.input_array(upsample_leftCol_buffer),
																					.upsampled_array(upsampled_leftCol));
									  
intra_edge_upsample 									aboveRow_upsample(.clk(clk),
																					.referencePixel(referencePixel_buffer),
																					.numPx(numPx_buffer),
																					.input_array(upsample_aboveRow_buffer),
																					.upsampled_array(upsampled_aboveRow));	
																					
intra_edge_filter_strength_selection   filter_strength_leftCol(.clk(clk),
																				   .w(w_buffer),
																				   .h(h_buffer),
																				   .filterType(filterType_buffer),
																				   .delta(delta_leftCol_buffer),
																				   .filter_strength(leftCol_filter_strength));			
																		
intra_edge_filter_strength_selection  filter_strength_aboveRow(.clk(clk),
																				   .w(w_buffer),
																				   .h(h_buffer),
																				   .filterType(filterType_buffer),
																				   .delta(delta_aboveRow_buffer),
																				   .filter_strength(aboveRow_filter_strength));		
																	
intra_edge_upsample_selection 			   use_upsample_leftCol(.clk(clk),
																					.filterType(filterType_buffer),
																					.w(w_buffer),
																					.h(h_buffer),
																					.delta(delta_leftCol_upsample_buffer),
																					.useUpsample(upsampleLeft));	
																					
intra_edge_upsample_selection 			  use_upsample_aboveRow(.clk(clk),
																					.filterType(filterType_buffer),
																					.w(w_buffer),
																					.h(h_buffer),
																					.delta(delta_aboveRow_upsample_buffer),
																					.useUpsample(upsampleAbove));				

// always_ff
always_ff @(posedge clk)
	begin
		// push result out - force it to 10 bit
		pred <= truncated_pred;
		
		// push data into leftCol strength selection
		if(leftCol_strength_selection_enable == 1'd1)
			begin
				w_buffer <= w;
				h_buffer <= h;
				filterType_buffer <= filterType;
				delta_leftCol_buffer <= pAngle - 10'd180;
			end

		
		// push data into aboveRow strength selection
		if(aboveRow_strength_selection_enable == 1'd1)
			begin
				w_buffer <= w;
				h_buffer <= h;
				filterType_buffer <= filterType;
				delta_aboveRow_buffer <= pAngle - 10'd90;
			end

			
		//	push data into leftCol upsample selection
		if(leftCol_upsample_selection_enable == 1'd1)
			begin
				w_buffer <= w;
				h_buffer <= h;
				filterType_buffer <= filterType;
				delta_leftCol_upsample_buffer <= pAngle - 10'd180;
			end

		
		// push data into aboveRow upsample selection
		if(aboveRow_upsample_selection_enable == 1'd1)
			begin
				w_buffer <= w;
				h_buffer <= h;
				filterType_buffer <= filterType;
				delta_aboveRow_upsample_buffer <= pAngle - 10'd90;
			end

		
		// push data into leftCol filter
		if(filter_leftCol_enable == 1'd1)
			begin
				referencePixel_buffer  		  <= referencePixel;
				filter_strength_buffer 		  <= leftCol_filter_strength;
				filter_leftCol_buffer 		  <= '{30'd140,  30'd52, 30'd36, 30'd255, 30'd140,  30'd52, 30'd36, 30'd255};
			
			end

			
		// push data into aboveRow filter
		if(filter_aboveRow_enable == 1'd1)
			begin
				referencePixel_buffer  		  <= referencePixel;
				filter_strength_buffer 		  <= aboveRow_filter_strength;
				filter_aboveRow_buffer 		  <= '{ 30'd12, 30'd500, 30'd16, 30'd290, 30'd12, 30'd500, 30'd16, 30'd290};
			
			end

			
			
		// push data into leftCol upsample
		if(upsample_leftCol_enable == 1'd1)
			begin
				referencePixel_buffer    <= referencePixel;
				numPx_buffer 				 <= numPx;
				upsample_leftCol_buffer  <= upsample_in_leftCol;
			end

		
		// push data into aboveRow upsample
		if(upsample_aboveRow_enable == 1'd1)
			begin
				referencePixel_buffer    <= referencePixel;
				numPx_buffer 				 <= numPx;
				upsample_aboveRow_buffer  <= upsample_in_aboveRow;
			end

			

	end

// always_comb
always_comb
	begin
		
		// 1. derive angleDelta
		if(plane == 1'd0)
			begin
				angleDelta = AngleDeltaY;
			end
		else
			begin
				angleDelta = AngleDeltaUV;
			end
			
		// 2. derive pAngle
		pAngle = base_angle + (angleDelta * ANGLE_STEP);
		
		// 3. set  and upsampleLeft to 0
		//upsampleAbove = 1'd0;
		//upsampleLeft  = 1'd0;
		

		//referencePixel = 10'd0;
		filterType = 1'd0;
		secondTerm = 10'd0;
		numPx = 10'd0;
		filter_aboveRow_enable = 1'd0;
		filter_leftCol_enable = 1'd0;
		leftCol_strength_selection_enable = 1'd0;
		aboveRow_strength_selection_enable = 1'd0;
		leftCol_upsample_selection_enable = 1'd0;
		aboveRow_upsample_selection_enable = 1'd0;
		//filter_leftCol_enable = 1'd0;
		//filter_aboveRow_enable = 1'd0;
		upsample_leftCol_enable = 1'd0;
		upsample_aboveRow_enable = 1'd0;
		filtered_aboveRow = '{default:0};
		filtered_leftCol = '{default:0};
		//upsample_in_aboveRow = '{default:0};
		//upsample_in_leftCol = '{default:0};
		
		// 4. if enable_intra_edge_filter is set, do the following
		if(enable_intra_edge_filter == 1'd1)
			begin
			
				// if pAngle isn't 90 or 180 degrees, do the following
				if((pAngle != 10'd90) && (pAngle != 10'd180))
					begin
						
						// if 90 > pAngle > 180 and (w + h) >= 24, do the following
						if((pAngle > 10'd90) && (pAngle < 180) && (w + h >= 10'd24))
							begin
								
								// calculate referencePixel value via filter_corner modlue
								// needs access to RAM_frame
								// DEBUGGING:
								//referencePixel = 10'd200;
								
							end
						
// -------------------------------- FILTERING ------------------------------------------		
					
						// identify what filter type to use via get_filter_type module
						// needs access to RAM_frame
						// DEBUGGING:
						filterType = 1'd0;
						
						// if haveAbove is set, filter based upon aboveRow
						if(haveAbove == 1'd1)
							begin
								
								// identify the filter strength to be used via 
								// intra_edge_filter_strength_selection module
								// DEBUGGING:
								//filter_strength = 10'd2;
								
								//enable aboveRow filter strength selection
								aboveRow_strength_selection_enable = 1'd1;
								
								// calcualte numPx 
								if(pAngle < 10'd90)
									begin
										secondTerm = h;
									end
								else
									begin
										secondTerm = 0;
									end
									
								if(w < ((maxX - x + 1) + secondTerm))
									begin
										numPx = w;
									end
								else 
									begin
										numPx = (maxX - x + 1) + secondTerm;
									end
								
								// apply intra edge filter to samples - left = 0
								// DEBUGGING:
								filter_aboveRow_enable = 1'd1;
								
							end
						else
							begin
								// otherwise, don't filter
								filter_aboveRow_enable = 1'd0;
								aboveRow_strength_selection_enable = 1'd0;
							end
						
						if(haveLeft == 1'd1)
							begin
								
								// identify the filter strength to be used via 
								// intra_edge_filter_strength_selection module
								// DEBUGGING:
								//filter_strength = 10'd2;
								
								// enable leftCol filter strength selection
								leftCol_strength_selection_enable = 1'd1;
								
								// calcualte numPx 
								if(pAngle > 10'd180)
									begin
										secondTerm = w;
									end
								else
									begin
										secondTerm = 0;
									end
									
								if(h < ((maxY - y + 1) + secondTerm))
									begin
										numPx = w;
									end
								else 
									begin
										numPx = (maxY - y + 1) + secondTerm;
									end
									
								// apply intra edge filter to samples - left = 1
								// DEBUGGING:
								filter_leftCol_enable = 1'd1;
								
							end
						else
							begin
								// otherwise, don't filter
								filter_leftCol_enable  = 1'd0;
								leftCol_strength_selection_enable = 1'd0;
							end
						
						// assign output of filters to registers
						filtered_leftCol = filtered_leftCol_result;
						filtered_aboveRow = filtered_aboveRow_result;
						
					end
					
		
// -------------------------------- UPSAMPLING ------------------------------------------		
			
				// create upsample inputs, depending on whether samples were filtered
				// or not
				if(filter_leftCol_enable == 1'd1)
					begin
						upsample_in_leftCol = filtered_leftCol;
					end
				else
					begin
						upsample_in_leftCol = leftCol;
					end
				
				if(filter_aboveRow_enable == 1'd1)
					begin
						upsample_in_aboveRow = filtered_aboveRow;
					end
				else
					begin
						upsample_in_aboveRow = aboveRow;
					end
				
									
				// identify whether or not upsampling should be applied to edge 
				// via the intra_edge_upsample_selection module
				// UPSAMPLE FROM ABOVE
				// DEBUGGING:
				aboveRow_upsample_selection_enable = 1'd1;
				
				// set numPx
				if(pAngle < 10'd90)
					begin
						numPx = w + h;
					end
				else
					begin
						numPx = w;
					end
					
				// ------------- UPSAMPLE CREATION --------------------------	
				// if upsampleAbove is set, create upsampled values for aboveRow
				// via the intra_edge_upsample module
		
				if(upsampleAbove == 1'd1)
					begin
						// enable upsampling
						upsample_aboveRow_enable = 1'd1;
						// set output of upsampling
						prediction_input_aboveRow = upsampled_aboveRow;
					end
				else
					begin
						upsample_aboveRow_enable = 1'd0;
						
						// set input to prediction part as the filtered array in large array
						for(i = 0; i < 8; i++)
							begin
								prediction_input_aboveRow[i] = filtered_aboveRow[i];
							end
						for(i = 8; i < 17; i++)
							begin
								prediction_input_aboveRow[i] = 30'd0;
							end
					end
						
				// identify whether or not upsampling should be applied to edge 
				// via the intra_edge_upsample_selection module
				// UPSAMPLE FROM THE LEFT
				// DEBUGGING:
				leftCol_upsample_selection_enable = 1'd1;
				
				// set numPx
				if(pAngle > 10'd180)
					begin
						numPx = h + w;
					end
				else
					begin
						numPx = h;
					end
					
				// ------------- UPSAMPLE CREATION --------------------------	
				// if upsampleLeft is set, create upsampled values for leftCol
				// via the intra_edge_upsample module
				if(upsampleLeft == 1'd1)
					begin
						upsample_leftCol_enable = 1'd1;
						prediction_input_leftCol = upsampled_leftCol;
						$display("upsampled");
					end
				else
					begin
						upsample_leftCol_enable = 1'd0;
						
						for(i = 0; i < 8; i++)
							begin
								prediction_input_leftCol[i] = filtered_leftCol[i];
//								$display("prediction_input_leftCol[%d]Y: = %d",i, filtered_leftCol[i][9:0]);
//								$display("prediction_input_leftCol[%d]U: = %d",i, filtered_leftCol[i][19:10]);
//								$display("prediction_input_leftCol[%d]V: = %d",i, filtered_leftCol[i][29:20]);
							end
						for(i = 8; i < 17; i++)
							begin
								prediction_input_leftCol[i] = 32'd0;
//								$display("prediction_input_leftCol[%d]: = 0",i);
							end
						$display("not upsampled");
					end
					
//				// otherwise don't turn on the upsample selection modules
//				leftCol_upsample_selection_enable = 1'd0;
//				aboveRow_upsample_selection_enable = 1'd0;
				
			end		
			
// -------------------------- CALCULATING DX AND DY -------------------------------------					
			
		// 5. derive dx depending on size of pAngle
		if(pAngle < 10'd90)
			begin
			
				// $display("pAngle = %d", pAngle);


				// search matrix for value Dr_Intra_Derivative[pAngle]
				dx = dr_intra_derivative[pAngle];
				
				// $display("dx = %d", dx);
				
			end
		else if ((pAngle > 10'd90) && (pAngle < 10'd180))
			begin
				
				// seach matrix for value Dr_Intra_Derivative[180 - pAngle]
				dx = dr_intra_derivative[10'd180 - pAngle];
			end
		else
			begin
				dx = 10'd0;
			end
		
		// 6. derive dy depending on sie of pAngle
		if((pAngle > 10'd90) && (pAngle < 10'd180))
			begin
				
				// search matrix for value Dr_Intra_Derivative[pAngle - 90]
				dy = dr_intra_derivative[pAngle - 10'd90];
			end
		else if(pAngle > 10'd180)
			begin
				
				// search matrix for value Dr_Intra_Derivative[270 - pAgnle]
				dy = dr_intra_derivative[10'd270 - pAngle];
			end
		else
			begin
				dy = 10'd0;
			end
			
// -------------------------------- PREDICTION ------------------------------------------		
		i = 0;
		j = 0;

		
		// 7. if pAngle < 90, apply the following for i = 0 ... h-1, for j = 0 ... w - 1
		if(pAngle < 10'd90)
			begin			
				
				// $display("correct area");
				
				for(i = 0; i < HEIGHT; i++)
					begin
						for(j = 0; j < WIDTH; j++)
							begin
								
								// set idx
								idx = (i + 1) * dx;
								// set base
								base = (idx >>> (10'd6 - upsampleAbove)) + (j << upsampleAbove);
								// set shift
								shift = ((idx <<< upsampleAbove) >>> 10'd1) & 10'd31;
								// set maxBaseX
								maxBaseX = (w + h - 10'd1) << upsampleAbove;
								// if base < maxBaseX, do the following to set pred[i][j]
								if(base < maxBaseX)
									begin
										round2_bufferY = 10'((prediction_input_aboveRow[base + 10'd2][9:0] * (10'd32 - shift) + prediction_input_aboveRow[base + 10'd3][9:0] * shift));
										round2_bufferU = 10'((prediction_input_aboveRow[base + 10'd2][19:10] * (10'd32 - shift) + prediction_input_aboveRow[base + 10'd3][19:10] * shift));
										round2_bufferV = 10'((prediction_input_aboveRow[base + 10'd2][29:20] * (10'd32 - shift) + prediction_input_aboveRow[base + 10'd3][29:20] * shift));
										
										pred_buffer[i][j][9:0] = round2_bufferY + (10'd1 <<< (10'd5 - 10'd1)) >>> 10'd5;
										pred_buffer[i][j][19:10] = round2_bufferU + (10'd1 <<< (10'd5 - 10'd1)) >>> 10'd5;
										pred_buffer[i][j][29:20] = round2_bufferV + (10'd1 <<< (10'd5 - 10'd1)) >>> 10'd5;
										
										// cast to 10-bit number
										truncated_pred[i][j] =  (pred_buffer[i][j]);
									end
								// otherwise, do the following to set pred[i][j]
								else
									begin
										round2_bufferY = 10'd0;
										round2_bufferU = 10'd0;
										round2_bufferV = 10'd0;
										
										pred_buffer[i][j][9:0] = prediction_input_aboveRow[maxBaseX][9:0];
										pred_buffer[i][j][19:10]= prediction_input_aboveRow[maxBaseX][19:10];
										pred_buffer[i][j][29:20] = prediction_input_aboveRow[maxBaseX][29:20];
										
										// cast to 10-bit number
										truncated_pred[i][j] =  (pred_buffer[i][j]);
									end
								
							end
						
					end
				
			end
		else
			begin
				idx = 10'd0;
				base = 10'd0;
				shift = 10'd0;
				maxBaseX = 10'd0;
				
				round2_bufferY = 10'd0;
				round2_bufferU = 10'd0;
				round2_bufferV = 10'd0;
				
				for(i = 0; i < HEIGHT; i++)
					begin
						for(j = 0; j < WIDTH; j++)
							begin
								pred_buffer[i][j] = 30'd0;
								truncated_pred[i][j] = 30'd0;
							end
					end
			end
			
			
		// 10. if pAngle = 90, apply the following for i = 0 ... h - 1, for j = 0 ... w - 1
		if(pAngle == 10'd90)
			begin
				for(i = 0; i < HEIGHT; i++)
					begin
						for(j = 0; j < WIDTH; j++)
							begin
								pred_buffer[i][j] = aboveRow[j];
								// cast to 10-bit number
								truncated_pred[i][j] =  10'(pred_buffer[i][j]);
							end
					end
			end
			
		// 11. if pAngle = 180, apply the following for i = 0 ... h - 1, for j = 0 ... w - 1
		if(pAngle == 10'd180)
			begin
				for(i = 0; i < HEIGHT; i++)
					begin
						for(j = 0; j < WIDTH; j++)
							begin
								pred_buffer[i][j] = leftCol[i];
								// cast to 10-bit number
								truncated_pred[i][j] =  10'(pred_buffer[i][j]);
							end
					end
			end
			
	end
	
endmodule : control_directional_mode