`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/31 16:35:46
// Design Name: 
// Module Name: mem_wb_sim
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


module mem_wb_sim(

    );
    
    reg clock=1'b1;
    reg reset=1'b1;
    reg exe_mem_enable=1'b1;  
    
    //�洢+д��-in
    reg       MemorIOtoReg_in;    
    reg       IORead_in;      
    reg       MemRead_in;
    reg[31:0] ALU_Result_in;
    
    //����д��-in
    reg       RegDST_in;     
    reg       RegWrite_in;
    reg[31:0] write_register_address_in;
    reg       r_hi_in;  
    reg       r_lo_in;  
    reg       w_hi_in;  
    reg       w_lo_in; 
    reg[31:0] hi_lo_data_in;
    reg[31:0] ALU_HI_in;
    reg[31:0] ALU_LO_in;
    reg[31:0] write_data_in;
    reg       Jal_in;
    reg       Jalr_in;
    reg       bgezal_in;
    reg       bltzal_in;
    reg[1:0]  compare_in;  
        
    //�洢+д��-out
    wire       MemorIOtoReg_out;    //��IO
    wire       IORead_out;          //��IO
    wire       MemRead_out;
    wire[31:0] ALU_Result_out;
    
    //����д��-out
   wire       RegWrite_out;
   wire[31:0] write_register_address_out;
   wire       r_hi_out;
   wire       r_lo_out;             
   wire       w_hi_out;
   wire       w_lo_out;
   wire       RegDST_out;
   wire[31:0] hi_lo_data_out;
   wire[31:0] ALU_HI_out;
   wire[31:0] ALU_LO_out;
   wire[31:0] write_data_out;
   wire       Jal_out;
   wire       Jalr_out; 
   wire       bgezal_out;
   wire       bltzal_out;
   wire[1:0]  compare_out;



mem_wb_reg Uidexe(clock,reset,exe_mem_enable, 
write_register_address_in,r_hi_in, r_lo_in, w_hi_in, w_lo_in, RegDST_in,
MemorIOtoReg_in, IORead_in,RegWrite_in,MemRead_in,write_data_in,
 hi_lo_data_in,ALU_Result_in,ALU_HI_in,ALU_LO_in,Jal_in,Jalr_in,bgezal_in,bltzal_in,compare_in,
write_register_address_out,r_hi_out, r_lo_out, w_hi_out, w_lo_out, RegDST_out,
MemorIOtoReg_out,IORead_out,RegWrite_out,MemRead_out,write_data_out,
 hi_lo_data_out,ALU_Result_out,ALU_HI_out,ALU_LO_out,Jal_out,Jalr_out,bgezal_out,bltzal_out,compare_out
);

 initial begin
       
       #200 begin reset=1'b0;
                   MemorIOtoReg_in=0; 
                   IORead_in=0;       
                   MemRead_in=0;      
                   ALU_Result_in=0;   
                   RegDST_in=0;                
                   RegWrite_in=0;              
                   write_register_address_in=0;
                   r_hi_in=0;                  
                   r_lo_in=0;                  
                   w_hi_in=0;                  
                   w_lo_in=0;                  
                   hi_lo_data_in=0;            
                   ALU_HI_in=0;                
                   ALU_LO_in=0;                
                   write_data_in=0;            
                   Jal_in=0;                   
                   Jalr_in=0;                  
                   bgezal_in=0;                
                   bltzal_in=0;                
                   compare_in=0;               

                   
       end
       #200 begin                   
                   MemorIOtoReg_in=1; 
                   IORead_in=1;       
                   MemRead_in=1;      
                   ALU_Result_in=1;   
                   RegDST_in=1;                
                   RegWrite_in=1;              
                   write_register_address_in=1;
                   r_hi_in=1;                  
                   r_lo_in=1;                  
                   w_hi_in=1;                  
                   w_lo_in=1;                  
                   hi_lo_data_in=1;            
                   ALU_HI_in=1;                
                   ALU_LO_in=1;                
                   write_data_in=1;            
                   Jal_in=1;                   
                   Jalr_in=1;                  
                   bgezal_in=1;                
                   bltzal_in=1;                
                   compare_in=1;                            
       end
//       #200 begin
//                id_exe_enable=1'b1;
//       end
  end
   
   always #50 clock = ~clock; 
endmodule
