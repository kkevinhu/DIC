module find_Min(input [7:0] A, B, C, D, output [7:0] min);
    wire [7:0] m1, m2;
    assign m1 = (A < B) ? A : B;
    assign m2 = (C < D) ? C : D;
    assign min = (m1 < m2) ? m1 : m2;
endmodule