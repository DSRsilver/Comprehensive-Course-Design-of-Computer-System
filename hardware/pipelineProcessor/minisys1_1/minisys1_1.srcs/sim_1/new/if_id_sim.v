`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/25 16:27:07
// Design Name: 
// Module Name: if_id_sim
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


module if_id_sim();
//input
reg clock=1'b1;
reg reset=1'b1;
reg if_id_enable=1;
reg[31:0] pc_plus_4_in;
reg[31:0] instruction_in;

//output
wire[31:0] pc_plus_4_out;
wire[31:0] instruction_out;

if_id_reg Uifid(clock,reset,if_id_enable,pc_plus_4_in,instruction_in,pc_plus_4_out,instruction_out);

 initial begin
       
       #200 begin reset=1'b0;
                   pc_plus_4_in=32'h12345678;
                   instruction_in=32'h11223344;
       end
       #200 begin 
                   pc_plus_4_in=32'h87654321;
                   instruction_in=32'h23452345;
       end
  end
   
   always #50 clock = ~clock;   
   
endmodule
