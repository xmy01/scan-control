`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/08 19:55:13
// Design Name: 
// Module Name: key
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


module key(
    input   wire    clk_100m,
    input   wire    key_i,

    output  reg     reset
    );
    
    reg     reset  =  1'b1;
    
    wire key_cap;
    
    always @(posedge clk_100m)begin
        if(key_cap)begin
            reset <= ~reset;  
        end else reset <= reset;
    end
    
    key0#
    (
        .CLK_FREQ(100000000)
    )
    u_key0
    (
        .clk_i(clk_100m),
        .key_i(key_i),
        .key_cap(key_cap)
    );
    
endmodule
