`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module Idecode32(read_data_1,read_data_2,Instruction,read_data,ALU_result,
                 Jal,Jalr,bgezal,bltzal,compare,RegWrite,MemorIOtoReg,RegDst,Sign_extend,clock,reset,
                 opcplus4,write_register_address_out,w_hi,w_lo,write_register_address_in,
                 hi_data,lo_data,r_hi_in,r_lo_in,r_hi_out,r_lo_out,rt,MemorIOAddr);
                 
    input		  clock;
    input		  reset;
    input[31:0]  Instruction;//来自取指模块
    input[31:0]  read_data;   				//  从DATA RAM or I/O port取出的数据
    input[31:0]  ALU_result;   				//  需要扩展立即数到32位
    input        Jal; 
    input        Jalr;
    input        bgezal;
    input        bltzal;
    input[1:0]   compare;
    input        RegWrite;
    input        MemorIOtoReg;
    input        RegDst;        //为1说明目标是rd，否则是rt
    input[31:0]  opcplus4;                 // 来自取指单元，JAL中用
    input        w_hi;          //mthi,mult,multu,div,divu
    input        w_lo;          //mtlo,mult,multu,div,divu
    input        r_hi_in;       //mfhi
    input        r_lo_in;       //mflo
    input[4:0]  write_register_address_in;
   // input[31:0]  hi_lo_data;
    input[31:0]  hi_data;
    input[31:0]  lo_data;
    
    output[31:0] read_data_1;
    output[31:0] read_data_2;
    output[31:0] Sign_extend;
    output[4:0] write_register_address_out;
    output       r_hi_out;   //mfhi
    output       r_lo_out;   //mflo
    output[4:0]  rt;  //用于区分bgez\bgtz\blez等指令
    output[31:0] MemorIOAddr;
    
    reg[31:0] read_data_1;//rs
    reg[31:0] read_data_2;//rt
    reg[31:0] register[0:31];			   //寄存器组共32个32位寄存器
    reg[31:0] hi;
    reg[31:0] lo;
   
    reg[4:0] write_register_address_out;
    reg[31:0] write_data;
    wire[4:0] read_register_1_address,read_register_2_address;//1_rs  2_rt
    wire[4:0] write_register_address_1;//rd(r-form)
    wire[4:0] write_register_address_0;//rt(i-form)
    wire[15:0] Instruction_immediate_value;
    wire[5:0] opcode;//op
    wire sign;
    wire[4:0]  rt;
    
//    wire w_hi;
//    wire w_lo;
    wire r_hi_out;
    wire r_lo_out;
    
    reg[4:0] write_register_addr;
    
//    assign w_hi=(opcode==1&&Instruction[5:0]==6'b010001);
//    assign w_lo=(opcode==1&&Instruction[5:0]==6'b010011);
    assign r_hi_out=(opcode==6'b000000&&Instruction[5:0]==6'b010000);
    assign r_lo_out=(opcode==6'b000000&&Instruction[5:0]==6'b010010);
    assign rt=Instruction[20:16];

    assign opcode=Instruction[31:26];
    assign read_register_1_address=Instruction[25:21];
    assign read_register_2_address=Instruction[20:16];
    assign write_register_address_1=Instruction[15:11];//rd
    assign write_register_address_0=Instruction[20:16];//rt
    assign Instruction_immediate_value=Instruction[15:0];
    
    assign sign=Instruction_immediate_value[15];
    assign Sign_extend[31:0]=((opcode==6'b001100)
    ||(opcode==6'b001110)
    ||(opcode==6'b001101)
    ||(opcode==6'b001011))?{16'h0000,Instruction_immediate_value[15:0]}//立即数0扩展
    :{sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,
    Instruction_immediate_value[15:0]};
    
    
//    assign read_data_1 = register[read_register_1_address];
//    assign read_data_2 = register[read_register_2_address];
    always @* begin
        if(r_hi_out)begin
            read_data_1=hi;
        end else if(r_lo_out)begin
            read_data_1=lo;
        end else begin
            read_data_1=register[read_register_1_address];
            read_data_2=register[read_register_2_address];
        end
    end

    assign MemorIOAddr=read_data_1+Sign_extend;

    always  @*//这个进程指定不同指令下的目标寄存器
    begin
//    if((RegDst==1)&&(Jal==0))
    if(RegDst==1)
      write_register_address_out=write_register_address_1;//rd
//    else if ((RegDst==0)&&((Jal==1)||((bgezal==1)&&((compare==2'b10)||(compare==2'b00)))||((bltzal==1)&&(compare==2'b01))))
//    write_register_address_out=5'b11111;   //写31号寄存器
    else
      write_register_address_out=write_register_address_0;//rt
   
    end
 
                                              
//    always @* begin  //这个进程基本上是实现结构图中右下的多路选择器,准备要写的数据
//      if((MemorIOtoReg==0)&&((Jal==0)&&(Jalr==0)))
//       write_data=ALU_result[31:0];
//      else if ((MemorIOtoReg==0)&&((Jal==1)||(Jalr==1)||((bgezal==1)&&((compare==2'b10)||(compare==2'b00)))||((bltzal==1)&&(compare==2'b01))))
//      begin
//        write_data[31:0]=opcplus4[31:0];
//      end
//     else if(r_hi_in) begin
//        write_data=hi_data;
//     end else if(r_lo_in) begin
//        write_data=lo_data;
//     end else
//        write_data=read_data;
//     end    
    always @* begin//这个进程基本上是实现结构图中右下的多路选择器,准备要写的数据
        if(r_hi_in) begin
            write_data=hi_data;
         end else if(r_lo_in) begin
            write_data=lo_data;
         end else if(MemorIOtoReg==0) begin
            if((Jal==1)||(Jalr==1)||((bgezal==1)&&((compare==2'b10)||(compare==2'b00)))||((bltzal==1)&&(compare==2'b01))) begin
                write_data[31:0]=opcplus4[31:0];
            end else begin
                write_data=ALU_result[31:0];
            end
         end else begin
            write_data=read_data;
         end
       end
     
     always @* begin
     if(((Jal==1)||((bgezal==1)&&((compare==2'b10)||(compare==2'b00)))||((bltzal==1)&&(compare==2'b01))))
        write_register_addr=5'b11111;
     else
        write_register_addr=write_register_address_in;
     end
     
    integer i;
   // always @(posedge clock) begin       // 本进程写目标寄存器
   always @(negedge clock) begin       // 本进程写目标寄存器
        if(reset==1) begin              // 初化寄存器组
            for(i=0;i<32;i=i+1) register[i]<=i;
            hi<=32'h00000000;
            lo<=32'h00000000;
        end
       else if(RegWrite==1) begin  // 注意寄存器0恒等于0
//       if(write_register_address!=0) begin
//       register[write_register_address]<=write_data;
//       end
       if(w_hi||w_lo)begin
           if(w_hi) begin
            hi=hi_data;
           end 
           if(w_lo) begin
            lo=lo_data;
           end
       end else if(write_register_addr!=0) begin
        register[write_register_addr]<=write_data;
       end
        end
    end
endmodule
