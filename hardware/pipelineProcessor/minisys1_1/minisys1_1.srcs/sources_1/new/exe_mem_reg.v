`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/21 20:23:45
// Design Name: 
// Module Name: exe_mem_reg
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


module exe_mem_reg(clock,reset,exe_mem_enable, 
write_register_address_in,r_hi_in, r_lo_in, w_hi_in, w_lo_in,pc_plus_4_in,
MemorIOtoReg_in, IORead_in,IOWrite_in,RegWrite_in,MemWrite_in,MemRead_in,write_data_in,
ALU_Result_in,hi_data_in,lo_data_in,Jal_in,Jalr_in,bgezal_in,bltzal_in,compare_in,
MemEnable0_in,MemEnable1_in,MemEnable2_in,MemEnable3_in,
write_register_address_out,r_hi_out, r_lo_out, w_hi_out, w_lo_out,pc_plus_4_out,
MemorIOtoReg_out, IORead_out,IOWrite_out,RegWrite_out,MemWrite_out,MemRead_out,write_data_out,
 ALU_Result_out,hi_data_out,lo_data_out,Jal_out,Jalr_out,bgezal_out,bltzal_out,compare_out,
MemEnable0_out,MemEnable1_out,MemEnable2_out,MemEnable3_out
    );
    input       clock;
    input       reset;
    input       exe_mem_enable;  
    
    //用于存储-in    
    input       IOWrite_in;    
    input       MemWrite_in; 
    input       IORead_in;      
    input       MemRead_in;
    input[31:0] write_data_in;//向存储器写入的数据，用于sw指令，来自read_data_2
    input       MemEnable0_in;
    input       MemEnable1_in;
    input       MemEnable2_in;
    input       MemEnable3_in;     
    //存储+写回-in
    input       MemorIOtoReg_in;   
    input[31:0] ALU_Result_in;
    
    //用于写回-in 
    input[31:0] pc_plus_4_in;
    input       RegWrite_in;
    input[4:0]  write_register_address_in;
    input       r_hi_in;  
    input       r_lo_in;  
    input       w_hi_in;  
    input       w_lo_in; 
    input[31:0] hi_data_in;
    input[31:0] lo_data_in;
    input       Jal_in;
    input       Jalr_in;
    input       bgezal_in;
    input       bltzal_in;
    input[1:0]  compare_in;  
    
       
    //用于存储-out
    output       IOWrite_out;         //有IO
    output       MemWrite_out;
    output       IORead_out;          //有IO
    output       MemRead_out;
    output[31:0] write_data_out;
    output       MemEnable0_out;
    output       MemEnable1_out;
    output       MemEnable2_out;
    output       MemEnable3_out;
    //存储+写回-out
    output       MemorIOtoReg_out;    //有IO
    output[31:0] ALU_Result_out;
    
    //用于写回-out
    output[31:0] pc_plus_4_out;
    output       RegWrite_out;
    output[4:0] write_register_address_out;
    output       r_hi_out;
    output       r_lo_out;             
    output       w_hi_out;
    output       w_lo_out;
    output[31:0] hi_data_out;
    output[31:0] lo_data_out;
    output       Jal_out;
    output       Jalr_out; 
    output       bgezal_out;
    output       bltzal_out;
    output[1:0]  compare_out;

   //存储
    reg       IOWrite_out;         //有IO
    reg       MemWrite_out;
    reg       IORead_out;          //有IO
    reg       MemRead_out;
    reg[31:0] write_data_out;
    reg       MemEnable0_out;
    reg       MemEnable1_out;
    reg       MemEnable2_out;
    reg       MemEnable3_out;
    //存储+写回
    reg       MemorIOtoReg_out;    //有IO
    reg[31:0] ALU_Result_out;
    
   //写回
    reg[31:0] pc_plus_4_out;  
    reg[4:0] write_register_address_out;
    reg       r_hi_out;
    reg       r_lo_out;
    reg       w_hi_out;
    reg       w_lo_out;
    reg       RegWrite_out;
    reg[31:0] hi_data_out;
    reg[31:0] lo_data_out;
    reg       Jal_out;
    reg       Jalr_out; 
    reg       bgezal_out;
    reg       bltzal_out;
    reg[1:0]  compare_out;
    
    
always @(posedge reset or posedge clock) begin
        if(reset == 1'b1) begin    
            write_register_address_out <= 5'b00000;   
            r_hi_out <= 0;                      
            r_lo_out <= 0;                   
            w_hi_out <= 0;                    
            w_lo_out <= 0;     
            hi_data_out <= 32'b000;
            lo_data_out <= 32'b000;  
            ALU_Result_out <= 32'b000;        
            MemorIOtoReg_out <= 0;      
            IORead_out <= 0;            
            IOWrite_out <= 0;           
            RegWrite_out <= 0;      
            write_data_out <= 32'b000;            
            MemWrite_out <= 0;                  
            MemRead_out <= 0;             
            Jal_out <= 0;
            Jalr_out <= 0;   
            bgezal_out <= 0;   
            bltzal_out <= 0;    
            compare_out <=2'b00; 
            pc_plus_4_out <= 32'b0;
            MemEnable0_out  <= 0; 
            MemEnable1_out  <= 0; 
            MemEnable2_out  <= 0; 
            MemEnable3_out  <= 0; 
                   
        end else begin
            if(exe_mem_enable == 1'b1) begin  
                write_register_address_out <= write_register_address_in;
                r_hi_out <= r_hi_in;   
                r_lo_out <= r_lo_in;   
                w_hi_out <= w_hi_in;   
                w_lo_out <= w_lo_in;   
                hi_data_out <= hi_data_in;
                lo_data_out <= lo_data_in;
                ALU_Result_out <= ALU_Result_in;
                MemorIOtoReg_out <= MemorIOtoReg_in;   
                IORead_out <= IORead_in;         
                IOWrite_out <= IOWrite_in;        
                RegWrite_out <= RegWrite_in;    
                write_data_out <= write_data_in;   
                MemWrite_out <= MemWrite_in;       
                MemRead_out <= MemRead_in;    
                Jal_out <= Jal_in;
                Jalr_out <= Jalr_in;     
                bgezal_out <= bgezal_in;   
                bltzal_out <= bltzal_in;     
                compare_out <= compare_in;
                pc_plus_4_out <= pc_plus_4_in;
                MemEnable0_out  <= MemEnable0_in; 
                MemEnable1_out  <= MemEnable1_in; 
                MemEnable2_out  <= MemEnable2_in; 
                MemEnable3_out  <= MemEnable3_in; 
            end
        end
 end
    
endmodule