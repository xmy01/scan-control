`timescale 1ns / 1ps

module counter_frame(

    input  wire         reset,
    input  wire         start,
    input  wire [7:0]   cnt_nums,
    input  wire [63:0]  sig_period,
    input  wire [31:0]   sig_start,
    input  wire [15:0]  duty_cycle,
    input  wire         ref_clk_200m,
    input  wire         ref_clk_400m,
    
    output wire         ref_signal,
    output wire         done
    );
    
    
    reg       [63:0] cnt  =  64'd0;
    reg          start_r  =  1'b0;
    reg          done_r   =  1'b0;
    reg       flag_start  =  1'b0;
    reg     ref_signal_r  =  1'b0;
    reg      [7:0] count  =  8'b0;
    
    
    
    always@(posedge ref_clk_400m)begin
        start_r <= start;
        if(reset)begin
            flag_start <= 1'b0; 
        end if(!start_r && start)begin
            flag_start <= 1'b1;
        end else begin end
    end
    
    
    always@(posedge ref_clk_200m)begin
        if(reset)begin
            cnt        <= 0;
            count      <= 0;
        end else if( cnt == (sig_period - 1'b1) )begin
            cnt <= 0;
            count <= count + 1;
        end else if(flag_start) begin
            cnt <= cnt + 1;
        end else cnt <= cnt;   
    end
    
    always@(posedge ref_clk_200m)begin
        if(reset)begin
            done_r   <=   1'b0;
        end else if((count==cnt_nums-1'b1)&&(cnt==sig_period-1'b1))begin
            done_r   <=   1'b1;
        end else done_r   <=   done_r;
    end
    
    
    always@(posedge ref_clk_200m)begin
        if(cnt == (sig_start - 1) || cnt == (sig_start + duty_cycle - 1))begin
            ref_signal_r <= ~ref_signal_r;
        end else if(cnt == (sig_period - 1) || cnt == (sig_period - duty_cycle - 1))begin
            ref_signal_r <= ~ref_signal_r;
        end else begin
            ref_signal_r <= ref_signal_r;
        end
    end
    
    
    assign  ref_signal     = ref_signal_r;
    assign  done           = done_r;
    
   
endmodule
