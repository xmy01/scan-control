`timescale 1ns / 1ps



module top_scan(
    input   wire            clk,
    input   wire            clk_100m,
    input   wire            reset,
    input   wire   [15:0]   nx_pix,
    input   wire   [15:0]   ny_pix,
    input   wire   [31:0]   pixel_time,
    input   wire   [15:0]   nx_min,
    input   wire   [15:0]   nx_max,
    input   wire   [15:0]   ny_min,
    input   wire   [15:0]   ny_max,
    input   wire   [7:0]    zero_point,
    input   wire            send_en,

    output  wire            sendck,
    output  wire            sync,
    output  wire            chl_x,
    output  wire            chl_y,
    output  wire            txdone,
    output  wire            xy2_state,
    output  wire            xy2_send
    );
    

    wire [15:0] x_coord;
    wire [15:0] y_coord;
    
    
    
    xy2_100 u_xy2_100(
    //port list
        .rst_n                  (~reset),
        .clk50m                 (clk),
        .send_en                (xy2_send),
        .x_data                 (x_coord),
        .y_data                 (y_coord),
        
 
        .sendck                 (sendck),
        .sync                   (sync),
        .chl_x                  (chl_x),
        .chl_y                  (chl_y),
        .txdone                 (txdone),
        .xy2_state              (xy2_state)
    );
    

//    ScannerControl ScannerControl_inst(
//        .clk                (clk),          
//        .rst_n              (~reset),   
//        .start_scan         (send_en), 
//        .nx_min             (nx_min),
//        .nx_max             (nx_max),
//        .ny_min             (ny_min),
//        .ny_max             (ny_max),
//        .back2zero          (zero_point[0]),
//        .nx_pix             (nx_pix), 
//        .ny_pix             (ny_pix), 
//        .flag_duration      (pixel_time),
//        .x_coord            (x_coord), 
//        .y_coord            (y_coord),
//        .scan_done          (scan_done),
//        .pixel_done         (pixel_done)  
//    );

    scancontrol scancontrol_inst(
        .clk                (clk),    
        .clk_100m           (clk_100m),      
        .reset              (reset),   
        .start_scan         (send_en), 
        .nx_min             (nx_min),
        .nx_max             (nx_max),
        .ny_min             (ny_min),
        .ny_max             (ny_max),
        .nx_pix             (nx_pix), 
        .ny_pix             (ny_pix), 
        .flag_duration      (pixel_time),
        .x_coord            (x_coord), 
        .y_coord            (y_coord),
        .xy2_send           (xy2_send) 
    );   
    
endmodule


