`timescale 1ns / 1ps

module scancontrol(
  input  wire clk,                  // 时钟信号
  input  wire clk_100m,
  input  wire reset,                // 复位信号
  input  wire start_scan,           // 启动扫描信号
  input  wire [15:0] nx_pix,        // x轴长度nx_pix等份   像素数nx_pix+1
  input  wire [15:0] ny_pix,        // y轴长度ny_pix等份   像素数ny_pix+1
  input  wire [15:0] nx_min,
  input  wire [15:0] nx_max,
  input  wire [15:0] ny_min,
  input  wire [15:0] ny_max,
  input  wire [31:0] flag_duration, // 标志位持续时�????/控制单个像素扫描时间
  output wire [15:0] x_coord,       // 输出x坐标
  output wire [15:0] y_coord,       // 输出y坐标
  output wire xy2_send
);


reg  [15:0] x_count;
reg  [15:0] y_count;
reg  [16:0] x_coord_r;
reg  [16:0] y_coord_r;
reg  scan_in_progress3;
wire [15:0] dx;
wire [15:0] dy;


reg  [31:0] flag_counter  =   32'h0000;   // 标志位计数器
reg  flag                 =   1'b1;       // 标志�????
reg  scan_in_progress     =   1'b0;
reg  mode0                =   1'b0;
reg  mode1                =   1'b0;
reg  mode2                =   1'b0;
reg  mode0_done           =   1'b0;
reg  mode1_done           =   1'b0;
reg  mode2_done           =   1'b0;


assign dx = ((nx_max - nx_min) / nx_pix) +1;
assign dy = ((ny_max - ny_min) / ny_pix) +1;


//always @(posedge clk) begin
//  if (reset) begin
//    flag <= 1'b0;
//  end else if (flag_counter == 1'b1) begin
//    flag <= 1'b1;
//  end else if (!flag) begin
//    flag_counter <= flag_counter - 1'b1;
//  end
//end

always @(posedge clk or posedge reset) begin
  if (reset) begin
    mode0     <= 1'b0;
    mode1     <= 1'b0;
    mode2     <= 1'b0;
  end else if(start_scan && flag)begin
    if(nx_pix==0 && ny_pix==0)begin
      mode0   <= 1'b1;
    end else if(nx_pix==0 || ny_pix==0)begin
      mode1   <= 1'b1;
    end else if(nx_pix>0 && ny_pix>0)begin
      mode2   <= 1'b1;
    end
  end else if(mode0_done)begin
    mode0     <= 1'b0;
  end else if(mode1_done)begin
    mode1     <= 1'b0;
  end else if(mode2_done)begin
    mode2     <= 1'b0;
  end
end


always @(posedge clk or posedge reset) begin
    if(reset)begin
      // 原有的复位�?�辑
      x_count    <= 16'h0000;
      y_count    <= 16'h0000;
      x_coord_r  <= 17'h0;
      y_coord_r  <= 17'h0;
      scan_in_progress <= 1'b0;
      // 新增的复位�?�辑
      flag_counter <= 32'h0000;
      flag         <= 1'b1;
    end else if(start_scan)begin
        mode0_done     <= 1'b0;
        mode1_done     <= 1'b0;
        mode2_done     <= 1'b0;
    end else if ((!flag) && (flag_counter == 1'b1)) begin
        flag <= 1'b1;
    end else if (!flag) begin
        flag_counter <= flag_counter - 1'b1;
    end else if(flag && mode0 && !mode0_done)begin
      mode0_done       <= 1'b0;
      x_coord_r        <= {1'b0,nx_min};
      y_coord_r        <= {1'b0,ny_min};
      flag             <= 1'b0;
      flag_counter     <= flag_duration;
      scan_in_progress <= 1'b1;
      if(pixel_done)begin scan_in_progress <= 1'b0;  mode0_done <= 1'b1;  end
    end else if(flag && mode1 && !mode1_done)begin
      mode1_done       <= 1'b0;  
      if(!nx_pix && scan_done)begin
        x_coord_r        <= {1'b0,nx_min};   
        y_coord_r        <= {1'b0,ny_min};
        y_count          <= 1'b0;
        flag             <= 1'b0;
        flag_counter     <= flag_duration;
        scan_in_progress <= 1'b1;
      end else if(!nx_pix && !scan_done && (y_count< (ny_pix-1'b1)))begin
        y_count          <= y_count + 1'b1;
        x_coord_r        <= {1'b0,nx_min};
        y_coord_r        <= y_coord_r + dy;
        flag             <= 1'b0;
        flag_counter     <= flag_duration;
        scan_in_progress <= 1'b1;        
      end else if(!nx_pix && !scan_done && (y_count == (ny_pix-1'b1)))begin
        y_count          <= y_count + 1'b1;
        x_coord_r        <= {1'b0,nx_min};
        if((y_coord_r+dy)>ny_max) y_coord_r <= {1'b0,ny_max};
        else begin y_coord_r <= y_coord_r + dy; end

        flag             <= 1'b0;
        flag_counter     <= flag_duration;
      end else if(!nx_pix && !scan_done && (y_count == ny_pix))begin
        scan_in_progress <= 1'b0;     
        mode1_done       <= 1'b1;
      end else if(!ny_pix && scan_done)begin
        y_coord_r        <= {1'b0,ny_min};   
        x_coord_r        <= {1'b0,nx_min};
        x_count          <= 1'b0;
        flag             <= 1'b0;
        flag_counter     <= flag_duration;
        scan_in_progress <= 1'b1;
      end else if(!ny_pix && !scan_done && (x_count< (nx_pix-1'b1)))begin
        x_count          <= x_count + 1'b1;
        y_coord_r        <= {1'b0,ny_min};
        x_coord_r        <= x_coord_r + dx;
        flag             <= 1'b0;
        flag_counter     <= flag_duration;
        scan_in_progress <= 1'b1;
      end else if(!ny_pix && !scan_done && (x_count == (nx_pix-1'b1)))begin
        x_count          <= x_count + 1'b1;
        y_coord_r        <= {1'b0,ny_min};
        if((x_coord_r+dx)>nx_max) x_coord_r <= {1'b0,nx_max};
        else begin x_coord_r <= x_coord_r + dx; end

        flag             <= 1'b0;
        flag_counter     <= flag_duration;
      end else if(!ny_pix && !scan_done && (x_count == nx_pix))begin
        scan_in_progress <= 1'b0;     
        mode1_done       <= 1'b1;
      end 
    end else if(flag && mode2 && scan_done && !mode2_done)begin   
        mode2_done       <= 1'b0;
        x_coord_r        <= {1'b0,nx_min};
        y_coord_r        <= {1'b0,ny_min};  
        x_count          <= 16'h0000;
        y_count          <= 16'h0000;          
        flag             <= 1'b0;
        flag_counter     <= flag_duration;
        scan_in_progress <= 1'b1;    
      end else if(flag && mode2 && (x_count < (nx_pix-1'b1)) )begin
        x_coord_r        <= x_coord_r + dx;
        y_coord_r        <= y_coord_r;  
        x_count          <= x_count + 1'b1;
        flag             <= 1'b0;
        flag_counter     <= flag_duration;
        scan_in_progress <= 1'b1;  
      end else if(flag && mode2 && (x_count==(nx_pix - 1'b1)))begin
        if((x_coord_r + dx) > nx_max) x_coord_r  <= {1'b0,nx_max};
        else    x_coord_r  <= x_coord_r + dx;

        y_coord_r        <= y_coord_r;  
        x_count          <= x_count + 1'b1;
        flag             <= 1'b0;
        flag_counter     <= flag_duration;
        scan_in_progress <= 1'b1;  
      end else if(flag && mode2 && y_count==ny_pix)begin
        scan_in_progress <= 1'b0;  
        mode2_done       <= 1'b1;
      end else if(flag && mode2 && x_count==nx_pix && (y_count==(ny_pix - 1'b1)))begin
        x_coord_r        <= {1'b0,nx_min};
        if((y_coord_r+dy)>ny_max) y_coord_r <= {1'b0,ny_max};
        else begin y_coord_r <= y_coord_r + dy; end  
        
        x_count          <= 1'b0;
        y_count          <= y_count + 1'b1;
        flag             <= 1'b0;
        flag_counter     <= flag_duration;
        scan_in_progress <= 1'b1;  
      end else if(flag && mode2 && x_count==nx_pix && (y_count< (ny_pix-1'b1)))begin
        x_coord_r        <= {1'b0,nx_min};
        y_coord_r        <= y_coord_r + dy;   
        
        x_count          <= 1'b0;
        y_count          <= y_count + 1'b1;
        flag             <= 1'b0;
        flag_counter     <= flag_duration;
        scan_in_progress <= 1'b1;   
      end 
end



reg flag_r         = 1'b0;
reg flag_r2        = 1'b0;
reg pixel_done_r   = 1'b0;
reg pixel_done_r2  = 1'b0;
reg pixel_done_r3  = 1'b0;
reg pixel_done_r4  = 1'b0;
reg pixel_done_r5  = 1'b0;

always @(posedge clk_100m) begin
    flag_r  <= flag;
    flag_r2 <= flag_r;
    pixel_done_r2  <=   pixel_done_r;
    pixel_done_r3  <=   pixel_done_r2;
    pixel_done_r4  <=   pixel_done_r3;
    pixel_done_r5  <=   pixel_done_r4;
end

reg [63:0] cnt = 64'h0;
reg     locked = 1'b0;

always @ (posedge clk or posedge reset) begin
    if (reset || start_scan) begin
        cnt    <= 1'b0;
        locked <= 1'b0;
    end else if(cnt == ((nx_pix +1)*(ny_pix +1)-1'b1))begin
        locked <= 1'b1;
    end else if(pixel_done_r2&&(!pixel_done_r3))begin
        cnt = cnt + 1'b1;
    end 
end  

//else if (locked)begin
//        pixel_done_r   <=   1'b0;
//    end

always @(posedge clk_100m or posedge reset) begin
    if (reset) begin
        pixel_done_r   <=   1'b0;
    end else if (locked)begin
        pixel_done_r   <=   1'b0;
    end else if((!flag_r2)&&(flag_r))begin
        pixel_done_r   <=   1'b1;
    end else if(pixel_done_r&&pixel_done_r2&&pixel_done_r3&&pixel_done_r4&&pixel_done_r5)begin
        pixel_done_r   <= 1'b0;
    end else begin
    
    end
end   

reg scan_done_r = 0;
reg init_r      = 0;
reg init_r2     = 0;
reg init_r3     = 0;


always@(posedge clk)begin
    scan_done_r <= scan_done; 
    init_r2     <= init_r;
    init_r3     <= init_r2;
    
    if((!scan_done)&&(scan_done_r))begin
        init_r <= 1'b1;
    end else if(init_r3)begin
        init_r <= 1'b0;
    end else init_r <= init_r;
end



assign init       = init_r;
assign x_coord    = x_coord_r[15:0];
assign y_coord    = y_coord_r[15:0];
assign scan_done  = ~scan_in_progress;
assign pixel_done = pixel_done_r;
assign xy2_send   = (init||pixel_done)&(~scan_done); 

endmodule
