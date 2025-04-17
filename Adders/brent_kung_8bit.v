module Brent_kung_adder(
    input [7:0] a,b,
    input cin,
    output [7:0] sum,
    output cout
);
// Generation and propagation declaration
wire [7:0] G,P;
assign G = a & b;
assign P = a ^ b;

// Level_1 1st half
wire [7:0] G1,P1;             // 0:1
assign G1[1] = G[1] | P[1] & G[0];      // 0:1
assign P1[1] = P[1] & P[0];             
assign G1[3] = G[3] | P[3] & G[2];      // 2:3
assign P1[3] = P[3] & P[2];
assign G1[5] = G[5] | P[5] & G[4];      // 4:5
assign P1[5] = P[5] & P[4];
assign G1[7] = G[7] | P[7] & G[6];      // 6:7
assign P1[7] = P[7] & P[6];
// Level_1 2nd half
assign G1[2] = G[2] | P[2] & G[1];      // 0:2
assign P1[2] = P[2] & P[1];             
assign G1[4] = G[4] | P[4] & G[3];      // 0:4
assign P1[4] = P[4] & P[3];             
assign G1[6] = G[6] | P[6] & G[5];      // 0:6
assign P1[6] = P[6] & P[5];             

// level_2 1st half
wire [7:0] G2,P2;
assign G2[3] = G1[3] | P1[3] & G1[1];   // 0:3
assign P2[3] = P1[3] & P1[1];           
assign G2[7] = G1[7] | P1[7] & G1[5];   // 4:7
assign P2[7] = P1[7] & P1[5];           
// level_2 2nd half
assign G2[5] = G1[5] | P1[5] & G1[3];   // 0:5
assign P2[5] = P1[5] & P1[3];           // 0:5

// level 3
wire G3,P3;
assign G3 = G2[7] | P2[7] & G2[3];      // 0:7
assign P3 = P2[7] & P2[3];

// Carry calculations
wire [7:0] C;
assign C[0] = cin;
assign C[1] = G[0] | (P[0] & cin);
assign C[2] = G1[1] | (P1[1] & C[1]);
assign C[3] = G1[2] | (P1[2] & C[2]);
assign C[4] = G2[3] | (P2[3] & C[3]);
assign C[5] = G1[4] | (P1[4] & C[4]);
assign C[6] = G2[5] | (P2[5] & C[5]);
assign C[7] = G1[6] | (P1[6] & C[6]);
assign cout = G3 | (P3 & C[7]);

// Sum Calculation
assign sum = P ^ C;



endmodule