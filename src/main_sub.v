`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Spehro
// 
// Create Date:    06:05:25 11/21/2022 
// Design Name: 
// Module Name:    main 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`default_nettype none
`timescale 1ns/1ps

module trexon_main (
    input [7:0] io_in,
    output [7:0] io_out
    );
  wire clk = io_in[0];
  wire nrset = io_in[1];
  wire eeprom_out = io_in[2]; 
  wire run_nstop = io_in[3]; 
  
  wire eeprom_cs; 
  assign io_out[0] = eeprom_cs;
  wire eeprom_in; 
  assign io_out[0] = eeprom_in;
  wire eeprom_clk; 
  assign io_out[0] = eeprom_clk;
  wire hc595_clk; 
  assign io_out[0] = hc595_clk;
  wire hc595_lat 
  assign io_out[0] = hc595_lat;
  wire hc595_noe; 
  assign io_out[0] = hc595_noe;
  wire hc595_dat_and_stepper_dat; 
  assign io_out[0] = hc595_dat_and_stepper_dat;
  wire stepper_step; 
  assign io_out[0] = stepper_step;
  


endmodule


module main(
//    input fpga_clk, // just for testing! 
    input clk,
//    output reg clk_out, 
    input nreset,
    input eeprom_out,
    input run_nstop,
    output reg eeprom_cs, 
    output reg eeprom_in,
    output reg eeprom_clk,
    output reg hc595_clk,
    output reg hc595_latch,
    output reg hc595_noe,
    output reg hc595_dat_and_stepper_dat,
	 output reg [1:0] my_state,  // just for testing
	 output reg my_sr_shift, // just for testing 
    output reg spi_snd_r, 
    output reg stepper_step,
    input unused_1,
    input unused_2,
    input unused_3,
    input unused_4
    );
localparam IDLE_state = 0,
           EEPROM_INSTRUCTION_state = 1,
		     EEPROM_READING_state = 2,
           RUNNING_state = 3; 
 reg [1:0] next_state; 
 reg [1:0] current_state; 			  
	 

 reg [7:0] eeprom_byte; 
 
 reg spi1_send_request; 

 reg spi2_send_request; 

 
wire [7:0] spi1_din; 
wire [7:0] spi2_din; 
 reg spi1_cs_at_end; 
 reg spi2_cs_at_end; 
 
 
 reg [7:0] sr_input_data;
 
 
 wire [7:0] spi1_dout; 
 wire [7:0] spi2_dout; 
 wire [3:0] spi1_bit_counter; 
 wire [3:0] spi2_bit_counter; 
 wire [6:0] pixels; 
 wire [7:0] sr_output_data; 
 
 
   
 reg sr_direction; 
 reg sr_shift;
 reg sr_input_rotate; 
 
 
 reg stepper_run_in; 
 
 reg spi1_data_valid_dly; // delayed version by one clock 
 reg spi2_data_valid_dly; // delayed version by one clock 
 
 // test stuff!!! 
// 
// reg clk; 
// reg [12:0] clk_ctr; 
// always @ (posedge fpga_clk)
//   begin
//	   if (clk_ctr == 13'd2500)
//		  begin
//		     clk <= ~clk; 
//			  clk_out <= clk; 
//		     clk_ctr <= 0; 
//		  end 
//		 else 
//         clk_ctr <= clk_ctr +1; 		 
//	 
//	end 

 // State transitions for state machine 
always @ (*)
  begin
    next_state = current_state; // this is the default 
    case (current_state) 
      IDLE_state: 
		  begin 
		     if (run_nstop) next_state = EEPROM_INSTRUCTION_state; 
		  end 
		EEPROM_INSTRUCTION_state:
        begin
		  
         if ((spi1_data_valid) && (eeprom_byte == 4 )) 
             next_state = EEPROM_READING_state;  	   
        end 		  
      EEPROM_READING_state: 
		  begin
         if ((spi1_data_valid) && (eeprom_byte == 8'd100 )) 

			    next_state = RUNNING_state; 
        end 		  
		RUNNING_state: 
		  begin 
		     if (!run_nstop) next_state = IDLE_state;
		  end 
    endcase 
  end 
  
 

// wire modules up with i/o and other modules 
always @(*) 
   begin 
	  eeprom_cs = (!((current_state == EEPROM_INSTRUCTION_state) || (current_state == EEPROM_READING_state))); 
	  stepper_run_in = (current_state == RUNNING_state) ? 1'h1:1'h0; 
	  eeprom_clk = spi1_sclk; 
     eeprom_in = spi1_mosi; 
	  hc595_clk = spi2_sclk; 
//	  hc595_dat_and_stepper_dat = spi2_mosi ;  // this one needs gating and combined 
//	  hc595_dat_and_stepper_dat = (spi2_mosi & spi2_processing) | (dir & hc595_latch) ; 
//	  hc595_dat_and_stepper_dat =  ((dir & ~spi2_processing) | (spi2_mosi & spi2_processing));  
	  hc595_dat_and_stepper_dat =  ((~dir & ~spi2_processing) | (spi2_mosi & spi2_processing));  


	  
//	  stepper_step = step;  // need to delay this by one clock pulse 
	  hc595_noe = nOE; 
	  my_state = current_state; // test
	  my_sr_shift = sr_shift; // test 

	  spi_snd_r = spi1_send_request; 
	  sr_input_data = spi1_dout; 
//	  sr_input_data = 8'hAA; // just a test! 
	
	end 

 assign spi1_reset = nreset; 
 assign spi2_reset = nreset; 
 assign sr_reset = nreset; 
 assign stepper_reset = nreset; 
 assign spi1_clk = clk;
 assign spi2_clk = clk; 
 assign spi1_miso = eeprom_out; 
 assign spi2_miso = 0; 
 assign spi1_din = ((eeprom_byte == 0) && (current_state == EEPROM_INSTRUCTION_state)) ? 8'h3:8'h0; 
 assign spi2_din = sr_output_data;

// instantiate spi1 module - EEPROM read SPI 
	spi_send_receive spi1 (
		.clk(spi1_clk), 
		.nreset(spi1_reset), 
		.mosi(spi1_mosi), 
		.miso(spi1_miso), 
		.sclk(spi1_sclk),
		.cs(spi1_cs), 
		.din(spi1_din), 
		.dout(spi1_dout), 
		.data_valid(spi1_data_valid), 
		.processing (spi1_processing), 
		.send_request(spi1_send_request), 
		.cs_at_end(spi1_cs_at_end),
		.bit_counter(spi1_bit_counter)
	);


// instantiate spi2 module - output SPI 
	spi_send_receive spi2 (
		.clk(spi2_clk), 
		.nreset(spi2_reset), 
		.mosi(spi2_mosi), 
		.miso(spi2_miso), 
		.sclk(spi2_sclk),
		.cs(spi2_cs), 
		.din(spi2_din), 
		.dout(spi2_dout), 
		.data_valid(spi2_data_valid), 
		.processing (spi2_processing), 
		.send_request(spi2_send_request), 
		.cs_at_end(spi2_cs_at_end),
		.bit_counter(spi2_bit_counter)
	);

// instantiate stepper control 
	stepper_control_v2 stepper (
		.clk(clk), 
		.nreset(stepper_reset), 
		.run(stepper_run_in), 
		.step(step), 
		.dir(dir),
		.pixel_clock(pixel_clock), 
		.nOE(nOE), 
		.pixels(pixels)
	);
// instantiate shift registers with depth of 100 and default with of 8 
	bidi_shift_register   #(.SR_DEPTH(100)) shift_reg (
		.clk(clk), 
		.nreset(sr_reset), 
		.input_data(sr_input_data), 
		.output_data(sr_output_data), 
		.direction(sr_direction), 
		.shift(sr_shift),    // shift on positive edge 
		.input_rotate(sr_input_rotate)
	);
	

initial  // simulation only 
begin
  current_state = IDLE_state; 
end 



always @ (posedge clk or negedge nreset) 
begin
	if (!nreset) 
	  begin
	  current_state <= IDLE_state; 

	  spi1_send_request <= 0; 
     spi1_data_valid_dly <=0; 
	  spi2_send_request <= 0; 
     spi2_data_valid_dly <=0; 
	  hc595_latch <= 0;   // positive edge triggered 

     spi2_cs_at_end <= 0; 

	 

	  end 
	else 
	begin  // now we have a clock edge without reset 
	  stepper_step <= step;  // delayed step clock 
     spi1_data_valid_dly <= spi1_data_valid; // delay it 
     spi2_data_valid_dly <= spi2_data_valid; // delay it 
	  
	  spi1_send_request <= 0; 
     case (current_state) 
	      IDLE_state: 
			   begin  
				end
			EEPROM_INSTRUCTION_state: 
            begin 
	    	     if (! (spi1_processing)) 
  				    begin 
				       sr_direction <= 0; 
					    sr_shift <= 0; 
					    sr_input_rotate <= 0; 
					    spi1_cs_at_end <= 0; 
                   spi1_send_request <= 1; // prime it 
                 end
               else 
                   spi1_send_request <= 0;  // only pulse it 
               						 
               if ((spi1_data_valid) && (!spi1_data_valid_dly))
                 begin
                   eeprom_byte <= eeprom_byte+1;      
                 end 					  
             end 				
			EEPROM_READING_state:
            begin 
	    	     if (! (spi1_processing)) 
  				    begin 
				       sr_direction <= 0; 
					    sr_shift <= 0; 
					    sr_input_rotate <= 0; 
					    spi1_cs_at_end <= 0; 
                   spi1_send_request <= 1; // prime it 
                 end
               else 
                   spi1_send_request <= 0;  // only pulse it 
               						 
               if ((spi1_data_valid) && (!spi1_data_valid_dly))
                 begin
                   eeprom_byte <= eeprom_byte+1;     
                   sr_shift <= 1; 						 
                 end 					  
             end 		
         RUNNING_state: 
			   begin 
				   spi2_send_request <= pixel_clock; 
	    	     if (! (spi2_processing)) 
  				    begin 
					    sr_direction <= dir;  // shift in the direction the stepper controller wants 
				       sr_shift <= 0; 
					    sr_input_rotate <= 1; 
					    spi1_cs_at_end <= 0;   // not connected 
       //            spi2_send_request <= 1; // data from last time 
						 hc595_latch <= 0; 
                 end
               else 
					   begin
						end 
      //             spi2_send_request <= 0;  // only pulse it 
               						 
               if ((spi2_data_valid) && (!spi2_data_valid_dly))
                 begin
                   eeprom_byte <= eeprom_byte+1;     // don't really need to keep track of this 
                   sr_shift <= 1; 		
                   hc595_latch <= 1; 						// latch the data to the outputs and turn LEDs on. 
						 
                 end 					  
             end 					
			 endcase 
	if (current_state != next_state) 
      begin 
        eeprom_byte <= 0; 
		  //eeprom_reading_done <= 0; 
		  sr_shift <= 0; 
      end 		
   current_state <= next_state; 
	end 
end 	





endmodule





