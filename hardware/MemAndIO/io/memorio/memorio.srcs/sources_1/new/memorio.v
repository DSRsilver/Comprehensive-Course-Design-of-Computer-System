`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/8 14:53:08
// Design Name: 
// Module Name: memorio
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


module memorio(
caddress,address,memread,memwrite,ioread,iowrite,
mread_data,ioread_data,wdata,rdata,write_data,
LEDCtrl,KEYCtrl,CTCCtrl,PWMCtrl,UARTCtrl,WDTCtrl
    );
input[15:0] caddress;
input memread;
input memwrite;
input ioread;
input iowrite;
input[31:0] mread_data;
input[15:0] ioread_data;
input[31:0] wdata;
output[31:0] rdata;
output[31:0] write_data;
output[11:0] address;
output LEDCtrl;
output KEYCtrl;
output CTCCtrl;
output PWMCtrl;
output UARTCtrl;
output WDTCtrl;

reg[31:0] write_data;
wire iorw;

assign address = caddress[11:0];
assign rdata = ( memread == 1 ) ? mread_data : { 16'h0000, ioread_data[15:0] };
assign iorw = ( iowrite || ioread );

assign LEDCtrl = (( iorw == 1 ) && (caddress[15:4] == 12'hff0)) ? 1'b1:1'b0;
assign KEYCtrl = (( iorw == 1 ) && (caddress[15:4] == 12'hff1)) ? 1'b1:1'b0;
assign CTCCtrl = (( iorw == 1 ) && (caddress[15:4] == 12'hff2)) ? 1'b1:1'b0;
assign PWMCtrl = (( iorw == 1 ) && (caddress[15:4] == 12'hff3)) ? 1'b1:1'b0;
assign UARTCtrl = (( iorw == 1 ) && (caddress[15:4] == 12'hff4)) ? 1'b1:1'b0;
assign WDTCtrl = (( iorw == 1 ) && (caddress[15:4] == 12'hff5)) ? 1'b1:1'b0;

always
begin 
  if((memwrite == 1) || (iowrite == 1))
  begin
    write_data = wdata;
  end
  else
    begin
      write_data = 32'hzzzzzzzz;
    end
 end

endmodule
