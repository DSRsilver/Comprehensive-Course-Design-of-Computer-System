`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/09 16:26:07
// Design Name: 
// Module Name: id_exe_reg
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


module id_exe_reg(clock,reset,id_exe_enable, pc_plus_4_in, instruction_in,read_data_1_in,read_data_2_in,sign_extend_in,
write_register_address_in,r_hi_in, r_lo_in, w_hi_in, w_lo_in, 
ALUSrc_in,MemorIOtoReg_in, IORead_in,IOWrite_in,RegWrite_in,MemWrite_in,MemRead_in, I_format_in,Sftmd_in,ALUOp_in,Jal_in,Jalr_in,bgezal_in,bltzal_in,
lb_in,lbu_in,lh_in,lhu_in,lw_in,sb_in,sh_in,sw_in,compare_in,
pc_plus_4_out,instruction_out, read_data_1_out,read_data_2_out,sign_extend_out,
write_register_address_out,r_hi_out, r_lo_out, w_hi_out, w_lo_out, 
ALUSrc_out,MemorIOtoReg_out, IORead_out,IOWrite_out,RegWrite_out,MemWrite_out,MemRead_out, 
 I_format_out,Sftmd_out,ALUOp_out,Jal_out,Jalr_out,bgezal_out,bltzal_out,
lb_out,lbu_out,lh_out,lhu_out,lw_out,sb_out,sh_out,sw_out,compare_out
    );
    
    input       clock;
    input       reset;
    input       id_exe_enable;  

//    //用于取指-in
//    input       Jrn_in;
//    input       Jmp_in;
//    input       Jal_in;

    //用于执行-in
    input[31:0] pc_plus_4_in;
    input[31:0] instruction_in;
    input       ALUSrc_in;            // 决定第二个操作数是寄存器还是立即数
    input       Sftmd_in;
    input[1:0]  ALUOp_in;
    input       I_format_in;
//    input       Branch_in;
//    input       nBranch_in;    
    input[31:0] read_data_1_in;
    input[31:0] read_data_2_in;
    input[31:0] sign_extend_in;
//    input       bgez_in;
//    input       bgtz_in;
//    input       blez_in;
//    input       bltz_in;
//    input       bgezal_in;
//    input       bltzal_in;
    input       lb_in;
    input       lbu_in;
    input       lh_in;
    input       lhu_in;
    input       lw_in;
    input       sb_in;
    input       sh_in;
    input       sw_in;
    
    //用于存储-in    
    input       IOWrite_in;    
    input       MemWrite_in;
    
    //存储+写回-in
    input       MemorIOtoReg_in;    
    input       IORead_in;      
    input       MemRead_in;
    
    //用于写回-in
    input       RegWrite_in;
    input[4:0]  write_register_address_in;
    input       r_hi_in;  
    input       r_lo_in;  
    input       w_hi_in;  
    input       w_lo_in;
    input       Jal_in;
    input       Jalr_in;
    input       bgezal_in;
    input       bltzal_in;
    input[1:0]  compare_in;
    
    
//    //用于取指-out
//    output       Jrn_out;
//    output       Jmp_out;
//    output       Jal_out;
    
    //用于执行-out
    output[31:0] pc_plus_4_out;
    output[31:0] instruction_out;
    output       ALUSrc_out;            // 决定第二个操作数是寄存器还是立即数
    output       Sftmd_out;
    output[31:0] read_data_1_out;
    output[31:0] read_data_2_out;
//    output       Branch_out;
//    output       nBranch_out;
    output       I_format_out;
    output[1:0]  ALUOp_out;
    output[31:0] sign_extend_out;
//    output       bgez_out;
//    output       bgtz_out;
//    output       blez_out;
//    output       bltz_out;
//    output       bgezal_out;
//    output       bltzal_out;
    output       lb_out;
    output       lbu_out;
    output       lh_out;
    output       lhu_out;
    output       lw_out;
    output       sb_out;
    output       sh_out;
    output       sw_out;
       
    //用于存储-out
    output       IOWrite_out;         //有IO
    output       MemWrite_out;
    //存储+写回-out
    output       MemorIOtoReg_out;    //有IO
    output       IORead_out;          //有IO
    output       MemRead_out;
    
    //用于写回-out
    output       RegWrite_out;
    output[4:0] write_register_address_out;
    output       r_hi_out;
    output       r_lo_out;             
    output       w_hi_out;
    output       w_lo_out;
    output       Jal_out;
    output       Jalr_out; 
    output       bgezal_out;
    output       bltzal_out;
    output[1:0]  compare_out;

//    //取指
//    reg       Jrn_out;
//    reg       Jmp_out;
//    reg       Jal_out;
    
    //执行
    reg[31:0] pc_plus_4_out;
    reg[31:0] instruction_out;
    reg       ALUSrc_out;            // 决定第二个操作数是寄存器还是立即数
    reg       Sftmd_out;
    reg[1:0]  ALUOp_out;
//    reg       Branch_out;
//    reg       nBranch_out;
    reg       I_format_out;
    reg[31:0] read_data_1_out;
    reg[31:0] read_data_2_out;
    reg[31:0] sign_extend_out;
//    reg       bgez_out;
//    reg       bgtz_out;
//    reg       blez_out;
//    reg       bltz_out;
//    reg       bgezal_out;
//    reg       bltzal_out;
    reg       lb_out;
    reg       lbu_out;
    reg       lh_out;
    reg       lhu_out;
    reg       lw_out;
    reg       sb_out;
    reg       sh_out;
    reg       sw_out;
   
   //存储
    reg       IOWrite_out;         //有IO
    reg       MemWrite_out;
    //存储+写回
    reg       IORead_out;          //有IO
    reg       MemRead_out;
    reg       MemorIOtoReg_out;    //有IO
    
   //写回
    reg[4:0] write_register_address_out;
    reg       r_hi_out;
    reg       r_lo_out;
    reg       w_hi_out;
    reg       w_lo_out;
    reg       RegWrite_out;
    reg       Jal_out;
    reg       Jalr_out; 
    reg       bgezal_out;
    reg       bltzal_out;
    reg[1:0]  compare_out;
    
    
always @(posedge clock) begin
        if(reset == 1'b1) begin
            pc_plus_4_out <= 32'b0;
            instruction_out <= 32'b0;
            read_data_1_out <= 32'b000;               
            read_data_2_out <= 32'b000;               
            sign_extend_out <= 32'b000;               
            write_register_address_out <= 5'b00000;   
            r_hi_out <= 0;                      
            r_lo_out <= 0;  
//            bgez_out <= 0;   
//            bgtz_out <= 0;   
//            blez_out <= 0;   
//            bltz_out <= 0;   
            bgezal_out <= 0;   
            bltzal_out <= 0; 
            lb_out <= 0; 
            lbu_out <= 0;
            lh_out <= 0; 
            lhu_out <= 0;
            lw_out <= 0; 
            sb_out <= 0; 
            sh_out <= 0;              
            sw_out <= 0; 
            
            w_hi_out <= 0;                    
            w_lo_out <= 0;                       
            ALUSrc_out <= 0;            
            MemorIOtoReg_out <= 0;      
            IORead_out <= 0;            
            IOWrite_out <= 0;           
            RegWrite_out <= 0;                  
            MemWrite_out <= 0;                  
            MemRead_out <= 0;                   
//            Branch_out <= 0;                    
//            nBranch_out <= 0;                   
            I_format_out <= 0;                 
            Sftmd_out <= 0;                    
            ALUOp_out <= 2'b00; 
            Jal_out <= 0;
            Jalr_out <= 0;    
            compare_out <= 2'b00;             
        end else begin
            if(id_exe_enable == 1'b1) begin
                pc_plus_4_out <= pc_plus_4_in;    
                instruction_out <= instruction_in;
                read_data_1_out <= read_data_1_in;
                read_data_2_out <= read_data_2_in;
                sign_extend_out <= sign_extend_in;
                write_register_address_out <= write_register_address_in;
                r_hi_out <= r_hi_in;   
                r_lo_out <= r_lo_in; 
//                bgez_out <= bgez_in;   
//                bgtz_out <= bgtz_in;   
//                blez_out <= blez_in;   
//                bltz_out <= bltz_in;   
                bgezal_out <= bgezal_in;   
                bltzal_out <= bltzal_in; 
                lb_out <= lb_in; 
                lbu_out <= lbu_in;
                lh_out <= lh_in; 
                lhu_out <=lhu_in;
                lw_out <= lw_in;  
                sb_out <= sb_in;  
                sh_out <= sh_in;               
                sw_out <= sw_in;  
                                                
                w_hi_out <= w_hi_in;   
                w_lo_out <= w_lo_in;             
                ALUSrc_out <= ALUSrc_in;         
                MemorIOtoReg_out <= MemorIOtoReg_in;   
                IORead_out <= IORead_in;         
                IOWrite_out <= IOWrite_in;        
                RegWrite_out <= RegWrite_in;       
                MemWrite_out <= MemWrite_in;       
                MemRead_out <= MemRead_in;        
//                Branch_out <= Branch_in;         
//                nBranch_out <= nBranch_in;       
                I_format_out <= I_format_in;       
                Sftmd_out <= Sftmd_in;          
                ALUOp_out <= ALUOp_in; 
                Jal_out <= Jal_in;
                Jalr_out <= Jalr_in;          
                compare_out <= compare_in;   
            end
        end
 end
    
endmodule
