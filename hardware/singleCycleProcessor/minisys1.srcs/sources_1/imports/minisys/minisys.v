`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module minisys(prst,pclk,led2N4,switch2N4,pc,alu_result_out,read_data_1_out,read_data_2_out,write_data_out,instruction_out,branch_out,zero_out,memwrite_out,regwrite_out,i_format_out);
    input prst;               //板上的Reset信号，低电平复位
    input pclk;               //板上的100MHz时钟信号
    input[23:0] switch2N4;    //拨码开关输入
    output[23:0] led2N4;      //led结果输出到Nexys4
    output[31:0] pc;
    output[31:0] alu_result_out;
    output[31:0] read_data_1_out;
    output[31:0] read_data_2_out;
    output[31:0] write_data_out;
    output[31:0] instruction_out;
    output branch_out;
    output zero_out;
    output memwrite_out;
    output regwrite_out;
    output i_format_out;
    
    wire clock;              //clock: 分频后时钟供给系统
    wire reset;
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
    
    assign instruction_out=instruction;
    assign alu_result_out=alu_result;
    assign read_data_1_out=read_data_1;
    assign read_data_2_out=read_data_2;
    assign write_data_out=(memreg==1)?read_data:alu_result;
    assign branch_out=branch;
    assign zero_out=zero;
    assign regwrite_out=regwrite;
    assign memwrite_out=memwrite;
    assign i_format_out=i_format;
    assign reset=!prst;
  
    assign write_data=(memwrite==1)?read_data_2:32'bz;
   
    
    cpuclk cpuclk(
        .clk_in1(pclk),    //100MHz
        .clk_out1(clock)    //cpuclock
    );
    
    Ifetc32 ifetch(.Instruction(instruction),//out
                   .PC_plus_4_out(pc_plus_4),//out
                   .Add_result(add_result),//in
                   .Branch(branch),//in
                   .nBranch(nbranch),//in
                   .Jmp(jmp),//in
                   .Jal(jal),//in
                   .Jrn(jrn),//in
                   .Read_data_1(read_data_1),//in
                   .Zero(zero),//in
                  // .PC_out(pc),
                   .clock(clock),//in
                   .reset(reset),//in
                   .opcplus4(opcplus4),//out
                   .PC_out(pc)
        
    );
    
    Idecode32 idecode(.read_data_1(read_data_1),//out
                      .read_data_2(read_data_2),//out
                      .Instruction(instruction),//in
                      .read_data(read_data),//in
                      .ALU_result(alu_result),//in
                     // .MemorIOtoReg(memoriotoreg),//in
                     .MemorIOtoReg(memreg),
                      .RegWrite(regwrite),//in
                      .RegDst(regdst),//in
                      .Sign_extend(sign_extend),//in
                      .Jal(jal),//in
                   //   .PC_next(pc_next),
                      .clock(clock),//in
                      .reset(reset),//in
                      .opcplus4(opcplus4),//in
                      .read_register_1_address(read_register_1_address)//out
        
    );
    
    control32 control(.Opcode(instruction[31:26]),//in
                      .Function_opcode(instruction[5:0]),//in
                      .RegDST(regdst),//out
                      .ALUSrc(alusrc),//out
                      .MemtoReg(memreg),//out
                      .RegWrite(regwrite),//out
                      .MemWrite(memwrite),//out
                      .ALUOp(aluop),//out
                      .I_format(i_format),//out
                      .Branch(branch),//out
                      .nBranch(nbranch),//out
                      .Sftmd(sftmd),//out
                      .Jal(jal),//out
                      .Jrn(jrn),//out
                      .Jmp(jmp)//out
        
    );
                      
    Executs32 execute(.Read_data_1(read_data_1),//in
                      .Read_data_2(read_data_2),//in
                      .Sign_extend(sign_extend),//in
                      .Function_opcode(instruction[5:0]),//in
                      .Shamt(instruction[10:6]),//in
                      .Exe_opcode(instruction[31:26]),//in
                      .Sftmd(sftmd),//in
                      .ALUOp(aluop),//in
                      .ALUSrc(alusrc),//in
                      .ALU_Result(alu_result),//out
                      .Add_Result(add_result),//out
                      .I_format(i_format),//in
                      .Zero(zero),//out
                      .PC_plus_4(pc_plus_4)//in
                      
       
     );
    
    dmemory32 memory(.read_data(read_data),//out
                     .address(alu_result),//in//alu_result[11:0]
                     .write_data(write_data),//in//read_data_2
                     .Memwrite(memwrite),//in
                     .clock(clock)//in
      
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
