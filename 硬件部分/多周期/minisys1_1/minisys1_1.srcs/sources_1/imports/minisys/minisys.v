`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module minisys (fpga_rst,fpga_clk,led2N4,start_pg,rx,tx );
    input			fpga_rst;	        // 板上的Reset信号，高电平复位
    input			fpga_clk;	    // 板上的100MHz时钟信号
 //   input	[23:0]	switch2N4;	// 拨码开关输入
    output	[23:0]	led2N4;		// LED结果输出到板上
	// UART Programmer Pinouts
	input           start_pg;           // 接板上的S3按键做下载启动键
	input           rx;                      // UART接收
	output          tx;                     // UART发送

    
    wire[1:0] wpc;
    wire wir;
    wire waluresult;
    wire clock;				            //clock: 分频后时钟供给系统
    wire reset;
    wire iowrite,ioread;	        //I/O读写信号
    wire [31:0] write_data;	    //写RAM或IO的数据
    wire [31:0] rdata;		        //读RAM或IO的数据
    wire [15:0] ioread_data;	//读IO的数据
    wire [31:0] pc_plus_4;	    //PC+4
    wire [31:0] read_data_1;	
    wire [31:0] read_data_2;	
    wire [31:0] sign_extend;	//符号扩展
    wire [31:0] add_result;	
    wire [31:0] alu_result;	
    wire [31:0] read_data;	    //RAM中读取的数据
    wire [31:0] address;
    wire alusrc;
    wire branch;
    wire nbranch,jmp,jal,jrn,i_format;
    wire regdst;
    wire regwrite;
    wire zero;
    wire memwrite;
    wire memread;
    wire memoriotoreg;
    wire memreg;
    wire sftmd;
    wire[1:0] aluop;
    wire[31:0] instruction;
    wire[31:0] opcplus4;
	wire [13:0] rom_adr;
	wire [31:0] rom_dat;
    wire ledctrl,switchctrl;
    wire[15:0] ioread_data_switch;
    wire rst;
	// UART Programmer Pinouts
	wire upg_clk, upg_clk_o, upg_wen_o, upg_done_o;
	wire [14:0] upg_adr_o;
	wire [31:0] upg_dat_o;
	wire [31:0] pc;
	wire[4:0] read_register_1_address;

	wire spg_bufg;
	BUFG U1(.I(start_pg), .O(spg_bufg));	    // S3按键去抖
    
	// Generate UART Programmer reset signal
	reg upg_rst;
	always @ (posedge fpga_clk) begin
		if (spg_bufg)	upg_rst = 0;
		if (fpga_rst)	upg_rst = 1;
	end
	
	assign rst = fpga_rst | !upg_rst;
	
	assign reset=!fpga_rst;
	
    cpuclk cpuclk (
        .clk_in1		    (fpga_clk),	    // 100MHz, 板上时钟
        .clk_out1		(clock),    	    // CPU Clock (23MHz), 主时钟
		.clk_out2		(upg_clk)		// UPG Clock (10MHz), 用于串口下载
    );
	
	uart_bmpg_0 uartpg (                // 此模块已经接好，只作为串口下载的附件，可不去关注
		.upg_clk_i		(upg_clk),		// 10MHz   
		.upg_rst_i		(upg_rst),		// 高电平有效
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
		.rom_clk_i		(clock),		    // 给CPU的23MHz的主时钟
		.rom_adr_i		(rom_adr),		// 取指单元给ROM的地址（PC）
		.Jpadr			(rom_dat),		    // ROM中读的数据（指令）
		// UART Programmer Pinouts, 以下是串口下载所用，可不必关注
		.upg_rst_i		(upg_rst),		// UPG reset (高电平有效)
		.upg_clk_i		(upg_clk_o),	// UPG clock (10MHz)
		.upg_wen_i		(upg_wen_o & !upg_adr_o[14]),	// UPG write enable
		.upg_adr_i		(upg_adr_o[13:0]),	// UPG write address
		.upg_dat_i		(upg_dat_o),	            // UPG write data
		.upg_done_i		(upg_done_o)	    // 1 if programming is finished
	);
    
    Ifetc32 ifetch(
        .Instruction	(instruction),
        .PC_plus_4_out	(pc_plus_4),
        .Wpc(wpc),//in
        .Wir(wir),//in
        .Add_result(add_result),//in
        .Jmp(jmp),//in
        .Jal(jal),//in
        .Read_data_1(read_data_1),//in
        .clock(clock),//in
        .reset(reset),//in
        .opcplus4(opcplus4),//out
        .PC_out(pc),
		// ROM Pinouts
		.rom_adr_o		(rom_adr),
		.Jpadr			(rom_dat)
    );
    
    Idecode32 idecode(
        .read_data_1	(read_data_1),
        .read_data_2	(read_data_2),
        .Instruction(instruction),//in
        .read_data(read_data),//in
        .ALU_result(alu_result),//in
        .MemorIOtoReg(memoriotoreg),//in
       // .MemorIOtoReg(memreg),//in
        .RegWrite(regwrite),//in
        .RegDst(regdst),//in
        .Sign_extend(sign_extend),//in
        .Jal(jal),//in
        //   .PC_next(pc_next),
        .clock(clock),//in
        .reset(reset),//in
        .opcplus4(opcplus4),//in
        .read_register_1_address(read_register_1_address)//out
    );
    
    control32 control(
        .clock(clock),//in
        .reset(reset),//in
        .Zero(zero),//in
        .Wpc(wpc),//out
        .Wir(wir),//out
        .Waluresult(waluresult),//out
        .Opcode			(instruction[31:26]),//in
        .Function_opcode(instruction[5:0]),//in
        .Alu_resultHigh(alu_result[31:10]),//in
        .RegDST(regdst),//out
        .ALUSrc(alusrc),//out
        .MemorIOtoReg(memoriotoreg),//out
        .RegWrite(regwrite),//out
        .MemWrite(memwrite),//out
        .MemRead(memread),//out
        .IOWrite(iowrite),//out
        .IORead(ioread),//out
        .ALUOp(aluop),//out
        .I_format(i_format),//out
        .Branch(branch),//out
        .nBranch(nbranch),//out
        .Sftmd(sftmd),//out
        .Jal(jal),//out
        .Jrn(jrn),//out
        .Jmp(jmp)//out
    );
	
    Executs32 execute(
        .clock(clock),
        .reset(reset),
        .Waluresult(waluresult),
        .Read_data_1	(read_data_1),
        .Read_data_2	(read_data_2),
        .Sign_extend(sign_extend),
        .Function_opcode(instruction[5:0]),
        .Shamt(instruction[10:6]),
        .Exe_opcode(instruction[31:26]),
        .Sftmd(sftmd),
        .ALUOp(aluop),
        .ALUSrc(alusrc),
        .ALU_Result(alu_result),
        .Add_Result(add_result),
        .I_format(i_format),
        .Jrn(jrn),
        .Zero(zero),
        .PC_plus_4(pc_plus_4)
       
	);
    assign write_data=(memwrite==1)?read_data_2:32'bz;
    dmemory32 memory (
        .ram_clk_i		(clock),
        .ram_wen_i	(memwrite),			    // 来自控制单元
        .ram_adr_i		(alu_result[15:2]),	        // 来自memorio模块，源头是来自执行单元算出的alu_result
        .ram_dat_i		(write_data),		        // 来自译码单元的read_data2
        .ram_dat_o		(read_data),		        // 从存储器中获得的数据
		// UART Programmer Pinouts
		.upg_rst_i		(upg_rst),			// UPG reset (Active High)
		.upg_clk_i		(upg_clk_o),		// UPG clock (10MHz)
		.upg_wen_i		(upg_wen_o & upg_adr_o[14]),	// UPG write enable
		.upg_adr_i		(upg_adr_o[13:0]),	// UPG write address
		.upg_dat_i		(upg_dat_o),		// UPG write data
		.upg_done_i		(upg_done_o)		// 1 if programming is finished
    );
	
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
