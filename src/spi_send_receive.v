`timescale 1us / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Spehro Pefhany
// 
// Create Date:    22:56:06 11/11/2022 
// Design Name: 
// Module Name:    spi_send_receive 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description:  first Verilog project ever 
//
// Dependencies:  
//
// Revision: pulse
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spi_send_receive(
    input clk, // 5kHz external clock 
	 input nreset,
	 output reg mosi, 
	 input miso, 
	 output reg sclk, // clock to SPI EEPROM
	 output reg cs, // chip select 
	 input [7:0] din, // input byte
	 output reg [7:0] dout,
	 output reg data_valid, 
	 output reg processing, 
	 input send_request,
	 input cs_at_end, // whether to leave cs high or low at end - leave low if more bytes to be transferred 
	 output reg [3:0] bit_counter // just a test 
	 );
	 reg in_progress; 
	 reg send_request_dly;

    reg [7:0] dlat; 
	 
initial // this is just for simulation 
    begin
	 bit_counter = 4'd0; 
	 cs = 1; 
	 in_progress = 0; 
	 send_request_dly = 0;    
	 end 
	 
always @ (*)
    processing = in_progress; 


// this is a combinatorial multiplexer 	  
//always @ (din, bit_counter)
always @ (*)
   begin
			    case (bit_counter)
				   0: begin mosi = dlat[7]; end
				   1: begin  mosi = dlat[6]; end
					2: begin  mosi = dlat[5]; end
					3: begin  mosi = dlat[4]; end
					4: begin  mosi = dlat[3]; end
					5: begin  mosi = dlat[2]; end
					6: begin  mosi = dlat[1]; end
					default: begin mosi = dlat[0]; end
				 endcase	 	  
	 end 
	  
// clock and level-sensitive reset 	  
always @ (posedge clk or negedge nreset)
    begin
    if (!nreset) 
	    begin
		 bit_counter <= 4'd0; 
		 cs <= 1; 
		 dout <= 8'd0;  
		 data_valid <= 0;
		 in_progress <= 0; 
		 sclk <= 0; 
       dlat <= 8'h0; 
		 //mosi <= 0;

		 end 
     else 
	    begin
		   
		   if ((!sclk && in_progress) && (bit_counter <8)) sclk <= 1;  // just clock it on every alternate input clock cycle  was 1!!!
         else 
			   begin
				   send_request_dly <= send_request;  
			     if ((!in_progress) && ( send_request))  
				    begin   
						dlat <= din; 
                end
			     if ((!in_progress) && ( send_request_dly))  // first clock after send_request active? 

		          begin
					   //dlat <= din; 
						in_progress <= 1; 	 
						data_valid <= 0; 
						cs <= 0; 
						bit_counter <= 4'd0; 
                end 
			 if (in_progress) 
          begin
            if  (bit_counter < 8) sclk <= 0; 	// set up to be clocked next input clock edge 
				if (bit_counter == 8) 
            begin
				  data_valid <= 1; 
				  bit_counter <= 0; 
				  in_progress <= 0;
				  cs <= cs_at_end; 
				end 	 
            else 
				begin 
				   //bit_counter = bit_counter + 4'd1; 
					case (bit_counter)
					  0: begin dout[7]<=miso;  end
					  1: begin dout[6]<=miso; end
					  2: begin dout[5]<=miso;  end
					  3: begin dout[4]<=miso;  end
					  4: begin dout[3]<=miso;  end
					  5: begin dout[2]<=miso;  end
					  6: begin dout[1]<=miso;  end
					 default: begin dout[0]<=miso;  end
					 endcase	  
					 bit_counter <= bit_counter + 4'd1; 
		 		   end 

         end 			 
       end 
	  end
	end

endmodule
