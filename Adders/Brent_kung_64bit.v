module Brent_kung_64bit #(parameter WIDTH = 64)(
    input [WIDTH-1:0] a,b,
    input cin,
    output [WIDTH-1:0] sum,
    output cout
);
// Generation and propagation declaration
wire [WIDTH-1:0] G,P;
assign G = a & b;
assign P = a ^ b;

// Level_1
wire [WIDTH-1:0] G1,P1;
genvar i1;
generate for (i1 = 1;i1<WIDTH ;i1=i1+1 ) begin
    assign G1[i1] = G[i1] | P[i1] & G[i1-1];
    assign P1[i1] = P[i1] & P[i1-1];
end
endgenerate
assign G1[0]=G[0];
assign P1[0]=P[0];

// Level_2
wire [WIDTH-1:0] G2,P2;
genvar i2;
generate for (i2 = 3;i2<WIDTH ;i2=i2+2 ) begin
    assign G2[i2] = G1[i2] | P1[i2] & G1[i2-2];
    assign P2[i2] = P1[i2] & P1[i2-2];
end
endgenerate
assign G2[2:0] = G1[2:0];
assign P2[2:0] = P1[2:0];

// Level_3
wire [WIDTH-1:0] G3,P3;
genvar i3;
generate for (i3 = 7;i3<WIDTH ;i3=i3+4 ) begin
    assign G3[i3] = G2[i3] | P2[i3] & G2[i3-4];
    assign P3[i3] = P2[i3] & P2[i3-4];
end
endgenerate
assign G3[6:0] = G1[6:0];
assign P3[6:0] = P1[6:0];

// Level_4
wire [WIDTH-1:0] G4,P4;
genvar i4;
generate for (i4 = 15;i4<WIDTH ;i4=i4+8 ) begin
    assign G4[i4] = G3[i4] | P3[i4] & G3[i4-8];
    assign P4[i4] = P3[i4] & P3[i4-8];
end
endgenerate
assign G4[14:0] = G1[14:0];
assign P4[14:0] = P1[14:0];

// Level_5
wire [WIDTH-1:0] G5,P5;
genvar i5;
generate for (i5 = 31;i5<WIDTH ;i5=i5+16 ) begin
    assign G5[i5] = G4[i5] | P4[i5] & G4[i5-16];
    assign P5[i5] = P4[i5] & P4[i5-16];
end
endgenerate
assign G5[30:0] = G1[30:0];
assign P5[30:0] = P1[30:0];

// Level_6
wire [WIDTH-1:0] G6,P6;
genvar i6;
generate for (i6 = 63;i6<WIDTH ;i6=i6+32 ) begin
    assign G6[i6] = G5[i6] | P5[i6] & G5[i6-32];
    assign P6[i6] = P5[i6] & P5[i6-32];
end
endgenerate
assign G6[62:0] = G1[62:0];
assign P6[62:0] = P1[62:0];

// Carry calculations
wire [WIDTH-1:0] C;
assign C[0] = cin;

genvar i;
generate for (i= 1;i<WIDTH ;i=i+1 ) begin
    assign C[i] = G6[i-1] | (P6[i-1] & C[i-1]);
end
endgenerate

// Sum and Cout Calculation
assign cout = G6[WIDTH-1] | (P6[WIDTH-1] & C[WIDTH-1]);
assign sum = P ^ C;

endmodule