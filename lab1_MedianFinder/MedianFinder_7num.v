module MedianFinder_7num(num1, num2, num3, num4, num5, num6, num7, median);
    input  [3:0] num1, num2, num3, num4, num5, num6, num7;
    output [3:0] median;

    Comparator com1(.A(num1),     .B(num2),     .min(), .max());
    Comparator com2(.A(num3),     .B(num4),     .min(), .max());
    Comparator com3(.A(com1.min), .B(com2.min), .min(), .max());
    Comparator com4(.A(com1.max), .B(com2.max), .min(), .max());
    Comparator com5(.A(num5),     .B(num6),     .min(), .max());
    Comparator com6(.A(com3.min), .B(com5.min), .min(), .max());
    Comparator com7(.A(com5.max), .B(com4.max), .min(), .max());

    MedianFinder_5num mf5(.num1(com3.max), .num2(com6.max), .num3(com7.min), .num4(com4.min), .num5(num7), .median(median));
endmodule