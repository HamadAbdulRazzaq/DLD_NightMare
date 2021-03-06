// Code your design here
// Code your design here
`timescale 1ns / 1ps
module counter_10_bit(clk, count, trig);
  input clk;
  output [9:0] count;
  output trig;
  reg trig;
  reg [9:0] count;
  initial
    begin
    count = 0;
  	trig = 0;
    end
  always @(posedge clk)
    begin
      if (count < 799)
        begin       
          count <= count + 1;
          trig<=0;
        end
      else
        begin
          count <= 0;
          trig <= 1;
        end
    end
endmodule

//---------------------------------------------
module counter_10_bit1(clk, count, enable);
  input clk;
  input enable;
  output [9:0] count;
  reg [9:0] count;
  initial
    begin
    count = 0;
    end
  always @(posedge clk)
    begin
      if (enable == 1)
        begin
          if (count <= 523)
            begin        
              count <= count + 1;
            end
          else
            begin
          		count <= 0;
            end
      	end
     end
endmodule

//------------------------------------------------------------

module clk_div(clk,clk_d);
  parameter div_value= 1;
  input clk;
  output clk_d;
  reg clk_d;
  reg count;
  initial
    begin 
      clk_d=0;
      count=0;
    end
  always @(posedge clk)
    begin 
      if (count == div_value)
        count <=0;
      else
        count<=count+1;
    end
  always @(posedge clk)
    begin 
      if (count == div_value)
        clk_d <= ~ clk_d;
    end
endmodule





module clk_div2(clk,clk_d2);
  parameter div_value= 4999999;
  input clk;
  output clk_d2;
  reg clk_d2;
  reg [23:0]count;
  initial
    begin 
      clk_d2=0;
      count=0;
    end
  always @(posedge clk)
    begin 
      if (count == div_value)
        count <=0;
      else
        count<=count+1;
    end
  always @(posedge clk)
    begin 
      if (count == div_value)
        clk_d2 <= ~ clk_d2;
    end
endmodule










//----------------------------------//

module vga_sync (
  input [9:0] h_count,
  input [9:0] v_count,
  output  h_sync,
  output v_sync,
  output video_on,
  output [9:0] x_loc,
  output [9:0] y_loc
);
  
  //horizontal
  localparam HD = 640;
  localparam HF = 16;
  localparam HB = 48;
  localparam HR = 96;
  
  //vertical
  localparam VD = 480;
  localparam VF = 10; 
  localparam VB = 33; 
  localparam VR = 2;
  
assign h_sync = ((h_count < (HD+HF)) || (h_count >= (HD+HF+HR)));
  
assign v_sync = ((v_count < (VD+VF)) || (v_count >= (VD+VF+VR)));
  
assign video_on = ((h_count < HD) && (v_count < VD));
  
  
  assign x_loc = h_count; //the location of will simply be the horiontal count
  assign y_loc = v_count; //same for vertical count
  
endmodule
//----------------------------
// Code your design here
// Code your design here
//`timescale 1ns / 1ps





