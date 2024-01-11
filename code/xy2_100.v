module xy2_100(
//端口列表
 rst_n,
 clk50m,
 send_en,
 x_data,
 y_data,
 
 sendck,
 sync,
 chl_x,
 chl_y,
 txdone,
 xy2_state
);
//端口定义
   input rst_n;
   input clk50m;
   input send_en;
   input [15:0]x_data;
   input [15:0]y_data;

   output reg sendck;
   output reg sync;
   output reg chl_x;
   output reg chl_y;
   output reg txdone;
   output reg xy2_state;

   reg [4:0]div_cnt;//分频计数器
	
	reg [4:0]bps_cnt;//波特率时钟计数器
	
	reg [15:0]r_data_x;
	reg [15:0]r_data_y;
	
	localparam bps_DR = 5'd24;     //分频计数最大值
	localparam CTRL_WD = 3'b001;  //控制字
	localparam MAX_BIT = 5'd20;
//发送状态信号
   always@(posedge clk50m or negedge rst_n)
	if(!rst_n)
		xy2_state <= 1'b0;
	else if(send_en)
		xy2_state <= 1'b1;
	else if(bps_cnt == MAX_BIT)
		xy2_state <= 1'b0;
	else
		xy2_state <= xy2_state;
//发送数据锁存
   always@(posedge clk50m or negedge rst_n)
	if(!rst_n)
	   r_data_x <= 15'd0;
	else if(send_en)
	   r_data_x <= x_data;
	else
	   r_data_x <= r_data_x;
		
	always@(posedge clk50m or negedge rst_n)
	if(!rst_n)
	   r_data_y <= 15'd0;
	else if(send_en)
	   r_data_y <= y_data;
	else
	   r_data_y <= r_data_y;
//分频计数器
   always@(posedge clk50m or negedge rst_n)
	if(!rst_n)
	   div_cnt <= 5'd0;
	else if(xy2_state||send_en) begin
	  if(div_cnt == bps_DR)
	    div_cnt <= 5'd0;
	  else 
	    div_cnt <= div_cnt+1'b1;
	 end
	else
	 div_cnt <= 5'd0;
// bps counter
   always@(posedge clk50m or negedge rst_n)
	if(!rst_n)
	 bps_cnt <= 5'd0;
	else if(bps_cnt==MAX_BIT)
	 bps_cnt <= 5'd0;
	else if(div_cnt==bps_DR)
	 bps_cnt <= bps_cnt + 1'b1;
	else
	 bps_cnt <= bps_cnt;
	 
// 发送完成信号
   always@(posedge clk50m or negedge rst_n)
	if(!rst_n)
	 txdone <= 1'b0;
	else if(bps_cnt == MAX_BIT)
	 txdone <= 1'b1;
	else 
	 txdone <= 1'b0;
	 
// x按位发送数据
   always@(posedge clk50m or negedge rst_n)
	if(!rst_n)
	  chl_x <= 1'b0;
	else if(div_cnt==5'd0) begin
	  case (bps_cnt)
	  	0:chl_x <= 1'b0; //c2
		1:chl_x <= 1'b0; //c1
		2:chl_x <= 1'b1; //c0
		3:chl_x <= r_data_x[15];
		4:chl_x <= r_data_x[14];
		5:chl_x <= r_data_x[13];
		6:chl_x <= r_data_x[12];
		7:chl_x <= r_data_x[11];
		8:chl_x <= r_data_x[10];
		9:chl_x <= r_data_x[9];
		10:chl_x <= r_data_x[8];
		11:chl_x <= r_data_x[7];
		12:chl_x <= r_data_x[6];
		13:chl_x <= r_data_x[5];
		14:chl_x <= r_data_x[4];
		15:chl_x <= r_data_x[3];
		16:chl_x <= r_data_x[2];
		17:chl_x <= r_data_x[1];
		18:chl_x <= r_data_x[0];
		19:chl_x <= ^{CTRL_WD,r_data_x};  //偶校验
		default:chl_x <= 1'b0;
	  endcase
	end
// y按位发送数据
   always@(posedge clk50m or negedge rst_n)
	if(!rst_n)
	  chl_y <= 1'b0;
	else if(div_cnt==5'd0) begin
	  case (bps_cnt)
	  	0:chl_y <= 1'b0; //c2
		1:chl_y <= 1'b0; //c1
		2:chl_y <= 1'b1; //c0
		3:chl_y <= r_data_y[15];
		4:chl_y <= r_data_y[14];
		5:chl_y <= r_data_y[13];
		6:chl_y <= r_data_y[12];
		7:chl_y <= r_data_y[11];
		8:chl_y <= r_data_y[10];
		9:chl_y <= r_data_y[9];
		10:chl_y <= r_data_y[8];
		11:chl_y <= r_data_y[7];
		12:chl_y <= r_data_y[6];
		13:chl_y <= r_data_y[5];
		14:chl_y <= r_data_y[4];
		15:chl_y <= r_data_y[3];
		16:chl_y <= r_data_y[2];
		17:chl_y <= r_data_y[1];
		18:chl_y <= r_data_y[0];
		19:chl_y <= ^{CTRL_WD,r_data_y};  //偶校验
		default:chl_y <= 1'b0;
	  endcase
	end

//同步信号
   always@(posedge clk50m or negedge rst_n)
	if(!rst_n)
	 sync <= 1'b0;
	else if(send_en)
	 sync <= 1'b1;
	else if(bps_cnt==(MAX_BIT-1))    //&&(div_cnt==5'd0))
	 sync <= 1'b0;
	else
	 sync <= sync;
//发送时钟信号
   always@(posedge clk50m or negedge rst_n)
	if(!rst_n)
	 sendck <= 1'b0;
	else if((xy2_state||send_en)&&(bps_cnt<MAX_BIT)) begin
	 if(div_cnt<=bps_DR/2)
	  sendck <= 1'b1;
	 else
	  sendck <= 1'b0;
	end
	else
	 sendck <= 1'b0;
endmodule
