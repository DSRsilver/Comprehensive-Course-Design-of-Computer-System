`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module minisys (fpga_rst,fpga_clk,led2N4,start_pg,rx,tx );
    input			fpga_rst;	        // ���ϵ�Reset�źţ��ߵ�ƽ��λ
    input			fpga_clk;	    // ���ϵ�100MHzʱ���ź�
 //   input	[23:0]	switch2N4;	// ���뿪������
    output	[23:0]	led2N4;		// LED������������
	// UART Programmer Pinouts
	input           start_pg;           // �Ӱ��ϵ�S3����������������
	input           rx;                      // UART����
	output          tx;                     // UART����

    wire clock;				            //clock: ��Ƶ��ʱ�ӹ���ϵͳ
    wire reset;
    
    wire  if_stall;
    
    wire[31:0] instruction_if_id_in;
	wire[31:0] pc_plus_4_if_id_in;
	wire [13:0] rom_adr;
	wire[31:0] pc;
	
	wire       if_id_reset;
	reg        if_id_enable;
	wire[31:0] pc_plus_4_if_id_out;
    wire[31:0] instruction_if_id_out;
    
    //ideģ�����
    wire[31:0]  read_data_1_id_exe_in;	
    wire[31:0]  read_data_2_id_exe_in;	
    wire[31:0]  sign_extend_id_exe_in;	//������չ
    wire[4:0]   write_register_address_id_exe_in;
    wire        r_hi_id_exe_in, r_lo_id_exe_in;
    wire[4:0]   rt;
    wire[31:0]  memorioaddr;
    wire        reset_if_id;
    wire        reset_id_exe;
    wire        stall;
    
    wire        reset_ifid_id_exe_in;
    wire        reset_idexe_id_exe_in;
    
    wire        jmp,jal_id_exe_in,jrn,jalr_id_exe_in;
    wire        branch,nbranch,bgez,bgtz,blez,bltz,bgezal_id_exe_in,bltzal_id_exe_in;
    wire        lb_id_exe_in,lbu_id_exe_in,lh_id_exe_in,lhu_id_exe_in,lw_id_exe_in,sb_id_exe_in,sh_id_exe_in,sw_id_exe_in;
    wire        alusrc_id_exe_in;
    wire[1:0]   aluop_id_exe_in;
    wire        i_format_id_exe_in;
    wire        sftmd_id_exe_in;
    wire        regdst;
    wire        regwrite_id_exe_in;
    wire        memwrite_id_exe_in,memread_id_exe_in;
    wire        iowrite_id_exe_in,ioread_id_exe_in;	        //I/O��д�ź�
    wire        memoriotoreg_id_exe_in;
    wire        w_hi_id_exe_in,w_lo_id_exe_in;
    wire        zero;
    wire[1:0]   compare_id_exe_in;
    
    wire        id_exe_reset;
    wire        id_exe_enable;
    
    wire[31:0]  instruction_id_exe_out;
    wire[31:0]  pc_plus_4_id_exe_out;
    wire        alusrc_id_exe_out;
    wire[1:0]   aluop_id_exe_out;
    wire        sftmd_id_exe_out;
    wire        i_format_id_exe_out;
    wire[31:0]  read_data_1_id_exe_out;
    wire[31:0]  read_data_2_id_exe_out;
    wire[31:0]  sign_extend_id_exe_out;
    wire        bgez_id_exe_out,bgtz_id_exe_out,blez_id_exe_out,bltz_id_exe_out,bgezal_id_exe_out,bltzal_id_exe_out;
    wire        lb_id_exe_out,lbu_id_exe_out,lh_id_exe_out,lhu_id_exe_out,lw_id_exe_out,sb_id_exe_out,sh_id_exe_out,sw_id_exe_out;
    wire        iowrite_id_exe_out,ioread_id_exe_out;
    wire        memwrite_id_exe_out,memread_id_exe_out;
    wire        memoriotoreg_id_exe_out;
    wire        regwrite_id_exe_out;
    wire[4:0]   write_register_address_id_exe_out;
    wire        r_hi_id_exe_out,r_lo_id_exe_out;
    wire        w_hi_id_exe_out,w_lo_id_exe_out;
    wire        jal_id_exe_out;
    wire        jalr_id_exe_out;
    wire[1:0]   compare_id_exe_out;
    
    wire        overflow;
    wire[31:0]  alu_result_exe_mem_in;	
    wire[31:0]  hi_data_exe_mem_in;
    wire[31:0]  lo_data_exe_mem_in;
    wire [31:0] add_result;	
    wire        memenable0_exe_mem_in,memenable1_exe_mem_in,memenable2_exe_mem_in,memenable3_exe_mem_in;
    
    
    //
    wire        exe_mem_reset;
    wire        exe_mem_enable;
    wire        iowrite_exe_mem_out;       //��IO
    wire        memwrite_exe_mem_out;
    wire[31:0]  write_data_exe_mem_out;
    wire        memenable0_exe_mem_out;
    wire        memenable1_exe_mem_out;
    wire        memenable2_exe_mem_out;
    wire        memenable3_exe_mem_out;
    wire        memoriotoreg_exe_mem_out;   //��IO
    wire        ioread_exe_mem_out;    //��IO
    wire        memread_exe_mem_out;
    wire[31:0]  alu_result_exe_mem_out;
    wire        regwrite_exe_mem_out;
    wire[4:0]   write_register_address_exe_mem_out;
    wire        r_hi_exe_mem_out;
    wire        r_lo_exe_mem_out;
    wire        w_hi_exe_mem_out;
    wire        w_lo_exe_mem_out;
    wire[31:0]  hi_data_exe_mem_out;
    wire[31:0]  lo_data_exe_mem_out;
    wire        jal_exe_mem_out;
    wire        jalr_exe_mem_out;
    wire        bgezal_exe_mem_out;
    wire        bltzal_exe_mem_out;
    wire[1:0]   compare_exe_mem_out;
    wire[31:0]  pc_plus_4_exe_mem_out;
    
    
    wire[31:0]  memoriodata_mem_wb_in;
    
    wire        mem_wb_reset;
    wire        mem_wb_enable;
    wire        memoriotoreg_mem_wb_out;
    wire[31:0]  alu_result_mem_wb_out;
    wire        regwrite_mem_wb_out;
    wire[4:0]   write_register_address_mem_wb_out;
    wire        r_hi_mem_wb_out;
    wire        r_lo_mem_wb_out;          
    wire        w_hi_mem_wb_out;
    wire        w_lo_mem_wb_out;
    wire[31:0]  hi_data_mem_wb_out;
    wire[31:0]  lo_data_mem_wb_out;
    wire[31:0]  memoriodata_mem_wb_out;
    wire        jal_mem_wb_out;
    wire        jalr_mem_wb_out;
    wire        bgezal_mem_wb_out;
    wire        bltzal_mem_wb_out;
    wire[1:0]   compare_mem_wb_out;
    wire[31:0]  pc_plus_4_mem_wb_out;
    
    
    
    
    
    wire [31:0] write_data;	    //дRAM��IO������
    wire [31:0] rdata;		        //��RAM��IO������
    wire [15:0] ioread_data;	//��IO������
    wire [31:0] read_data;	    //RAM�ж�ȡ������
    wire [31:0] address;
	wire [31:0] rom_dat;
    wire        ledctrl,switchctrl;
    wire[15:0]  ioread_data_switch;
    
    
    
    
    wire rst;
	// UART Programmer Pinouts
	wire upg_clk, upg_clk_o, upg_wen_o, upg_done_o;
	wire [14:0] upg_adr_o;
	wire [31:0] upg_dat_o;

	wire spg_bufg;
	BUFG U1(.I(start_pg), .O(spg_bufg));	    // S3����ȥ��
    
	// Generate UART Programmer reset signal
	reg upg_rst;
	always @ (posedge fpga_clk) begin
		if (spg_bufg)	upg_rst = 0;
		if (fpga_rst)	upg_rst = 1;
	end
	
	assign rst = fpga_rst | !upg_rst;
	
	assign reset=!fpga_rst;
	
    cpuclk cpuclk (
        .clk_in1		    (fpga_clk),	    // 100MHz, ����ʱ��
        .clk_out1		(clock),    	    // CPU Clock (23MHz), ��ʱ��
		.clk_out2		(upg_clk)		// UPG Clock (10MHz), ���ڴ�������
    );
	
	uart_bmpg_0 uartpg (                // ��ģ���Ѿ��Ӻã�ֻ��Ϊ�������صĸ������ɲ�ȥ��ע
		.upg_clk_i		(upg_clk),		// 10MHz   
		.upg_rst_i		(upg_rst),		// �ߵ�ƽ��Ч
		// blkram signals
		.upg_clk_o		(upg_clk_o),
		.upg_wen_o		(upg_wen_o),
		.upg_adr_o		(upg_adr_o),
		.upg_dat_o		(upg_dat_o),
		.upg_done_o		(upg_done_o),
		// uart signals
		.upg_rx_i		(rx),
		.upg_tx_o		(tx)
	);
	
	programrom ROM (
		// Program ROM Pinouts
		.rom_clk_i		(clock),		    // ��CPU��23MHz����ʱ��
		.rom_adr_i		(rom_adr),		// ȡָ��Ԫ��ROM�ĵ�ַ��PC��
		.Jpadr			(rom_dat),		    // ROM�ж������ݣ�ָ�
		// UART Programmer Pinouts, �����Ǵ����������ã��ɲ��ع�ע
		.upg_rst_i		(upg_rst),		// UPG reset (�ߵ�ƽ��Ч)
		.upg_clk_i		(upg_clk_o),	// UPG clock (10MHz)
		.upg_wen_i		(upg_wen_o & !upg_adr_o[14]),	// UPG write enable
		.upg_adr_i		(upg_adr_o[13:0]),	// UPG write address
		.upg_dat_i		(upg_dat_o),	            // UPG write data
		.upg_done_i		(upg_done_o)	    // 1 if programming is finished
	);
	
  
    assign    if_stall = (stall==1)?1'b1:1'b0;
  
    
    Ifetc32 ifetch(
        .stall(if_stall),
        .reset(reset),
        .clock(clock),
        .Add_result(add_result),
        .Read_data_1(read_data_1_id_exe_in),		// �������뵥Ԫ��jrָ���õĵ�ַ
        .Branch(branch),			// ���Կ��Ƶ�Ԫ
        .nBranch(nbranch),			// ���Կ��Ƶ�Ԫ
        .Zero(zero),				// ����ִ�е�Ԫ
        .Jmp(jmp),				// ���Կ��Ƶ�Ԫ
        .Jal(jal_id_exe_in),				// ���Կ��Ƶ�Ԫ
        .Jalr(jalr_id_exe_in),                //���Կ��Ƶ�Ԫ
        .Jrn(jrn),				// ���Կ��Ƶ�Ԫ
        .Jpadr(rom_dat),		// �ӳ���ROM��Ԫ�л�ȡ��ָ��
        .bgez(bgez),
        .bgtz(bgtz),
        .blez(blez),
        .bltz(bltz),
        .bgezal(bgezal_id_exe_in),
        .bltzal(bltzal_id_exe_in),
        .compare(compare_id_exe_in),
        .Instruction(instruction_if_id_in),	// ���ָ�����ģ��
        .PC_out(pc),	// (pc+4)��ִ�е�Ԫ
        .PC_plus_4_out(pc_plus_4_if_id_in),
        .rom_adr_o(rom_adr),			// ������ROM��Ԫ��ȡָ��ַ
        .instruction_in(instruction_if_id_out)
    );
    
//    always @(negedge clock)begin
//        if_id_reset <= ((reset == 1)||(reset_if_id == 1))?1'b1:1'b0;
//    end
    assign if_id_reset = ((reset_if_id == 1)||(reset == 1))?1'b1:1'b0;
 //   assign if_id_enable=(stall==1)?1'b0:1'b1;
    always @* begin
        if(reset==1)
           if_id_enable=1'b1;
        if(stall==1) 
            if_id_enable=1'b0;
        else
            if_id_enable=1'b1;
    end
//    assign if_id_enable=1'b1;
    
	if_id_reg if_id(
	    .clock(clock),
        .reset(if_id_reset),
        .if_id_enable(if_id_enable),
        .pc_plus_4_in(pc_plus_4_if_id_in),
        .instruction_in(instruction_if_id_in),
        .pc_plus_4_out(pc_plus_4_if_id_out),
        .instruction_out(instruction_if_id_out)
	);
    
    Idecode32 idecode(
        .clock(clock),
        .reset(reset),
        .PC_plus_4(pc_plus_4_if_id_out),
        .Instruction(instruction_if_id_out),
        .read_data(memoriodata_mem_wb_out),   				//  ��DATA RAM or I/O portȡ��������
        .ALU_result(alu_result_mem_wb_out),   				//  ��Ҫ��չ��������32λ
        .Jal_wb(jal_mem_wb_out), 
        .Jalr_wb(jalr_mem_wb_out),
        .bgezal_wb(bgezal_mem_wb_out),
        .bltzal_wb(bltzal_mem_wb_out),
        .compare_wb(compare_mem_wb_out),
        .RegWrite(regwrite_mem_wb_out),
        .MemorIOtoReg(memoriotoreg_mem_wb_out),
        .RegDst(regdst),        //Ϊ1˵��Ŀ����rd��������rt
        .opcplus4(pc_plus_4_mem_wb_out),                 // ����ȡָ��Ԫ��JAL����
        .w_hi_wb(w_hi_mem_wb_out),          //mthi,mult,multu,div,divu
        .w_lo_wb(w_lo_mem_wb_out),          //mtlo,mult,multu,div,divu
        .r_hi_wb(r_hi_mem_wb_out),       //mfhi
        .r_lo_wb(r_lo_mem_wb_out),       //mflo
        .write_register_address_in(write_register_address_mem_wb_out),
        .hi_data(hi_data_mem_wb_out),
        .lo_data(lo_data_mem_wb_out),
        .read_data_1(read_data_1_id_exe_in),
        .read_data_2(read_data_2_id_exe_in),
        .Sign_extend(sign_extend_id_exe_in),
        .write_register_address_out(write_register_address_id_exe_in),
        .r_hi(r_hi_id_exe_in),   //mfhi
        .r_lo(r_lo_id_exe_in),   //mflo
        .rt(rt),  //��������bgez\bgtz\blez��ָ��
        .MemorIOAddr(memorioaddr),
        .Jrn(jrn),
        .Jal(jal_id_exe_in),
        .Jalr(jalr_id_exe_in),
        .Jmp(jmp),
        .Zero(zero),
        .Branch(branch),
        .nBranch(nbranch),
        .bgez(bgez),
        .bgtz(bgtz),
        .blez(blez),
        .bltz(bltz),
        .bgezal(bgezal_id_exe_in),
        .bltzal(bltzal_id_exe_in),
        .compare(compare_id_exe_in),
        .Add_Result(add_result),
        .write_register_address_id_exe(write_register_address_id_exe_out),
        .write_register_address_exe_mem(write_register_address_exe_mem_out),
        .write_register_address_mem_wb(write_register_address_mem_wb_out),
        .stall(stall),
        .reset_if_id(reset_if_id),
        .reset_id_exe(reset_id_exe)
    );
    
    control32 control(
        .clock(clock),
        .reset(reset),
        .Opcode(instruction_if_id_out[31:26]),            // ����ȡָ��Ԫinstruction[31..26]
        .Function_opcode(instruction_if_id_out[5:0]),  	// r-form instructions[5..0]
        .Alu_resultHigh(memorioaddr[31:10]),     //����ִ�е�ԪAlu_result[31:10]
        .rt(rt), //��������bgez\bgtz\blez��ָ��
        
        .Jrn(jrn),
        .Jalr(jalr_id_exe_in),
        .RegDST(regdst),            //Ϊ1˵��Ŀ����rd��������rt
        .ALUSrc(alusrc_id_exe_in),            // �����ڶ����������ǼĴ�������������,����������Ϊ1
        .MemorIOtoReg(memoriotoreg_id_exe_in),    //��IO
        .IORead(ioread_id_exe_in),          //��IO
        .IOWrite(iowrite_id_exe_in),         //��IO
        .RegWrite(regwrite_id_exe_in),
        .MemWrite(memwrite_id_exe_in),
        .MemRead(memread_id_exe_in),
        .Branch(branch),
        .nBranch(nbranch),
        .bgez(bgez),
        .bgtz(bgtz),
        .blez(blez),
        .bltz(bltz),
        .bgezal(bgezal_id_exe_in),
        .bltzal(bltzal_id_exe_in),
        .Lb(lb_id_exe_in),
        .Lbu(lbu_id_exe_in),
        .Lh(lh_id_exe_in),
        .Lhu(lhu_id_exe_in),
        .Lw(lw_id_exe_in),
        .Sb(sb_id_exe_in),
        .Sh(sh_id_exe_in),
        .Sw(sw_id_exe_in),
        .Jmp(jmp),
        .Jal(jal_id_exe_in),
        .I_format(i_format_id_exe_in),
        .Sftmd(sftmd_id_exe_in),
        .ALUOp(aluop_id_exe_in),
        .w_hi(w_hi_id_exe_in),
        .w_lo(w_lo_id_exe_in),
        .r_hi(r_hi_id_exe_in),   //mfhi
        .r_lo(r_lo_id_exe_in)   //mflo
    );
    
//    always@(negedge clock)begin
//        id_exe_reset=((reset==1'b1)||(reset_id_exe==1'b1))?1'b1:1'b0;
//    end
	assign id_exe_reset=(reset_id_exe==1'b1)||(reset==1'b1);
    assign id_exe_enable=1'b1;
    
	id_exe_reg id_exe(
	     .clock(clock),
         .reset(id_exe_reset),
         .id_exe_enable(id_exe_enable),
         .pc_plus_4_in(pc_plus_4_if_id_out),
         .instruction_in(instruction_if_id_out),
         .ALUSrc_in(alusrc_id_exe_in),           // �����ڶ����������ǼĴ�������������
         .Sftmd_in(sftmd_id_exe_in),
         .ALUOp_in(aluop_id_exe_in),
         .I_format_in(i_format_id_exe_in), 
         .read_data_1_in(read_data_1_id_exe_in),
         .read_data_2_in(read_data_2_id_exe_in),
         .sign_extend_in(sign_extend_id_exe_in),
         .bgezal_in(bgezal_id_exe_in),
         .bltzal_in(bltzal_id_exe_in),
         .lb_in(lb_id_exe_in),
         .lbu_in(lbu_id_exe_in),
         .lh_in(lh_id_exe_in),
         .lhu_in(lhu_id_exe_in),
         .lw_in(lw_id_exe_in),
         .sb_in(sb_id_exe_in),
         .sh_in(sh_id_exe_in),
         .sw_in(sw_id_exe_in),
         .IOWrite_in(iowrite_id_exe_in),
         .MemWrite_in(memwrite_id_exe_in),
         .MemorIOtoReg_in(memoriotoreg_id_exe_in),
         .IORead_in(ioread_id_exe_in),      
         .MemRead_in(memread_id_exe_in),
         .RegWrite_in(regwrite_id_exe_in),
         .write_register_address_in(write_register_address_id_exe_in),
         .r_hi_in(r_hi_id_exe_in),
         .r_lo_in(r_lo_id_exe_in),
         .w_hi_in(w_hi_id_exe_in),
         .w_lo_in(w_lo_id_exe_in),
         .Jal_in(jal_id_exe_in),
         .Jalr_in(jalr_id_exe_in),
         .compare_in(compare_id_exe_in),
         
         .pc_plus_4_out(pc_plus_4_id_exe_out),
         .instruction_out(instruction_id_exe_out),
         .ALUSrc_out(alusrc_id_exe_out),            // �����ڶ����������ǼĴ�������������
         .Sftmd_out(sftmd_id_exe_out),
         .read_data_1_out(read_data_1_id_exe_out),
         .read_data_2_out(read_data_2_id_exe_out),
         .I_format_out(i_format_id_exe_out),
         .ALUOp_out(aluop_id_exe_out),
         .sign_extend_out(sign_extend_id_exe_out),
         .bgezal_out(bgezal_id_exe_out),
         .bltzal_out(bltzal_id_exe_out),
         .lb_out(lb_id_exe_out),
         .lbu_out(lbu_id_exe_out),
         .lh_out(lh_id_exe_out),
         .lhu_out(lhu_id_exe_out),
         .lw_out(lw_id_exe_out),
         .sb_out(sb_id_exe_out),
         .sh_out(sh_id_exe_out),
         .sw_out(sw_id_exe_out),
         .IOWrite_out(iowrite_id_exe_out),         //��IO
         .MemWrite_out(memwrite_id_exe_out),
         .MemorIOtoReg_out(memoriotoreg_id_exe_out),    //��IO
         .IORead_out(ioread_id_exe_out),          //��IO
         .MemRead_out(memread_id_exe_out),
         .RegWrite_out(regwrite_id_exe_out),
         .write_register_address_out(write_register_address_id_exe_out),
         .r_hi_out(r_hi_id_exe_out),
         .r_lo_out(r_lo_id_exe_out),
         .w_hi_out(w_hi_id_exe_out),
         .w_lo_out(w_lo_id_exe_out),
         .Jal_out(jal_id_exe_out),
         .Jalr_out(jalr_id_exe_out),
         .compare_out(compare_id_exe_out)
	);
	
    Executs32 execute(
         .clock(clock),
         .reset(reset),
         .Read_data_1(read_data_1_id_exe_out),		//r-form rs// �����뵥Ԫ��Read_data_1����
         .Read_data_2(read_data_2_id_exe_out),		//r-form rt// �����뵥Ԫ��Read_data_2����
         .Sign_extend(sign_extend_id_exe_out),		//i-form// �����뵥Ԫ������չ���������
         .Function_opcode(instruction_id_exe_out[5:0]),  	//r-form instructions[5..0]// ȡָ��Ԫ����r-����ָ�����,r-form instructions[5:0]
         .Exe_opcode(instruction_id_exe_out[31:26]),  		//op code instruction[31:26]// ȡָ��Ԫ���Ĳ�����
         .ALUOp(aluop_id_exe_out),//�ӿ��Ƶ�Ԫ���������룬��R���ͻ�����Ҫ��������ָ��1λΪ1��beq\bneָ����0λΪ1// ���Կ��Ƶ�Ԫ������ָ����Ʊ���
         .Shamt(instruction_id_exe_out[10:6]),//����ȡֵ��Ԫ��instruction[10:6]��ָ����λ����// ����ȡָ��Ԫ��instruction[10:6]��ָ����λ����
         .Sftmd(sftmd_id_exe_out),// ���Կ��Ƶ�Ԫ�ģ���������λָ��
         .ALUSrc(alusrc_id_exe_out),// ���Կ��Ƶ�Ԫ�������ڶ�������������������beq��bne���⣩
         .I_format(i_format_id_exe_out),// ���Կ��Ƶ�Ԫ�������ǳ�beq, bne, LW, SW֮���I-����ָ��
    //     .PC_plus_4(pc_plus_4_id_exe_out),         // ����ȡָ��Ԫ��PC+4
         .lb(lb_id_exe_out),
         .lbu(lbu_id_exe_out),
         .lh(lh_id_exe_out),
         .lhu(lhu_id_exe_out),
         .lw(lw_id_exe_out),
         .sb(sb_id_exe_out),
         .sh(sh_id_exe_out),
         .sw(sw_id_exe_out),
        
         .overflow(overflow),
         .ALU_Result(alu_result_exe_mem_in),        // ��������ݽ��
         .hi_data(hi_data_exe_mem_in),
         .lo_data(lo_data_exe_mem_in),
    //     .Add_Result(add_result),		//pc op  ����ĵ�ַ���     
         .MemEnable0(memenable0_exe_mem_in),
         .MemEnable1(memenable1_exe_mem_in),
         .MemEnable2(memenable2_exe_mem_in),
         .MemEnable3(memenable3_exe_mem_in)
	);
	
	assign exe_mem_reset=(reset==1)?1'b1:1'b0;
    assign exe_mem_enable=1'b1;
    
	exe_mem_reg exe_mem(
	     .clock(clock),
         .reset(exe_mem_reset),
         .exe_mem_enable(exe_mem_enable), 
         .IOWrite_in(iowrite_id_exe_out),    
         .MemWrite_in(memwrite_id_exe_out), 
         .IORead_in(ioread_id_exe_out),      
         .MemRead_in(memread_id_exe_out),
         .write_data_in(read_data_2_id_exe_out),//��洢��д������ݣ�����swָ�����read_data_2
         .MemEnable0_in(memenable0_exe_mem_in),
         .MemEnable1_in(memenable1_exe_mem_in),
         .MemEnable2_in(memenable2_exe_mem_in),
         .MemEnable3_in(memenable3_exe_mem_in),
         .MemorIOtoReg_in(memoriotoreg_id_exe_out),   
         .ALU_Result_in(alu_result_exe_mem_in),
         .RegWrite_in(regwrite_id_exe_out),
         .write_register_address_in(write_register_address_id_exe_out),
         .r_hi_in(r_hi_id_exe_out),
         .r_lo_in(r_lo_id_exe_out),
         .w_hi_in(w_hi_id_exe_out),
         .w_lo_in(w_lo_id_exe_out),
         .hi_data_in(hi_data_exe_mem_in),
         .lo_data_in(lo_data_exe_mem_in),
         .Jal_in(jal_id_exe_out),
         .Jalr_in(jalr_id_exe_out),
         .bgezal_in(bgezal_id_exe_out),
         .bltzal_in(bltzal_id_exe_out),
         .compare_in(compare_id_exe_out), 
         .pc_plus_4_in(pc_plus_4_id_exe_out),
         
         .IOWrite_out(iowrite_exe_mem_out) ,       //��IO
         .MemWrite_out(memwrite_exe_mem_out),
         .write_data_out(write_data_exe_mem_out),
         .MemEnable0_out(memenable0_exe_mem_out),
         .MemEnable1_out(memenable1_exe_mem_out),
         .MemEnable2_out(memenable2_exe_mem_out),
         .MemEnable3_out(memenable3_exe_mem_out),
         .MemorIOtoReg_out(memoriotoreg_exe_mem_out),    //��IO
         .IORead_out(ioread_exe_mem_out),          //��IO
         .MemRead_out(memread_exe_mem_out),
         .ALU_Result_out(alu_result_exe_mem_out),
         .RegWrite_out(regwrite_exe_mem_out),
         .write_register_address_out(write_register_address_exe_mem_out),
         .r_hi_out(r_hi_exe_mem_out),
         .r_lo_out(r_lo_exe_mem_out),
         .w_hi_out(w_hi_exe_mem_out),
         .w_lo_out(w_lo_exe_mem_out),
         .hi_data_out(hi_data_exe_mem_out),
         .lo_data_out(lo_data_exe_mem_out),
         .Jal_out(jal_exe_mem_out),
         .Jalr_out(jalr_exe_mem_out),
         .bgezal_out(bgezal_exe_mem_out),
         .bltzal_out(bltzal_exe_mem_out),
         .compare_out(compare_exe_mem_out),
         .pc_plus_4_out(pc_plus_4_exe_mem_out)
	);
	
	assign mem_wb_reset=(reset==1)?1'b1:1'b0;
    assign mem_wb_enable=1'b1;
    
	mem_wb_reg mem_wb(
	     .clock(clock),
         .reset(mem_wb_reset),
         .mem_wb_enable(mem_wb_enable),
         .MemorIOtoReg_in(memoriotoreg_exe_mem_out),  
         .ALU_Result_in(alu_result_exe_mem_out),
         .RegWrite_in(regwrite_exe_mem_out),
         .write_register_address_in(write_register_address_exe_mem_out),
         .r_hi_in(r_hi_exe_mem_out),
         .r_lo_in(r_lo_exe_mem_out),
         .w_hi_in(w_hi_exe_mem_out),
         .w_lo_in(w_lo_exe_mem_out),
         .hi_data_in(hi_data_exe_mem_out),
         .lo_data_in(lo_data_exe_mem_out),
         .write_data_in(memoriodata_mem_wb_in),
         .Jal_in(jal_exe_mem_out),
         .Jalr_in(jalr_exe_mem_out),
         .bgezal_in(bgezal_exe_mem_out),
         .bltzal_in(bltzal_exe_mem_out),
         .compare_in(compare_exe_mem_out),
         .pc_plus_4_in(pc_plus_4_exe_mem_out),
         .MemorIOtoReg_out(memoriotoreg_mem_wb_out),
         .ALU_Result_out(alu_result_mem_wb_out),
         .RegWrite_out(regwrite_mem_wb_out),
         .write_register_address_out(write_register_address_mem_wb_out),
         .r_hi_out(r_hi_mem_wb_out),
         .r_lo_out(r_lo_mem_wb_out),            
         .w_hi_out(w_hi_mem_wb_out),
         .w_lo_out(w_lo_mem_wb_out),
         .hi_data_out(hi_data_mem_wb_out),
         .lo_data_out(lo_data_mem_wb_out),
         .write_data_out(memoriodata_mem_wb_out),
         .Jal_out(jal_mem_wb_out),
         .Jalr_out(jalr_mem_wb_out),
         .bgezal_out(bgezal_mem_wb_out),
         .bltzal_out(bltzal_mem_wb_out),
         .compare_out(compare_mem_wb_out),
         .pc_plus_4_out(pc_plus_4_mem_wb_out)

	);
	
    //assign write_data=(memwrite==1)?read_data_2:32'bz;
//    dmemory32 memory (
//        .ram_clk_i		(clock),
//        .ram_wen_i	(memwrite),			    // ���Կ��Ƶ�Ԫ
//        .ram_adr_i		(alu_result[15:2]),	        // ����memorioģ�飬Դͷ������ִ�е�Ԫ�����alu_result
//        .ram_dat_i		(write_data),		        // �������뵥Ԫ��read_data2
//        .ram_dat_o		(read_data),		        // �Ӵ洢���л�õ�����
//		// UART Programmer Pinouts
//		.upg_rst_i		(upg_rst),			// UPG reset (Active High)
//		.upg_clk_i		(upg_clk_o),		// UPG clock (10MHz)
//		.upg_wen_i		(upg_wen_o & upg_adr_o[14]),	// UPG write enable
//		.upg_adr_i		(upg_adr_o[13:0]),	// UPG write address
//		.upg_dat_i		(upg_dat_o),		// UPG write data
//		.upg_done_i		(upg_done_o)		// 1 if programming is finished
//    );
	
//    memorio memio(
//        .caddress		(alu_result),
//        .address		(address),
//        .memread		(memread),
//        .memwrite		(memwrite),
//        .ioread			(ioread),
//        .iowrite		(iowrite),
//        .mread_data		(read_data),
//        .ioread_data	(ioread_data),
//        .wdata			(read_data_2),
//        .rdata			(rdata),
//        .write_data		(write_data),
//        .LEDCtrl		(ledctrl),
//        .SwitchCtrl		(switchctrl)
//    );
    
//    ioread multiioread(
//        .reset				(rst),
//        .ior				(ioread),
//        .switchctrl			(switchctrl),
//        .ioread_data		(ioread_data),
//        .ioread_data_switch	(ioread_data_switch)
//    );
	
//    leds led24(
//        .ledrst			(rst),
//        .led_clk		(clock),
//       ???
//	);
	
//	switchs switch24(
//        .switrst		(rst),
//		.switclk		(clock),
//        ???
//	);
	
endmodule
