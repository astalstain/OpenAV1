// Filename    : intra_edge_filter_strength_selection.sv
// Author      : Jean-Paul Astal-Stain
// Description : 
// Created     : 22/04/2020 
// Changes     : 
//	To-do     	: - [DONE] need to update system to handle negative delta

module intra_edge_filter_strength_selection(
	input  logic		        clk,
	input  logic        [9:0] w,
	input  logic        [9:0] h,
	input  logic              filterType,
	input  logic signed [9:0] delta,
	output logic        [9:0] filter_strength
);

// define internal registers
logic [9:0] next_filter_strength;
logic [9:0] blkWh; 						// w + h
logic [9:0] d;

// on every clock, push result to output
always_ff @(posedge clk)
	begin
		
		filter_strength <= next_filter_strength;

	end
	
always_comb
	begin
		
		// calculate d = abs(delta)
		if(delta > 0)
			begin
				d = delta;
			end
		else
			begin
				d = -delta;
			end
			
		// define next_filter_strength
		next_filter_strength = 10'd3;
		
		// calculate blkWh
		blkWh = w + h;
		
		// identify strength with conditional statements
		if(filterType == 1'd0)
			begin
				if(blkWh <= 10'd8)
					begin
						if(d >= 10'd56)
							begin
								next_filter_strength = 10'd1;
							end
					end
				else if(blkWh <= 10'd12)
					begin
						if(d >= 10'd40)
							begin
								next_filter_strength = 10'd1;
							end
					end
				else if(blkWh <= 10'd16)
					begin
						if(d >= 10'd40)
							begin
								next_filter_strength = 10'd1;
							end
					end
				else if(blkWh <= 10'd24)
					begin
						if(d >= 10'd8)
							begin
								next_filter_strength = 10'd1;
							end
						if(d >= 10'd16)
							begin
								next_filter_strength = 10'd2;
							end
						if(d >= 10'd32)
							begin
								next_filter_strength = 10'd3;
							end
					end
				else if(blkWh <= 10'd32)
					begin
						next_filter_strength = 10'd1;
						
						if(d >= 10'd4)
							begin
								next_filter_strength = 10'd2;
							end
						if(d >= 10'd32)
							begin
								next_filter_strength = 10'd3;
							end
					end
				else
					begin
						next_filter_strength = 10'd3;
					end
			end
		else
			begin
				if(blkWh <= 10'd8)
					begin
						if(d >= 10'd40)
							begin
								next_filter_strength = 10'd1;
							end
						if(d >= 10'd64)
							begin
								next_filter_strength = 10'd2;
							end
					end
				else if(blkWh <= 10'd16)
					begin
						if(d >= 10'd20)
							begin
								next_filter_strength = 10'd1;
							end
						if(d >= 10'd48)
							begin
								next_filter_strength = 10'd2;
							end
					end
				else if(blkWh <= 10'd24)
					begin
						if(d >= 10'd4)
							begin
								next_filter_strength = 10'd3;
							end
					end
				else
					begin
						next_filter_strength = 10'd3;
					end
			end
		
	end

endmodule : intra_edge_filter_strength_selection