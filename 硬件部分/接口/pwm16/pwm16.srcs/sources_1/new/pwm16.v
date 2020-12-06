`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/25 10:00:38
// Design Name: 
// Module Name: pwm16
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


module pwm16(reset,address,data,cs,clk,iow,pwm);

input reset;
input[2:0] address;
input[15:0] data;
input cs;
input clk;
input iow;
output pwm;

reg pwm;
reg[15:0] maxcount;
reg[15:0] midcount;
reg[15:0] flag;
reg[15:0] rubbish;
reg[15:0] counter;

always@(negedge clk)
begin
  if(reset == 1)
   begin
    maxcount=16'b1111111111111111;
    midcount=16'b0111111111111111;
    flag=16'b0000000000000000;
    pwm=1;
    counter=16'b0000000000000000;
   end
  else if(cs ==1 && iow == 1)
         begin
          case(address[2:0])
           3'b000:maxcount=data;
           3'b010:midcount=data;
           3'b100:flag[0]=data[0];
           default:rubbish=data;
          endcase
         end
        else
          if(flag[0])
           begin
            if(counter == maxcount)
              begin
               counter=16'b0000000000000000;
               pwm=1;
              end
            else
             begin
              counter=counter+1'b1;
              if(counter>midcount)
                pwm=0;
              else
                pwm=1;
             end
           end
          else
           pwm=1;
end

endmodule