module Keyboard(
	input CLK,	
   input PS2_CLK,	
   input PS2_DATA,


//	output reg [3:0]COUNT,
//	output reg TRIG_ARR,
//	output reg [7:0]CODEWORD,
   output reg up, reg down, reg left, reg right	//8 LEDs
   );

  wire [7:0] ARROW_UP = 8'h1D;	//codes for arrows
  wire [7:0] ARROW_DOWN = 8'h1B;
  wire [7:0] ARROW_LEFT = 8'h1C;
  wire [7:0] ARROW_RIGHT = 8'h23;
	//wire [7:0] EXTENDED = 8'hE0;	//codes 
	//wire [7:0] RELEASED = 8'hF0;

	reg read; 
	reg [11:0] count_reading;	
	reg PREVIOUS_STATE;			
	reg scan_err;				
	reg [10:0] scan_code;		
	reg [7:0] CODEWORD;			
	reg TRIG_ARR;				
	reg [3:0]COUNT;				
	reg TRIGGER = 0;			 
	reg [7:0]DOWNCOUNTER = 0;	

	
	initial begin
		PREVIOUS_STATE = 1;		
		scan_err = 0;		
		scan_code = 0;
		COUNT = 0;			
		CODEWORD = 0;
		read = 0;
		count_reading = 0;
	end

	always @(posedge CLK) begin	
		if (DOWNCOUNTER < 249) begin 
			DOWNCOUNTER <= DOWNCOUNTER + 1;
			TRIGGER <= 0;
		end
		else begin
			DOWNCOUNTER <= 0;
			TRIGGER <= 1;
		end
	end
	
	always @(posedge CLK) begin	
		if (TRIGGER) begin
			if (read)				
				count_reading <= count_reading + 1;
			else 						
				count_reading <= 0;		
		end
	end


	always @(posedge CLK) begin		
	if (TRIGGER) begin						
		if (PS2_CLK != PREVIOUS_STATE) begin
			if (!PS2_CLK) begin				
				read <= 1;				
				scan_err <= 0;			
				scan_code[10:0] <= {PS2_DATA, scan_code[10:1]};	
				COUNT <= COUNT + 1;			
			end
		end
		else if (COUNT == 11) begin				
			COUNT <= 0;
			read <= 0;				
			TRIG_ARR <= 1;			
			
			if (!scan_code[10] || scan_code[0] || !(scan_code[1]^scan_code[2]^scan_code[3]^scan_code[4]
				^scan_code[5]^scan_code[6]^scan_code[7]^scan_code[8]
				^scan_code[9]))
				scan_err <= 1;
			else 
				scan_err <= 0;
		end	
		else  begin						
			TRIG_ARR <= 0;				
			if (COUNT < 11 && count_reading >= 4000) begin	
				COUNT <= 0;				
				read <= 0;				
			end
		end
	PREVIOUS_STATE <= PS2_CLK;					
	end
	end


	always @(posedge CLK) begin
		if (TRIGGER) begin					
			if (TRIG_ARR) begin				
				if (scan_err) begin			
					CODEWORD <= 8'd0;		
				end
				else begin
					CODEWORD <= scan_code[8:1];	
				end				
			end					
			else CODEWORD <= 8'd0;	
		end
		else CODEWORD <= 8'd0;		
	end
	
	always @(posedge CLK) begin
        up = 0;
        down = 0;
        right = 0;
        left = 0;
		if (CODEWORD == ARROW_UP)
		begin				
			up = 1;
			down = 0;	
			left = 0;
			right =0;	
		end			
		else if (CODEWORD == ARROW_DOWN)
		begin				
			up = 0;
			down = 1;	
			left = 0;
			right = 0;	
		end			 
        else if (CODEWORD == ARROW_LEFT)	
		begin				
			up = 0;
			down = 0;	
			left = 1;
			right = 0;	
		end	
        else if (CODEWORD == ARROW_RIGHT)	
		begin				
			up = 0;
			down = 0;	
			left = 0;
			right = 1;	
		end	
	end

endmodule








module pixel_gen(
  input [9:0] pixel_x,
  input [9:0] pixel_y,
  input clk_d,
  input video_on,
  output reg [3:0] red = 0,
  output reg [3:0] blue = 0,
  output reg [3:0] green = 0,
  input circle_x,
  input circle_y,
  input clk_d2,
  input  up,
  input down,
  input left,
  input right
  
);
reg [23:0] cp = 0;
reg [23:0] cm= 0;
reg w1 = 1'b0;
reg [10:0] x1 = 10'd320;
reg [10:0] y1 = 10'd240;
reg [10:0] px1 = 10'd320;
reg [10:0] py1 = 10'd100;
reg [10:0] dx1 = 10'd320;
reg [10:0] dy1 = 10'd380;
//parameter x1= 320;
//parameter y1= 240 ;
parameter x2 = 320;
parameter y2 = 240;
//initial begin
parameter px2 = 320;
parameter py2 = 100;
parameter dx2 = 320;
parameter dy2 = 380;
//initial begin
//if (circle_x && circle_y)begin
//x =x1;
//y  = y1;
//end
//else begin
//x =x2;
//y =y2;
//end
//end
//always @(posedge clk_d2) begin

//if((~w1))begin
//// && ((x1-20 >160 && x1+20 <480) && (y1 >20 && y1 <460))

//x1=x1+1;
//end
//else if((w1)  )begin
//// && ((x1-20 >160 && x1+20 <480) && (y1 >20 && y1 <460))
//x1=x1-1;
//end
//else begin
//w1 <= ~w1;
//end



//end
  
  always @ (posedge clk_d) begin
  cm<= cm+1;
  cp<= cp+1;
  if (cp>=499999 && (((x1-10 >160 && x1+10 <480) && (y1-10 >20 && y1+10 <460)))) begin
  cp<=0;
  if (up) begin
  dy1 <= dy1 -1;
  end
  if (down) begin
  dy1 <= dy1 +1;
  end
  if (left) begin
  dx1 <= dx1 -1;
  end
  if (right) begin
  dx1 <= dx1 +1;
  end
  end
  if ( (~w1)&& (cm>=2499999) && ((x1-10 >160 && x1+10 <480) && (y1-10 >20 && y1+10 <460)) ) begin
  x1 <= x1+1;
  cm <=0;
  end
