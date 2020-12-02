`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module Ifetc32(Instruction,PC_plus_4_out,Add_result,Read_data_1,Branch,nBranch,Jmp,Jal,Jrn,Zero,clock,reset,opcplus4,PC_out);
    output[31:0] Instruction;			// 输出指令
    output[31:0] PC_plus_4_out;
    input[31:0]  Add_result;
    input[31:0]  Read_data_1;
    input        Branch;
    input        nBranch;
    input        Jmp;
    input        Jal;
    input        Jrn;
    input        Zero;
    input        clock,reset;
    output[31:0] opcplus4;
    output[31:0] PC_out;//验证使用

    
    wire[31:0]   PC_plus_4;
    reg[31:0]	  PC;
    reg[31:0]    next_PC; 
//    reg[17:0] PC;
//    reg[15:0] next_PC;
    wire[31:0]   Jpadr;
    reg[31:0]    opcplus4;
    
   //分配64KB ROM，编译器实际只用 64KB ROM
    prgrom instmem(
        .clka(clock),         // input wire clka
        .addra(PC[15:2]),     // input wire [13 : 0] addra
        .douta(Jpadr)         // output wire [31 : 0] douta
    );

    assign PC_out=PC[31:0];
    assign PC_plus_4_out=PC_plus_4[31:0];    
    assign PC_plus_4[31:2]=PC[31:2]+30'b001;
    assign PC_plus_4[1:0]=2'b00;

    assign Instruction = Jpadr;              //  取出指令


    always @* begin                          // beq $n ,$m if $n=$m branch   bne if $n /=$m branch jr
        if(((Branch==1)&&(Zero==1))||((nBranch==1)&&(Zero==0)))
            next_PC=Add_result;
        else if(Jrn==1) next_PC=Read_data_1[31:0];
        else    next_PC=PC_plus_4;
    end
    
   always @(negedge clock) begin
     if(reset==1)   PC<=32'b00000000000000000000000000000000;//PC初始化
     else if((Jmp==1)||(Jal==1))begin
 //           opcplus4={2'b00,PC_plus_4[31:2]};//右移两位再放入$31
             opcplus4=PC_plus_4[31:0];
            PC<={4'b0000,Jpadr[25:0],2'b00};
        end
    else PC<=next_PC;  
   end
endmodule
