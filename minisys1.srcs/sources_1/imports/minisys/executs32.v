`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module Executs32(Read_data_1,Read_data_2,Sign_extend,Function_opcode,Exe_opcode,ALUOp,
                 Shamt,ALUSrc,I_format,Zero,Sftmd,ALU_Result,Add_Result,PC_plus_4
                 );
    input[31:0]  Read_data_1;		//r-form rs
    input[31:0]  Read_data_2;		//r-form rt
    input[31:0]  Sign_extend;		//i-form
    input[5:0]   Function_opcode;  	//r-form instructions[5..0]
    input[5:0]   Exe_opcode;  		//op code instruction[31:26]
    input[1:0]   ALUOp;//从控制单元来的运算码，是R类型或者需要立即数的指令1位为1，beq\bne指令则0位为1
    input[4:0]   Shamt;//来自取值单元的instruction[10:6]，指定移位次数
    input  		 Sftmd;
    input        ALUSrc;
    input        I_format;
    output       Zero;//为1表明计算值为0
    output[31:0] ALU_Result;
    output[31:0] Add_Result;		//pc op  计算的地址结果      
    input[31:0]  PC_plus_4;
    
    reg[31:0] ALU_Result;
    wire[31:0] Ainput,Binput;//ALU两个输入口
    reg[31:0] Cinput,Dinput;//all,srl指令的结果暂存器
    reg[31:0] Einput,Finput;//allv,srlv指令的结果暂存器
    reg[31:0] Ginput,Hinput;//sra,srav指令的结果暂存器
    reg[31:0] Sinput;//以上六种以为指令的最终结果
    reg[31:0] ALU_output_mux;
    wire[32:0] Branch_Add;
    wire[2:0] ALU_ctl;
    wire[5:0] Exe_code;
    wire[2:0] Sftm;
    wire Sftmd;
    reg s;
    
    assign Sftm = Function_opcode[2:0];   // 实际有用的只有低三位(移位指令）
    
        //为beq,bne指令算地址
    assign Branch_Add = PC_plus_4[31:2] + Sign_extend[31:0];
    assign Add_Result = Branch_Add[31:0];   //算出的下一个PC值已经做了除4处理，所以不需左移16位
    //判断结果是否为0
    assign Zero = (ALU_output_mux[31:0]== 32'h00000000) ? 1'b1 : 1'b0;
    
    assign Ainput=Read_data_1;//为ALU的A端口赋值
    assign Binput=(ALUSrc==0)?Read_data_2:Sign_extend[31:0];//如果是I类型指令（除了beq\bne），B端口的值来自扩展的立即数，否则来自译码单元的Read_data_2
    
    always @*    //Sll逻辑左移指令执行
    begin
      case(Shamt)   //Sll rd,rt,shamt
        5'b00000:Cinput[31:0]=Binput[31:0]; //左移0位
        5'b00001:Cinput[31:0]={Binput[30:0],1'b0};//左移1位
        5'b00010:Cinput[31:0]={Binput[29:0],2'b00};
        5'b00011:Cinput[31:0]={Binput[28:0],3'b000};
        5'b00100:Cinput[31:0]={Binput[27:0],4'b0000};
        5'b00101:Cinput[31:0]={Binput[26:0],5'b00000};
        5'b00110:Cinput[31:0]={Binput[25:0],6'b000000};
        5'b00111:Cinput[31:0]={Binput[24:0],7'b0000000};
        5'b01000:Cinput[31:0]={Binput[23:0],8'b00000000};
        5'b01001:Cinput[31:0]={Binput[22:0],9'b000000000};
        5'b01010:Cinput[31:0]={Binput[21:0],10'b0000000000};
        5'b01011:Cinput[31:0]={Binput[20:0],11'b00000000000};
        5'b01100:Cinput[31:0]={Binput[19:0],12'b000000000000};
        5'b01101:Cinput[31:0]={Binput[18:0],13'b0000000000000};
        5'b01110:Cinput[31:0]={Binput[17:0],14'b00000000000000};
        5'b01111:Cinput[31:0]={Binput[16:0],15'b000000000000000};
        5'b10000:Cinput[31:0]={Binput[15:0],16'b0000000000000000};
        5'b10001:Cinput[31:0]={Binput[14:0],17'b00000000000000000};
        5'b10010:Cinput[31:0]={Binput[13:0],18'b000000000000000000};
        5'b10011:Cinput[31:0]={Binput[12:0],19'b0000000000000000000};
        5'b10100:Cinput[31:0]={Binput[11:0],20'b00000000000000000000};
        5'b10101:Cinput[31:0]={Binput[10:0],21'b000000000000000000000};
        5'b10110:Cinput[31:0]={Binput[9:0],22'b0000000000000000000000};
        5'b10111:Cinput[31:0]={Binput[8:0],23'b00000000000000000000000};
        5'b11000:Cinput[31:0]={Binput[7:0],24'b000000000000000000000000};
        5'b11001:Cinput[31:0]={Binput[6:0],25'b0000000000000000000000000};
        5'b11010:Cinput[31:0]={Binput[5:0],26'b00000000000000000000000000};
        5'b11011:Cinput[31:0]={Binput[4:0],27'b000000000000000000000000000};
        5'b11100:Cinput[31:0]={Binput[3:0],28'b0000000000000000000000000000};
        5'b11101:Cinput[31:0]={Binput[2:0],29'b00000000000000000000000000000};
        5'b11110:Cinput[31:0]={Binput[1:0],30'b000000000000000000000000000000};
        5'b11111:Cinput[31:0]={Binput[0],31'b0000000000000000000000000000000};
        default:Cinput[31:0]=Binput[31:0];
      endcase
    end
    
    always @*    //Srl逻辑右移指令执行
    begin
      case(Shamt)   //Srl rd,rt,shamt
        5'b00000:Dinput[31:0]=Binput[31:0]; //右移0位
        5'b00001:Dinput[31:0]={1'b0,Binput[30:0]};
        5'b00010:Dinput[31:0]={2'b00,Binput[29:0]};
        5'b00011:Dinput[31:0]={3'b000,Binput[28:0]};
        5'b00100:Dinput[31:0]={4'b0000,Binput[27:0]};
        5'b00101:Dinput[31:0]={5'b00000,Binput[26:0]};
        5'b00110:Dinput[31:0]={6'b000000,Binput[25:0]};
        5'b00111:Dinput[31:0]={7'b0000000,Binput[24:0]};
        5'b01000:Dinput[31:0]={8'b00000000,Binput[23:0]};
        5'b01001:Dinput[31:0]={9'b000000000,Binput[22:0]};
        5'b01010:Dinput[31:0]={10'b0000000000,Binput[21:0]};
        5'b01011:Dinput[31:0]={11'b00000000000,Binput[20:0]};
        5'b01100:Dinput[31:0]={12'b000000000000,Binput[19:0]};
        5'b01101:Dinput[31:0]={13'b0000000000000,Binput[18:0]};
        5'b01110:Dinput[31:0]={14'b00000000000000,Binput[17:0]};
        5'b01111:Dinput[31:0]={15'b000000000000000,Binput[16:0]};
        5'b10000:Dinput[31:0]={16'b0000000000000000,Binput[15:0]};
        5'b10001:Dinput[31:0]={17'b00000000000000000,Binput[14:0]};
        5'b10010:Dinput[31:0]={18'b000000000000000000,Binput[13:0]};
        5'b10011:Dinput[31:0]={19'b0000000000000000000,Binput[12:0]};
        5'b10100:Dinput[31:0]={20'b00000000000000000000,Binput[11:0]};
        5'b10101:Dinput[31:0]={21'b000000000000000000000,Binput[10:0]};
        5'b10110:Dinput[31:0]={22'b0000000000000000000000,Binput[9:0]};
        5'b10111:Dinput[31:0]={23'b00000000000000000000000,Binput[8:0]};
        5'b11000:Dinput[31:0]={24'b000000000000000000000000,Binput[7:0]};
        5'b11001:Dinput[31:0]={25'b0000000000000000000000000,Binput[6:0]};
        5'b11010:Dinput[31:0]={26'b00000000000000000000000000,Binput[5:0]};
        5'b11011:Dinput[31:0]={27'b000000000000000000000000000,Binput[4:0]};
        5'b11100:Dinput[31:0]={28'b0000000000000000000000000000,Binput[3:0]};
        5'b11101:Dinput[31:0]={29'b00000000000000000000000000000,Binput[2:0]};
        5'b11110:Dinput[31:0]={30'b000000000000000000000000000000,Binput[1:0]};
        5'b11111:Dinput[31:0]={31'b0000000000000000000000000000000,Binput[0]};
        default:Dinput[31:0]=Binput[31:0];
      endcase
    end
    
    
     always @*    //Sllv逻辑左移指令执行
    begin
      case(Ainput[4:0])   //Sllv rd,rt,rs
        5'b00000:Einput[31:0]=Binput[31:0]; //右移0位
        5'b00001:Einput[31:0]={Binput[30:0],1'b0};
        5'b00010:Einput[31:0]={Binput[29:0],2'b00};
        5'b00011:Einput[31:0]={Binput[28:0],3'b000};
        5'b00100:Einput[31:0]={Binput[27:0],4'b0000};
        5'b00101:Einput[31:0]={Binput[26:0],5'b00000};
        5'b00110:Einput[31:0]={Binput[25:0],6'b000000};
        5'b00111:Einput[31:0]={Binput[24:0],7'b0000000};
        5'b01000:Einput[31:0]={Binput[23:0],8'b00000000};
        5'b01001:Einput[31:0]={Binput[22:0],9'b000000000};
        5'b01010:Einput[31:0]={Binput[21:0],10'b0000000000};
        5'b01011:Einput[31:0]={Binput[20:0],11'b00000000000};
        5'b01100:Einput[31:0]={Binput[19:0],12'b000000000000};
        5'b01101:Einput[31:0]={Binput[18:0],13'b0000000000000};
        5'b01110:Einput[31:0]={Binput[17:0],14'b00000000000000};
        5'b01111:Einput[31:0]={Binput[16:0],15'b000000000000000};
        5'b10000:Einput[31:0]={Binput[15:0],16'b0000000000000000};
        5'b10001:Einput[31:0]={Binput[14:0],17'b00000000000000000};
        5'b10010:Einput[31:0]={Binput[13:0],18'b000000000000000000};
        5'b10011:Einput[31:0]={Binput[12:0],19'b0000000000000000000};
        5'b10100:Einput[31:0]={Binput[11:0],20'b00000000000000000000};
        5'b10101:Einput[31:0]={Binput[10:0],21'b000000000000000000000};
        5'b10110:Einput[31:0]={Binput[9:0],22'b0000000000000000000000};
        5'b10111:Einput[31:0]={Binput[8:0],23'b00000000000000000000000};
        5'b11000:Einput[31:0]={Binput[7:0],24'b000000000000000000000000};
        5'b11001:Einput[31:0]={Binput[6:0],25'b0000000000000000000000000};
        5'b11010:Einput[31:0]={Binput[5:0],26'b00000000000000000000000000};
        5'b11011:Einput[31:0]={Binput[4:0],27'b000000000000000000000000000};
        5'b11100:Einput[31:0]={Binput[3:0],28'b0000000000000000000000000000};
        5'b11101:Einput[31:0]={Binput[2:0],29'b00000000000000000000000000000};
        5'b11110:Einput[31:0]={Binput[1:0],30'b000000000000000000000000000000};
        5'b11111:Einput[31:0]={Binput[0],31'b0000000000000000000000000000000};
        default:Einput[31:0]=Binput[31:0];
      endcase
    end
    
     always @*    //Srlv逻辑右移指令执行
    begin
      case(Ainput[4:0])   //Srlv rd,rt,rs
        5'b00000:Finput[31:0]=Binput[31:0]; //右移0位
        5'b00001:Finput[31:0]={1'b0,Binput[30:0]};
        5'b00010:Finput[31:0]={2'b00,Binput[29:0]};
        5'b00011:Finput[31:0]={3'b000,Binput[28:0]};
        5'b00100:Finput[31:0]={4'b0000,Binput[27:0]};
        5'b00101:Finput[31:0]={5'b00000,Binput[26:0]};
        5'b00110:Finput[31:0]={6'b000000,Binput[25:0]};
        5'b00111:Finput[31:0]={7'b0000000,Binput[24:0]};
        5'b01000:Finput[31:0]={8'b00000000,Binput[23:0]};
        5'b01001:Finput[31:0]={9'b000000000,Binput[22:0]};
        5'b01010:Finput[31:0]={10'b0000000000,Binput[21:0]};
        5'b01011:Finput[31:0]={11'b00000000000,Binput[20:0]};
        5'b01100:Finput[31:0]={12'b000000000000,Binput[19:0]};
        5'b01101:Finput[31:0]={13'b0000000000000,Binput[18:0]};
        5'b01110:Finput[31:0]={14'b00000000000000,Binput[17:0]};
        5'b01111:Finput[31:0]={15'b000000000000000,Binput[16:0]};
        5'b10000:Finput[31:0]={16'b0000000000000000,Binput[15:0]};
        5'b10001:Finput[31:0]={17'b00000000000000000,Binput[14:0]};
        5'b10010:Finput[31:0]={18'b000000000000000000,Binput[13:0]};
        5'b10011:Finput[31:0]={19'b0000000000000000000,Binput[12:0]};
        5'b10100:Finput[31:0]={20'b00000000000000000000,Binput[11:0]};
        5'b10101:Finput[31:0]={21'b000000000000000000000,Binput[10:0]};
        5'b10110:Finput[31:0]={22'b0000000000000000000000,Binput[9:0]};
        5'b10111:Finput[31:0]={23'b00000000000000000000000,Binput[8:0]};
        5'b11000:Finput[31:0]={24'b000000000000000000000000,Binput[7:0]};
        5'b11001:Finput[31:0]={25'b0000000000000000000000000,Binput[6:0]};
        5'b11010:Finput[31:0]={26'b00000000000000000000000000,Binput[5:0]};
        5'b11011:Finput[31:0]={27'b000000000000000000000000000,Binput[4:0]};
        5'b11100:Finput[31:0]={28'b0000000000000000000000000000,Binput[3:0]};
        5'b11101:Finput[31:0]={29'b00000000000000000000000000000,Binput[2:0]};
        5'b11110:Finput[31:0]={30'b000000000000000000000000000000,Binput[1:0]};
        5'b11111:Finput[31:0]={31'b0000000000000000000000000000000,Binput[0]};
        default:Finput[31:0]=Binput[31:0];
      endcase
    end
    
    always @*    //Sra算术右移指令执行
    begin
    s=Binput[31];//提取操作数符号位，算术右移符号位要跟着一起右移，同时符号位还要保留
      case(Shamt)   //Sra rd,rt,shamt
        5'b00000:Ginput[31:0]=Binput[31:0]; //左移0位
        5'b00001:Ginput[31:0]={1'b0,Binput[30:0]};
        5'b00010:Ginput[31:0]={2'b00,Binput[29:0]};
        5'b00011:Ginput[31:0]={3'b000,Binput[28:0]};
        5'b00100:Ginput[31:0]={4'b0000,Binput[27:0]};
        5'b00101:Ginput[31:0]={5'b00000,Binput[26:0]};
        5'b00110:Ginput[31:0]={6'b000000,Binput[25:0]};
        5'b00111:Ginput[31:0]={7'b0000000,Binput[24:0]};
        5'b01000:Ginput[31:0]={8'b00000000,Binput[23:0]};
        5'b01001:Ginput[31:0]={9'b000000000,Binput[22:0]};
        5'b01010:Ginput[31:0]={10'b0000000000,Binput[21:0]};
        5'b01011:Ginput[31:0]={11'b00000000000,Binput[20:0]};
        5'b01100:Ginput[31:0]={12'b000000000000,Binput[19:0]};
        5'b01101:Ginput[31:0]={13'b0000000000000,Binput[18:0]};
        5'b01110:Ginput[31:0]={14'b00000000000000,Binput[17:0]};
        5'b01111:Ginput[31:0]={15'b000000000000000,Binput[16:0]};
        5'b10000:Ginput[31:0]={16'b0000000000000000,Binput[15:0]};
        5'b10001:Ginput[31:0]={17'b00000000000000000,Binput[14:0]};
        5'b10010:Ginput[31:0]={18'b000000000000000000,Binput[13:0]};
        5'b10011:Ginput[31:0]={19'b0000000000000000000,Binput[12:0]};
        5'b10100:Ginput[31:0]={20'b00000000000000000000,Binput[11:0]};
        5'b10101:Ginput[31:0]={21'b000000000000000000000,Binput[10:0]};
        5'b10110:Ginput[31:0]={22'b0000000000000000000000,Binput[9:0]};
        5'b10111:Ginput[31:0]={23'b00000000000000000000000,Binput[8:0]};
        5'b11000:Ginput[31:0]={24'b000000000000000000000000,Binput[7:0]};
        5'b11001:Ginput[31:0]={25'b0000000000000000000000000,Binput[6:0]};
        5'b11010:Ginput[31:0]={26'b00000000000000000000000000,Binput[5:0]};
        5'b11011:Ginput[31:0]={27'b000000000000000000000000000,Binput[4:0]};
        5'b11100:Ginput[31:0]={28'b0000000000000000000000000000,Binput[3:0]};
        5'b11101:Ginput[31:0]={29'b00000000000000000000000000000,Binput[2:0]};
        5'b11110:Ginput[31:0]={30'b000000000000000000000000000000,Binput[1:0]};
        5'b11111:Ginput[31:0]={31'b0000000000000000000000000000000,Binput[0]};
        default:Ginput[31:0]=Binput[31:0];
      endcase
    end
    
       always @*    //Srav算术右移指令执行
    begin
    s=Binput[31];//提取操作数符号位，算术右移符号位要跟着一起右移，同时符号位还要保留
      case(Ainput[4:0])   //Srav rd,rt,rs
        5'b00000:Hinput[31:0]=Binput[31:0]; //左移0位
        5'b00001:Hinput[31:0]={1'b0,Binput[30:0]};
        5'b00010:Hinput[31:0]={2'b00,Binput[29:0]};
        5'b00011:Hinput[31:0]={3'b000,Binput[28:0]};
        5'b00100:Hinput[31:0]={4'b0000,Binput[27:0]};
        5'b00101:Hinput[31:0]={5'b00000,Binput[26:0]};
        5'b00110:Hinput[31:0]={6'b000000,Binput[25:0]};
        5'b00111:Hinput[31:0]={7'b0000000,Binput[24:0]};
        5'b01000:Hinput[31:0]={8'b00000000,Binput[23:0]};
        5'b01001:Hinput[31:0]={9'b000000000,Binput[22:0]};
        5'b01010:Hinput[31:0]={10'b0000000000,Binput[21:0]};
        5'b01011:Hinput[31:0]={11'b00000000000,Binput[20:0]};
        5'b01100:Hinput[31:0]={12'b000000000000,Binput[19:0]};
        5'b01101:Hinput[31:0]={13'b0000000000000,Binput[18:0]};
        5'b01110:Hinput[31:0]={14'b00000000000000,Binput[17:0]};
        5'b01111:Hinput[31:0]={15'b000000000000000,Binput[16:0]};
        5'b10000:Hinput[31:0]={16'b0000000000000000,Binput[15:0]};
        5'b10001:Hinput[31:0]={17'b00000000000000000,Binput[14:0]};
        5'b10010:Hinput[31:0]={18'b000000000000000000,Binput[13:0]};
        5'b10011:Hinput[31:0]={19'b0000000000000000000,Binput[12:0]};
        5'b10100:Hinput[31:0]={20'b00000000000000000000,Binput[11:0]};
        5'b10101:Hinput[31:0]={21'b000000000000000000000,Binput[10:0]};
        5'b10110:Hinput[31:0]={22'b0000000000000000000000,Binput[9:0]};
        5'b10111:Hinput[31:0]={23'b00000000000000000000000,Binput[8:0]};
        5'b11000:Hinput[31:0]={24'b000000000000000000000000,Binput[7:0]};
        5'b11001:Hinput[31:0]={25'b0000000000000000000000000,Binput[6:0]};
        5'b11010:Hinput[31:0]={26'b00000000000000000000000000,Binput[5:0]};
        5'b11011:Hinput[31:0]={27'b000000000000000000000000000,Binput[4:0]};
        5'b11100:Hinput[31:0]={28'b0000000000000000000000000000,Binput[3:0]};
        5'b11101:Hinput[31:0]={29'b00000000000000000000000000000,Binput[2:0]};
        5'b11110:Hinput[31:0]={30'b000000000000000000000000000000,Binput[1:0]};
        5'b11111:Hinput[31:0]={31'b0000000000000000000000000000000,Binput[0]};
        default:Hinput[31:0]=Binput[31:0];
      endcase
    end
    

always @* begin  // 6种移位指令
       if(Sftmd)
        case(Sftm[2:0])
            3'b000:Sinput = Cinput;			   //Sll rd,rt,shamt  00000
            3'b010:Sinput = Dinput; 		       //Srl rd,rt,shamt  00010
            3'b100:Sinput = Einput;                   //Sllv rd,rt,rs 000100
            3'b110:Sinput = Finput;                   //Srlv rd,rt,rs 000110
            3'b011:Sinput = Ginput;         		//Sra rd,rt,shamt 00011
            3'b111:Sinput = Hinput;		        //Srav rd,rt,rs 00111
            default:Sinput = Binput;
        endcase
       else Sinput = Binput;
    end
    
    
assign Exe_code=(I_format==0)? Function_opcode:{3'b000,Exe_opcode[2:0]};
assign ALU_ctl[0]=(Exe_code[0]|Exe_code[3])&ALUOp[1];//生成一个组合码
assign ALU_ctl[1]=((!Exe_code[2])|(!ALUOp[1]));
assign ALU_ctl[2]=(Exe_code[1]&ALUOp[1])|ALUOp[0];
//assign ALU_ctl[3] = Exe_code[3] & ALUOp[1];     

    always @(ALU_ctl or Ainput or Binput) begin  //处理各类运算
        case(ALU_ctl)
            3'b000:ALU_output_mux = Ainput & Binput;//AND,ANDI
            3'b001:ALU_output_mux = Ainput | Binput;//OR, ORI
            3'b010:ALU_output_mux =  Ainput + Binput;//ADD,ADDI
            3'b011:ALU_output_mux = Ainput + Binput;//ADDU,ADDUI
            3'b100:ALU_output_mux = Ainput ^ Binput;//XOR,XORI
            3'b101:ALU_output_mux = ~(Ainput | Binput);//NOR
            3'b110:ALU_output_mux = Ainput - Binput;//SUB,BEQ,SLTI
            3'b111:ALU_output_mux = Ainput - Binput;//SUBU,SLT,SLTU,SLTIU
            default:ALU_output_mux = 32'h00000000;
        endcase
    end

    
assign Exe_code = (I_format==0) ? Function_opcode : {3'b000,Exe_opcode[2:0]};
assign Ainput = Read_data_1;
assign Binput = (ALUSrc == 0) ? Read_data_2 : Sign_extend[31:0]; //R/LW,SW  sft  else的时候含LW和SW
assign ALU_ctl[0] = (Exe_code[0] | Exe_code[3]) & ALUOp[1];      //24H AND 
assign ALU_ctl[1] = ((!Exe_code[2]) | (!ALUOp[1]));
assign ALU_ctl[2] = (Exe_code[1] & ALUOp[1]) | ALUOp[0];

 
 
    always @* begin
        if(((ALU_ctl==3'b111) && (Exe_code[3]==1))||((ALU_ctl[2:1]==2'b11) && (I_format==1))) //slti(sub)  处理所有SLT类的问题
            ALU_Result = {31'b0000000000000000000000000000000,ALU_output_mux[31]};
        else if((ALU_ctl==3'b101) && (I_format==1)) //处理lui指令
            ALU_Result[31:0] = {Binput[15:0],16'b0000000000000000}  ;
        else if(Sftmd==1) ALU_Result = Sinput  ; //移位指令
        else  ALU_Result = ALU_output_mux[31:0]; //otherwise
    end
 
endmodule
    