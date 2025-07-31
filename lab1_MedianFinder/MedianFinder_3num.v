module MedianFinder_3num(num1, num2, num3, median);
    input  [3:0] num1, num2, num3;
    output [3:0] median;
    wire   [3:0] min1, max1, min2;

    Comparator com1(.A(num1), .B(num2), .min(min1), .max(max1));
    Comparator com2(.A(max1), .B(num3), .min(min2), .max());
    Comparator com3(.A(min1), .B(min2), .min(), .max(median));
endmodule