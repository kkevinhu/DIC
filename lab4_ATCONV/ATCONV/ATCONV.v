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
parameter READ = 0, layer0_RD = 1, layer0_WR = 2, DONE = 3;

reg [2:0]  state, next_state;
reg [3:0]  counter;
reg [6:0]  x, y, px, py;
reg signed [31:0] mul;
reg [15:0] image [0:4095];

wire [11:0] img_idx;
wire [15:0] bias;
wire [15:0] kernal [0:8];

assign img_idx = 64 * py + px;
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
        layer0_WR : next_state <= (layer0_A == 12'd4095) ? DONE : layer0_RD;
    endcase
end

always @(*) begin
    case (state)
        READ : image[iaddr] <= idata;
        layer0_WR : layer0_D <= (mul[31]) ? 16'd0 : mul[19:4];
    endcase
end

always @(posedge clk or posedge rst) begin
    if (rst)
        iaddr <= 12'd0;
    else if (state == READ)
        iaddr <= iaddr + 1'd1;
end

always @(posedge clk or posedge rst) begin
    if (rst)
        layer0_A <= 12'd0;
    else if (state == layer0_WR)
        layer0_A <= layer0_A + 1'd1;
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

always @(*) begin
    case (state)
        READ : begin
            ROM_rd <= 1;
            layer0_ceb <= 0;
            layer0_web <= 1;
            done <= 0;
        end
        layer0_RD : begin
            ROM_rd <= 0;
            layer0_ceb <= 0;
            layer0_web <= 1;
            done <= 0;
        end
        layer0_WR : begin
            ROM_rd <= 0;
            layer0_ceb <= 1;
            layer0_web <= 0;
            done <= 0;
        end
        DONE : begin
            ROM_rd <= 0;
            layer0_ceb <= 0;
            layer0_web <= 1;
            done <= 1;
        end
    endcase
end
endmodule

/*
ROM_rd
layer0_ceb
layer0_web
done
*/