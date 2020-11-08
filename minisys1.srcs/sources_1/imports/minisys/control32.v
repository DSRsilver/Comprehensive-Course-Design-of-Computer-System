`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module control32(Opcode,Function_opcode,Jrn,RegDST,ALUSrc,MemtoReg,RegWrite,MemWrite,Branch,nBranch,Jmp,Jal,I_format,Sftmd,ALUOp);
    input[5:0]   Opcode;            // 来自取指单元instruction[31..26]
    input[5:0]   Function_opcode;  	// r-form instructions[5..0]
    output       Jrn;
    output       RegDST;
    output       ALUSrc;            // 决定第二个操作数是寄存器还是立即数
    output       MemtoReg;
    output       RegWrite;
    output       MemWrite;
    output       Branch;
    output       nBranch;
    output       Jmp;
    output       Jal;
    output       I_format;
    output       Sftmd;
    output[1:0]  ALUOp;
     
    wire Jmp,I_format,Jal,Branch,nBranch;
    wire R_format,Lw,Sw;
    wire sll_srl_sra;
   
    assign R_format = (Opcode==6'b000000)? 1'b1:1'b0;    	//--00h 
    assign RegDST = R_format;                               //说明目标是rd，否则是rt
    
    assign Jrn=(Opcode==6'b000000&&Function_opcode==6'b001000)?1'b1:1'b0;
    assign Jmp=(Opcode==6'b000010)?1'b1:1'b0;
    assign Jal=(Opcode==6'b000011)?1'b1:1'b0;
//    assign I_format=(Opcode===6'b001xxx)?1'b1:1'b0;
    assign I_format=(Opcode==6'b001000||Opcode==6'b001001||Opcode==6'b001100||Opcode==6'b001101||Opcode==6'b001110||Opcode==6'b001111||Opcode==6'b001010||Opcode==6'b001011)?1'b1:1'b0;
    assign Lw=(Opcode==6'b100011)?1'b1:1'b0;
    assign Sw=(Opcode==6'b101011)?1'b1:1'b0;
    assign Branch=(Opcode==6'b000100)?1'b1:1'b0;
    assign nBranch=(Opcode==6'b000101)?1'b1:1'b0;
    assign MemtoReg=Lw;
    assign MemWrite=Sw;
    assign RegWrite=I_format||Lw|||Jal||Jrn||(R_format&&(!Jrn));
//    assign sll_srl_sra=(Opcode==6'b000000&&Function_opcode===6'b0000xx)?1'b1:1'b0;
    assign sll_srl_sra=(Opcode==6'b000000&&(Function_opcode==6'b000000||Function_opcode==6'b000010||Function_opcode==6'b000011))?1'b1:1'b0;
    assign ALUSrc=sll_srl_sra||I_format||Lw||Sw;
//    assign Sftmd=(Opcode==6'b000000&&Function_opcode===6'b000xxx)?1'b1:1'b0;
    assign Sftmd=(Opcode==6'b000000&&(Function_opcode==6'b000000||Function_opcode==6'b000010||Function_opcode==6'b000011||Function_opcode==6'b000100||Function_opcode==6'b000110||Function_opcode==6'b000111))?1'b1:1'b0;
    assign ALUOp={(R_format||I_format),(Branch||nBranch)};
//    assign ALUOp[1]=(R_format==1||I_format==1)?1'b1:1'b0;
//    assign ALUOp[0]=(Branch==1||nBranch==1)?1'b1:1'b0;
//    always @* begin
//        if(Lw==1||Sw==1)    
//            ALUOp = 2'b00;
//        else if(Branch==1||nBranch==1)
//            ALUOp=2'b01;
//        else if(R_format==1||I_format==1)    ALUop=2'b10;
//        else ALUOp=2'b00;
//    end



endmodule