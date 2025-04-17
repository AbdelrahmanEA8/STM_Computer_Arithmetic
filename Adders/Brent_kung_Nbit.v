module Brent_kung_Nbit #(parameter N = 64)(
    input [N-1:0] a, b,
    input cin,
    output [N-1:0] sum,
    output cout
);
    // Generation and propagation declaration
    wire [N-1:0] G, P;
    assign G = a & b;
    assign P = a ^ b;

    // Levels
    localparam STAGES = $clog2(N);
    wire [N-1:0] G1 [0:STAGES];
    wire [N-1:0] P1 [0:STAGES];

    // Initialize level 0
    assign G1[0] = G;
    assign P1[0] = P;

    // Generate block for Brent-Kung logic
    genvar i, j;
    generate
        for (i = 1; i <= STAGES; i = i + 1) begin : stage
            for (j = 0; j < N; j = j + 1) begin : bit
                if (j >= (1 << (i - 1))) begin
                    assign G1[i][j] = G1[i-1][j] | (P1[i-1][j] & G1[i-1][j-(1<<(i-1))]);
                    assign P1[i][j] = P1[i-1][j] & P1[i-1][j-(1<<(i-1))];
                end else begin
                    assign G1[i][j] = G1[i-1][j];
                    assign P1[i][j] = P1[i-1][j];
                end
            end
        end
    endgenerate

    // Carry calculations
    wire [N-1:0] C;
    assign C[0] = cin;

    genvar k;
    generate
        for (k = 1; k < N; k = k + 1) begin : carry
            assign C[k] = G1[STAGES][k-1] | (P1[STAGES][k-1] & C[k-1]);
        end
    endgenerate

    // Sum and Cout Calculation
    assign sum = P ^ C;
    assign cout = G1[STAGES][N-1] | (P1[STAGES][N-1] & C[N-1]);

endmodule