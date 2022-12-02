`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Spehro Pefhany 
// 
// Create Date:    06:02:46 11/16/2022 
// Design Name: 
// Module Name:    bidi_shift_register 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description:  parameterized width shift-register that can input data or rotate
//	right or left  first Verilog project ever
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module bidi_shift_register
   #(parameter SR_WIDTH=8, parameter SR_DEPTH = 16)(
	 input clk, 
	 input nreset, 
	 input [SR_WIDTH-1:0] input_data,

//	 output reg [SR_WIDTH-1:0] output_data [SR_DEPTH-1:0] ,
	 output reg  [SR_WIDTH-1:0] output_data,

	 input direction,  // 0 = right, 1 = left 
	 input shift, // 1 = shift 0 = supress shift 
	 input input_rotate   // 0 = input 1 = rotate 
	 );
integer i; 
reg shift_dly; // only shift once per high 
//reg [SR_DEPTH-1:0] temp; 
reg [SR_WIDTH-1:0] sr_data [SR_DEPTH-1:0];  
initial begin 
//   output_data <= 8'd0; // should expand to width of register? 
   output_data <= 0; // should expand to width of register? 

   end 
always @ (posedge  clk)  
begin

   if (!nreset) 
	  begin 
	   for (i=0; i<SR_DEPTH; i=i+1)
		  sr_data[i] <= 0; 
	   end 	  
	else 
   begin 	
   shift_dly <= shift; 
   if ((shift) && (!shift_dly)) 
	  begin
       if (direction == 0)  // right shift or rotate
       begin 
       	for (i= SR_DEPTH-1; i>0; i = i-1)
		      begin 
			    sr_data[i]<=sr_data[i-1]; 
			   end
          sr_data[0]<= (input_rotate == 0) ? input_data : sr_data[SR_DEPTH-1]; 

       end 			 
		 else // must be left shift or rotate 
		   begin
			  for (i=0; i< SR_DEPTH-1 ; i= i+1) 
			    begin 
				   sr_data[i]<=sr_data[i+1]; 
				 end 
	       sr_data[SR_DEPTH-1] <= (input_rotate == 0) ? input_data : sr_data[0]; 
			  
  			 end 
	  end 
  end 
// output_data = sr_data[SR_DEPTH-1];  // NOT  here 

end 

always @ (sr_data[SR_DEPTH-1])
    output_data <= sr_data[SR_DEPTH-1];  

endmodule
