module unsigned_array_mplier #(
    parameter N = 32
)(
    input  [N-1:0]   mplier,
    input  [N-1:0]   mcand,
    output [2*N-1:0] product
);

    // Partial product generation
    wire [N-1:0] pp [N-1:0];

    genvar i, j;
    generate
        for (i = 0; i < N; i = i + 1) begin : pp_gen
            for (j = 0; j < N; j = j + 1) begin : and_gen
                assign pp[i][j] = mcand[i] & mplier[j];  // Unsigned multiplication
            end
        end
    endgenerate

    // Adder array
    wire [N-1:0] sum   [N-1:0];
    wire [N-1:0] carry [N-1:0];

    // First row: just assign partial products directly
    generate
        for (j = 0; j < N; j = j + 1) begin : first_row
            assign sum[0][j]   = pp[0][j];
            assign carry[0][j] = 1'b0;
        end
    endgenerate

    // Adder array rows
    generate
        for (i = 1; i < N; i = i + 1) begin : adder_rows
            for (j = 0; j < N; j = j + 1) begin : adder_cols
            // last column : No carry from prev colums 
                if (j == N-1) begin 
                    full_adder fa (
                        .a(pp[i][j]),
                        .b(carry[i-1][j]),
                        .c(1'b0),
                        .sum(sum[i][j]),
                        .cout(carry[i][j])
                    );
                end else begin
                // General form for all rows 
                    full_adder fa (
                        .a(pp[i][j]),
                        .b(sum[i-1][j+1]),
                        .c(carry[i-1][j]),
                        .sum(sum[i][j]),
                        .cout(carry[i][j])
                    );
                end
            end
        end
    endgenerate

    // Connecting product bits
    wire [N-1:0] cin;
    assign product[0] = sum[0][0];
    assign cin[0] = 1'b0;

    generate
        for (i = 1; i < N; i = i + 1) begin : product_lower
            assign product[i] = sum[i][0];
        end

        for (i = 0; i < N-1; i = i + 1) begin : product_upper
            full_adder fa (
                .a(sum[N-1][i+1]),
                .b(carry[N-1][i]),
                .c(cin[i]),
                .sum(product[N+i]),
                .cout(cin[i+1])
            );
        end
    endgenerate

    // Final MSB of product
    assign product[2*N-1] = carry[N-1][N-1] ^ cin[N-1];  //  XOR of last carrys , operates likes sum of HA

endmodule
