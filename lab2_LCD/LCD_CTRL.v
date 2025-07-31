module LCD_CTRL(
    input            clk,
    input            rst,
    input      [3:0] cmd,
    input            cmd_valid,
    output reg       IROM_rd,
    output reg [5:0] IROM_A,
    input      [7:0] IROM_Q,
    output reg       IRAM_ceb,
    output reg       IRAM_web,
    output reg [5:0] IRAM_A,
    output reg [7:0] IRAM_D,
    input      [7:0] IRAM_Q,
    output reg       busy,
    output reg       done
);

parameter READ = 0, CMD = 1, EXEC = 2, WRITE = 3, DONE = 4;
parameter WR = 0, SU = 1, SD = 2, SL = 3, SR = 4, MAX = 5, MIN = 6, AVG = 7;

reg [3:0] state, next_state;
reg [2:0] pX, pY;
reg [7:0] image [0:63];

wire [7:0] p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15;
wire [7:0]  max, min;
reg  [11:0] aver;

assign p0 = 8*(pY-2)+(pX-2);
assign p1 = 8*(pY-2)+(pX-1);
assign p2 = 8*(pY-2)+pX;
assign p3 = 8*(pY-2)+(pX+1);

assign p4 = 8*(pY-1)+(pX-2);
assign p5 = 8*(pY-1)+(pX-1);
assign p6 = 8*(pY-1)+pX;
assign p7 = 8*(pY-1)+(pX+1);

assign p8  = 8*(pY)+(pX-2);
assign p9  = 8*(pY)+(pX-1);
assign p10 = 8*(pY)+pX;
assign p11 = 8*(pY)+(pX+1);

assign p12 = 8*(pY+1)+(pX-2);
assign p13 = 8*(pY+1)+(pX-1);
assign p14 = 8*(pY+1)+pX;
assign p15 = 8*(pY+1)+(pX+1);

find_Max f_max1(.A(image[p0]) , .B(image[p1]) , .C(image[p2]) , .D(image[p3]) , .max());
find_Max f_max2(.A(image[p4]) , .B(image[p5]) , .C(image[p6]) , .D(image[p7]) , .max());
find_Max f_max3(.A(image[p8]) , .B(image[p9]) , .C(image[p10]), .D(image[p11]), .max());
find_Max f_max4(.A(image[p12]), .B(image[p13]), .C(image[p14]), .D(image[p15]), .max());
find_Max f_max5(.A(f_max1.max), .B(f_max2.max), .C(f_max3.max), .D(f_max4.max), .max(max));

find_Min f_min1(.A(image[p0]) , .B(image[p1]) , .C(image[p2]) , .D(image[p3]) , .min());
find_Min f_min2(.A(image[p4]) , .B(image[p5]) , .C(image[p6]) , .D(image[p7]) , .min());
find_Min f_min3(.A(image[p8]) , .B(image[p9]) , .C(image[p10]), .D(image[p11]), .min());
find_Min f_min4(.A(image[p12]), .B(image[p13]), .C(image[p14]), .D(image[p15]), .min());
find_Min f_min5(.A(f_min1.min), .B(f_min2.min), .C(f_min3.min), .D(f_min4.min), .min(min));

always @(*) begin
    aver = (image[p0]+image[p1]+image[p2]+image[p3]+image[p4]+image[p5]+image[p6]+image[p7]+image[p8]
            +image[p9]+image[p10]+image[p11]+image[p12]+image[p13]+image[p14]+image[p15]) / 16;
end

always @(posedge clk or posedge rst) begin
    if (rst)
        state <= READ;
    else
        state <= next_state;
end

always @(posedge clk or posedge rst) begin
    if (rst)
        IROM_A <= 6'd0;
    else if (state == READ)
        IROM_A <= IROM_A + 5'd1;
end

