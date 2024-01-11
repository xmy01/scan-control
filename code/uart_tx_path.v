`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*
Company : Liyang Milian Electronic Technology Co., Ltd.
Brand: ������(msxbo)
Technical forum��uisrc.com
taobao: osrc.taobao.com
Create Date: 2020/05/22
Module Name: uart_tx_path
Description: 
The baud rate of this serial port is 9600
Copyright: Copyright (c) msxbo
Revision: 1.0
Signal description��
1) _i input
2) _o output
3) _n activ low
4) _dg debug signal 
5) _r delay or register
6) _s state mechine
*/
//////////////////////////////////////////////////////////////////////////////////
module uart_tx_path(
	input clk_i,
	input [7:0] uart_tx_data_i,	//����������
	input uart_tx_en_i,			//���ͷ���ʹ���ź�
	output uart_tx_o,
	output uart_busy
);

parameter [13:0] BAUD_DIV     = 14'd10416;//������ʱ�ӣ�9600bps��100Mhz/9600 - 1'b1=5207
//�����ʷ�������ʵ�ʾ��Ƿ�����
reg bps_start_en = 1'b0;
reg [13:0] baud_div = 13'd0;

assign uart_busy = bps_start_en;

always@(posedge clk_i)begin
    if(bps_start_en && baud_div < BAUD_DIV)	
        baud_div <= baud_div + 1'b1;
    else 
        baud_div <= 14'd0;
end

reg [9:0] uart_tx_data_r = 10'h3ff;
wire bps_en = (baud_div == BAUD_DIV);
reg [3:0] tx_cnt = 4'd0;
assign uart_tx_o = uart_tx_data_r[0];
always@(posedge clk_i)begin
//���ȵ�����ʹ����Ч���Ĵ�����
    if(uart_tx_en_i) begin
        bps_start_en <= 1'b1;
        tx_cnt <= 4'd0;
        uart_tx_data_r <= {1'b1,uart_tx_data_i[7:0],1'b0};
    end
    else if(!bps_start_en)begin//��bps_start_enΪ0��״̬������ֹͣ״̬
        uart_tx_data_r <= 10'h3ff;
        tx_cnt <= 4'd0;
    end
// ͨ����λ��������
    if(bps_en && tx_cnt < 4'd9)begin
         uart_tx_data_r <= {uart_tx_data_r[0],uart_tx_data_r[9:1]};
         tx_cnt <= tx_cnt + 1'b1;
    end
    else if(bps_en)begin
         bps_start_en <= 1'd0;
    end
end   

endmodule
