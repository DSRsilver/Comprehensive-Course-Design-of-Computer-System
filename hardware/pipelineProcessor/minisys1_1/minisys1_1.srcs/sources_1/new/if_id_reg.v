`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/09 15:28:50
// Design Name: 
// Module Name: if_id_reg
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


module if_id_reg(clock,reset,if_id_enable,pc_plus_4_in,instruction_in,pc_plus_4_out,instruction_out);
input clock;
input reset;
input if_id_enable;
input[31:0] pc_plus_4_in;
input[31:0] instruction_in;

output[31:0] pc_plus_4_out;
output[31:0] instruction_out;

reg[31:0] pc_plus_4_out;
reg[31:0] instruction_out;

always @(posedge reset or posedge clock) begin
        if(reset == 1'b1) begin
            pc_plus_4_out <= 32'b0;
            instruction_out<=32'b0;
        end else begin
            if(if_id_enable == 1'b1) begin
                pc_plus_4_out <= pc_plus_4_in;
                instruction_out<=instruction_in;
            end
        end
 end

endmodule
