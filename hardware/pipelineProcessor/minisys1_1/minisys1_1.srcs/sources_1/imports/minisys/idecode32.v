`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module Idecode32(read_data_1,read_data_2,Instruction,read_data,ALU_result,Jrn,Jalr,Jmp,Jal,Branch,nBranch,bgez,bgtz,blez,bltz,bgezal,bltzal,
                 Jal_wb,Jalr_wb,bgezal_wb,bltzal_wb,compare_wb,RegWrite,MemorIOtoReg,RegDst,Sign_extend,clock,reset,
                 opcplus4,write_register_address_out,w_hi_wb,w_lo_wb,write_register_address_in,w_hi_exe,w_lo_exe,w_hi_mem,w_lo_mem,
                 write_register_address_id_exe,write_register_address_exe_mem,write_register_address_mem_wb,
                 hi_data,lo_data,r_hi_wb,r_lo_wb,r_hi,r_lo,rt,MemorIOAddr,Zero,compare,PC_plus_4,Add_Result,
                 reset_if_id,reset_id_exe,stall
                 );
                 
    input		  clock;
    input		  reset;
    input[31:0]  Instruction;//来自取指模块
    input[31:0]  read_data;   				//  从DATA RAM or I/O port取出的数据
    input[31:0]  ALU_result;   				//  需要扩展立即数到32位
    input        Jrn;
    input        Jalr;
    input        Jmp;
    input        Jal;
    input        Branch;
    input        nBranch;
    input        bgez;  
    input        bgtz;  
    input        blez;  
    input        bltz; 
    input        bgezal;
    input        bltzal;
    input        Jal_wb; 
    input        Jalr_wb;
    input        bgezal_wb;
    input        bltzal_wb;
    input[1:0]   compare_wb;
    input        RegWrite;
    input        MemorIOtoReg;
    input        RegDst;        //为1说明目标是rd，否则是rt
    input[31:0]  opcplus4;                 // 来自取指单元，JAL中用
    input        w_hi_wb;          //mthi,mult,multu,div,divu
    input        w_lo_wb;          //mtlo,mult,multu,div,divu
    input        r_hi_wb;       //mfhi
    input        r_lo_wb;       //mflo
    input[4:0]  write_register_address_in;
   // input[31:0]  hi_lo_data;
    input[31:0]  hi_data;
    input[31:0]  lo_data;
    input[31:0]  PC_plus_4;
    input        r_hi;   //mfhi
    input        r_lo;   //mflo
    input        w_hi_exe;
    input        w_lo_exe;
    input        w_hi_mem;
    input        w_lo_mem;
    
    //数据相关解决
    input[4:0]  write_register_address_id_exe;
    input[4:0]  write_register_address_exe_mem;
    input[4:0]  write_register_address_mem_wb;
    output      stall;
    output      reset_id_exe;
    
    
    //控制冲突解决部分,清空流水寄存器信号
    output reset_if_id;
 
    output[31:0] read_data_1;
    output[31:0] read_data_2;
    output[31:0] Sign_extend;
    output[4:0]  write_register_address_out;
    output[4:0]  rt;  //用于区分bgez\bgtz\blez等指令
    output[31:0] MemorIOAddr;
    output       Zero;
    output[1:0]  compare;    //用于bgez,bgtz,blez,bltz,bgezal,bltzal//大于0是10，等于0是00，小于0是01
    output[31:0] Add_Result;
    
    reg[1:0]  compare;
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
//    wire r_hi_out;
//    wire r_lo_out;
    
//    reg[4:0] write_register_addr;

    //pc阻塞
    reg stall;
    
    //流水寄存器清空
//    reg reset_if_id;
//    reg reset_id_exe;
    reg reset_if_id;
    reg reset_id_exe;
    
    
//    assign w_hi=(opcode==1&&Instruction[5:0]==6'b010001);
////    assign w_lo=(opcode==1&&Instruction[5:0]==6'b010011);
//    assign r_hi=(opcode==6'b000000&&Instruction[5:0]==6'b010000);
//    assign r_lo=(opcode==6'b000000&&Instruction[5:0]==6'b010010);
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
    
    
    assign Add_Result = PC_plus_4[31:0] + {Sign_extend[29:0],2'b00};    // 给取指单元作为beq和bne指令的跳转地址 
    
    assign Zero=(read_data_1==read_data_2)?1'b1:1'b0;
    
    always @* begin
        if((bgez==1)||(bgtz==1)||(blez==1)||(bltz==1)||(bgezal==1)||(bltzal==1))begin
            if(read_data_1[31]==1) begin
                compare=2'b01;//小于0
            end else if(read_data_1==32'b0000_0000_0000_0000_0000_0000_0000_0000) begin
                compare=2'b00;//等于0
            end else begin
                compare=2'b10;//大于0
            end 
       end else begin
        compare=2'b11;
       end
    end
    
//    assign read_data_1 = register[read_register_1_address];
//    assign read_data_2 = register[read_register_2_address];
    always @* begin
        if(r_hi)begin
            read_data_1=hi;
        end else if(r_lo)begin
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
        else if ((RegDst==0)&&((Jal==1)||((bgezal==1)&&((compare==2'b10)||(compare==2'b00)))||((bltzal==1)&&(compare==2'b01))))
            write_register_address_out=5'b11111;   //写31号寄存器
        else if((bgez==1)||(bgtz==1)||(blez==1)||(bltz==1)||(bgezal==1)||(bltzal==1))
            write_register_address_out=5'b00000;    //不写寄存器
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
        if(r_hi_wb) begin
            write_data=hi_data;
         end else if(r_lo_wb) begin
            write_data=lo_data;
         end else if(MemorIOtoReg==0) begin
            if((Jal_wb==1)||(Jalr_wb==1)||((bgezal_wb==1)&&((compare_wb==2'b10)||(compare_wb==2'b00)))||((bltzal_wb==1)&&(compare_wb==2'b01))) begin
                write_data[31:0]=opcplus4[31:0];
            end else begin
                write_data=ALU_result[31:0];
            end
         end else begin
            write_data=read_data;
         end
       end
     
//     always @* begin
//     if(((Jal_wb==1)||((bgezal_wb==1)&&((compare_wb==2'b10)||(compare_wb==2'b00)))||((bltzal_wb==1)&&(compare_wb==2'b01))))
//        write_register_addr=5'b11111;
//     else
//        write_register_addr=write_register_address_in;
//     end
     
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
           if(w_hi_wb||w_lo_wb)begin
               if(w_hi_wb) begin
                hi=hi_data;
               end 
               if(w_lo_wb) begin
                lo=lo_data;
               end
           end else if(write_register_address_in!=0) begin
                register[write_register_address_in]<=write_data;
           end
        end
    end

//控制相关的处理-气泡法
    always @* begin
        if((Jrn==1)||(Jalr==1)||(Jmp==1)||(Jal==1)||((Branch==1)&&(Zero==1))||((nBranch==1)&&(Zero==0))||
            ((bgez==1)&&((compare==2'b10)||(compare==2'b00)))||((bgtz==1)&&(compare==2'b10))||((blez==1)&&((compare==2'b00)||(compare==2'b01)))
            ||((bltz==1)&&(compare==2'b01))||((bgezal==1)&&((compare==2'b10)||(compare==2'b00)))||((bltzal==1)&&(compare==2'b01)))
                reset_if_id=1'b1;
        else
                reset_if_id=1'b0;
    end
//assign reset_if_id=((Jrn==1)||(Jalr==1)||(Jmp==1)||(Jal==1)||((Branch==1)&&(Zero==1))||((nBranch==1)&&(Zero==0))||
//            ((bgez==1)&&((compare==2'b10)||(compare==2'b00)))||((bgtz==1)&&(compare==2'b10))||((blez==1)&&((compare==2'b00)||(compare==2'b01)))
//            ||((bltz==1)&&(compare==2'b01))||((bgezal==1)&&((compare==2'b10)||(compare==2'b00)))||((bltzal==1)&&(compare==2'b01)))?1'b1:1'b0;
            
//assign reset_id_exe=((Jrn==1)||(Jalr==1)||(Jmp==1)||(Jal==1)||((Branch==1)&&(Zero==1))||((nBranch==1)&&(Zero==0))||
//            ((bgez==1)&&((compare==2'b10)||(compare==2'b00)))||((bgtz==1)&&(compare==2'b10))||((blez==1)&&((compare==2'b00)||(compare==2'b01)))
//            ||((bltz==1)&&(compare==2'b01))||((bgezal==1)&&((compare==2'b10)||(compare==2'b00)))||((bltzal==1)&&(compare==2'b01)))?1'b1:1'b0;
    
 //数据相关的处理-气泡法
 //read_register_1_address,read_register_2_address;//1_rs  2_rt   
//  input[4:0]  write_register_address_id_exe;
//    input[4:0]  write_register_address_exe_mem;
//    input[4:0]  write_register_address_mem_wb;
    always @* begin
        if(((read_register_1_address==write_register_address_id_exe)&&(write_register_address_id_exe!==5'b00000))||
                ((read_register_2_address==write_register_address_id_exe)&&(write_register_address_id_exe!==5'b00000))||
                ((read_register_1_address==write_register_address_exe_mem)&&(write_register_address_exe_mem!==5'b00000))||
                ((read_register_2_address==write_register_address_exe_mem)&&(write_register_address_exe_mem!==5'b00000))||
                ((read_register_1_address==write_register_address_mem_wb)&&(write_register_address_mem_wb!==5'b00000))||
                ((read_register_2_address==write_register_address_mem_wb)&&(write_register_address_mem_wb!==5'b00000))||
                ((r_hi==1)&&(w_hi_exe==1))||((r_lo==1)&&(w_lo_exe==1))||
                ((r_hi==1)&&(w_hi_mem==1))||((r_lo==1)&&(w_lo_mem==1))||
                ((r_hi==1)&&(w_hi_wb==1))||((r_lo==1)&&(w_lo_wb==1)))
            reset_id_exe= 1'b1;
        else
            reset_id_exe= 1'b0;
    end
    
    always @* begin
        if(((read_register_1_address==write_register_address_id_exe)&&(write_register_address_id_exe!==5'b00000))||
                ((read_register_2_address==write_register_address_id_exe)&&(write_register_address_id_exe!==5'b00000))||
                ((read_register_1_address==write_register_address_exe_mem)&&(write_register_address_exe_mem!==5'b00000))||
                ((read_register_2_address==write_register_address_exe_mem)&&(write_register_address_exe_mem!==5'b00000))||
                ((read_register_1_address==write_register_address_mem_wb)&&(write_register_address_mem_wb!==5'b00000))||
                ((read_register_2_address==write_register_address_mem_wb)&&(write_register_address_mem_wb!==5'b00000))||
                ((r_hi==1)&&(w_hi_exe==1))||((r_lo==1)&&(w_lo_exe==1))||
                ((r_hi==1)&&(w_hi_mem==1))||((r_lo==1)&&(w_lo_mem==1))||
                ((r_hi==1)&&(w_hi_wb==1))||((r_lo==1)&&(w_lo_wb==1)))
            stall= 1'b1;
        else
            stall= 1'b0;
    end

// assign reset_id_exe=(((read_register_1_address==write_register_address_id_exe)&&(write_register_address_id_exe!==5'b00000))||
//                ((read_register_2_address==write_register_address_id_exe)&&(write_register_address_id_exe!==5'b00000))||
//                ((read_register_1_address==write_register_address_exe_mem)&&(write_register_address_exe_mem!==5'b00000))||
//                ((read_register_2_address==write_register_address_exe_mem)&&(write_register_address_exe_mem!==5'b00000))||
//                ((read_register_1_address==write_register_address_mem_wb)&&(write_register_address_mem_wb!==5'b00000))||
//                ((read_register_2_address==write_register_address_mem_wb)&&(write_register_address_mem_wb!==5'b00000))||
//                ((r_hi==1)&&(w_hi_exe==1))||((r_lo==1)&&(w_lo_exe==1))||
//                ((r_hi==1)&&(w_hi_mem==1))||((r_lo==1)&&(w_lo_mem==1))||
//                ((r_hi==1)&&(w_hi_wb==1))||((r_lo==1)&&(w_lo_wb==1)))?1'b1:1'b0;

// assign stall=(((read_register_1_address==write_register_address_id_exe)&&(write_register_address_id_exe!==5'b00000))||
//                ((read_register_2_address==write_register_address_id_exe)&&(write_register_address_id_exe!==5'b00000))||
//                ((read_register_1_address==write_register_address_exe_mem)&&(write_register_address_exe_mem!==5'b00000))||
//                ((read_register_2_address==write_register_address_exe_mem)&&(write_register_address_exe_mem!==5'b00000))||
//                ((read_register_1_address==write_register_address_mem_wb)&&(write_register_address_mem_wb!==5'b00000))||
//                ((read_register_2_address==write_register_address_mem_wb)&&(write_register_address_mem_wb!==5'b00000))||
//                ((r_hi==1)&&(w_hi_exe==1))||((r_lo==1)&&(w_lo_exe==1))||
//                ((r_hi==1)&&(w_hi_mem==1))||((r_lo==1)&&(w_lo_mem==1))||
//                ((r_hi==1)&&(w_hi_wb==1))||((r_lo==1)&&(w_lo_wb==1)))?1'b1:1'b0;
// assign reset_id_exe=(((read_register_1_address==write_register_address_id_exe)&&(write_register_address_id_exe!==5'b00000))||
//                ((read_register_2_address==write_register_address_id_exe)&&(write_register_address_id_exe!==5'b00000))||
//                ((read_register_1_address==write_register_address_exe_mem)&&(write_register_address_exe_mem!==5'b00000))||
//                ((read_register_2_address==write_register_address_exe_mem)&&(write_register_address_exe_mem!==5'b00000))||
//                ((read_register_1_address==write_register_address_mem_wb)&&(write_register_address_mem_wb!==5'b00000))||
//                ((read_register_2_address==write_register_address_mem_wb)&&(write_register_address_mem_wb!==5'b00000)))?1'b1:1'b0;

// assign stall=(((read_register_1_address==write_register_address_id_exe)&&(write_register_address_id_exe!==5'b00000))||
//                ((read_register_2_address==write_register_address_id_exe)&&(write_register_address_id_exe!==5'b00000))||
//                ((read_register_1_address==write_register_address_exe_mem)&&(write_register_address_exe_mem!==5'b00000))||
//                ((read_register_2_address==write_register_address_exe_mem)&&(write_register_address_exe_mem!==5'b00000))||
//                ((read_register_1_address==write_register_address_mem_wb)&&(write_register_address_mem_wb!==5'b00000))||
//                ((read_register_2_address==write_register_address_mem_wb)&&(write_register_address_mem_wb!==5'b00000)))?1'b1:1'b0;
    
endmodule
