`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module Executs32(clock,reset,Waluresult,Read_data_1,Read_data_2,Sign_extend,Function_opcode,Exe_opcode,ALUOp,
                 Shamt,ALUSrc,I_format,Jrn,Zero,Sftmd,ALU_Result,Add_Result,PC_plus_4
                 );
    input        clock;
    input        reset;
    input        Waluresult;
    input[31:0]  Read_data_1;		//r-form rs// 从译码单元的Read_data_1中来
    input[31:0]  Read_data_2;		//r-form rt// 从译码单元的Read_data_2中来
    input[31:0]  Sign_extend;		//i-form// 从译码单元来的扩展后的立即数
    input[5:0]   Function_opcode;  	//r-form instructions[5..0]// 取指单元来的r-类型指令功能码,r-form instructions[5:0]
    input[5:0]   Exe_opcode;  		//op code instruction[31:26]// 取指单元来的操作码
    input[1:0]   ALUOp;//从控制单元来的运算码，是R类型或者需要立即数的指令1位为1，beq\bne指令则0位为1// 来自控制单元的运算指令控制编码
    input[4:0]   Shamt;//来自取值单元的instruction[10:6]，指定移位次数// 来自取指单元的instruction[10:6]，指定移位次数
    input  		 Sftmd;// 来自控制单元的，表明是移位指令
    input        ALUSrc;// 来自控制单元，表明第二个操作数是立即数（beq，bne除外）
    input        I_format;// 来自控制单元，表明是除beq, bne, LW, SW之外的I-类型指令
    input        Jrn;// 来自控制单元，书名是JR指令
    output       Zero;//为1表明计算值为0
    output[31:0] ALU_Result;        // 计算的数据结果
    output[31:0] Add_Result;		//pc op  计算的地址结果      
    input[31:0]  PC_plus_4;         // 来自取指单元的PC+4
    
    reg[31:0] ALU_Result;
    wire[31:0] Ainput,Binput;//ALU两个输入口
    reg[31:0] Cinput,Dinput;//all,srl指令的结果暂存器
    reg[31:0] Einput,Finput;//allv,srlv指令的结果暂存器
    reg[31:0] Ginput,Hinput;//sra,srav指令的结果暂存器
    reg[31:0] Sinput;//以上六种以为指令的最终结果
    reg[31:0] ALU_output_mux;
    wire[2:0] ALU_ctl;
    wire[5:0] Exe_code;
    wire[2:0] Sftm;
   // wire[32:0] Branch_Add;
    wire Sftmd;
    reg s;
    
    assign Sftm = Function_opcode[2:0];   // 实际有用的只有低三位(移位指令）
    assign Exe_code = (I_format==0) ? Function_opcode : {3'b000,Exe_opcode[2:0]};
    assign Ainput = Read_data_1;
    assign Binput = (ALUSrc == 0) ? Read_data_2 : Sign_extend[31:0]; //R/LW,SW  sft  else的时候含LW和SW
    assign ALU_ctl[0] = (Exe_code[0] | Exe_code[3]) & ALUOp[1];      //24H AND 
    assign ALU_ctl[1] = ((!Exe_code[2]) | (!ALUOp[1]));
    assign ALU_ctl[2] = (Exe_code[1] & ALUOp[1]) | ALUOp[0];
 
    integer i;
    always @*    //Sll逻辑左移指令执行
    begin
        for(i=0;i<32;i=i+1)begin
            if(i<Shamt) Cinput[i]<=0;
            else    Cinput[i]<=Binput[i-Shamt];
        end
//      case(Shamt)   //Sll rd,rt,shamt
//        5'b00000:Cinput[31:0]=Binput[31:0]; //左移0位
//        5'b00001:Cinput[31:0]={Binput[30:0],1'b0};//左移1位
//        5'b00010:Cinput[31:0]={Binput[29:0],2'b00};
//        5'b00011:Cinput[31:0]={Binput[28:0],3'b000};
//        5'b00100:Cinput[31:0]={Binput[27:0],4'b0000};
//        5'b00101:Cinput[31:0]={Binput[26:0],5'b00000};
//        5'b00110:Cinput[31:0]={Binput[25:0],6'b000000};
//        5'b00111:Cinput[31:0]={Binput[24:0],7'b0000000};
//        5'b01000:Cinput[31:0]={Binput[23:0],8'b00000000};
//        5'b01001:Cinput[31:0]={Binput[22:0],9'b000000000};
//        5'b01010:Cinput[31:0]={Binput[21:0],10'b0000000000};
//        5'b01011:Cinput[31:0]={Binput[20:0],11'b00000000000};
//        5'b01100:Cinput[31:0]={Binput[19:0],12'b000000000000};
//        5'b01101:Cinput[31:0]={Binput[18:0],13'b0000000000000};
//        5'b01110:Cinput[31:0]={Binput[17:0],14'b00000000000000};
//        5'b01111:Cinput[31:0]={Binput[16:0],15'b000000000000000};
//        5'b10000:Cinput[31:0]={Binput[15:0],16'b0000000000000000};
//        5'b10001:Cinput[31:0]={Binput[14:0],17'b00000000000000000};
//        5'b10010:Cinput[31:0]={Binput[13:0],18'b000000000000000000};
//        5'b10011:Cinput[31:0]={Binput[12:0],19'b0000000000000000000};
//        5'b10100:Cinput[31:0]={Binput[11:0],20'b00000000000000000000};
//        5'b10101:Cinput[31:0]={Binput[10:0],21'b000000000000000000000};
//        5'b10110:Cinput[31:0]={Binput[9:0],22'b0000000000000000000000};
//        5'b10111:Cinput[31:0]={Binput[8:0],23'b00000000000000000000000};
//        5'b11000:Cinput[31:0]={Binput[7:0],24'b000000000000000000000000};
//        5'b11001:Cinput[31:0]={Binput[6:0],25'b0000000000000000000000000};
//        5'b11010:Cinput[31:0]={Binput[5:0],26'b00000000000000000000000000};
//        5'b11011:Cinput[31:0]={Binput[4:0],27'b000000000000000000000000000};
//        5'b11100:Cinput[31:0]={Binput[3:0],28'b0000000000000000000000000000};
//        5'b11101:Cinput[31:0]={Binput[2:0],29'b00000000000000000000000000000};
//        5'b11110:Cinput[31:0]={Binput[1:0],30'b000000000000000000000000000000};
//        5'b11111:Cinput[31:0]={Binput[0],31'b0000000000000000000000000000000};
//        default:Cinput[31:0]=Binput[31:0];
//      endcase
    end
    
    always @*    //Srl逻辑右移指令执行
    begin
      case(Shamt)   //Srl rd,rt,shamt
        5'b00000:Dinput[31:0]=Binput[31:0]; //右移0位
        5'b00001:Dinput[31:0]={1'b0,Binput[31:1]};
        5'b00010:Dinput[31:0]={2'b00,Binput[31:2]};
        5'b00011:Dinput[31:0]={3'b000,Binput[31:3]};
        5'b00100:Dinput[31:0]={4'b0000,Binput[31:4]};
        5'b00101:Dinput[31:0]={5'b00000,Binput[31:5]};
        5'b00110:Dinput[31:0]={6'b000000,Binput[31:6]};
        5'b00111:Dinput[31:0]={7'b0000000,Binput[31:7]};
        5'b01000:Dinput[31:0]={8'b00000000,Binput[31:8]};
        5'b01001:Dinput[31:0]={9'b000000000,Binput[31:9]};
        5'b01010:Dinput[31:0]={10'b0000000000,Binput[31:10]};
        5'b01011:Dinput[31:0]={11'b00000000000,Binput[31:11]};
        5'b01100:Dinput[31:0]={12'b000000000000,Binput[31:12]};
        5'b01101:Dinput[31:0]={13'b0000000000000,Binput[31:13]};
        5'b01110:Dinput[31:0]={14'b00000000000000,Binput[31:14]};
        5'b01111:Dinput[31:0]={15'b000000000000000,Binput[31:15]};
        5'b10000:Dinput[31:0]={16'b0000000000000000,Binput[31:16]};
        5'b10001:Dinput[31:0]={17'b00000000000000000,Binput[31:17]};
        5'b10010:Dinput[31:0]={18'b000000000000000000,Binput[31:18]};
        5'b10011:Dinput[31:0]={19'b0000000000000000000,Binput[31:19]};
        5'b10100:Dinput[31:0]={20'b00000000000000000000,Binput[31:20]};
        5'b10101:Dinput[31:0]={21'b000000000000000000000,Binput[31:21]};
        5'b10110:Dinput[31:0]={22'b0000000000000000000000,Binput[31:22]};
        5'b10111:Dinput[31:0]={23'b00000000000000000000000,Binput[31:23]};
        5'b11000:Dinput[31:0]={24'b000000000000000000000000,Binput[31:24]};
        5'b11001:Dinput[31:0]={25'b0000000000000000000000000,Binput[31:25]};
        5'b11010:Dinput[31:0]={26'b00000000000000000000000000,Binput[31:26]};
        5'b11011:Dinput[31:0]={27'b000000000000000000000000000,Binput[31:27]};
        5'b11100:Dinput[31:0]={28'b0000000000000000000000000000,Binput[31:28]};
        5'b11101:Dinput[31:0]={29'b00000000000000000000000000000,Binput[31:29]};
        5'b11110:Dinput[31:0]={30'b000000000000000000000000000000,Binput[31:30]};
        5'b11111:Dinput[31:0]={31'b0000000000000000000000000000000,Binput[31]};
        default:Dinput[31:0]=Binput[31:0];
      endcase
    end
    
     always @*    //Sllv逻辑左移指令执行
    begin
      case(Ainput[4:0])   //Sllv rd,rt,rs
        5'b00000:Einput[31:0]=Binput[31:0]; //左移0位
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
        5'b00001:Finput[31:0]={1'b0,Binput[31:1]};                               
        5'b00010:Finput[31:0]={2'b00,Binput[31:2]};                              
        5'b00011:Finput[31:0]={3'b000,Binput[31:3]};                             
        5'b00100:Finput[31:0]={4'b0000,Binput[31:4]};                            
        5'b00101:Finput[31:0]={5'b00000,Binput[31:5]};                           
        5'b00110:Finput[31:0]={6'b000000,Binput[31:6]};                          
        5'b00111:Finput[31:0]={7'b0000000,Binput[31:7]};                         
        5'b01000:Finput[31:0]={8'b00000000,Binput[31:8]};                        
        5'b01001:Finput[31:0]={9'b000000000,Binput[31:9]};                       
        5'b01010:Finput[31:0]={10'b0000000000,Binput[31:10]};                    
        5'b01011:Finput[31:0]={11'b00000000000,Binput[31:11]};                   
        5'b01100:Finput[31:0]={12'b000000000000,Binput[31:12]};                  
        5'b01101:Finput[31:0]={13'b0000000000000,Binput[31:13]};                 
        5'b01110:Finput[31:0]={14'b00000000000000,Binput[31:14]};                
        5'b01111:Finput[31:0]={15'b000000000000000,Binput[31:15]};               
        5'b10000:Finput[31:0]={16'b0000000000000000,Binput[31:16]};              
        5'b10001:Finput[31:0]={17'b00000000000000000,Binput[31:17]};             
        5'b10010:Finput[31:0]={18'b000000000000000000,Binput[31:18]};            
        5'b10011:Finput[31:0]={19'b0000000000000000000,Binput[31:19]};           
        5'b10100:Finput[31:0]={20'b00000000000000000000,Binput[31:20]};          
        5'b10101:Finput[31:0]={21'b000000000000000000000,Binput[31:21]};         
        5'b10110:Finput[31:0]={22'b0000000000000000000000,Binput[31:22]};        
        5'b10111:Finput[31:0]={23'b00000000000000000000000,Binput[31:23]};       
        5'b11000:Finput[31:0]={24'b000000000000000000000000,Binput[31:24]};      
        5'b11001:Finput[31:0]={25'b0000000000000000000000000,Binput[31:25]};     
        5'b11010:Finput[31:0]={26'b00000000000000000000000000,Binput[31:26]};    
        5'b11011:Finput[31:0]={27'b000000000000000000000000000,Binput[31:27]};   
        5'b11100:Finput[31:0]={28'b0000000000000000000000000000,Binput[31:28]};  
        5'b11101:Finput[31:0]={29'b00000000000000000000000000000,Binput[31:29]}; 
        5'b11110:Finput[31:0]={30'b000000000000000000000000000000,Binput[31:30]};
        5'b11111:Finput[31:0]={31'b0000000000000000000000000000000,Binput[31]};  
        default:Finput[31:0]=Binput[31:0];
      endcase
    end
    
    always @*    //Sra算术右移指令执行
    begin
    s=Binput[31];//提取操作数符号位，算术右移符号位要跟着一起右移，同时符号位还要保留
      case(Shamt)   //Sra rd,rt,shamt
        5'b00000:Ginput[31:0]=Binput[31:0]; //右移0位
        5'b00001:Ginput[31:0]={s,Binput[31:1]};
        5'b00010:Ginput[31:0]={s,s,Binput[31:2]};
        5'b00011:Ginput[31:0]={s,s,s,Binput[31:3]};
        5'b00100:Ginput[31:0]={s,s,s,s,Binput[31:4]};
        5'b00101:Ginput[31:0]={s,s,s,s,s,Binput[31:5]};
        5'b00110:Ginput[31:0]={s,s,s,s,s,s,Binput[31:6]};
        5'b00111:Ginput[31:0]={s,s,s,s,s,s,s,Binput[31:7]};
        5'b01000:Ginput[31:0]={s,s,s,s,s,s,s,s,Binput[31:8]};
        5'b01001:Ginput[31:0]={s,s,s,s,s,s,s,s,s,Binput[31:9]};
        5'b01010:Ginput[31:0]={s,s,s,s,s,s,s,s,s,s,Binput[31:10]};
        5'b01011:Ginput[31:0]={s,s,s,s,s,s,s,s,s,s,s,Binput[31:11]};
        5'b01100:Ginput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:12]};
        5'b01101:Ginput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:13]};
        5'b01110:Ginput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:14]};
        5'b01111:Ginput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:15]};
        5'b10000:Ginput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:16]};
        5'b10001:Ginput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:17]};
        5'b10010:Ginput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:18]};
        5'b10011:Ginput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:19]};
        5'b10100:Ginput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:20]};
        5'b10101:Ginput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:21]};
        5'b10110:Ginput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:22]};
        5'b10111:Ginput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:23]};
        5'b11000:Ginput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:24]};
        5'b11001:Ginput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:25]};
        5'b11010:Ginput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:26]};
        5'b11011:Ginput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:27]};
        5'b11100:Ginput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:28]};
        5'b11101:Ginput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:29]};
        5'b11110:Ginput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:30]};
        5'b11111:Ginput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31]};
        default:Ginput[31:0]=Binput[31:0];
      endcase
    end
    
    always @*    //Srav算术右移指令执行
    begin
    s=Binput[31];//提取操作数符号位，算术右移符号位要跟着一起右移，同时符号位还要保留
      case(Ainput[4:0])   //Srav rd,rt,rs
        5'b00000:Hinput[31:0]=Binput[31:0]; //右移0位
        5'b00001:Hinput[31:0]={s,Binput[31:1]};                                                              
        5'b00010:Hinput[31:0]={s,s,Binput[31:2]};                                                            
        5'b00011:Hinput[31:0]={s,s,s,Binput[31:3]};                                                          
        5'b00100:Hinput[31:0]={s,s,s,s,Binput[31:4]};                                                        
        5'b00101:Hinput[31:0]={s,s,s,s,s,Binput[31:5]};                                                      
        5'b00110:Hinput[31:0]={s,s,s,s,s,s,Binput[31:6]};                                                    
        5'b00111:Hinput[31:0]={s,s,s,s,s,s,s,Binput[31:7]};                                                  
        5'b01000:Hinput[31:0]={s,s,s,s,s,s,s,s,Binput[31:8]};                                                
        5'b01001:Hinput[31:0]={s,s,s,s,s,s,s,s,s,Binput[31:9]};                                              
        5'b01010:Hinput[31:0]={s,s,s,s,s,s,s,s,s,s,Binput[31:10]};                                           
        5'b01011:Hinput[31:0]={s,s,s,s,s,s,s,s,s,s,s,Binput[31:11]};                                         
        5'b01100:Hinput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:12]};                                       
        5'b01101:Hinput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:13]};                                     
        5'b01110:Hinput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:14]};                                   
        5'b01111:Hinput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:15]};                                 
        5'b10000:Hinput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:16]};                               
        5'b10001:Hinput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:17]};                             
        5'b10010:Hinput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:18]};                           
        5'b10011:Hinput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:19]};                         
        5'b10100:Hinput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:20]};                       
        5'b10101:Hinput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:21]};                     
        5'b10110:Hinput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:22]};                   
        5'b10111:Hinput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:23]};                 
        5'b11000:Hinput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:24]};               
        5'b11001:Hinput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:25]};             
        5'b11010:Hinput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:26]};           
        5'b11011:Hinput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:27]};         
        5'b11100:Hinput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:28]};       
        5'b11101:Hinput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:29]};     
        5'b11110:Hinput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31:30]};   
        5'b11111:Hinput[31:0]={s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Binput[31]};    
        default:Hinput[31:0]=Binput[31:0];
      endcase
    end
    


	always @* begin  // 6种移位指令
       if(Sftmd)
        case(Sftm[2:0])
            3'b000:Sinput =  Cinput;			   //Sll rd,rt,shamt  00000
            3'b010:Sinput =  Dinput;		       //Srl rd,rt,shamt  00010
            3'b100:Sinput =  Einput;                  //Sllv rd,rt,rs 000100
            3'b110:Sinput =  Finput;                  //Srlv rd,rt,rs 000110
            3'b011:Sinput =  Ginput;        		//Sra rd,rt,shamt 00011
            3'b111:Sinput =  Hinput;		        //Srav rd,rt,rs 00111
            default:Sinput = Binput;
        endcase
       else Sinput = Binput;
    end
    
    assign Add_Result = PC_plus_4[31:0] + {Sign_extend[29:0],2'b00};    // 给取指单元作为beq和bne指令的跳转地址 
    //判断结果是否为0
    assign Zero = (ALU_output_mux[31:0]== 32'h00000000) ? 1'b1 : 1'b0;
    
    always @(ALU_ctl or Ainput or Binput) begin
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
 
    always @(negedge clock or posedge reset) begin
        if(reset) begin
            ALU_Result=32'hxxxxxxxx;
        end else if(Waluresult==1) begin
            if(((ALU_ctl==3'b111) && (Exe_code[3]==1))||((ALU_ctl[2:1]==2'b11) && (I_format==1))) //slti(sub)  处理所有SLT类的问题
                ALU_Result = {31'b0000000000000000000000000000000,ALU_output_mux[31]};
            else if((ALU_ctl==3'b101) && (I_format==1))
             ALU_Result[31:0] = {Binput[15:0],16'b0000000000000000};   //lui data
            else if(Sftmd==1) ALU_Result = Sinput ;  //  移位
            else  ALU_Result = ALU_output_mux[31:0];   //otherwise
        end
    end
 
endmodule
