`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module switchs (
    input			switrst,		// ��λ�ź�
    input			switclk,		// ʱ���ź�
    input			switchcs,		// ��memorio���ģ��ɵ�����λ�γɵ�switchƬѡ�ź�  !!!!!!!!!!!!!!!!!
    input	[1:0]	switchaddr,		// ��switchģ��ĵ�ַ�Ͷ�  !!!!!!!!!!!!!!!
    input			switchread,		// ���ź�
    output	[15:0]	switchrdata,	// �͵�CPU�Ĳ��뿪��ֵע����������ֻ��16��
    input	[23:0]	switch_i		// �Ӱ��϶���24λ��������
);

    reg [15:0] switchrdata;
    always@(negedge switclk or posedge switrst) begin
    
          //  �ڴ˴���д���뿪��ģ��Ĵ���
          
    end
endmodule
