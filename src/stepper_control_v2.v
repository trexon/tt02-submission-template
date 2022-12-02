`timescale 1us / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Spehro Pefhany
// 
// Create Date:    13:22:58 11/24/2022 
// Design Name: 
// Module Name:    stepper_control_v2 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: first Verilog project ever
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
// as long as run is high it generates pulses to scan continously. When run is
// removed it returns to left 
//
//////////////////////////////////////////////////////////////////////////////////
module stepper_control_v2(
    input clk,
    input nreset,
    input run,
    output reg step,
    output reg dir,
	 output reg pixel_clock, 
	 output reg nOE, 
	 output reg [6:0] pixels 
    );

parameter CLK_DIVIDER = 20; // clocks per clock out , minimum 2 (data_out only allowed to change when clk_out is *falling*  
localparam IDLE  = 0,
		     RUNNING_L_TO_R = 1,
           RUNNING_R_TO_L  = 2;
			  
    reg [1:0] next_state; 
	 reg [1:0] current_state; 
	 reg do_step;
    reg [6:0] pixel_counter;  // only 100 are actually pixels 	 
	 wire left_count, right_count; 
	 reg [$clog2(CLK_DIVIDER+1):0] clk_divider;
	 wire clk_divider_done;
	 wire showing_leds;
	 
// State transitions 
always @ (*)
  begin
    next_state = current_state; // this is the default 
    case (current_state) 
      IDLE: 
		  begin 
		     if (run) next_state = RUNNING_L_TO_R; 
		  end 
      RUNNING_L_TO_R: 
		  begin
           if (right_count) next_state = RUNNING_R_TO_L; 
        end 		  
		RUNNING_R_TO_L: 
		  begin 
		     if ((left_count) && (run)) next_state = RUNNING_L_TO_R; 
			     else if (left_count) next_state = IDLE; 
		  end 
//		 default: next_state = current_state; 
    endcase 
  end 
  
  
always @ (posedge clk or negedge nreset) 
  begin
    if (!nreset) 
	    begin 
		   current_state <= 0; 
			pixel_counter <= 0; 
   	 end 
    else 
	    if (clk_divider_done)
	    begin 
			 current_state <= next_state; 
          if (current_state == RUNNING_L_TO_R) pixel_counter <= pixel_counter +1; 
		    if (current_state == RUNNING_R_TO_L) pixel_counter <= pixel_counter -1; 

       end 

  end   
  
 

assign right_count =  (pixel_counter == 7'h7E) ? 1:0; 
assign left_count = (pixel_counter == 7'h1) ? 1:0; 

assign showing_leds = ((pixel_counter > 14) && (pixel_counter < 115)); 


assign clk_divider_done = (clk_divider == CLK_DIVIDER - 1) ? 1:0; 

always @(posedge clk or negedge nreset)
  begin
    if (!nreset) 
	  begin 
	    clk_divider <= 0; 
		 step <= 0; 
		 pixel_clock <= 0; 
	  end 
  else begin
     step <= (clk_divider_done == 1) ? do_step:0; 
	  pixel_clock <= (clk_divider_done == 1) ? showing_leds:0; 
	  if  (clk_divider_done) 
	     begin 
			 clk_divider  <= 0; 
		  end	 
	  else 
       begin 
          clk_divider <= clk_divider+1; 
       end 		 
   end
 end 



always @ (*)
   begin
     dir <= (current_state == RUNNING_R_TO_L) ? 1:0; 
     pixels <= pixel_counter ; 
	  nOE <= ~showing_leds; 
   end 

always @ (*) 
  begin 
//    do_step =  run ? 1'h1:1'h0; 
     do_step  =  ((current_state == RUNNING_L_TO_R) ||  (current_state == RUNNING_R_TO_L )) ? 1'h1 : 1'h0; 
//    if (((pixel_counter < 14) || (pixel_counter > 115)) &&  (run == 1'h1))	 
    if (((pixel_counter < 14) || (pixel_counter > 115)) &&  ((current_state == RUNNING_L_TO_R) ||  (current_state == RUNNING_R_TO_L )))	 
      begin 
	    case (pixel_counter)  // acceleration control for both directions 
          0: do_step = 1; 
          4: do_step = 1;
          7: do_step = 1;
          10: do_step = 1;
			 12: do_step = 1;
		    127: do_step = 1;
		    123: do_step = 1;
		    120: do_step = 1;
		    117: do_step = 1;
		    115: do_step = 1;
		     default: do_step = 1'h0;
        endcase     

		end   
  
  end 
  
/*
always @(posedge clk or negedge clk)
  begin 
 //   if (clk) (do_step) step <= 1; 
	//   else step <= 0; 
  end 
//always @ (negedge clk) 
 //  step <= 0; 
*/
//always @(*)
//  begin
//     step = clk & do_step; 
//  end 

endmodule


