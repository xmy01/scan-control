`timescale 1ns / 1ps



module top(
    input   wire    uart_rx_i,
    input   wire    diff_clock_clk_p,
	input   wire    diff_clock_clk_n,
    input   wire    key_i,
    
    //output  wire    locked,
    output  wire    uart_tx_o,
    
    output  wire    sendck,
    output  wire    sync,
    output  wire    chl_x,
    output  wire    chl_y,
    output  wire    txdone,
    output  wire    xy2_state,
    
    output  wire    frame,       
    output  wire    pixel,   
    output  wire    laser,
    output  wire    spad,
    output  wire    spad_fine,
    output  wire    u_laser,
    output  wire    u_spad,
    output  wire    u_spad_fine,    
    output  wire    card_power_en,
    output  wire    m50,
    output  wire    reset
);
    
    wire clk;
    //对差分时钟采用 IBUFGDS IP 核去转换
    IBUFGDS CLK_U(
    .I(diff_clock_clk_p),
    .IB(diff_clock_clk_n),
    .O(clk)
    );
    
    M50 u_M50(
        .clk    (clk),
    
        .m50    (m50)
    );
    
    assign  card_power_en   =   1'b1;  
    
    ip_clock u_ip_clock(
        .clk             (clk),
           
        .locked          (),
        .clk_out_57m     (clk_57m),
        .clk_out_50m     (clk_50m)
    );
    
    ip_clock1 u_ip_clock1(
        .clk            (clk),

        .clk_out_200m   (clk_out_200m),
        .clk_out_400m   (clk_out_400m)
    );
 
    
    wire [7:0]  uart_rx_data_o;
    wire        uart_busy;
    reg         uart_busy_r  = 1'b0;
    reg         uart_busy_r1 = 1'b0;
    reg  [7:0]  negedge_cnt  = 7'b0;
    reg         send_en_r    = 1'b0;
    reg         send_en_r2   = 1'b0;
    reg         send_en_r3   = 1'b0;
    
    reg  [7:0]  cnt = 7'b0;
    
    reg  [15:0] nx_pix;
    reg  [15:0] ny_pix;
    reg  [31:0] pixel_time;
    reg  [15:0] nx_min;   
    reg  [15:0] nx_max;
    reg  [15:0] ny_min;
    reg  [15:0] ny_max;
    reg  [7:0]  zero_point;
    
    
    reg  [7:0]  frame_nums;
    reg  [7:0]  pixel_nums;
    reg  [7:0]  laser_nums;
    reg  [7:0]  spad_nums;
    reg  [31:0]  sig_start_frame;
    reg  [15:0]  duty_cycle_frame;
    reg  [31:0]  sig_start_pixel;
    reg  [15:0]  duty_cycle_pixel;
    reg  [31:0]  sig_start_laser;
    reg  [15:0]  duty_cycle_laser;
    reg  [31:0]  sig_start_spad;
    reg  [15:0]  duty_cycle_spad;
    reg  [63:0] frame_period;
    reg  [31:0] pixel_period;
    reg  [31:0] laser_period;
    reg  [31:0] spad_period;
    reg  [8:0]  i_cnt_value;
    
    uart_tx_path u_uart_tx_path(
        .clk_i                              (clk),
        .uart_tx_data_i                     (uart_rx_data_o), //待发送数据
        .uart_tx_en_i                       (uart_rx_done), //发送发送使能信号
        
        .uart_tx_o                          (uart_tx_o),
        .uart_busy                          (uart_busy)
    );
    
    uart_rx_path u_uart_rx_path(
        .clk_i                              (clk),
        .uart_rx_i                          (uart_rx_i),
        
        .uart_rx_data_o                     (uart_rx_data_o),
        .uart_rx_done                       (uart_rx_done)
    );
    
    always@(posedge clk)begin
        if(!reset && uart_rx_done && cnt==7'b0000000)begin
            sig_start_frame[31:24]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0000001)begin
            sig_start_frame[23:16]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0000010)begin
            sig_start_frame[15:8]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0000011)begin
            sig_start_frame[7:0]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0000100)begin
            duty_cycle_frame[15:8]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0000101)begin
            duty_cycle_frame[7:0]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0000110)begin
            sig_start_pixel[31:24] <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0000111)begin
            sig_start_pixel[23:16] <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0001000)begin
            sig_start_pixel[15:8] <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0001001)begin
            sig_start_pixel[7:0] <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0001010)begin
            duty_cycle_pixel[15:8]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0001011)begin
            duty_cycle_pixel[7:0]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0001100)begin
            sig_start_laser[31:24]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0001101)begin
            sig_start_laser[23:16]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0001110)begin
            sig_start_laser[15:8]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0001111)begin
            sig_start_laser[7:0]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0010000)begin
            duty_cycle_laser[15:8]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0010001)begin
            duty_cycle_laser[7:0]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0010010)begin
            frame_period[63:56]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0010011)begin
            frame_period[55:48]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0010100)begin
            frame_period[47:40]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0010101)begin
            frame_period[39:32]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0010110)begin
            frame_period[31:24]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0010111)begin
            frame_period[23:16]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0011000)begin
            frame_period[15:8]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0011001)begin
            frame_period[7:0]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0011010)begin
            pixel_period[31:24]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0011011)begin
            pixel_period[23:16]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0011100)begin
            pixel_period[15:8]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0011101)begin
            pixel_period[7:0]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0011110)begin
            laser_period[31:24]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0011111)begin
            laser_period[23:16]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0100000)begin
            laser_period[15:8]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0100001)begin
            laser_period[7:0]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0100010)begin
            frame_nums[7:0]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0100011)begin
            pixel_nums[7:0]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0100100)begin
            laser_nums[7:0]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0100101)begin
            nx_pix[15:8]      <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0100110)begin
            nx_pix[7:0]      <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0100111)begin
            ny_pix[15:8]      <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0101000)begin
            ny_pix[7:0]      <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0101001)begin
            nx_min[15:8]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0101010)begin
            nx_min[7:0]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0101011)begin
            nx_max[15:8]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0101100)begin
            nx_max[7:0]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0101101)begin
            ny_min[15:8]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0101110)begin
            ny_min[7:0]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0101111)begin
            ny_max[15:8]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0110000)begin
            ny_max[7:0]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0110001)begin
            pixel_time[31:24]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0110010)begin
            pixel_time[23:16]  <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0110011)begin
            pixel_time[15:8]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0110100)begin
            pixel_time[7:0]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0110101)begin
            zero_point[7:0]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0110110)begin
            i_cnt_value[8:1]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0110111)begin
            i_cnt_value[0]   <= uart_rx_data_o[0];
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0111000)begin
            spad_nums[7:0]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0111001)begin
            sig_start_spad[31:24]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0111010)begin
            sig_start_spad[23:16]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0111011)begin
            sig_start_spad[15:8]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0111100)begin
            sig_start_spad[7:0]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0111101)begin
            duty_cycle_spad[15:8]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0111110)begin
            duty_cycle_spad[7:0]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b0111111)begin
            spad_period[31:24]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b1000000)begin
            spad_period[23:16]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b1000001)begin
            spad_period[15:8]   <= uart_rx_data_o;
            cnt <= cnt + 1'b1; 
        end else if(!reset && uart_rx_done && cnt==7'b1000010)begin
            spad_period[7:0]   <= uart_rx_data_o;
            cnt <= 7'b0000000; 
        end   
    end
    



    always@(posedge clk)begin
        uart_busy_r  <= uart_busy; 
        uart_busy_r1 <= uart_busy_r;   
    end
    
    wire busy_negedge = (!uart_busy_r&&uart_busy_r1);
    
    always@(posedge clk)begin
        send_en_r2   <=   send_en_r;
        send_en_r3   <=   send_en_r2;
           
        if(busy_negedge)begin
            negedge_cnt <=  negedge_cnt + 1;     
        end else if(!reset && negedge_cnt == 7'b1000011)begin
            send_en_r   <=  1'b1;
            negedge_cnt <=  7'b0;
        end else if(send_en_r3) begin send_en_r <= 1'b0; 
        end else begin end   
    end
    
    assign send_en = send_en_r;
    
//    ila_0 u_ila_0 (
//	.clk(clk), // input wire clk

//	.probe0(send_en), // input wire [0:0]  probe0  
//    .probe1(u_top_scan.scancontrol_inst.init),
//    .probe2(u_top_scan.scancontrol_inst.pixel_done_r),
//    .probe3(u_top_scan.scancontrol_inst.flag_r), 
//	.probe4(u_top_scan.scancontrol_inst.flag), 
//	.probe5(u_top_scan.scancontrol_inst.flag_counter), 
//	.probe6(u_top_scan.scancontrol_inst.x_count),
//	.probe7(u_top_scan.scancontrol_inst.flag_r2)
//    );

    
    top_scan u_top_scan(
        .clk                (clk_50m),
        .clk_100m           (clk),
        .reset              (reset),
        .nx_pix             (nx_pix),
        .ny_pix             (ny_pix),
        .pixel_time         (pixel_time),
        .nx_min             (nx_min),
        .nx_max             (nx_max),
        .ny_min             (ny_min),
        .ny_max             (ny_max),
        .zero_point         (zero_point),
        .send_en            (send_en),

        .sendck             (sendck),
        .sync               (sync),
        .chl_x              (chl_x),
        .chl_y              (chl_y),     
        .txdone             (txdone),      
        .xy2_state          (xy2_state),
        .xy2_send           (xy2_send) 
    );
    
    top_signal u_top_signal(
        .sys_clk_100M           (clk),
        .clk_200m               (clk_out_200m),
        .clk_400m               (clk_out_400m),
        .reset                  (reset),
        .txdone                 (txdone),
        .frame_nums             (frame_nums),
        .pixel_nums             (pixel_nums),
        .laser_nums             (laser_nums),
        .spad_nums              (spad_nums),
        .i_cnt_value            (i_cnt_value),
        .sig_start_frame        (sig_start_frame),
        .duty_cycle_frame       (duty_cycle_frame), 
        .sig_start_pixel        (sig_start_pixel),
        .duty_cycle_pixel       (duty_cycle_pixel),   
        .sig_start_laser        (sig_start_laser),
        .duty_cycle_laser       (duty_cycle_laser),
        .sig_start_spad         (sig_start_spad),
        .duty_cycle_spad        (duty_cycle_spad),
        .frame_period           (frame_period),
        .pixel_period           (pixel_period),
        .laser_period           (laser_period),
        .spad_period            (spad_period),
        
        .frame                  (frame),       
        .pixel                  (pixel),   
        .laser                  (laser),
        .spad                   (spad),
        .spad_fine              (spad_fine)
    );
    
    key u_key(
        .clk_100m               (clk),
        .key_i                  (key_i),

        .reset                  (reset)
    );
    
    assign  u_laser       =  ~laser;
    assign  u_spad        =  ~spad;
    assign  u_spad_fine   =  ~spad_fine;
    
endmodule
