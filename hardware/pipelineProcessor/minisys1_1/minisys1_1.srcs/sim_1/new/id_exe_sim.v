`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/30 17:21:30
// Design Name: 
// Module Name: id_exe_sim
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


module id_exe_sim();
//input
reg clock=1'b1;
reg reset=1'b1;
reg id_exe_enable=1'b1;
//用于执行-in
reg[31:0] pc_in;
reg       ALUSrc_in;            // 决定第二个操作数是寄存器还是立即数
reg       Sftmd_in;
reg[1:0]  ALUOp_in;
reg       I_format_in;
reg       Branch_in;
reg       nBranch_in;    
reg[31:0] read_data_1_in;
reg[31:0] read_data_2_in;
reg[31:0] sign_extend_in;
reg       bgez_in;
reg       bgtz_in;
reg       blez_in;
reg       bltz_in;
reg       bgezal_in;
reg       bltzal_in;
reg       lb_in;
reg       lbu_in;
reg       lh_in;
reg       lhu_in;
reg       lw_in;
reg       sb_in;
reg       sh_in;
reg       sw_in;
//用于存储-in    
reg       IOWrite_in;    
reg       MemWrite_in;
//存储+写回-in
reg       MemorIOtoReg_in;    
reg       IORead_in;      
reg       MemRead_in;
//用于写回-in
reg       RegDST_in;     
reg       RegWrite_in;
reg[31:0] write_register_address_in;
reg       r_hi_in;  
reg       r_lo_in;  
reg       w_hi_in;  
reg       w_lo_in;
reg       Jal_in;
reg       Jalr_in;

//output
wire[31:0] pc_out;
wire       ALUSrc_out;            // 决定第二个操作数是寄存器还是立即数
wire       Sftmd_out;
wire[1:0]  ALUOp_out;
wire       Branch_out;
wire       nBranch_out;
wire       I_format_out;
wire[31:0] read_data_1_out;
wire[31:0] read_data_2_out;
wire[31:0] sign_extend_out;
wire       bgez_out;
wire       bgtz_out;
wire       blez_out;
wire       bltz_out;
wire       bgezal_out;
wire       bltzal_out;
wire       lb_out;
wire       lbu_out;
wire       lh_out;
wire       lhu_out;
wire       lw_out;
wire       sb_out;
wire       sh_out;
wire       sw_out;

//存储
wire       IOWrite_out;         //有IO
wire       MemWrite_out;
//存储+写回
wire       IORead_out;          //有IO
wire       MemRead_out;
wire       MemorIOtoReg_out;    //有IO

//写回
wire[31:0] write_register_address_out;
wire       r_hi_out;
wire       r_lo_out;
wire       w_hi_out;
wire       w_lo_out;
wire       RegDST_out;
wire       RegWrite_out;
wire       Jal_out;
wire       Jalr_out; 

id_exe_reg Uidexe(clock,reset,id_exe_enable, pc_in, read_data_1_in,read_data_2_in,sign_extend_in,
            write_register_address_in,r_hi_in, r_lo_in, w_hi_in, w_lo_in, RegDST_in,
            ALUSrc_in,MemorIOtoReg_in, IORead_in,IOWrite_in,RegWrite_in,MemWrite_in,MemRead_in, Branch_in,
            nBranch_in,I_format_in,Sftmd_in,ALUOp_in,Jal_in,Jalr_in,bgez_in,bgtz_in,blez_in,bltz_in,bgezal_in,bltzal_in,
            lb_in,lbu_in,lh_in,lhu_in,lw_in,sb_in,sh_in,sw_in,
            pc_out, read_data_1_out,read_data_2_out,sign_extend_out,
            write_register_address_out,r_hi_out, r_lo_out, w_hi_out, w_lo_out, RegDST_out,
            ALUSrc_out,MemorIOtoReg_out, IORead_out,IOWrite_out,RegWrite_out,MemWrite_out,MemRead_out, Branch_out,
            nBranch_out, I_format_out,Sftmd_out,ALUOp_out,Jal_out,Jalr_out,bgez_out,bgtz_out,blez_out,bltz_out,bgezal_out,bltzal_out,
            lb_out,lbu_out,lh_out,lhu_out,lw_out,sb_out,sh_out,sw_out
);

 initial begin
       
       #200 begin reset=1'b0;
                   pc_in=32'h12345678;
                   ALUSrc_in=1;            // 决定第二个操作数是寄存器还是立即数
                   Sftmd_in=1;
                   ALUOp_in=2'b10;
                   I_format_in=1;
                   Branch_in=1;
                   nBranch_in=1;    
                   read_data_1_in=32'h12344321;
                   read_data_2_in=32'h34566543;
                   sign_extend_in=32'h24681357;
                   bgez_in=1;
                   bgtz_in=1;
                   blez_in=1;
                   bltz_in=1;
                   bgezal_in=1;
                   bltzal_in=1;
                   lb_in=1;
                   lbu_in=1;
                   lh_in=1;
                   lhu_in=1;
                   lw_in=1;
                   sb_in=1;
                   sh_in=1;
                   sw_in=1;
                   IOWrite_in=1;    
                   MemWrite_in=1;
                   MemorIOtoReg_in=1;    
                   IORead_in=1;      
                   MemRead_in=1;
                   RegDST_in=1;     
                   RegWrite_in=1;
                   write_register_address_in=32'h13578642;
                   r_hi_in=1;  
                   r_lo_in=1;  
                   w_hi_in=1;  
                   w_lo_in=1;
                   Jal_in=1;
                   Jalr_in=1;
       end
       #200 begin 
                   pc_in=32'h87654321;
                   ALUSrc_in=0;            // 决定第二个操作数是寄存器还是立即数
                   Sftmd_in=0;
                   ALUOp_in=2'b01;
                   I_format_in=0;
                   Branch_in=0;
                   nBranch_in=0;    
                   read_data_1_in=32'h85478478;
                   read_data_2_in=32'h99999999;
                   sign_extend_in=32'h77777777;
                   bgez_in=0;
                   bgtz_in=0;
                   blez_in=0;
                   bltz_in=0;
                   bgezal_in=0;
                   bltzal_in=0;
                   lb_in=0;
                   lbu_in=0;
                   lh_in=0;
                   lhu_in=0;
                   lw_in=0;
                   sb_in=0;
                   sh_in=0;
                   sw_in=0;
                   IOWrite_in=0;    
                   MemWrite_in=0;
                   MemorIOtoReg_in=0;    
                   IORead_in=0;      
                   MemRead_in=0;
                   RegDST_in=0;     
                   RegWrite_in=0;
                   write_register_address_in=32'h17777772;
                   r_hi_in=0;  
                   r_lo_in=0;  
                   w_hi_in=0;  
                   w_lo_in=0;
                   Jal_in=0;
                   Jalr_in=0;
       end
//       #200 begin
//                id_exe_enable=1'b1;
//       end
  end
   
   always #50 clock = ~clock; 
endmodule
