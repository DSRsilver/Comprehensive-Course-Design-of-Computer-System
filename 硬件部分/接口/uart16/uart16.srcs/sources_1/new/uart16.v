`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/25 10:35:43
// Design Name: 
// Module Name: uart16
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


module uart16(reset, clk, cs, iow, ior, xtal, address, iowrite_data,
              ioread_data, txd, rxd);

input reset, clk, cs, iow, ior;
input xtal;
input rxd;
output txd;
input[1:0] address;
input[7:0] iowrite_data;
output[15:0] ioread_data;

reg[15:0] ioread_data;
reg txd, txd1, txd2;
reg[4:0] cnt, rcnt, scnt;
reg[4:0] rcnt2, rcnt3;
reg[4:0] scnt1, scnt2, scnt3;
reg[15:0] status, stat1, stat2, stat3;
reg[7:0] receivebuff, sentbuff, buff;
reg[7:0] sentbuff1, sentbuff2;
reg[7:0] receivebuff1, receivebuff2;
reg baundclk;
reg statflag1, statflag2;

always@(negedge clk)
begin
  if(reset == 0)
   begin
    if(scnt3 == 5'd2)
      scnt1=5'd0;
    if(cs == 1)
     begin
      if(iow == 1)
       begin
        if(address == 2'b00)
         begin
          sentbuff1=iowrite_data;
          stat1=stat3 & 16'b1111111111111110;
          scnt1=5'd1;
         end
       end
      else if(ior == 1)
            begin
             if(address == 2'b00)
              begin
               ioread_data=receivebuff;
               stat1=stat3 & 16'b1111111111111101;
              end
             else if(address == 2'b10)
                   begin
                    stat1=stat3;
                    ioread_data=stat3;
                   end
            end
           else stat1=status;
     end
   end
end

always@(posedge xtal)
begin
 if(reset == 1)
  begin
   cnt=5'd0;
   scnt2=5'd0;
   rcnt2=5'd0;
   buff=8'b00000000;
   baundclk=0;
   stat2=16'b0000000000000000;
   txd1=1;
  end
 else
  begin
   cnt=cnt+1'b1;
   if(cnt == 5'd8)
    begin
    cnt=5'd0;
    baundclk=!baundclk;
    end
  end
end

always@(posedge baundclk)
begin
 case(scnt)
  5'd0: begin txd2=1;sentbuff2=sentbuff;stat3=status;
            scnt3<=5'd0;statflag1=0; end
  5'd1: if(!(cs == 1)&&(iow == 1))
         begin
          txd2=0;sentbuff2=sentbuff;scnt3<=5'd2;
          stat3=status & 16'b1111111111111110;
         end
        else txd2=txd1;
  5'd2:begin txd2=sentbuff[0];sentbuff2[7:0]={1'b0,sentbuff[7:1]};
             scnt3<=5'd3; end
  5'd3:begin txd2=sentbuff[0];sentbuff2[7:0]={1'b0,sentbuff[7:1]};
             scnt3<=5'd4; end
  5'd4:begin txd2=sentbuff[0];sentbuff2[7:0]={1'b0,sentbuff[7:1]};
             scnt3<=5'd5; end
  5'd5:begin txd2=sentbuff[0];sentbuff2[7:0]={1'b0,sentbuff[7:1]};
             scnt3<=5'd6; end
  5'd6:begin txd2=sentbuff[0];sentbuff2[7:0]={1'b0,sentbuff[7:1]};
             scnt3<=5'd7; end
  5'd7:begin txd2=sentbuff[0];sentbuff2[7:0]={1'b0,sentbuff[7:1]};
             scnt3<=5'd8; end
  5'd8:begin txd2=sentbuff[0];sentbuff2[7:0]={1'b0,sentbuff[7:1]};
             scnt3<=5'd9; end
  5'd9:begin txd2=1;stat3=status|16'b0000000000000001;
             scnt3<=5'd0;statflag1=1; end
  5'd10:begin txd2=sentbuff[0];sentbuff2[7:0]={1'b0,sentbuff[7:1]};
             scnt3<=5'd3; end
  default:begin  end 
 endcase
 case(rcnt)
  5'd0: if(rxd == 0) rcnt3<=5'd1;else begin rcnt3<=5'd0;statflag2=0; end
  5'd1:begin receivebuff[7:0]={rxd,receivebuff[7:1]};rcnt3<=5'd2; end
  5'd2:begin receivebuff[7:0]={rxd,receivebuff[7:1]};rcnt3<=5'd3; end
  5'd3:begin receivebuff[7:0]={rxd,receivebuff[7:1]};rcnt3<=5'd4; end
  5'd4:begin receivebuff[7:0]={rxd,receivebuff[7:1]};rcnt3<=5'd5; end
  5'd5:begin receivebuff[7:0]={rxd,receivebuff[7:1]};rcnt3<=5'd6; end
  5'd6:begin receivebuff[7:0]={rxd,receivebuff[7:1]};rcnt3<=5'd7; end
  5'd7:begin receivebuff[7:0]={rxd,receivebuff[7:1]};rcnt3<=5'd8; end
  5'd8:begin receivebuff[7:0]={rxd,receivebuff[7:1]};rcnt3<=5'd9; end
  5'd9:if(rxd == 1) begin stat3=status|16'b0000000000000010;
                                rcnt3<=5'd0;statflag2=1; end
             else begin receivebuff=8'h0000;rcnt3<=5'd0; end
  default rcnt3<=5'd0; 
 endcase
end

always@(stat1,stat2,statflag1,statflag2)
begin
 if(reset == 1)
  status=stat2;
 else
  if(cs == 1)
    status=stat1;
  else if((statflag1 == 1)||(statflag2))
        status=stat3;   
end

always@(scnt1,scnt2,scnt3)
begin
 if(reset == 1)
  scnt=scnt2;
 else
  if(scnt1 == 1)
   scnt=scnt1;
  else
   scnt=scnt3;
end

always@(rcnt2,rcnt3)
begin
 if(reset == 1)
  rcnt=rcnt2;
 else
  rcnt=rcnt3;
end

always@(sentbuff1,sentbuff2)
begin
 if(reset == 1)
  sentbuff=buff;
 else
  if(scnt == 5'd1)
   sentbuff=sentbuff1;
  else
   sentbuff=sentbuff2;
end

always@(txd1,txd2)
begin
 if((reset == 1)||(scnt3 == 5'd0))
  txd=txd1;
 else
  txd=txd2;
end

endmodule
