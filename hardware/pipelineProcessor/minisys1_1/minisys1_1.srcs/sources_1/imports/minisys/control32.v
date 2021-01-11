`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
 module control32(clock,reset,Opcode,Function_opcode,
 Alu_resultHigh,Jrn,Jalr,RegDST,ALUSrc,MemorIOtoReg,IORead,IOWrite,RegWrite,MemRead,
 MemWrite,Branch,nBranch,bgez,bgtz,blez,bltz,bgezal,bltzal,Lb,Lbu,Lh,Lhu,Lw,Sb,Sh,Sw,Jmp,Jal,I_format,Sftmd,ALUOp,w_hi,w_lo,rt,r_hi,r_lo);
    
    input clock;
    input reset;
    input[5:0]   Opcode;            // 来自取指单元instruction[31..26]
    input[5:0]   Function_opcode;  	// r-form instructions[5..0]
    input[21:0]  Alu_resultHigh;     //来自执行单元Alu_result[31:10]
    input[4:0]   rt; //用于区分bgez\bgtz\blez等指令
    
    output       Jrn;
    output       Jalr;
    output       RegDST;            //为1说明目标是rd(R-format)，否则是rt
    output       ALUSrc;            // 决定第二个操作数是寄存器还是立即数,是立即数则为1
    output       MemorIOtoReg;    //有IO
    output       IORead;          //有IO
    output       IOWrite;         //有IO
    output       RegWrite;
    output       MemWrite;
    output       MemRead;
    output       Branch;
    output       nBranch;
    output       bgez;
    output       bgtz;
    output       blez;
    output       bltz;
    output       bgezal;
    output       bltzal;
    output       Lb,Lbu,Lh,Lhu,Sb,Sh,Lw,Sw;
    output       Jmp;
    output       Jal;
    output       I_format;
    output       Sftmd;
    output[1:0]  ALUOp;
    output       w_hi;
    output       w_lo;
    output       r_hi;
    output       r_lo;
     
    wire Jmp,I_format,Jal,Branch,nBranch;
    wire R_format,Lw,Sw;
    wire Lb,Lbu,Lh,Lhu,Sb,Sh;
    
    assign R_format = (Opcode==6'b000000)? 1'b1:1'b0;    	//--00h     
    assign I_format=(Opcode==6'b001000||Opcode==6'b001001||Opcode==6'b001100||Opcode==6'b001101
        ||Opcode==6'b001110||Opcode==6'b001111||Opcode==6'b001010||Opcode==6'b001011)?1'b1:1'b0;//addi,addiu,andi,ori,xori,lui,slti,sltiu  
    assign Lw=(Opcode==6'b100011)?1'b1:1'b0;
    assign Sw=(Opcode==6'b101011)?1'b1:1'b0; 
    assign Lb=(Opcode==6'b100000)?1'b1:1'b0;
    assign Lbu=(Opcode==6'b100100)?1'b1:1'b0;
    assign Lh=(Opcode==6'b100001)?1'b1:1'b0; 
    assign Lhu=(Opcode==6'b100101)?1'b1:1'b0;
    assign Sb=(Opcode==6'b101000)?1'b1:1'b0; 
    assign Sh=(Opcode==6'b101001)?1'b1:1'b0;
    
    
     //取指
    assign Jrn=(Opcode==6'b000000&&Function_opcode==6'b001000)?1'b1:1'b0;
    assign Jalr=(Opcode==6'b000000&&Function_opcode==6'b001001)?1'b1:1'b0;
    assign Jmp=(Opcode==6'b000010)?1'b1:1'b0;
    assign Jal=(Opcode==6'b000011)?1'b1:1'b0;
    
    //执行
    assign ALUSrc=I_format||Lw||Sw||Lb||Lbu||Lh||Lhu||Sb||Sh;
    assign Sftmd=(Opcode==6'b000000&&(Function_opcode==6'b000000||Function_opcode==6'b000010||Function_opcode==6'b000011
            ||Function_opcode==6'b000100||Function_opcode==6'b000110||Function_opcode==6'b000111))?1'b1:1'b0;
    assign ALUOp={(R_format||I_format),(Branch||nBranch)};    
    assign Branch=(Opcode==6'b000100)?1'b1:1'b0;
    assign nBranch=(Opcode==6'b000101)?1'b1:1'b0;
    assign bgez=(Opcode==6'b000001&&rt==5'b00001)?1'b1:1'b0;
    assign bgtz=(Opcode==6'b000111&&rt==5'b00000)?1'b1:1'b0;
    assign blez=(Opcode==6'b000110&&rt==5'b00000)?1'b1:1'b0;
    assign bltz=(Opcode==6'b000001&&rt==5'b00000)?1'b1:1'b0;
    assign bgezal=(Opcode==6'b000001&&rt==5'b10001)?1'b1:1'b0;
    assign bltzal=(Opcode==6'b000001&&rt==5'b10000)?1'b1:1'b0;
    
    
    //存储
    assign MemWrite=((Sw==1)||(Sb==1)||(Sh==1))&&(Alu_resultHigh[21:0]!=22'b1111_1111_1111_1111_1111_11);
    assign MemRead=((Lw==1)||(Lb==1)||(Lbu==1)||(Lh==1)||(Lhu==1))&&(Alu_resultHigh[21:0]!=22'b1111_1111_1111_1111_1111_11);
    assign MemorIOtoReg=(IORead||MemRead);   
    assign IOWrite=(Sw==1)&&(Alu_resultHigh[21:0]==22'b1111_1111_1111_1111_1111_11);   
    assign IORead=(Lw==1)&&(Alu_resultHigh[21:0]==22'b1111_1111_1111_1111_1111_11);
    
     
    //写回
    assign RegWrite=I_format||Lw|Lb||Lbu||Lh||Lhu||Jal||Jalr||bgezal||bltzal||(R_format&&(!Jrn));
    assign RegDST=(R_format&&(!Jrn));//说明目标是rd，否则是rt
    assign w_hi=(Opcode==6'b000000&&(Function_opcode==6'b010001||
        Function_opcode==6'b011000||Function_opcode==6'b011001||Function_opcode==6'b011010||Function_opcode==6'b011011))?1'b1:1'b0;//mthi,mult,multu,div,divu
    assign w_lo=(Opcode==6'b000000&&(Function_opcode==6'b010011||
        Function_opcode==6'b011000||Function_opcode==6'b011001||Function_opcode==6'b011010||Function_opcode==6'b011011))?1'b1:1'b0;//mtlo,mult,multu,div,divu
    assign r_hi=(Opcode==6'b000000&&Function_opcode==6'b010000)?1'b1:1'b0;   
    assign r_lo=(Opcode==6'b000000&&Function_opcode==6'b010010)?1'b1:1'b0;
   

endmodule  