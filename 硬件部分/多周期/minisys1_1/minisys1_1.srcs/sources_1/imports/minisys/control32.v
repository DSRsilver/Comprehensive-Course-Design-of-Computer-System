`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
 module control32(clock,reset,Zero,Wpc,Wir,Waluresult,Opcode,Function_opcode,Alu_resultHigh,Jrn,RegDST,ALUSrc,MemorIOtoReg,IORead,IOWrite,RegWrite,MemRead,MemWrite,Branch,nBranch,Jmp,Jal,I_format,Sftmd,ALUOp);
    
    input clock;
    input reset;
    input Zero;
    output[1:0] Wpc;        //Ϊ1��Ҫ�޸�PC��д�ź�
    output Wir;             //��ҪдIR���ź�
    output Waluresult;      //дaluresult���ź�
    
    input[5:0]   Opcode;            // ����ȡָ��Ԫinstruction[31..26]
    input[5:0]   Function_opcode;  	// r-form instructions[5..0]
    input[21:0] Alu_resultHigh;     //����ִ�е�ԪAlu_result[31:10]
    output       Jrn;
    output       RegDST;
    output       ALUSrc;            // �����ڶ����������ǼĴ�������������
    output       MemorIOtoReg;    //��IO
    output       IORead;          //��IO
    output       IOWrite;         //��IO
    output       RegWrite;
    output       MemWrite;
    output       MemRead;
    output       Branch;
    output       nBranch;
    output       Jmp;
    output       Jal;
    output       I_format;
    output       Sftmd;
    output[1:0]  ALUOp;
     
    wire Jmp,I_format,Jal,Branch,nBranch;
    wire R_format,Lw,Sw;
    
    reg[2:0] next_state;
    reg[2:0] state;
    
    parameter[2:0] sinit=3'b000,//��ʼ״̬
                    sif=3'b001,//1
                    sid=3'b011,//3
                    sexe=3'b010,//2
                    smem=3'b110,//6
                    swb=3'b100;//4
     
    //״̬��              
    always @ (posedge clock or posedge reset)begin
        if(reset)begin
            state<=sinit;
        end else begin
            state<=next_state;
        end
    end 
    
    always @ *begin
        case(state)
        sinit:begin
                next_state=sif; 
             end
        sif:begin
                next_state=sid;
            end
        sid:begin
                if(Jrn==1||Jmp==1||Jal==1)begin       //j��ָ��
                    next_state=sif;
                end else begin
                    next_state=sexe;           //����ָ���µ�״̬�ı�
                end
            end
        sexe:begin
                if((Branch==1)&&(Zero==1)||(nBranch==1)&&(Zero==0))begin       //bne,beq
                    next_state=sif;
                end else if(Lw==1||Sw==1) begin     //lw,sw
                    next_state=smem;
                end else begin          //����ָ���µ�״̬�ı�
                    next_state=swb;
                end    
             end
        smem:begin
                if(Lw==1)begin       //lw
                    next_state=swb;
                end else begin      //����ָ���µ�״̬�ı�
                    next_state=sif;
                end
             end
        swb:begin
                next_state=sif;
            end
        default:begin
                    next_state=sinit;
                 end
        endcase
    end   
    
    //����״̬�������
    assign Wir=(state==sif);
    assign Wpc={((state==sid)&&(Jmp==1||Jrn==1||Jal==1))||((state==sexe)&&((Branch==1)&&(Zero==1)||(nBranch==1)&&(Zero==0))),
                    (state==sif)||((state==sexe)&&((Branch==1)&&(Zero==1)||(nBranch==1)&&(Zero==0)))};
    assign Waluresult=(state==sexe);//ʲô״̬
    assign RegWrite=(state==swb)||((state==sid)&&(Jal==1));//sid״̬����Ч������jal==1
    assign MemWrite=(state==smem)&&(Sw==1)&&(Alu_resultHigh[21:0]!=22'b1111_1111_1111_1111_1111_11);
    assign MemRead=((state==smem)||(state==swb))&&(Lw==1)&&(Alu_resultHigh[21:0]!=22'b1111_1111_1111_1111_1111_11);//��״̬����״̬�Ƿ��йأ�
    assign MemorIOtoReg=(IORead||MemRead);   //��IO////���ڴ洢�׶λ���д�ؽ׶Σ�
    assign IOWrite=(state==smem)&&(Sw==1)&&(Alu_resultHigh[21:0]==22'b1111_1111_1111_1111_1111_11);    //��IO
    assign IORead=((state==smem)||(state==swb))&&(Lw==1)&&(Alu_resultHigh[21:0]==22'b1111_1111_1111_1111_1111_11);//��״̬����״̬�Ƿ��йأ�
    assign RegDST=(state==swb)&&(R_format==1);//д�ؽ׶Σ�����׶Σ�//˵��Ŀ����rd��������rt
    
   //ԭ�����ڲ���
    assign R_format = (Opcode==6'b000000)? 1'b1:1'b0;    	//--00h     
    assign Jrn=(Opcode==6'b000000&&Function_opcode==6'b001000)?1'b1:1'b0;
    assign Jmp=(Opcode==6'b000010)?1'b1:1'b0;
    assign Jal=(Opcode==6'b000011)?1'b1:1'b0;
    assign I_format=(Opcode==6'b001000||Opcode==6'b001001||Opcode==6'b001100||Opcode==6'b001101||Opcode==6'b001110||Opcode==6'b001111||Opcode==6'b001010||Opcode==6'b001011)?1'b1:1'b0;
    assign Lw=(Opcode==6'b100011)?1'b1:1'b0;
    assign Sw=(Opcode==6'b101011)?1'b1:1'b0;
    assign Branch=(Opcode==6'b000100)?1'b1:1'b0;
    assign nBranch=(Opcode==6'b000101)?1'b1:1'b0;
    assign ALUSrc=I_format||Lw||Sw;
    assign Sftmd=(Opcode==6'b000000&&(Function_opcode==6'b000000||Function_opcode==6'b000010||Function_opcode==6'b000011||Function_opcode==6'b000100||Function_opcode==6'b000110||Function_opcode==6'b000111))?1'b1:1'b0;
    assign ALUOp={(R_format||I_format),(Branch||nBranch)};



endmodule  