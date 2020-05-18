// Filename    : intra_edge_upsample_selection.sv
// Author      : Jean-Paul Astal-Stain
// Description : 
// Created     : 22/04/2020 
// Changes     : 
//	To-do     	: - need to calculate delta properly - use absolute function

module intra_edge_upsample_selection(
	input  logic       		  clk,
	input  logic 		 		  filterType,
	input  logic 		  [9:0] w,
	input  logic 		  [9:0] h,
	input  logic signed [9:0] delta,
	output logic       		  useUpsample
);

// define internal registers
logic		   next_useUpsample;
logic [9:0] blkWh;
logic [9:0] d;
 
// push result to output
always_ff @(posedge clk)
	begin
		useUpsample <= next_useUpsample;
	end

// calculate useUpsample
always_comb
		begin
			
			// set useUpsample = 0 to prevent latch
			next_useUpsample = 1'b0;
		
			// calculate d = abs(delta)
			if(delta > 0)
				begin
					d = delta;
				end
			else
				begin
					d = -delta;
				end
		
			//$display("d: %d", d);
			
			// calcuate blkWh
			blkWh = w + h;
			
			if(d <= 10'd0 || d >= 10'd40)
				begin
					next_useUpsample = 1'd0;
				end
			else if(filterType == 1'd0)
				begin
					if(blkWh <= 10'd16)
						begin
							next_useUpsample = 1'd1;
						end
					else
						begin
							next_useUpsample = 1'd0;
						end
				end
			else
				begin
					if(blkWh <= 10'd8)
						begin
							next_useUpsample = 1'd1;
						end
					else
						begin
							next_useUpsample = 1'd0;
						end
			end
		end
		
endmodule : intra_edge_upsample_selection