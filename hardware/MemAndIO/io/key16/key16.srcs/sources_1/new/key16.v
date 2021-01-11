`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/22 16:57:56
// Design Name: 
// Module Name: key16
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


module key16(reset, cs, clk, ior, address, col, line, ioread_data);

input reset;
input cs;
input clk;
input ior;
input[1:0] address;
input[3:0] col;
output[3:0] line;
output[15:0] ioread_data;

reg[15:0] ioread_data;
reg[3:0] line;
reg[15:0] keyvalue;
reg[15:0] keystat;

always @(negedge clk)
begin
 if(reset == 1)
 begin
  ioread_data=16'b0000000000000000;
  keyvalue=16'b00000000000000000;
  keystat=16'b0000000000000000;
  line=4'b0000;
 end
 else
 begin
 case(line)
  4'b0000: if(col!=4'b1111) line<=4'b1110;
  4'b1110: if(col!=4'b1111) 
           begin
            keyvalue[3:0]=col;
            keyvalue[7:4]=line;
            keystat=keystat|16'b0000000000000001;
           end
           else
            line<=4'b0000;
  4'b1101:if(col!=4'b1111)
          begin
          keyvalue[3:0]=col;
          keyvalue[7:4]=line;
          keystat=keystat|16'b0000000000000001;
          line<=4'b0000;
          end
          else
           line<=4'b1011;
  4'b1011:if(col!=4'b1111)
          begin
          keyvalue[3:0]=col;
          keyvalue[7:4]=line;
          keystat=keystat|16'b0000000000000001;
          line<=4'b0000;
          end
          else
           line<=4'b0111;
  4'b0111:if(col!=4'b1111)
          begin
          keyvalue[3:0]=col;
          keyvalue[7:4]=line;
          keystat=keystat|16'b0000000000000001;
          line<=4'b0000;
          end
          else
          begin line<=4'b0000;keystat = keystat & 16'b1111111111111110; end
 endcase
 if((cs == 1)&&(ior == 1))
   if(address == 2'b00)
     ioread_data=keyvalue;
   else if(address == 2'b10)
     begin ioread_data=keystat;keystat=keystat & 16'b1111111111111110; end
 end
end
endmodule
