`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/15 16:19:12
// Design Name: 
// Module Name: led16
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module led16(reset, data,cs,iow,led0,led1,led2,led3);

input reset;
input[15:0] data;
input cs;
input iow;
output[6:0] led0;
output[6:0] led1;
output[6:0] led2;
output[6:0] led3;

reg[6:0] led0,led1,led2,led3;
reg[15:0] rdata;

always@(posedge cs,posedge reset)
begin
  if(reset == 1)
    rdata = 16'h0000;
  else if(cs == 1 && iow == 1)
    rdata = data;
end

always@(rdata)
begin
 case(rdata[3:0])
    4'b0000: led0=7'b1000000;//0
    4'b0000: led0=7'b1111001;//1
    4'b0000: led0=7'b0100100;//2
    4'b0000: led0=7'b0110000;//3
    
    4'b0000: led0=7'b0011001;//4
    4'b0000: led0=7'b0010010;//5
    4'b0000: led0=7'b0000010;//6
    4'b0000: led0=7'b1111000;//7
    
    4'b0000: led0=7'b0000000;//8
    4'b0000: led0=7'b0010000;//9
    4'b0000: led0=7'b0001000;//a
    4'b0000: led0=7'b0000011;//b
    
    4'b0000: led0=7'b1000110;//c
    4'b0000: led0=7'b0100001;//d
    4'b0000: led0=7'b0000110;//e
    4'b0000: led0=7'b0001110;//f
    default: led0=7'b1111111;
 endcase
 case(rdata[7:4])
    4'b0000: led1=7'b1000000;//0
    4'b0000: led1=7'b1111001;//1
    4'b0000: led1=7'b0100100;//2
    4'b0000: led1=7'b0110000;//3
    
    4'b0000: led1=7'b0011001;//4
    4'b0000: led1=7'b0010010;//5
    4'b0000: led1=7'b0000010;//6
    4'b0000: led1=7'b1111000;//7
    
    4'b0000: led1=7'b0000000;//8
    4'b0000: led1=7'b0010000;//9
    4'b0000: led1=7'b0001000;//a
    4'b0000: led1=7'b0000011;//b
    
    4'b0000: led1=7'b1000110;//c
    4'b0000: led1=7'b0100001;//d
    4'b0000: led1=7'b0000110;//e
    4'b0000: led1=7'b0001110;//f
    default: led1=7'b1111111;
 endcase
 case(rdata[11:8])
    4'b0000: led2=7'b1000000;//0
    4'b0000: led2=7'b1111001;//1
    4'b0000: led2=7'b0100100;//2
    4'b0000: led2=7'b0110000;//3
   
    4'b0000: led2=7'b0011001;//4
    4'b0000: led2=7'b0010010;//5
    4'b0000: led2=7'b0000010;//6
    4'b0000: led2=7'b1111000;//7
    
    4'b0000: led2=7'b0000000;//8
    4'b0000: led2=7'b0010000;//9
    4'b0000: led2=7'b0001000;//a
    4'b0000: led2=7'b0000011;//b
    
    4'b0000: led2=7'b1000110;//c
    4'b0000: led2=7'b0100001;//d
    4'b0000: led2=7'b0000110;//e
    4'b0000: led2=7'b0001110;//f
    default: led2=7'b1111111;
 endcase
 case(rdata[15:12])
    4'b0000: led3=7'b1000000;//0
    4'b0000: led3=7'b1111001;//1
    4'b0000: led3=7'b0100100;//2
    4'b0000: led3=7'b0110000;//3
   
    4'b0000: led3=7'b0011001;//4
    4'b0000: led3=7'b0010010;//5
    4'b0000: led3=7'b0000010;//6
    4'b0000: led3=7'b1111000;//7
    
    4'b0000: led3=7'b0000000;//8
    4'b0000: led3=7'b0010000;//9
    4'b0000: led3=7'b0001000;//a
    4'b0000: led3=7'b0000011;//b
    
    4'b0000: led3=7'b1000110;//c
    4'b0000: led3=7'b0100001;//d
    4'b0000: led3=7'b0000110;//e
    4'b0000: led3=7'b0001110;//f
    default: led3=7'b1111111;
 endcase
end

endmodule
