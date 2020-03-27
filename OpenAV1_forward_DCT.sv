// Filename: OpenAV1_forward_DCT.sv
// Author: Jean-Paul Astal-Stain


	
// Y = ( C . X . Ct) x E
	

// takes two 4x4 matrices and applies the dot product
//module OpenAV1_4x4_dotproduct(clk, reset, A, B, C);
module OpenAV1_forward_DCT(A, B, C);

	// input port definitions - 4x4x8 = 128 bits
	input [127:0] A;
	input [127:0] B;
	
	// output port definition - 4x4x8 = 128 bits
	output [127:0] C;
	
	// internal variable definitions
	reg [127:0] C;
	reg [7:0] A1 [0:3][0:3];
	reg [7:0] B1 [0:3][0:3];
	reg [7:0] C1 [0:3][0:3];
	int i, j, k;
	
	// do the following when A or B change
	always @ (A or B)
		begin
		
		// convert the 1D arrays into 3D (2D + value)
		{A1[0][0], A1[0][1], A1[0][2], A1[0][3],
		 A1[1][0], A1[1][1], A1[1][2], A1[1][3],
		 A1[2][0], A1[2][1], A1[2][2], A1[2][3],
		 A1[3][0], A1[3][1], A1[3][2], A1[3][3]} = A;
			  
		{B1[0][0], B1[0][1], B1[0][2], B1[0][3],
		 B1[1][0], B1[1][1], B1[1][2], B1[1][3],
		 B1[2][0], B1[2][1], B1[2][2], B1[2][3],
		 B1[3][0], B1[3][1], B1[3][2], B1[3][3]} = B;
			  
		// initialise C1 to 0s	  
		{C1[0][0], C1[0][1], C1[0][2], C1[0][3],
	    C1[1][0], C1[1][1], C1[1][2], C1[1][3],
		 C1[2][0], C1[2][1], C1[2][2], C1[2][3],
		 C1[3][0], C1[3][1], C1[3][2], C1[3][3]} = 128'd0;
			  
	   // initialise loop variables to 0
		i = 0;
		j = 0;
		k = 0;
		
		// matrix dot product loop
		for (i = 0; i < 4; i = i + 1)
			for(j = 0; j < 4; j = j + 1)
				for(k = 0; k < 4; k = k + 1)
					C1[i][j] = C1[i][j] + (A1[i][k] * B1[k][j]);
		
		// final output assignment - conversion back to 1D array
		C = {C1[0][0], C1[0][1], C1[0][2], C1[0][3],
			  C1[1][0], C1[1][1], C1[1][2], C1[1][3],
			  C1[2][0], C1[2][1], C1[2][2], C1[2][3],
			  C1[3][0], C1[3][1], C1[3][2], C1[3][3]};
		
		end

endmodule 


