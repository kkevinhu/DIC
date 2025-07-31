module Comparator2(A, B, min, max);
    input  [3:0] A, B;
    output [3:0] min, max;

    assign min = (A < B) ? A : B;
    assign max = (A < B) ? B : A;
endmodule   