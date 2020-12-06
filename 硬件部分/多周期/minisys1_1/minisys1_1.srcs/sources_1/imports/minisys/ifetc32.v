`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module Ifetc32 (Wpc,Wir,reset,clock,Instruction,PC_out,PC_plus_4_out,Add_result,Read_data_1,Jmp,Jal,opcplus4,rom_adr_o,Jpadr);

    input[1:0]   Wpc;
    input        Wir;

	input			reset;				// ��λ�ź�(�ߵ�ƽ��Ч)
    input			clock;				// ʱ��(23MHz)
	output	[31:0]	Instruction;		// ���ָ�����ģ��
	output [31:0]  PC_out;
    output	[31:0]	PC_plus_4_out;		// (pc+4)��ִ�е�Ԫ
    input	[31:0]	Add_result;		// ����ִ�е�Ԫ,�������ת��ַ
    input	[31:0]	Read_data_1;		// �������뵥Ԫ��jrָ���õĵ�ַ
//    input			Branch,				// ���Կ��Ƶ�Ԫ
//    input			nBranch,			// ���Կ��Ƶ�Ԫ
    input			Jmp;				// ���Կ��Ƶ�Ԫ
    input			Jal;				// ���Կ��Ƶ�Ԫ
//    input			Jrn,				// ���Կ��Ƶ�Ԫ
//    input			Zero,				// ����ִ�е�Ԫ
    output [31:0]	opcplus4;			// JALָ��ר�õ�PC+4
    // ROM Pinouts
	output	[13:0]	rom_adr_o;			// ������ROM��Ԫ��ȡָ��ַ
	input	[31:0]	Jpadr;		// �ӳ���ROM��Ԫ�л�ȡ��ָ��

    
    wire [31:0] PC_plus_4;
    reg [31:0] PC;
    reg [31:0] next_PC;		// ����ָ���PC����һ����PC+4)
    reg [31:0] opcplus4;
    
	// ROM Pinouts
	assign rom_adr_o = PC[15:2];
//	assign Instruction = Jpadr;
    
       reg[31:0] IR;
       
    //������ֵ�ͷ�������ֵ
    //���ir�÷�����<=�� PC={4'b0000,IR[25:0],2'b00};������һ������
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
