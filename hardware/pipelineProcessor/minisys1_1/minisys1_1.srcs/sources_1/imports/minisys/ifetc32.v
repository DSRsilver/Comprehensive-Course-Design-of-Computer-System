`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module Ifetc32 (reset,clock,Instruction,PC_out,Add_result,Read_data_1,Branch,nBranch,Zero,Jmp,Jal,Jalr,stall,
Jrn,rom_adr_o,Jpadr,bgez,bgtz,blez,bltz,bgezal,bltzal,compare,instruction_in,PC_plus_4_out);

	input			reset;				// ��λ�ź�(�ߵ�ƽ��Ч)
    input			clock;				// ʱ��(23MHz)
    input	[31:0]	Add_result;		// ����ִ�е�Ԫ,�������ת��ַ
    input	[31:0]	Read_data_1;		// �������뵥Ԫ��jrָ���õĵ�ַ
    input			Branch;			// ���Կ��Ƶ�Ԫ
    input			nBranch;			// ���Կ��Ƶ�Ԫ
    input			Zero;				// ����ִ�е�Ԫ
    input			Jmp;				// ���Կ��Ƶ�Ԫ
    input			Jal;				// ���Կ��Ƶ�Ԫ
    input			Jalr;                //���Կ��Ƶ�Ԫ
    input			Jrn;				// ���Կ��Ƶ�Ԫ
	input	[31:0]	Jpadr;		// �ӳ���ROM��Ԫ�л�ȡ��ָ��
    input           bgez;
    input           bgtz;
    input           blez;
    input           bltz;
    input           bgezal;
    input           bltzal;
    input[1:0]      compare;
 //   input[31:0]     pc_in;
    input[31:0]     instruction_in;
    input           stall;
	
    
	output	[31:0]	Instruction;		// ���ָ�����ģ��
	output [31:0]	PC_out;
    output	[31:0]	PC_plus_4_out;		// (pc+4)��ִ�е�Ԫ
//    output[31:0]	opcplus4;			// JALָ��ר�õ�PC+4
    // ROM Pinouts
	output	[13:0]	rom_adr_o;			// ������ROM��Ԫ��ȡָ��ַ

    
    wire [31:0] PC_plus_4;
    reg [31:0] PC;
    reg [31:0] PC_plus_4_out;
   // reg [31:0] next_PC;		// ����ָ���PC����һ����PC+4)
//    reg [31:0] opcplus4;
    
	// ROM Pinouts
	assign rom_adr_o = PC[15:2];
//	assign Instruction = Jpadr;
    
       reg[31:0] IR;
       
    //������ֵ�ͷ�������ֵ
    //���ir�÷�����<=�� PC={4'b0000,IR[25:0],2'b00};������һ������
    always @ (*) begin
        if(reset)begin
            IR=0;
        end else  begin
            IR=Jpadr;
        end
    end
    
    always @ (negedge clock) begin
        if(reset) begin
            PC<=32'b0;
        end else if(stall==0)begin
//            if(((bgezal==1)&&((compare==2'b10)||(compare==2'b00)))||((bltzal==1)&&(compare==2'b01))) begin
//                PC<=Add_result;//bgezal,bltzal
//            end  else
            if(((Branch==1)&&(Zero==1))||((nBranch==1)&&(Zero==0))
                           ||((bgez==1)&&((compare==2'b10)||(compare==2'b00)))||((bgtz==1)&&(compare==2'b10))
                           ||((blez==1)&&((compare==2'b01)||(compare==2'b00)))||((bltz==1)&&(compare==2'b10))
                           ||((bgezal==1)&&((compare==2'b10)||(compare==2'b00)))||((bltzal==1)&&(compare==2'b01))) begin
                 PC<=Add_result;//beq,bne,bgez,bgtz,blez,bltz
            end else if(Jmp==1||Jal==1)begin
     //            opcplus4<=pc_in[31:0];
                 PC<={4'b0000,instruction_in[25:0],2'b00};//jmp,jal
            end else if(Jrn==1||Jalr==1)begin
                 PC<=Read_data_1[31:0];//jrn,jalr
//            end else if(Jalr==1)begin
//     //            opcplus4<=pc_in[31:0];
//                 PC<=Read_data_1[31:0];//jalr
            end  else begin
                 PC<=PC_plus_4;
            end
        end
                // PC<=PC_plus_4_out;//pc+4
    end
    always @ (negedge clock) begin
        PC_plus_4_out=PC_plus_4[31:0];
    end
    
    assign PC_out=PC[31:0]; 
   // assign PC_plus_4_out=PC;    
 //   assign PC_plus_4_out=PC_plus_4[31:0];    
    assign PC_plus_4[31:2]=PC[31:2]+30'b001;
    assign PC_plus_4[1:0]=2'b00;
    assign Instruction=IR;
//	assign PC_plus_4[31:2] =������
//	assign PC_plus_4[1:0] =������
//	assign PC_plus_4_out = PC_plus_4[31:0];  

//    always @* begin  // beq $n ,$m if $n=$m branch   bne if $n /=$m branch jr
    
//     �������� ������������������     // �뿼����������ָ����ж�������
//                                // �Լ�����ָ���ִ�иø�next_PC��ʲôֵ
//    end
    
//   always @(negedge clock) begin  //����J��Jalָ���reset�Ĵ���
      
//     ��������  ������������

//   end
endmodule