always @(posedge clk or posedge rst) begin
    if (rst)
        IRAM_A <= 6'd0;
    else if (state == WRITE)
        IRAM_A <= IRAM_A + 5'd1;
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        pX <= 3'd4;
        pY <= 3'd4;
    end
    else if (state == EXEC) begin
        case (cmd) 
            SU : pY <= (pY == 2) ? 2 : (pY - 1); 
            SD : pY <= (pY == 6) ? 6 : (pY + 1);
            SL : pX <= (pX == 2) ? 2 : (pX - 1);
            SR : pX <= (pX == 6) ? 6 : (pX + 1);        
        endcase
    end
end

always @(*) begin
    case (state)
        READ : next_state <= (IROM_A == 6'd63) ? CMD : READ;
        CMD  : begin
            if (cmd_valid && cmd != 0)
                next_state <= EXEC;
            else if (cmd_valid && cmd == 0)
                next_state <= WRITE;
            else
                next_state <= CMD;
        end
        EXEC :  next_state <= CMD;
        WRITE : next_state <= (IRAM_A == 6'd63) ? DONE : WRITE;
    endcase
end

always @(*) begin
    case (state)
        READ : image[IROM_A] <= IROM_Q;
        EXEC : begin
            case (cmd)
                MAX : begin
                    image[p0] <= max;
                    image[p1] <= max;
                    image[p2] <= max;
                    image[p3] <= max;
                    image[p4] <= max;
                    image[p5] <= max;
                    image[p6] <= max;
                    image[p7] <= max;
                    image[p8] <= max;
                    image[p9] <= max;
                    image[p10] <= max;
                    image[p11] <= max;
                    image[p12] <= max;
                    image[p13] <= max;
                    image[p14] <= max;
                    image[p15] <= max;
                end
                MIN : begin
                    image[p0] <= min;
                    image[p1] <= min;
                    image[p2] <= min;
                    image[p3] <= min;
                    image[p4] <= min;
                    image[p5] <= min;
                    image[p6] <= min;
                    image[p7] <= min;
                    image[p8] <= min;
                    image[p9] <= min;
                    image[p10] <= min;
                    image[p11] <= min;
                    image[p12] <= min;
                    image[p13] <= min;
                    image[p14] <= min;
                    image[p15] <= min;
                end
                AVG : begin
                    image[p0] <= aver;
                    image[p1] <= aver;
                    image[p2] <= aver;
                    image[p3] <= aver;
                    image[p4] <= aver;
                    image[p5] <= aver;
                    image[p6] <= aver;
                    image[p7] <= aver;
                    image[p8] <= aver;
                    image[p9] <= aver;
                    image[p10] <= aver;
                    image[p11] <= aver;
                    image[p12] <= aver;
                    image[p13] <= aver;
                    image[p14] <= aver;
                    image[p15] <= aver;
                end 
            endcase
        end
        WRITE : IRAM_D <= image[IRAM_A];
    endcase
end

always @(*) begin
    case (state)
        READ : begin
            IROM_rd <= 1;
            IRAM_ceb <= 0;
            IRAM_web <= 1;
            busy <= 1;
            done <= 0;
        end
        CMD : begin
            IROM_rd <= 0;
            IRAM_ceb <= 0;
            IRAM_web <= 1;
            busy <= 0;
            done <= 0;
        end
        EXEC : begin
            IROM_rd <= 0;
            IRAM_ceb <= 0;
            IRAM_web <= 1;
            busy <= 1;
            done <= 0;
        end
        WRITE : begin
            IROM_rd <= 0;
            IRAM_ceb <= 1;
            IRAM_web <= 0;
            busy <= 1;
            done <= 0;
        end
        DONE : begin
            IROM_rd <= 0;
            IRAM_ceb <= 1;
            IRAM_web <= 1;
            busy <= 0;
            done <= 1;
        end
    endcase
end
endmodule

/*
IROM_rd
IRAM_ceb
IRAM_web
busy
done
*/