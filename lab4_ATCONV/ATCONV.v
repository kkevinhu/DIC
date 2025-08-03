module ATCONV(
    input             clk,
    input             rst,
    output reg        ROM_rd,
    output reg [11:0] iaddr,
    input      [15:0] idata,
    output reg        layer0_ceb,
    output reg        layer0_web,
    output reg [11:0] layer0_A,
    output reg [15:0] layer0_D,
    input      [15:0] layer0_Q,
    output reg        layer1_ceb,
    output reg        layer1_web,
    output reg [11:0] layer1_A,
    output reg [15:0] layer1_D,
    input      [15:0] layer1_Q,
    output reg        done
);
parameter READ = 0, layer0_RD = 1, layer0_WR = 2, layer1_RD = 3, layer1_WR = 4, DONE = 5;

reg [2:0]  state, next_state;
reg [2:0]  p_counter;
reg [3:0]  counter;
reg [5:0]  pool_x, pool_y; // layer 1
reg [6:0]  x, y, px, py;   // layer 0
reg [15:0] max;
reg signed [31:0] mul;
reg [15:0] image [0:4095];

wire [11:0] img_idx;
wire [11:0] re_idx;
wire [15:0] bias;
wire [15:0] kernal [0:8];

assign img_idx = 64 * py + px;
assign re_idx  = 64 * pool_y + pool_x;
assign bias = 16'hFFF4;
assign kernal[0] = 16'hFFFF;
assign kernal[1] = 16'hFFFE;
assign kernal[2] = 16'hFFFF;
assign kernal[3] = 16'hFFFC;
assign kernal[4] = 16'h0010;
assign kernal[5] = 16'hFFFC;
assign kernal[6] = 16'hFFFF;
assign kernal[7] = 16'hFFFE;
assign kernal[8] = 16'hFFFF;

always @(posedge clk or posedge rst) begin
    if (rst)
        state <= READ;
    else
        state <= next_state;
end

