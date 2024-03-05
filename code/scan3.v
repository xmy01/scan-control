`timescale 1ns / 1ps

module scan3(
  input  wire clk,                 
  input  wire reset,             
  input  wire start_scan,         
  input  wire [15:0] nx_pix,    
  input  wire [15:0] ny_pix,    
  input  wire [15:0] nx_min,
  input  wire [15:0] nx_max,
  input  wire [15:0] ny_min,
  input  wire [15:0] ny_max,
  input  wire [31:0] flag_duration, 
  output wire [15:0] x_coord,   
  output wire [15:0] y_coord,    
  output wire xy2_send
);


reg  [15:0] x_count;
reg  [15:0] y_count;
reg  [16:0] x_coord_r;
reg  [16:0] y_coord_r;
wire [15:0] dx;
wire [15:0] dy;
wire u_flag;

reg  flag                 =   1'b0;
reg  flag_r               =   1'b0;
reg  flag_r2              =   1'b0;
reg  scan3_done           =   1'b0;
reg  mode0                =   1'b0;
reg  mode1                =   1'b0;
reg  mode2                =   1'b0;
reg  mode0_done           =   1'b0;  
reg  mode1_done           =   1'b0;
reg  mode2_done           =   1'b0;


assign dx     = (nx_pix!=16'h0)?(((nx_max - nx_min) / nx_pix) +1):16'h0;
assign dy     = (ny_pix!=16'h0)?(((ny_max - ny_min) / ny_pix) +1):16'h0;
assign u_flag = ~flag;


flag_counter u_flag_counter(
  .clk(clk),
  .start(flag),
  .sig_period(flag_duration[31:0]),

  .ref_signal(flag20)
);

always @(posedge clk or posedge reset) begin
  if (reset) begin
    mode0     <= 1'b0;
    mode1     <= 1'b0;
    mode2     <= 1'b0;
  end else if(start_scan && u_flag)begin
    if((nx_pix==0)&&(ny_pix==0)&&(nx_min==nx_max)&&(ny_min==ny_max))begin
      mode0   <= 1'b1;
    end else if( ((nx_pix==0)&&(ny_pix!=0)) || ((nx_pix!=0)&&(ny_pix==0)) )begin
      mode1   <= 1'b1;
    end else if((nx_pix>=2'b11) && (ny_pix>=2'b11))begin
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
        x_count        <= 16'h0000;
        y_count        <= 16'h0000;
        x_coord_r      <= 17'h0;
        y_coord_r      <= 17'h0;
    end else if(start_scan && u_flag)begin
        mode0_done     <= 1'b0;
        mode1_done     <= 1'b0;
        mode2_done     <= 1'b0;
    end else if(flag20)begin
        flag             <= 1'b0;
    end else if(u_flag && mode0 && !mode0_done)begin 
      if(!nx_pix && mode0 && !mode0_done && (x_count == 16'h0000))begin
        x_coord_r        <= {1'b0,nx_min};   
        y_coord_r        <= {1'b0,ny_min}; 
        x_count          <= 16'h0001;
        y_count          <= 16'h0000;
        flag             <= 1'b1; 
      end else if(!nx_pix && mode0 && !mode0_done && (x_count == 16'h0001))begin
        x_count          <= 16'h0000;
        y_count          <= 16'h0000;
        x_coord_r        <= 17'h0;
        y_coord_r        <= 17'h0;
        mode0_done       <= 1'b1;
      end
    end else if(u_flag && mode1 && !mode1_done)begin
      if(!nx_pix && mode1 && !mode1_done && (y_count == 16'h0000))begin
        x_coord_r        <= {1'b0,nx_min};   
        y_coord_r        <= {1'b0,ny_min};
        y_count          <= 16'h0001;
        x_count          <= 16'h0000;
        flag             <= 1'b1;
      end else if(!nx_pix && mode1 && !mode1_done && (y_count < ny_pix))begin
        y_count          <= y_count + 1'b1;
        x_count          <= 16'h0000;
        x_coord_r        <= {1'b0,nx_min};
        y_coord_r        <= y_coord_r + dy;
        flag             <= 1'b1;     
      end else if(!nx_pix && mode1 && !mode1_done && (y_count == ny_pix))begin
        y_count          <= y_count + 1'b1;
        x_coord_r        <= {1'b0,nx_min};
        if((y_coord_r+dy)>ny_max) y_coord_r <= {1'b0,ny_max};
        else begin y_coord_r <= y_coord_r + dy; end

        flag             <= 1'b1;
      end else if(!nx_pix && mode1 && !mode1_done && (y_count > ny_pix))begin  
        x_count          <= 16'h0000;
        y_count          <= 16'h0000;
        x_coord_r        <= 17'h0;
        y_coord_r        <= 17'h0;
        mode1_done       <= 1'b1;
      end else if(!ny_pix && mode1 && !mode1_done && (x_count == 16'h0000))begin
        y_coord_r        <= {1'b0,ny_min};   
        x_coord_r        <= {1'b0,nx_min};
        y_count          <= 16'h0000;
        x_count          <= 16'h0001;
        flag             <= 1'b1;
      end else if(!ny_pix && mode1 && !mode1_done && (x_count< nx_pix))begin
        x_count          <= x_count + 1'b1;
        y_count          <= 16'h0000;
        y_coord_r        <= {1'b0,ny_min};
        x_coord_r        <= x_coord_r + dx;
        flag             <= 1'b1;
      end else if(!ny_pix && mode1 && !mode1_done && (x_count == nx_pix))begin
        x_count          <= x_count + 1'b1;
        y_count          <= 16'h0000;
        y_coord_r        <= {1'b0,ny_min};
        if((x_coord_r+dx)>nx_max) x_coord_r <= {1'b0,nx_max};
        else begin x_coord_r <= x_coord_r + dx; end

        flag             <= 1'b1;
      end else if(!ny_pix && mode1 && !mode1_done && (x_count > nx_pix))begin   
        x_count          <= 16'h0000;
        y_count          <= 16'h0000;
        x_coord_r        <= 17'h0;
        y_coord_r        <= 17'h0;
        mode1_done       <= 1'b1;
      end 
    end else if(u_flag && mode2 && !mode2_done && (x_count == 16'h0000))begin   
        x_coord_r        <= {1'b0,nx_min};
        y_coord_r        <= {1'b0,ny_min};  
        x_count          <= 16'h0001;
        y_count          <= 16'h0000;          
        flag             <= 1'b1;
      end else if(u_flag && mode2 && !mode2_done && (x_count < nx_pix) && (y_count == 16'h0000) && !scan3_done)begin
        x_coord_r        <= x_coord_r + dx;
        y_coord_r        <= y_coord_r;     
        x_count          <= x_count + 1'b1;
        flag             <= 1'b1;
      end else if(u_flag && mode2 && !mode2_done && (x_count == nx_pix) && (y_count == 16'h0000))begin
        if((x_coord_r + dx) > nx_max) x_coord_r  <= {1'b0,nx_max};
        else begin x_coord_r <= x_coord_r + dx; end

        y_coord_r        <= y_coord_r;  
        x_count          <= x_count + 1'b1;
        flag             <= 1'b1;
      end else if(u_flag && mode2 && !mode2_done && (x_count == nx_pix+1'b1) && (y_count == 16'h0000))begin
        x_coord_r        <= x_coord_r;
        y_coord_r        <= y_coord_r + dy;  
        x_count          <= x_count;
        y_count          <= y_count + 1'b1;
        flag             <= 1'b1;
      end else if(u_flag && mode2 && !mode2_done && (x_count == nx_pix+1'b1) && (y_count < (ny_pix - 1'b1)))begin
        x_coord_r        <= x_coord_r;
        y_coord_r        <= y_coord_r + dy;  
        x_count          <= x_count;
        y_count          <= y_count + 1'b1;
        flag             <= 1'b1;
      end else if(u_flag && mode2 && !mode2_done && (x_count == nx_pix+1'b1) && (y_count == (ny_pix - 1'b1)))begin
        if((y_coord_r + dy) > ny_max) y_coord_r <= {1'b0,ny_max};
        else begin y_coord_r <= y_coord_r + dy; end

        x_coord_r        <= x_coord_r;  
        y_count          <= y_count + 1'b1;
        flag             <= 1'b1;
      end else if(u_flag && mode2 && !mode2_done && (x_count == nx_pix+1'b1) && (y_count == ny_pix))begin
        y_coord_r        <= y_coord_r;
        x_coord_r        <= x_coord_r - dx;
        y_count          <= y_count;
        x_count          <= x_count - 1'b1;
        flag             <= 1'b1;
      end else if(u_flag && mode2 && !mode2_done && (x_count > 16'h0002) && (y_count == ny_pix))begin
        y_coord_r        <= y_coord_r;
        x_coord_r        <= x_coord_r - dx;
        y_count          <= y_count;
        x_count          <= x_count - 1'b1;
        flag             <= 1'b1;
      end else if(u_flag && mode2 && !mode2_done && (x_count == 16'h0002) && (y_count == ny_pix))begin
        x_coord_r        <= {1'b0,nx_min};
        y_coord_r        <= y_coord_r;
        x_count          <= x_count - 1'b1;
        y_count          <= y_count;
        flag             <= 1'b1;
      end else if(u_flag && mode2 && !mode2_done && (x_count == 16'h0001) && (y_count == ny_pix))begin
        y_coord_r        <= y_coord_r - dy;
        x_coord_r        <= x_coord_r;
        y_count          <= y_count - 1'b1;
        x_count          <= x_count;
        flag             <= 1'b1;
      end else if(u_flag && mode2 && !mode2_done && (x_count == 16'h0001) && (y_count > 1'b1))begin
        y_coord_r        <= y_coord_r - dy;
        x_coord_r        <= x_coord_r;
        y_count          <= y_count - 1'b1;
        x_count          <= x_count;   
        flag             <= 1'b1;     
      end else if(u_flag && mode2 && !mode2_done && (x_count == 16'h0001) && (y_count == 1'b1))begin
        y_coord_r        <= {1'b0,ny_min};
        x_coord_r        <= x_coord_r;
        y_count          <= y_count - 1'b1;
        x_count          <= x_count;
        flag             <= 1'b1;
        scan3_done       <= 1'b1;
      end else if(u_flag && mode2 && !mode2_done && (x_count == 16'h0001) && (y_count == 1'b0) && scan3_done)begin
        x_count          <= 16'h0000;
        y_count          <= 16'h0000;
        x_coord_r        <= 17'h0;
        y_coord_r        <= 17'h0;
        scan3_done       <= 1'b0;
        mode2_done       <= 1'b1;
      end


end


reg pixel_done_r   = 1'b0;
reg pixel_done_r2  = 1'b0;
reg pixel_done_r3  = 1'b0;
reg pixel_done_r4  = 1'b0;
reg pixel_done_r5  = 1'b0;

always @(posedge clk) begin
    flag_r  <= flag;
    flag_r2 <= flag_r;
    pixel_done_r2  <=   pixel_done_r;
    pixel_done_r3  <=   pixel_done_r2;
    pixel_done_r4  <=   pixel_done_r3;
    pixel_done_r5  <=   pixel_done_r4;
end


always @(posedge clk or posedge reset) begin
    if (reset) begin
        pixel_done_r   <=   1'b0;
    end else if((!flag_r2)&&(flag_r))begin
        pixel_done_r   <=   1'b1;
    end else if(pixel_done_r&&pixel_done_r2&&pixel_done_r3&&pixel_done_r4&&pixel_done_r5)begin
        pixel_done_r   <=   1'b0;
    end else begin
    
    end
end   

assign x_coord    = x_coord_r[15:0];
assign y_coord    = y_coord_r[15:0];
assign pixel_done = pixel_done_r;
assign xy2_send   = flag & pixel_done; 

endmodule
