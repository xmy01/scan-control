`timescale 1ns / 1ps


module signal(
    input   wire              reset,      
    input   wire              sys_clk_100M,
    input   wire              clk_400m,
    input   wire              clk_200m,
    input   wire              uart_rx_i,   
    input   wire              txdone,
    input   wire    [7:0]     frame_nums,
    input   wire    [7:0]     pixel_nums,
    input   wire    [7:0]     laser_nums,
    input   wire    [7:0]     spad_nums,
    input   wire    [8:0]     i_cnt_value,
    input   wire    [31:0]     sig_start_frame,
    input   wire    [15:0]     duty_cycle_frame, 
    input   wire    [31:0]     sig_start_spad,
    input   wire    [15:0]     duty_cycle_spad,
    input   wire    [31:0]     sig_start_pixel,
    input   wire    [15:0]     duty_cycle_pixel,   
    input   wire    [31:0]     sig_start_laser,
    input   wire    [15:0]     duty_cycle_laser,
    input   wire    [63:0]    frame_period,
    input   wire    [31:0]    pixel_period,
    input   wire    [31:0]    laser_period,
    input   wire    [31:0]    spad_period,
    
    output  wire              uart_tx_o,
    output  wire              frame,       
    output  wire              pixel,   
    output  wire              laser,
    output  wire              spad,   
    output  wire              spad_fine,
    output  wire              o_idelay_rdy
    );
    
    
    reg  frame_reset     = 1'b1;
    reg  pixel_reset     = 1'b1;
    reg  laser_reset     = 1'b1;
    reg  spad_reset      = 1'b1;
    reg  frame_start     = 1'b0;
    reg  pixel_start     = 1'b0;
    reg  laser_start     = 1'b0;
    reg  spad_start      = 1'b0;     
    wire frame_done;
    wire pixel_done;
    wire laser_done;
    wire spad_done;
    reg  txdone_r        = 1'b0;
    reg  frame_done_r    = 1'b0;
    reg  pixel_done_r    = 1'b0;
    reg  txdone_r2       = 1'b0;
    reg  txdone_r3       = 1'b0;
    reg  txdone_r4       = 1'b0;
    reg  txdone_r5       = 1'b0;
    reg  txdone_r6       = 1'b0;
    reg  laser_done_r    = 1'b0;
    reg  spad_done_r     = 1'b0;
    reg  frame_r         = 1'b0;    
    reg  pixel_r         = 1'b0;
    reg  frame_r2        = 1'b0;    
    reg  pixel_r2        = 1'b0;
    reg  frame_r3        = 1'b0;    
    reg  pixel_r3        = 1'b0;
    
    always @(posedge clk_400m)begin
        frame_done_r  <= frame_done; 
        txdone_r      <= txdone;
        txdone_r2     <= txdone_r;
        txdone_r3     <= txdone_r2;
        
        
        if(!txdone_r && txdone)begin
            frame_reset <= 1'b0;
        end else if(!frame_done_r && frame_done)begin
            frame_reset <= 1'b1;
        end else frame_reset <= frame_reset;
    end
    
    always @(posedge clk_400m)begin 
        pixel_done_r  <= pixel_done; 
        txdone_r4     <= txdone_r3;
        txdone_r5     <= txdone_r4;
        txdone_r6     <= txdone_r5;
        
        if(!txdone_r4 && txdone_r3)begin
            pixel_reset <= 1'b0;
        end else if(!pixel_done_r && pixel_done)begin
            pixel_reset <= 1'b1;
        end else pixel_reset <= pixel_reset;
    end
    
    always @(posedge clk_400m)begin
        laser_done_r  <= laser_done; 
        pixel_r   <= pixel;
        pixel_r2  <= pixel_r;
        pixel_r3  <= pixel_r2;      
        
        if(!pixel_r && pixel)begin
            laser_reset <= 1'b0;
        end else if(!laser_done_r && laser_done)begin
            laser_reset <= 1'b1;
        end else laser_reset <= laser_reset;
    end
    
    always @(posedge clk_400m)begin
        spad_done_r  <= spad_done; 
        pixel_r   <= pixel;
        pixel_r2  <= pixel_r;
        pixel_r3  <= pixel_r2;       
        
        if(!pixel_r && pixel)begin
            spad_reset <= 1'b0;
        end else if(!spad_done_r && spad_done)begin
            spad_reset <= 1'b1;
        end else spad_reset <= spad_reset;
    end 
    
    counter_frame u_counter_frame(
        .reset                  (frame_reset),
        .start                  (txdone_r3),
        .sig_period             (frame_period),
        .sig_start              (sig_start_frame),
        .duty_cycle             (duty_cycle_frame),
        .ref_clk_400m           (clk_400m),
        .ref_clk_200m           (clk_200m),
        .cnt_nums               (frame_nums),
        
        .done                   (frame_done),
        .ref_signal             (frame)
    );
    
    counter counter_pixel(
        .reset                  (pixel_reset),
        .start                  (txdone_r6),
        .sig_period             (pixel_period),
        .sig_start              (sig_start_pixel),
        .duty_cycle             (duty_cycle_pixel),
        .ref_clk_400m           (clk_400m),
        .ref_clk_200m           (clk_200m),
        .cnt_nums               (pixel_nums),
        
        .done                   (pixel_done),
        .ref_signal             (pixel)
    );
    
  
    
    counter counter_laser(
        .reset                  (laser_reset),
        .start                  (pixel_r3),
        .sig_period             (laser_period),
        .sig_start              (sig_start_laser),
        .duty_cycle             (duty_cycle_laser),
        .ref_clk_400m           (clk_400m),
        .ref_clk_200m           (clk_200m),
        .cnt_nums               (laser_nums),
        
        .done                   (laser_done),
        .ref_signal             (laser)
    );
    
    
    
    counter counter_spad(
        .reset                  (spad_reset),
        .start                  (pixel_r3),
        .sig_period             (spad_period),
        .sig_start              (sig_start_spad),
        .duty_cycle             (duty_cycle_spad),
        .ref_clk_400m           (clk_400m),
        .ref_clk_200m           (clk_200m),
        .cnt_nums               (spad_nums),
        
        .done                   (spad_done),
        .ref_signal             (spad)
    );
    
    idelay3 u_idelay3(
        .reset                  (reset),
        .ref_signal             (spad),
        .i_cnt_value            (i_cnt_value),
        .ref_clk_400m           (clk_400m),
    
        .ref_signal_fine        (spad_fine),
        .o_idelay_rdy           (o_idelay_rdy)
    );
    
endmodule
