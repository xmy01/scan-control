`timescale 1ns / 1ps

module top_signal(
    input   wire              sys_clk_100M,
    input   wire              clk_400m,
    input   wire              clk_200m,
    input   wire              reset,
    input   wire              txdone,
    input   wire    [7:0]     frame_nums,
    input   wire    [7:0]     pixel_nums,
    input   wire    [7:0]     laser_nums,
    input   wire    [7:0]     spad_nums,
    input   wire    [8:0]     i_cnt_value,
    input   wire    [31:0]     sig_start_frame,
    input   wire    [15:0]     duty_cycle_frame, 
    input   wire    [31:0]     sig_start_pixel,
    input   wire    [15:0]     duty_cycle_pixel,   
    input   wire    [31:0]     sig_start_laser,
    input   wire    [15:0]    duty_cycle_laser,
    input   wire    [31:0]     sig_start_spad,
    input   wire    [15:0]     duty_cycle_spad,
    input   wire    [63:0]    frame_period,
    input   wire    [31:0]    pixel_period,
    input   wire    [31:0]    laser_period,
    input   wire    [31:0]    spad_period,
    
    output  wire              frame,       
    output  wire              pixel,   
    output  wire              laser,
    output  wire              spad,       
    output  wire              spad_fine,   
    output  wire              o_idelay_rdy      
    );
    
    
    signal u_signal(
        .reset                  (reset),      
        .sys_clk_100M           (sys_clk_100M),
        .clk_400m               (clk_400m),
        .clk_200m               (clk_200m),  
        .txdone                 (txdone),
        .frame_nums             (frame_nums),
        .pixel_nums             (pixel_nums),
        .laser_nums             (laser_nums),
        .spad_nums              (spad_nums),
        .i_cnt_value            (i_cnt_value),
        .sig_start_frame        (sig_start_frame),
        .duty_cycle_frame       (duty_cycle_frame), 
        .sig_start_spad         (sig_start_spad),
        .duty_cycle_spad        (duty_cycle_spad),
        .sig_start_pixel        (sig_start_pixel),
        .duty_cycle_pixel       (duty_cycle_pixel),   
        .sig_start_laser        (sig_start_laser),
        .duty_cycle_laser       (duty_cycle_laser),
        .frame_period           (frame_period),
        .pixel_period           (pixel_period),
        .laser_period           (laser_period), 
        .spad_period            (spad_period),
    
        .frame                  (frame),       
        .pixel                  (pixel),   
        .laser                  (laser),
        .spad                   (spad),
        .spad_fine              (spad_fine),
        .o_idelay_rdy           (o_idelay_rdy)
    );
     
    
endmodule
