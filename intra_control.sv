// Filename    : intra_control.sv
// Author      : Jean-Paul Astal-Stain
// Description : 
// Created     : 
// Changes     : 

module intra_control
#(parameter MI_COLS = 16'd480,
  parameter MI_ROWS = 16'd271,
  parameter MI_SIZE = 4)
(
	input  logic clk,
	input  logic plane,
	input  logic haveLeft,
	input  logic haveAbove,
	//input  logic haveAboveRight,
	//input  logic haveBelowLeft,
	input  logic use_filter_intra,
	input  logic [9:0] AngleDeltaY,
	input  logic [9:0] AngleDeltaUV,
	input  logic [9:0] base_angle,
	input  logic [3:0] mode,
	input  logic [9:0] log2W,
	input  logic [9:0] log2H,
	input  logic [29:0] aboveRow_read [0:7],
	input  logic [29:0] leftCol_read [0:7],
	input  logic [15:0] x,
	input  logic [15:0] y,
	output logic [29:0] pred_out [0:3][0:3]
);

// define internal registers
logic [9:0] w;
logic [9:0] h;
logic [15:0] maxX;
logic [15:0] maxY;
logic intra_filter_enable;
logic subsampling_x;
logic subsampling_y;
logic recursive_prediction_enable;
logic directional_prediction_enable;
logic smooth_prediction_enable;
logic DC_prediction_enable;
logic Paeth_prediction_enable;
logic [29:0] aboveRow [0:7];
logic [29:0] leftCol  [0:7];
logic [29:0] referencePixel;

// define buffers to instantiated modules
logic plane_buffer;
logic haveAbove_buffer;
logic haveLeft_buffer;
logic intra_filter_enable_buffer;
logic [3:0] mode_buffer;
logic [9:0] w_buffer;
logic [9:0] h_buffer;
logic [29:0] referencePixel_buffer;
logic [9:0] log2W_buffer;
logic [9:0] log2H_buffer;
logic [15:0] maxX_buffer;
logic [15:0] maxY_buffer;
logic [15:0] x_buffer;
logic [15:0] y_buffer;
logic [29:0] aboveRow_buffer    [0:7];
logic [29:0] leftCol_buffer     [0:7];
logic [29:0] directional_prediction_result [0:3][0:3];
logic [29:0] smooth_prediction_result [0:3][0:3];
logic [29:0] DC_prediction_result [0:3][0:3];
logic [29:0] paeth_prediction_result [0:3][0:3];

int i, j;

// instantiate the necessary modules

// directional_prediction instantiation 
control_directional_mode directional_prediction(.clk(clk),
																.plane(plane_buffer),
																.haveLeft(haveLeft_buffer),
																.haveAbove(haveAbove_buffer),
																.mode(mode),
																.enable_intra_edge_filter(intra_filter_enable_buffer),
																.AngleDeltaY(AngleDeltaY),
																.AngleDeltaUV(AngleDeltaUV),
																.referencePixel(referencePixel_buffer),
																.maxX(maxX_buffer),
																.maxY(maxY_buffer),
																.base_angle(base_angle),
																.w(w_buffer),
																.h(h_buffer),
																.x(x),
																.y(y),
																.aboveRow(aboveRow_buffer),
																.leftCol(leftCol_buffer),
																.pred(directional_prediction_result));
//// smooth prediction instantiation
//smooth_mode 						smooth_prediction(.clk(clk),
//																.mode(mode_buffer),
//																.log2W(log2W_buffer),
//																.log2H(log2H_buffer),
//																.aboveRow(aboveRow_buffer),
//																.leftCol(leftCol_buffer),
//																.pred(smooth_prediction_result));
																
// DC prediction instantiation
dc_mode								    DC_prediction(.clk(clk),
																.haveLeft(haveLeft_buffer),
																.haveAbove(haveLeft_buffer),
																.w(w_buffer),
																.h(h_buffer),
																.log2W(log2W_buffer),
																.log2H(log2H_buffer),
																.leftCol(leftCol_buffer),
																.aboveRow(aboveRow_buffer),
																.pred(DC_prediction_result));
																
// Paeth prediction instantiation
paeth_mode 							 Paeth_prediction(.clk(clk),
																.referencePixel(referencePixel_buffer),
																.aboveRow(aboveRow_buffer),
																.leftCol(leftCol_buffer),
																.pred(paeth_prediction_result));