//  if ( (~w1)&& (cm>=2499999) && ((px1-10 >160 && px1+10 <480) && (py1>10 && py1 <470)) ) begin
//  px1 <= px1+1;
//  cm <=0;
//  end
//  if ( (~w1)&& (cm>=2499999) && ((dx1-15 >160 && dx1+15 <480) && (dy1>15 && dy1 <465)) ) begin
//  dx1 <= dx1+1;
//  cm <=0;
//  end
  else if ((w1)&& (cm>=2499999) && ((x1-10 >160 && x1+10 <480) && (y1 -10 >20 && y1+10 <460))) begin
  x1 <= x1-1;
  cm<=0;
  end
//  else if ((w1)&& (cm>=2499999) && ((px1-10 >160 && px1+10 <480) && (py1 >10 && py1 <470))) begin
//  px1 <= px1-1;
//  cm<=0;
//  end
//  else if ((w1)&& (cm>=2499999) && ((dx1-15 >160 && dx1+15 <480) && (dy1 >15 && dy1 <465))) begin
//  dx1 <= dx1-1;
//  cm<=0;
//  end
  else if (x1+11>=480 || x1-11<=160) begin
  w1 <= ~w1;
  end
//   else if (px1+11>=480 || px1-11<=160) begin
//  w1 <= ~w1;
//  end
//  else if (dx1+16>=480 || dx1-16<=160) begin
//  w1 <= ~w1;
//  end





    if (((pixel_x <=160) || (pixel_x >=480))|| ((pixel_y <=20)|| (pixel_y >=460))) begin
      
      red <= 4'h0;
      blue <= 4'h0;
      green <= 4'h0;
    end
else begin
     if ((pixel_x >160 && pixel_x <480) && (pixel_y >20 && pixel_y <460)) begin
      red <= 4'h0;
      blue <= 4'hF;
      green <= 4'h0;
    
     if ((pixel_x >290  && pixel_x <350) && ((pixel_y >20 && pixel_y <50)||(pixel_y >430 && pixel_y <460))) begin
      red <= 4'hF;
      blue <= 4'hF;
      green <= 4'hF;
      end
     if ((pixel_x >160 && pixel_x <480) && (pixel_y > 238 && pixel_y <241)) begin
     red <= 4'h0;
      blue <= 4'h0;
      green <= 4'h0;
      end
      if (circle_x && circle_y) begin
      if (((pixel_y-y1)*(pixel_y-y1)<=((10*10)-((pixel_x-x1)*(pixel_x-x1))))&&((pixel_x>x1-10 && pixel_x<x1+10)&&(pixel_y>y1-10 && pixel_y<y1+10)) ) begin
      //&&((pixel_x>300 && pixel_x<340)&&(pixel_y>220 && pixel_y<260))
            red<=4'hF;
            green<=4'h0;
            blue<=4'h0;
            
     end
     end  
else begin
      if (((pixel_y-y2)*(pixel_y-y2)<=((10*10)-((pixel_x-x2)*(pixel_x-x2))))&&((pixel_x>x2-10 && pixel_x<x2+10)&&(pixel_y>y2-10 && pixel_y<y2+10)) ) begin
      //
            red<=4'hF;
            green<=4'h0;
            blue<=4'h0;
            y1 <= y2;
            x1 <= x2;
     end  
end    

     if ((((pixel_y-50)*(pixel_y-50)<=((25*25)-((pixel_x-320)*(pixel_x-320))))&&((pixel_x>295 && pixel_x<345)&&(pixel_y>25 && pixel_y<75)))&&(((pixel_y-50)*(pixel_y-50)<=((20*20)-((pixel_x-320)*(pixel_x-320))))&&((pixel_x>300 && pixel_x<340)&&(pixel_y>30 && pixel_y<70)))) begin
            red<=4'hF;
            green<=4'hF;
            blue<=4'hF;
     end
     if (((pixel_y-430)*(pixel_y-430)<=((20*20)-((pixel_x-320)*(pixel_x-320))))&&((pixel_x>300 && pixel_x<340)&&(pixel_y>410 && pixel_y<450))) begin
            red<=4'hF;
            green<=4'hF;
            blue<=4'hF;
     end    
      end
      if (circle_x && circle_y) begin
      if (((pixel_y-py1)*(pixel_y-py1)<=((15*15)-((pixel_x-px1)*(pixel_x-px1))))&&((pixel_x>px1-15 && pixel_x<px1+15)&&(pixel_y>py1-15 && pixel_y<py1+15)) ) begin
      //&&((pixel_x>300 && pixel_x<340)&&(pixel_y>220 && pixel_y<260))
            red<=4'hF;
            green<=4'h0;
            blue<=4'h0;
            
     end
     end  
