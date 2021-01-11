`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/07 12:05:39
// Design Name: 
// Module Name: DMem
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


module DMem(clock,
            write_data_in,
            ALU_Result_in,
            MemWrite_in,MemRead_in,MemEnable0_in,
            MemEnable1_in,MemEnable2_in,MemEnable3_in,
            Data_Out);
            
input clock;
input[31:0] ALU_Result_in;
input MemWrite_in;
input MemRead_in;
input[31:0] write_data_in;
input MemEnable0_in;
input MemEnable1_in;
input MemEnable2_in;
input MemEnable3_in;

output[31:0] Data_Out;

       
wire clk,MemWrite0,MemWrite1,MemWrite2,MemWrite3;
assign clk=!clock;
assign MemWrite0 = MemEnable0_in && MemWrite_in && clk;
assign MemWrite1 = MemEnable1_in && MemWrite_in && clk;
assign MemWrite2 = MemEnable2_in && MemWrite_in && clk;
assign MemWrite3 = MemEnable3_in && MemWrite_in && clk;

reg[7:0] data_out0,data_out1,data_out2,data_out3;
        
ram0 ram0(.a(ALU_Result_in[15:2]),.d(write_data_in[7:0]),.we(MemWrite0),
         .spo(data_out0),.clk(clk));
ram1 ram1(.a(ALU_Result_in[15:2]),.d(write_data_in[15:8]),.we(MemWrite0),
         .spo(data_out1),.clk(clk));
ram2 ram2(.a(ALU_Result_in[15:2]),.d(write_data_in[23:9]),.we(MemWrite0),
         .spo(data_out2),.clk(clk));
ram3 ram3(.a(ALU_Result_in[15:2]),.d(write_data_in[31:24]),.we(MemWrite0),
         .spo(data_out3),.clk(clk));
          
assign Data_Out[7:0] = data_out0;
assign Data_Out[15:8] = data_out1;
assign Data_Out[23:16] = data_out2;
assign Data_Out[31:24] = data_out3;
          
endmodule
