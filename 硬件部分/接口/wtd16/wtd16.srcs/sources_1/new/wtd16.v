`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/26 09:37:00
// Design Name: 
// Module Name: wtd16
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


module wtd16(reset,clk,cs,iow,data,rst);

input reset;
input clk;
input cs;
input iow;
input[15:0] data;
output rst;

reg rst;
reg[15:0] count;
reg[2:0] cnt;

always@(negedge clk)
begin
 if(reset == 1)
  begin
   count=16'hffff;
   cnt=3'b000;
   rst=0;
  end
 else
  begin
   if(count == 16'd0)
    begin
     cnt=3'b100;
     count=16'hffff;
     rst=1;
    end
   else
    count=count-1'b1;
    if(cnt == 3'b000)
     rst=0;
    else
     cnt=cnt-1'b1;
     if((cs == 1)&&(iow == 1))
      begin
       count=16'hffff;
       cnt=3'b000;
       rst=0;
      end
  end
end

endmodule