else begin
      if (((pixel_y-py2)*(pixel_y-py2)<=((15*15)-((pixel_x-px2)*(pixel_x-px2))))&&((pixel_x>px2-15 && pixel_x<px2+15)&&(pixel_y>py2-15 && pixel_y<py2+15)) ) begin
      //
            red<=4'hF;
            green<=4'h0;
            blue<=4'h0;
            py1 <= py2;
            px1 <= px2;
     end  
end    
      if (circle_x && circle_y) begin
      if (((pixel_y-dy1)*(pixel_y-dy1)<=((15*15)-((pixel_x-dx1)*(pixel_x-dx1))))&&((pixel_x>dx1-15 && pixel_x<dx1+15)&&(pixel_y>dy1-15 && pixel_y<dy1+15)) ) begin
      //&&((pixel_x>300 && pixel_x<340)&&(pixel_y>220 && pixel_y<260))
            red<=4'hF;
            green<=4'h0;
            blue<=4'h0;
            
     end
     end  
else begin
      if (((pixel_y-dy2)*(pixel_y-dy2)<=((15*15)-((pixel_x-dx2)*(pixel_x-dx2))))&&((pixel_x>dx2-15 && pixel_x<dx2+15)&&(pixel_y>dy2-15 && pixel_y<dy2+15)) ) begin
      //
            red<=4'hF;
            green<=4'h0;
            blue<=4'h0;
            dy1 <= dy2;
            dx1 <= dx2;
     end  
end 
     if ((((pixel_y-50)*(pixel_y-50)<=((25*25)-((pixel_x-320)*(pixel_x-320))))&&((pixel_x>295 && pixel_x<345)&&(pixel_y>25 && pixel_y<75)))&&(((pixel_y-50)*(pixel_y-50)<=((20*20)-((pixel_x-320)*(pixel_x-320))))&&((pixel_x>300 && pixel_x<340)&&(pixel_y>30 && pixel_y<70)))) begin
            red<=4'hF;
            green<=4'hF;
            blue<=4'hF;
     end
     if (((pixel_y-430)*(pixel_y-430)<=((20*20)-((pixel_x-320)*(pixel_x-320))))&&((pixel_x>300 && pixel_x<340)&&(pixel_y>410 && pixel_y<450))) begin
            red<=4'hF;
            green<=4'hF;
            blue<=4'hF;
     end    
      end
      end
    
    
  
endmodule

  
//--------------------------------------
module top_module1(clk_i, h_sync, v_sync, red_o, green_o, blue_o, x_in,y_in,ps2clk,ps2data);
    input clk_i;
    input x_in;
    input y_in;
	wire clk_d_o;
  	wire [9:0] h_count;
  	wire [9:0] v_count;
  	wire trig_o;
  	wire clk_do2;
  
   	output h_sync;
  	output v_sync;
    
  	wire video_on;
    wire [9:0] x_loc;
    wire [9:0] y_loc;
  
    output [3:0] red_o;
    output [3:0] green_o;
    output [3:0] blue_o;
    
    wire u;
    wire d;
    wire l;
    wire r;
    
    input ps2clk;
    input ps2data;
    

   	clk_div g1(.clk(clk_i), .clk_d(clk_d_o));
   	clk_div2 c12(clk,clk_do2);
  	counter_10_bit h_1(.clk(clk_d_o), .count(h_count), .trig(trig_o));
  	counter_10_bit1 v_1(.clk(clk_d_o), .enable(trig_o), .count(v_count));
  
 	vga_sync vga_sync1(.h_count(h_count), .v_count(v_count), .h_sync(h_sync), .v_sync(v_sync), .video_on(video_on), .x_loc(x_loc), .y_loc(y_loc));
  Keyboard k1(clk_d_o,ps2clk,ps2data,u,d,l,r);
  pixel_gen pixel_gen1(.clk_d(clk_d_o), .pixel_x(x_loc), .pixel_y(y_loc), .video_on(video_on), .red(red_o), .green(green_o), .blue(blue_o),.circle_x(x_in),.circle_y(y_in),.clk_d2(clk_do2),.up(u),.left(l),.right(r),.down(d));
  
  
endmodule
  
