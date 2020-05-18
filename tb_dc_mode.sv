// test bench
module tb_dc_mode(
	input logic clk, 
	input logic out
);

	// define the internal registers
	logic       clk_in;
	logic 		haveLeft_in;
	logic  		haveAbove_in;
	logic [9:0] w_in;
	logic [9:0] h_in;
	logic [9:0] log2W_in;
	logic [9:0] log2H_in;
	logic [29:0] leftCol_in  [0:7];
	logic [29:0] aboveRow_in [0:7];
	logic [29:0] result 		[0:3][0:3];
	int fd;
	logic[15:0] line;
	// instantiate the uut
	dc_mode uut(.clk(clk_in),
					.leftCol(leftCol_in), 
					.aboveRow(aboveRow_in), 
					.haveLeft(haveLeft_in), 
					.haveAbove(haveAbove_in), 
					.log2W(log2W_in), 
					.log2H(log2H_in), 
					.w(w_in), 
					.h(h_in), 
					.pred(result));
	
	initial
		begin
		
		// set inputs to zero at the start
		haveLeft_in  = 1'd0;
		haveAbove_in = 1'd0;
		log2W_in 	 = 10'd0;
		log2H_in 	 = 10'd0;
		w_in 			 = 10'd0;
		h_in 			 = 10'd0;
		leftCol_in   = '{30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0};
		aboveRow_in  = '{30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0, 30'd0};

		// delay 100ns
		#100;
		
		
		
		// set the inputs to stimulate the module		
		haveLeft_in  = 1'd1;
		haveAbove_in = 1'd0;
		log2W_in 	 = 10'd2;
		log2H_in 	 = 10'd2;
		w_in 			 = 10'd4;
		h_in 		    = 10'd4;
		leftCol_in 	 = '{30'd12, 30'd13, 30'd5, 30'd3, 30'd12, 30'd13, 30'd5, 30'd3};
		aboveRow_in  = '{30'd16,  30'd1, 30'd2, 30'd9, 30'd16,  30'd1, 30'd2, 30'd9};
 		

	end
		
	// toggle the clock every 5ns	
	always
		begin
			clk_in = 1'd0;
			#5;
			clk_in = 1'd1;
			#5;
		end
	
endmodule : tb_dc_mode