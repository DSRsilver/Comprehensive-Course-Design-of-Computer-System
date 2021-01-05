`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/24 10:51:36
// Design Name: 
// Module Name: ctc16
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


module ctc16(reset,clk,cs,iow,ior,pulse0,pulse1,address,iowrite_data,
ioread_data,cout0,cout1);

input reset;
input clk;
input cs;
input iow;
input ior;
input pulse0;
input pulse1;
input[3:0] address;
input[15:0] iowrite_data;
output[15:0] ioread_data;
output cout0;
output cout1;

reg cout0,cout1;
reg[15:0] ioread_data;
reg[15:0] status1,status2;
reg[15:0] stat11,stat12;
reg[15:0] stat21,stat22;
reg[15:0] mode1,mode2;
reg[15:0] count1,count2;
reg[15:0] cnt11,cnt12;
reg[15:0] cnt21,cnt22;
reg[15:0] initcnt1,initcnt2;
reg[15:0] rubbish;

always@(negedge clk)
begin
  if(reset == 1)
   begin
   cout0=1;
   cout1=1;
   initcnt1=16'b0000000000000000;
   initcnt2=16'b0000000000000000;
   cnt11=16'b0000000000000000;
   cnt21=16'b0000000000000000;
   stat11=16'b0000000000000000;
   stat21=16'b0000000000000000;
   end
  else
  begin
  if(cs == 1)
   begin
    if(iow == 1)
     begin
       case(address)
       4'b0000:begin mode1=iowrite_data;stat11=status1 & 16'h7FFC; end
       4'b0010:begin mode2=iowrite_data;stat21=status2 & 16'h7FFC; end
       4'b0100:begin initcnt1=iowrite_data;cnt11=iowrite_data;
                     stat11=status1 | 16'b1000000000000000; end
       4'b0110:begin initcnt2=iowrite_data;cnt21=iowrite_data;
                     stat21=status2 | 16'b1000000000000000; end
       default:rubbish=iowrite_data;
       endcase              
     end
     else if(ior ==1)
          begin
           case(address)
            4'b0000:begin ioread_data=status1;stat11=status1 & 16'hFFFC; end
            4'b0010:begin ioread_data=status2;stat21=status2 & 16'hFFFC; end
            4'b0100:begin ioread_data=count1; end
            4'b0110:begin ioread_data=count2; end
            default:ioread_data=16'bzzzzzzzzzzzzzzzz;
           endcase
          end
   end
   begin
   if(status1[15] == 1'b0)
     cout0=1;
   if((status1[15] == 1) && (mode1[0] == 0))
    begin
     if(count1 == 1)
      begin
       cout0=0;
       stat11=status1|16'b0000000000000001;
       if(mode1[1] == 1)
         cnt11=initcnt1;
       else
        begin
        stat11=stat11 & 16'b0111111111111111;
        cnt11=0;
        end
      end
   else
      begin
        cout0=1;
        cnt11=count1-1'b1;
        stat11=status1|16'b1000000000000000;
      end
    end
    if(status2[15] == 1'b0)
      cout1=1;
    if((status2[15] == 1)&&(mode2[0] == 0))
      begin
       if(count2 == 1)
         begin
          cout1=0;
          stat21 = status2|16'b0000000000000001;
            if(mode2[1] == 1)
              cnt21=initcnt2;
            else
             begin
              stat21=stat21&16'b0111111111111111;
              cnt21=0;
             end
         end
       else 
        begin
         cout1=1;
         cnt21=count2-1'b1;
         stat21=status2|16'b1000000000000000;
        end
      end
   end
  end
end

always@(negedge pulse0)
begin
if((status1[15] == 1)&&(mode1[0] == 1))
 begin
   if(count1 == 0)
    begin
      stat12=status1|16'b0000000000000001;
       if(mode1[1] == 1)
        cnt12=initcnt1;
       else
        begin
         stat12=stat12 & 16'b0111111111111111;
         cnt12=0;
        end
    end
   else
    begin
     cnt12=count1-1'b1;
     stat12=status1|16'b1000000000000000;
    end
 end
end

always@(negedge pulse1)
begin
if((status2[15] == 1)&&(mode2[0] == 1))
 begin
   if(count2 == 0)
    begin
      stat22=status2|16'b0000000000000001;
       if(mode2[1] == 1)
        cnt22=initcnt2;
       else
        begin
         stat22=stat22 & 16'b0111111111111111;
         cnt22=0;
        end
    end
   else
    begin
     cnt22=count2-1'b1;
     stat22=status2|16'b1000000000000000;
    end
 end
end

always@(stat11,stat12)
begin
if(reset == 0)
 begin
  if((cs == 1)&&(((iow == 1)&&((address == 4'b0100)||(address == 4'b0000)))
     ||((ior == 1)&&(address == 4'b0000))))//?
   status1=stat12;
  else
   if(mode1[0] == 1)
     status1 = stat12;
   else
     status1 = stat11;
 end
end

always@(stat21,stat22)
begin
if(reset == 0)
 begin
  if((cs == 1)&&(((iow == 1)&&((address == 4'b0100)||(address == 4'b0000)))
     ||((ior == 1)&&(address == 4'b0000))))//?
   status2=stat22;
  else
   if(mode2[0] == 1)
     status2 = stat22;
   else
     status2 = stat21;
 end
end

always@(cnt11,cnt12)
begin
 if(reset == 0)
  begin
   if((cs == 1)&&(iow == 1)&&(address == 4'b0100))//?
     count1=cnt11;
   else
     if(mode1[0] == 1)
      count1=cnt12;
     else
      count1=cnt11;
  end
end

always@(cnt21,cnt22)
begin
 if(reset == 0)
  begin
   if((cs == 1)&&(iow == 1)&&(address == 4'b0100))//?
     count2=cnt21;
   else
     if(mode2[0] == 1)
      count2=cnt22;
     else
      count2=cnt21;
  end
end

endmodule
