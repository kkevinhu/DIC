module find_Max(input [7:0] A, B, C, D, output [7:0] max);
    wire [7:0] m1, m2;
    assign m1 = (A > B) ? A : B;
    assign m2 = (C > D) ? C : D;
    assign max = (m1 > m2) ? m1 : m2;
endmodule