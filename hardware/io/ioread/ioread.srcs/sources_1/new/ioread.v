`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/8 15:43:26
// Design Name: 
// Module Name: ioread
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


module ioread(reset,clk,ior,keyctrl,ctcctrl,uartctrl,ioread_data,
               ioread_data_key,ioread_data_ctc,ioread_data_uart);
input reset,clk;
input ior,keyctrl,ctcctrl,uartctrl;
input[15:0] ioread_data_key;
input[15:0] ioread_data_ctc;
input[15:0] ioread_data_uart;
output[15:0] ioread_data;

reg[15:0] ioread_data;
always
begin
  if(reset == 1)
    ioread_data = 16'b0000000000000000;
  else
  if(ior == 1)
  begin
    if(keyctrl == 1)
      ioread_data = ioread_data_key;
    else if(ctcctrl == 1)
      ioread_data = ioread_data_ctc;
    else if(uartctrl == 1)
      ioread_data = ioread_data_uart;
   end
end

endmodule
