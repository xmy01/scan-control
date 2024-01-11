`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/08 17:37:10
// Design Name: 
// Module Name: ip_clock
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ip_clock(
    input wire      clk,
        
    output wire     locked,
    output wire     clk_out_57m,
    output wire     clk_out_50m
    );
    
    clk_wiz_0 u_clk_wiz_0
    (
    // Clock out ports
    .clk_out1                 (clk_out_57m),
    .clk_out2                 (clk_out_50m),               
    // Status and control signals
    .locked                   (locked),
    // Clock in ports
    .clk_in1                  (clk)
    );
    
    
endmodule