always @(*) begin
    case (state)
        READ :      next_state <= (iaddr == 12'd4095) ? layer0_RD : READ;
        layer0_RD : next_state <= (counter == 4'd8) ? layer0_WR : layer0_RD;
        layer0_WR : next_state <= (layer0_A == 12'd4095) ? layer1_RD : layer0_RD;
        layer1_RD : next_state <= (p_counter == 3'd5) ? layer1_WR : layer1_RD;
        layer1_WR : next_state <= (layer1_A == 12'd1023) ? DONE : layer1_RD;
    endcase
end

always @(*) begin
    case (state)
        READ : image[iaddr] <= idata;
        layer0_WR : layer0_D <= (mul[31]) ? 16'd0 : mul[19:4];
        layer1_WR : layer1_D <= (|max[3:0]) ? {max[15:4] + 16'b1, 4'b0} : max;
    endcase
end

always @(posedge clk or posedge rst) begin
    if (rst)
        iaddr <= 12'd0;
    else if (state == READ)
        iaddr <= iaddr + 1'd1;
end

// layer 0 
always @(posedge clk or posedge rst) begin
    if (rst)
        layer0_A <= 12'd0;
    else if (state == layer0_WR)
        layer0_A <= layer0_A + 1'd1;
    else if (state == layer1_RD) begin
        case (p_counter)
            3'd0 : layer0_A <= re_idx;
            3'd1 : layer0_A <= re_idx + 12'd1;
            3'd2 : layer0_A <= re_idx + 12'd64;
            3'd3 : layer0_A <= re_idx + 12'd65;
        endcase
    end
end

always @(posedge clk or posedge rst) begin
    if (rst)
        counter <= 4'd0;
    else if (state == layer0_RD)
        counter <= counter + 7'd1;
    else if (state == layer0_WR)
        counter <= 4'd0;
end

always @(posedge clk or posedge rst) begin
    if (rst) 
        mul <= 32'd0;
    else if (state == layer0_RD && counter == 8)
        mul <= mul + $signed(image[img_idx]) * $signed(kernal[counter]) + ($signed(bias) <<< 4);
    else if (state == layer0_RD)
        mul <= mul + $signed(image[img_idx]) * $signed(kernal[counter]);
    else if (state == layer0_WR)
        mul <= 32'd0;
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        x <= 7'd0;
        y <= 7'd0;
    end
    else if (state == layer0_WR) begin
        if (x == 7'd63) begin
            x <= 0;
            y <= y + 1'd1;
        end
        else begin
            x <= x + 1'd1;
        end
    end
end

always @(*) begin
    case (counter)
        4'd0 : begin
            px <= (x < 7'd2) ? 0 : (x - 7'd2);
            py <= (y < 7'd2) ? 0 : (y - 7'd2);
        end
        4'd1 : begin
            px <= x;
            py <= (y < 7'd2) ? 0 : (y - 7'd2);
        end
        4'd2 : begin
            px <= (x > 7'd61) ? 63 : (x + 7'd2);   // (x > 5) ? 7 : (x - 2)
            py <= (y < 7'd2) ? 0 : (y - 7'd2);
        end
        4'd3 : begin
            px <= (x < 7'd2) ? 0 : (x - 7'd2);
            py <= y;
        end
        4'd4 : begin
            px <= x;
            py <= y;
        end
        4'd5 : begin
            px <= (x > 7'd61) ? 63 : (x + 7'd2);
            py <= y;
        end
        4'd6 : begin
            px <= (x < 7'd2) ? 0 : (x - 7'd2);
            py <= (y > 7'd61) ? 63 : (y + 7'd2);
        end
        4'd7 : begin
            px <= x;
            py <= (y > 7'd61) ? 63 : (y + 7'd2);
        end
        4'd8 : begin
            px <= (x > 7'd61) ? 63 : (x + 7'd2);
            py <= (y > 7'd61) ? 63 : (y + 7'd2);
        end
    endcase
end

//layer 1
always @(posedge clk or posedge rst) begin
    if (rst)
        layer1_A <= 12'd0;
    else if (state == layer1_WR)
        layer1_A <= layer1_A + 1'd1;
end

always @(posedge clk or posedge rst) begin
    if (rst)
        p_counter <= 3'd0;
    else if (state == layer1_RD)
        p_counter <= p_counter + 3'd1;
    else if (state == layer1_WR)
        p_counter <= 3'd0;
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        pool_x <= 6'd0;
        pool_y <= 6'd0;
    end
    else if (state == layer1_WR) begin
        if (pool_x == 6'd62) begin
            pool_x <= 6'd0;
            pool_y <= pool_y + 6'd2;
        end
        else
            pool_x <= pool_x + 6'd2;
    end
end

always @(*) begin
    if (state == layer1_RD) begin
            if (p_counter == 0 || p_counter == 1)
                max <= 16'd0;
            else
            max <= (max > layer0_Q) ? max : layer0_Q;
    end
    else
        max <= max;
end

// output signal
always @(*) begin
    case (state)
        READ : begin
            ROM_rd <= 1;
            layer0_ceb <= 0;
            layer0_web <= 1;
            layer1_ceb <= 0;
            layer1_web <= 1;
            done <= 0;
        end
        layer0_RD : begin
            ROM_rd <= 0;
            layer0_ceb <= 0;
            layer0_web <= 1;
            layer1_ceb <= 0;
            layer1_web <= 1;
            done <= 0;
        end
        layer0_WR : begin
            ROM_rd <= 0;
            layer0_ceb <= 1;
            layer0_web <= 0;
            layer1_ceb <= 0;
            layer1_web <= 1;
            done <= 0;
        end
        layer1_RD : begin
            ROM_rd <= 0;
            layer0_ceb <= 1;
            layer0_web <= 1;
            layer1_ceb <= 0;
            layer1_web <= 1;
            done <= 0;
        end
        layer1_WR : begin
            ROM_rd <= 0;
            layer0_ceb <= 0;
            layer0_web <= 1;
            layer1_ceb <= 1;
            layer1_web <= 0;
            done <= 0;
        end
        DONE : begin
            ROM_rd <= 0;
            layer0_ceb <= 0;
            layer0_web <= 1;
            layer1_ceb <= 0;
            layer1_web <= 1;
            done <= 1;
        end
    endcase
end
endmodule