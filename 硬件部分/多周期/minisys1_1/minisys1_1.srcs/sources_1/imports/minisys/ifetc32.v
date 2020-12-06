`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module Ifetc32 (Wpc,Wir,reset,clock,Instruction,PC_out,PC_plus_4_out,Add_result,Read_data_1,Jmp,Jal,opcplus4,rom_adr_o,Jpadr);

    input[1:0]   Wpc;
    input        Wir;

	input			reset;				// 复位信号(高电平有效)
    input			clock;				// 时钟(23MHz)
	output	[31:0]	Instruction;		// 输出指令到其他模块
	output [31:0]  PC_out;
    output	[31:0]	PC_plus_4_out;		// (pc+4)送执行单元
    input	[31:0]	Add_result;		// 来自执行单元,算出的跳转地址
    input	[31:0]	Read_data_1;		// 来自译码单元，jr指令用的地址
//    input			Branch,				// 来自控制单元
//    input			nBranch,			// 来自控制单元
    input			Jmp;				// 来自控制单元
    input			Jal;				// 来自控制单元
//    input			Jrn,				// 来自控制单元
//    input			Zero,				// 来自执行单元
    output [31:0]	opcplus4;			// JAL指令专用的PC+4
    // ROM Pinouts
	output	[13:0]	rom_adr_o;			// 给程序ROM单元的取指地址
	input	[31:0]	Jpadr;		// 从程序ROM单元中获取的指令

    
    wire [31:0] PC_plus_4;
    reg [31:0] PC;
    reg [31:0] next_PC;		// 下条指令的PC（不一定是PC+4)
    reg [31:0] opcplus4;
    
	// ROM Pinouts
	assign rom_adr_o = PC[15:2];
//	assign Instruction = Jpadr;
    
       reg[31:0] IR;
       
    //阻塞赋值和非阻塞赋值
    //如果ir用非阻塞<=， PC={4'b0000,IR[25:0],2'b00};这句会慢一个周期
    always @ (negedge clock) begin
        if(reset)begin
            IR=0;
        end else if(Wir==1) begin
            IR=Jpadr;
        end else begin
            IR=IR;
        end
    end
    
    always @ (negedge clock) begin
        if(reset) begin
            PC<=32'b0;
        end else begin
            case(Wpc)
                2'b00:begin
                        PC<=PC;
                    end
                2'b01: begin
                        next_PC[31:2]=PC[31:2]+30'b001;
                        next_PC[1:0]=2'b00;
                        PC<=next_PC;
                    end
                // PC<=PC_plus_4_out;//pc+4
                2'b10:  begin
                        if(Jmp==1||Jal==1)begin
                            opcplus4=PC_plus_4_out[31:0];
                            PC<={4'b0000,IR[25:0],2'b00};//jmp,jal
                        end else begin
                            PC<=Read_data_1[31:0];//jrn
                        end
                    end
                2'b11:  PC<=Add_result;//beq,bne
            endcase
        end
    end
    
    
    assign PC_out=PC[31:0]; 
    assign PC_plus_4_out=PC;    
    assign Instruction=IR;
//	assign PC_plus_4[31:2] =？？？
//	assign PC_plus_4[1:0] =？？？
//	assign PC_plus_4_out = PC_plus_4[31:0];  

//    always @* begin  // beq $n ,$m if $n=$m branch   bne if $n /=$m branch jr
    
//     ………… ？？？？？…………     // 请考虑以上三条指令的判断条件，
//                                // 以及三条指令的执行该给next_PC赋什么值
//    end
    
//   always @(negedge clock) begin  //（含J，Jal指令和reset的处理）
     
//     …………  ？？…………

//   end
endmodule
