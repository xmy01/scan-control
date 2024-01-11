`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/30 13:58:18
// Design Name: 
// Module Name: 50M
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


module M50(
    input wire  clk,
    
    output wire m50
    );
    
    reg [7:0]   cnt = 8'd0;
    reg        flag = 1'b0;
    reg       m50_r = 1'b0;
    
    always@(posedge clk)begin
        cnt <= cnt + 1'b1;
        if(cnt==8'd24)begin
            cnt  <= 8'd0;
            flag <= 1'b1;        
        end else begin flag <= 1'b0; end
    end
    
    always@(posedge clk)begin
        if(flag)begin
            m50_r <= ~m50_r;    
        end else begin m50_r <= m50_r; end
    end

    assign m50 = m50_r;
endmodule

