`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module minisys(prst,pclk,led2N4,switch2N4);
    input prst;               //板上的Reset信号，低电平复位
    input pclk;               //板上的100MHz时钟信号
    input[23:0] switch2N4;    //拨码开关输入
    output[23:0] led2N4;      //led结果输出到Nexys4
    
    wire clock;              //clock: 分频后时钟供给系统
    wire iowrite,ioread;     //I/O读写信号
    wire[31:0] write_data;   //写RAM或IO的数据
    wire[31:0] rdata;        //读RAM或IO的数据
    wire[15:0] ioread_data;  //读IO的数据
    wire[31:0] pc_plus_4;    //PC+4
    wire[31:0] read_data_1;  //
    wire[31:0] read_data_2;  //
    wire[31:0] sign_extend;  //符号扩展
    wire[31:0] add_result;   //
    wire[31:0] alu_result;   //
    wire[31:0] read_data;    //RAM中读取的数据
    wire[31:0] address;
    wire alusrc;
    wire branch;
    wire nbranch,jmp,jal,jrn,i_format;
    wire regdst;
    wire regwrite;
    wire zero;
    wire memwrite;
    wire memread;
    wire memoriotoreg;
    wire memreg;
    wire sftmd;
    wire[1:0] aluop;
    wire[31:0] instruction;
    wire[31:0] opcplus4;
    wire[4:0] read_register_1_address;
    wire ledctrl,switchctrl;
    wire[15:0] ioread_data_switch;
    
    cpuclk cpuclk(
        .clk_in1(pclk),    //100MHz
        .clk_out1(clock)    //cpuclock
    );
    
    Ifetc32 ifetch(.Instruction(instruction),
                   .PC_plus_4_out(pc_plus_4),
                   .Add_result(add_result),
                   .Branch(branch),
                   .nBranch(nbranch),
                   .Jmp(jmp),
                   .Jal(jal),
                   .Jrn(jrn),
                   .Read_data_1(read_data_1),
                   .Zero(zero),
                  // .PC_out(pc),
                   .clock(clock),
                   .reset(prst),
                   .opcplus4(opcplus4)
        
    );
    
    Idecode32 idecode(.read_data_1(read_data_1),
                      .read_data_2(read_data_2),
                      .Instruction(instruction),
                      .read_data(read_data),
                      .ALU_result(alu_result),
                      .MemorIOtoReg(memoriotoreg),
                      .RegWrite(regwrite),
                      .RegDst(regdst),
                      .Sign_extend(sign_extend),
                      .Jal(jal),
                   //   .PC_next(pc_next),
                      .clock(clock),
                      .reset(prst),
                      .opcplus4(opcplus4),
                      .read_register_1_address(read_register_1_address)
        
    );
    
    control32 control(.Opcode(instruction[31:26]),
                      .Function_opcode(instruction[5:0]),
                      .RegDST(regdst),
                      .ALUSrc(alusrc),
                      .MemtoReg(memreg),//
                      .RegWrite(regwrite),
                      .MemWrite(memwrite),
                      .ALUOp(aluop),
                      .I_format(i_format),
                      .Branch(branch),
                      .nBranch(nbranch),
                      .Sftmd(sftmd),
                      .Jal(jal),
                      .Jrn(jrn)
                   //   .Jmp(jmp)
        
    );
                      
    Executs32 execute(.Read_data_1(read_data_1),
                      .Read_data_2(read_data_2),
                      .Sign_extend(sign_extend),
                      .Function_opcode(instruction[5:0]),
                      .Shamt(instruction[10:6]),
                      .Exe_opcode(instruction[31:26]),
                      .Sftmd(sftmd),
                      .ALUOp(aluop),
                      .ALUSrc(alusrc),
                      .ALU_Result(alu_result),
                      .Add_Result(add_result),
                      .I_format(i_format),
                      .Zero(zero),
                      .PC_plus_4(pc_plus_4)
                      
       
     );
    
    dmemory32 memory(.read_data(read_data),
                     .address(alu_result[11:0]),
                     .write_data(read_data_2),
                     .Memwrite(memwrite),
                     .clock(clock)
      
    );
            
//    memorio memio(
       
//    );
    
//    ioread multiioread(
        
//    );
 
//    leds led16(
        
//     );
     
//     switchs switch16(
        
//     );
endmodule
