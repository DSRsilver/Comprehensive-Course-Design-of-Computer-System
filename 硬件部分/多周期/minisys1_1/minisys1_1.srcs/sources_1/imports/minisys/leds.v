`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module leds (
    input			ledrst,		// ��λ�ź�
    input			led_clk,	// ʱ���ź�
    input			ledwrite,	// д�ź�
    input			ledcs,		// ��memorio���ģ��ɵ�����λ�γɵ�LEDƬѡ�ź�   !!!!!!!!!!!!!!!!!
    input	[1:0]	ledaddr,	// ��LEDģ��ĵ�ַ�Ͷ�  !!!!!!!!!!!!!!!!!!!!
    input	[15:0]	ledwdata,	// д��LEDģ������ݣ�ע��������ֻ��16��
    output	[23:0]	ledout		// ������������24λLED�ź�
);
  
    reg [23:0] ledout;
    
    always@(posedge led_clk or posedge ledrst) begin
    
        // �ڴ˴���дLDEģ��Ĵ���
  
    end
endmodule
