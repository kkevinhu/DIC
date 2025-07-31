module MedianFinder_5num(num1, num2, num3, num4, num5, median);
    input  [3:0] num1, num2, num3, num4, num5;
    output [3:0] median;
    
    Comparator com1(.A(num1), .B(num2), .min(), .max());
    Comparator com2(.A(num3), .B(num4), .min(), .max());
    Comparator com3(.A(com1.min), .B(com2.min), .min(), .max());
    Comparator com4(.A(com1.max), .B(com2.max), .min(), .max());
    MedianFinder_3num mf3(.num1(com3.max), .num2(com4.min), .num3(num5), .median(median));
endmodule