`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module Idecode32(read_data_1,read_data_2,Instruction,read_data,ALU_result,
                 Jal,RegWrite,MemorIOtoReg,RegDst,Sign_extend,clock,reset,
                 opcplus4,read_register_1_address);
    output[31:0] read_data_1;
    output[31:0] read_data_2;
    input[31:0]  Instruction;//来自取指模块
    input[31:0]  read_data;   				//  从DATA RAM or I/O port取出的数据
    input[31:0]  ALU_result;   				//  需要扩展立即数到32位
    input        Jal; 
    input        RegWrite;
    input        MemorIOtoReg;
    input        RegDst;
    output[31:0] Sign_extend;
    input		 clock,reset;
    input[31:0]  opcplus4;                 // 来自取指单元，JAL中用
    output[4:0] read_register_1_address;
    
    

    
    reg[31:0] read_data_1;
    reg[31:0] read_data_2;
    //reg[31:0] register[31:0];			   //寄存器组共32个32位寄存器
    
    reg[31:0] register0;
    reg[31:0] register1;
    reg[31:0] register2;
    reg[31:0] register3;
    reg[31:0] register4;
    reg[31:0] register5;
    reg[31:0] register6;
    reg[31:0] register7;
    reg[31:0] register8;
    reg[31:0] register9;
    reg[31:0] register10;
    reg[31:0] register11;
    reg[31:0] register12;
    reg[31:0] register13;
    reg[31:0] register14;
    reg[31:0] register15;
    reg[31:0] register16;
    reg[31:0] register17;
    reg[31:0] register18;
    reg[31:0] register19;
    reg[31:0] register20;
    reg[31:0] register21;
    reg[31:0] register22;
    reg[31:0] register23;
    reg[31:0] register24;
    reg[31:0] register25;
    reg[31:0] register26;
    reg[31:0] register27;
    reg[31:0] register28;
    reg[31:0] register29;
    reg[31:0] register30;
    reg[31:0] register31;
   
    reg[4:0] write_register_address;
    reg[31:0] write_data;
    wire[4:0] read_register_1_address,read_register_2_address;//1_rs  2_rt
    wire[4:0] write_register_address_1;//rd(r-form)
    wire[4:0] write_register_address_0;//rt(i-form)
    wire[15:0] Instruction_immediate_value;
    wire[5:0] opcode;//op
    wire sign;
    
//    assign register2[31:0]=register[2][31:0];
//    assign register3=register[3];

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
    ||(opcode==6'b001011))?{16'h0000,Instruction_immediate_value[15:0]}//立即数0扩展
    :{sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,
    Instruction_immediate_value[15:0]};
    
    always @(posedge clock)
    begin
      case(read_register_1_address[4:0])
      5'd0:read_data_1<=register0;
      5'd1:read_data_1<=register1;
      5'd2:read_data_1<=register2;
      5'd3:read_data_1<=register3;
      5'd4:read_data_1<=register4;
      5'd5:read_data_1<=register5;
      5'd6:read_data_1<=register6;
      5'd7:read_data_1<=register7;
      5'd8:read_data_1<=register8;
      5'd9:read_data_1<=register9;
      5'd10:read_data_1<=register10;
      5'd11:read_data_1<=register11;
      5'd12:read_data_1<=register12;
      5'd13:read_data_1<=register13;
      5'd14:read_data_1<=register14;
      5'd15:read_data_1<=register15;
      5'd16:read_data_1<=register16;
      5'd17:read_data_1<=register17;
      5'd18:read_data_1<=register18;
      5'd19:read_data_1<=register19;
      5'd20:read_data_1<=register20;
      5'd21:read_data_1<=register21;
      5'd22:read_data_1<=register22;
      5'd23:read_data_1<=register23;
      5'd24:read_data_1<=register24;
      5'd25:read_data_1<=register25;
      5'd26:read_data_1<=register26;
      5'd27:read_data_1<=register27;
      5'd28:read_data_1<=register28;
      5'd29:read_data_1<=register29;
      5'd30:read_data_1<=register30;
      5'd31:read_data_1<=register31;
      default read_data_1<=32'bx;
      
     endcase
   end
   
  always @(posedge clock)
    begin
      case(read_register_2_address[4:0])
      5'd0:read_data_2<=register0;
      5'd1:read_data_2<=register1;
      5'd2:read_data_2<=register2;
      5'd3:read_data_2<=register3;
      5'd4:read_data_2<=register4;
      5'd5:read_data_2<=register5;
      5'd6:read_data_2<=register6;
      5'd7:read_data_2<=register7;
      5'd8:read_data_2<=register8;
      5'd9:read_data_2<=register9;
      5'd10:read_data_2<=register10;
      5'd11:read_data_2<=register11;
      5'd12:read_data_2<=register12;
      5'd13:read_data_2<=register13;
      5'd14:read_data_2<=register14;
      5'd15:read_data_2<=register15;
      5'd16:read_data_2<=register16;
      5'd17:read_data_2<=register17;
      5'd18:read_data_2<=register18;
      5'd19:read_data_2<=register19;
      5'd20:read_data_2<=register20;
      5'd21:read_data_2<=register21;
      5'd22:read_data_2<=register22;
      5'd23:read_data_2<=register23;
      5'd24:read_data_2<=register24;
      5'd25:read_data_2<=register25;
      5'd26:read_data_2<=register26;
      5'd27:read_data_2<=register27;
      5'd28:read_data_2<=register28;
      5'd29:read_data_2<=register29;
      5'd30:read_data_2<=register30;
      5'd31:read_data_2<=register31;
      default read_data_2<=32'bx;
      
     endcase
   end
      
      
   always  @*//这个进程指定不同指令下的目标寄存器
   begin
   if((RegDst==1)&&(Jal==0))
     write_register_address=write_register_address_1;
   else if ((RegDst==0)&&(Jal==1))
   write_register_address=5'b11111;
   else
     write_register_address=write_register_address_0;
  
   end
   
                                              


    
    always @* begin  //这个进程基本上是实现结构图中右下的多路选择器,准备要写的数据
      if((MemorIOtoReg==0)&&(Jal==0))
       write_data=ALU_result[31:0];
      else if ((MemorIOtoReg==0)&&(Jal==1))
      begin
        write_data[31:0]={16'b0000000000000000,opcplus4[15:0]};
      end
     else write_data=read_data;
     end    
    //integer i;
    always @(posedge clock) begin       // 本进程写目标寄存器
        if(reset==1) begin              // 初化寄存器组
       
            register0<=32'd0;
            register1<=32'd1;
            register2<=32'd2;
            register3<=32'd3;
            register4<=32'd4;
            register5<=32'd5;
            register6<=32'd6;
            register7<=32'd7;
            register8<=32'd8;
            register9<=32'd9;
            register10<=32'd10;
            register11<=32'd11;
            register12<=32'd12;
            register13<=32'd13;
            register14<=32'd14;
            register15<=32'd15;
            register16<=32'd16;
            register17<=32'd17;
            register18<=32'd18;
            register19<=32'd19;
            register20<=32'd20;
            register21<=32'd21;
            register22<=32'd22;
            register23<=32'd23;
            register24<=32'd24;
            register25<=32'd25;
            register26<=32'd26;
            register27<=32'd27;
            register28<=32'd28;
            register29<=32'd29;
            register30<=32'd30;
            register31<=32'd31;
            
            read_data_1 <= 32'd0;
            read_data_2 <= 32'd0;
            
            //for(i=0;i<32;i=i+1) register[i]<=i;
        end
       else if(RegWrite==1) begin  // 注意寄存器0恒等于0
          case(write_register_address[4:0])
          5'd0:register0<=32'd0;
          5'd1:register1<=write_data;
          5'd2:register2<=write_data;
          5'd3:register3<=write_data;
          5'd4:register4<=write_data;
          5'd5:register5<=write_data;
          5'd6:register6<=write_data;
          5'd7:register7<=write_data;
          5'd8:register8<=write_data;
          5'd9:register9<=write_data;
          5'd10:register10<=write_data;
          5'd11:register11<=write_data;
          5'd12:register12<=write_data;
          5'd13:register13<=write_data;
          5'd14:register14<=write_data;
          5'd15:register15<=write_data;
          5'd16:register16<=write_data;
          5'd17:register17<=write_data;
          5'd18:register18<=write_data;
          5'd19:register19<=write_data;
          5'd20:register20<=write_data;
          5'd21:register21<=write_data;
          5'd22:register22<=write_data;
          5'd23:register23<=write_data;
          5'd24:register24<=write_data;
          5'd25:register25<=write_data;
          5'd26:register26<=write_data;
          5'd27:register27<=write_data;
          5'd28:register28<=write_data;
          5'd29:register29<=write_data;
          5'd30:register30<=write_data;
          5'd31:register31<=write_data;
          default:register0<=32'd0;
          
          endcase
       

        end
    end
endmodule
