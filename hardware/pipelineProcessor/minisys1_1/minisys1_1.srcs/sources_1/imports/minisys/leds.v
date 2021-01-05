`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module leds (
    input			ledrst,		// 复位信号
    input			led_clk,	// 时钟信号
    input			ledwrite,	// 写信号
    input			ledcs,		// 从memorio来的，由低至高位形成的LED片选信号   !!!!!!!!!!!!!!!!!
    input	[1:0]	ledaddr,	// 到LED模块的地址低端  !!!!!!!!!!!!!!!!!!!!
    input	[15:0]	ledwdata,	// 写到LED模块的数据，注意数据线只有16根
    output	[23:0]	ledout		// 向板子上输出的24位LED信号
);
  
    reg [23:0] ledout;
    
    always@(posedge led_clk or posedge ledrst) begin
    
        // 在此处填写LDE模块的代码
  
    end
endmodule
