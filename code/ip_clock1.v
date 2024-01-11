`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/22 14:23:40
// Design Name: 
// Module Name: ip_clock1
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


module ip_clock1(
    input wire      clk,
    
    
    output wire     locked,
    output wire     clk_out_200m,
    output wire     clk_out_400m
    );
    
    clk_wiz_1 u_clk_wiz_1 
    (
    // Clock out ports
    .clk_out_200m                   (clk_out_200m),
    .clk_out_400m                   (clk_out_400m),
    // Status and control signals
    .locked                         (locked),
    // Clock in ports
    .clk_in1                        (clk)
    );
 
endmodule