// always_ff
always_ff @(posedge clk)
	begin
			
		// load values into directional mode prediction
		if(directional_prediction_enable == 1'd1)
			begin
				plane_buffer				   <= plane;
				haveLeft_buffer				<= haveLeft;
				haveAbove_buffer				<= haveAbove;
				mode_buffer						<= mode;
				intra_filter_enable_buffer <= 1'd1;
				referencePixel_buffer		<= referencePixel;
				maxX_buffer						<= maxX;
				maxY_buffer						<= maxY;
				w_buffer							<= w;
				h_buffer							<= h;
				aboveRow_buffer				<= aboveRow;
				leftCol_buffer					<= leftCol;
				pred_out 						<= directional_prediction_result;
			end
			
//		// load values into smooth mode prediction
//		if(smooth_prediction_enable == 1'd1)
//			begin
//				mode_buffer     <= mode;
//				log2W_buffer    <= log2W;
//				log2H_buffer    <= log2H;
//				aboveRow_buffer <= aboveRow;
//				leftCol_buffer  <= leftCol;
//				pred_out			 <= smooth_prediction_result;
//			end
			
		// load values into DC mode prediction
		if(DC_prediction_enable == 1'd1)
			begin
				haveLeft_buffer  <= haveLeft;
				haveAbove_buffer <= haveAbove;
				w_buffer 		  <= w;
				h_buffer 		  <= h;
				log2W_buffer 	  <= log2W;
				log2H_buffer 	  <= log2H;
				leftCol_buffer   <= leftCol;
				aboveRow_buffer  <= aboveRow;
				pred_out			  <= DC_prediction_result;
			end
			
		// load values into Paeth mode prediction
		if(Paeth_prediction_enable == 1'd1)
			begin
				referencePixel_buffer <= referencePixel;
				aboveRow_buffer 		 <= aboveRow;
				leftCol_buffer 		 <= leftCol;
				pred_out					 <= paeth_prediction_result;
			end
	end

// always_comb
always_comb
	begin
		
// ------------------ VARIABLE DECLARATIONS  ------------------------
		
		// calculate log2W and log2H
		w = 10'd1 << log2W;
		h = 10'd1 << log2H;
		
		i = 0;
		j = 0;
		
		// set subsampling flags (for 4:2:0)
		subsampling_x = 1'd1;
		subsampling_y = 1'd1;
		
		// enable_intra_edge_filter
		intra_filter_enable = 1'd1;
		
		// calculate maxX and maxY
		if(plane > 0)
			begin
				maxX = ((MI_COLS * MI_SIZE) >> subsampling_x) - 1;
				maxY = ((MI_ROWS * MI_SIZE) >> subsampling_y) - 1;
			end
		else
			begin
				maxX = (MI_COLS * MI_SIZE) - 16'd1;
				maxY = (MI_ROWS * MI_SIZE) - 16'd1;
			end
			
// ------------------ ABOVEROW/LEFTCOL CREATION ----------------------
			
		// create aboveRow	
		if((haveAbove == 1'd0) && (haveLeft == 1'd1))
			begin
				// set aboveRow to the leftCol samples
				aboveRow = leftCol_read;
			end
		else if((haveAbove == 1'd0) && (haveLeft == 1'd0))
			begin
				// set all values of aboveRow to 512
				for(i = 0; i < 8; i++)
					begin
						aboveRow[i] = 10'd511;
					end
			end
		else
			begin
				aboveRow = aboveRow_read;
			end
			
		// create leftCol
		if((haveAbove == 1'd1) && (haveLeft == 1'd0))
			begin
				// set aboveRow to the leftCol samples
				leftCol = aboveRow_read;
			end
		else if((haveAbove == 1'd0) && (haveLeft == 1'd0))
			begin
				// set all values of aboveRow to 512
				for(i = 0; i < 8; i++)
					begin
						leftCol[i] = 10'd511;
					end
			end
		else
			begin
				leftCol = leftCol_read;
			end
		

// ------------------- REFERENCEPIXEL CREATION -----------------------		
		
		referencePixel = 10'd200;
		
// --------------------- PREDICTION ENABLE --------------------------- 
			
				
			// directional mode prediction
			if((mode > 10'd0) && (mode < 10'd9))
				begin
					directional_prediction_enable = 1'd1;
				end
			else
				begin
					directional_prediction_enable = 1'd0;
				end
			
//			// SMOOTH_PRED, SMOOTH_H_PRED and SMOOTH_V_PRED
//			if((mode > 10'd8) && (mode < 10'd12))
//				begin
//					smooth_prediction_enable = 1'd1;
//				end
//			else
//				begin
//					smooth_prediction_enable = 1'd0;
//				end
			
			// DC prediction
			if(mode == 10'd0)
				begin
					DC_prediction_enable = 1'd1;
				end
			else
				begin
					DC_prediction_enable = 1'd0;
				end
			
			// Paeth prediction
			if(mode == 10'd12)
				begin
					Paeth_prediction_enable = 1'd1;
				end
			else
				begin
					Paeth_prediction_enable = 1'd0;
				end
			
	end


endmodule : intra_control