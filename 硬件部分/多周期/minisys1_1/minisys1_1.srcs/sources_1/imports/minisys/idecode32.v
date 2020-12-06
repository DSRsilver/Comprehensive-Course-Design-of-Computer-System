`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module Idecode32(read_data_1,read_data_2,Instruction,read_data,ALU_result,
                 Jal,RegWrite,MemorIOtoReg,RegDst,Sign_extend,clock,reset,
                 opcplus4,read_register_1_address);
    output[31:0] read_data_1;
    output[31:0] read_data_2;
    input[31:0]  Instruction;//����ȡָģ��
    input[31:0]  read_data;   				//  ��DATA RAM or I/O portȡ��������
    input[31:0]  ALU_result;   				//  ��Ҫ��չ��������32λ
    input        Jal; 
    input        RegWrite;
    input        MemorIOtoReg;
    input        RegDst;
    output[31:0] Sign_extend;
    input		 clock,reset;
    input[31:0]  opcplus4;                 // ����ȡָ��Ԫ��JAL����
    output[4:0] read_register_1_address;
    
    

    
    wire[31:0] read_data_1;
    wire[31:0] read_data_2;
    reg[31:0] register[0:31];			   //�Ĵ����鹲32��32λ�Ĵ���

   
    reg[4:0] write_register_address;
    reg[31:0] write_data;
    wire[4:0] read_register_1_address,read_register_2_address;//1_rs  2_rt
    wire[4:0] write_register_address_1;//rd(r-form)
    wire[4:0] write_register_address_0;//rt(i-form)
    wire[15:0] Instruction_immediate_value;
    wire[5:0] opcode;//op
    wire sign;
    

    assign opcode=Instruction[31:26];
    assign read_register_1_address=Instruction[25:21];
    assign read_register_2_address=Instruction[20:16];
    assign write_register_address_1=Instruction[15:11];
    assign write_register_address_0=Instruction[20:16];
    assign Instruction_immediate_value=Instruction[15:0];
    
    assign sign=Instruction_immediate_value[15];
    assign Sign_extend[31:0]=((opcode==6'b001100)
    ||(opcode==6'b001110)
    ||(opcode==6'b001101)
    ||(opcode==6'b001011))?{16'h0000,Instruction_immediate_value[15:0]}//������0��չ
    :{sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,
    Instruction_immediate_value[15:0]};
    
    assign read_data_1 = register[read_register_1_address];
    assign read_data_2 = register[read_register_2_address];

   always  @*//�������ָ����ָͬ���µ�Ŀ��Ĵ���
   begin
   if((RegDst==1)&&(Jal==0))
     write_register_address=write_register_address_1;
   else if ((RegDst==0)&&(Jal==1))
   write_register_address=5'b11111;
   else
     write_register_address=write_register_address_0;
  
   end
   
                                              
    
    always @* begin  //������̻�������ʵ�ֽṹͼ�����µĶ�·ѡ����,׼��Ҫд������
      if((MemorIOtoReg==0)&&(Jal==0))
       write_data=ALU_result[31:0];
      else if ((MemorIOtoReg==0)&&(Jal==1))
      begin
        write_data[31:0]=opcplus4[31:0];
      end
     else write_data=read_data;
     end    
    integer i;
    always @(posedge clock) begin       // ������дĿ��Ĵ���
        if(reset==1) begin              // �����Ĵ�����
            for(i=0;i<32;i=i+1) register[i]<=i;
        end
       else if(RegWrite==1) begin  // ע��Ĵ���0�����0
       if(write_register_address!=0) begin
       register[write_register_address]<=write_data;
       end
        end
    end
endmodule
