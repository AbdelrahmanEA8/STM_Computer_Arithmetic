module signed_array_mplier #(
    parameter N = 32
) (
    input  [N-1:0]   mplier,
    input  [N-1:0]   mcand,
    output [2*N-1:0] product
);
    // Partial product
    wire [N-1:0] pp [0:N-1];

    // Partial Product Generation (The AND Gate Layer)
    genvar i, j;
    generate
        for (i=0; i<N; i=i+1) begin : pp_gen
            for (j=0; j<N; j=j+1) begin : and_gen
                if(j == N-1 ^ i == N-1)                         // Signed (2’s-complement)
                    assign pp[i][j] = !(mcand[i] & mplier[j]);
                else
                    assign pp[i][j] = mcand[i] & mplier[j];
            end
        end
    endgenerate

    // Adder array
    wire [N-1:0] sum [0:N-1];
    wire [N-1:0] carry [0:N-1];
    
    // First row (special case)
    // assign sum[0][0] = pp[0][0];
    // assign carry[0][0] = 1'b0;

    generate
        for (i = 0; i < N; i = i + 1) begin : rows_gen
            for (j = 0; j < N; j = j + 1) begin : cols_gen
                if (i == 0) begin                               // First row
                    full_adder fa (
                        .a(pp[i][j]),
                        .b(1'b0),                               // no sum from the prev row,column --> there is no prev row
                        .c(1'b0),                             // no carry from the prev row
                        .sum(sum[i][j]),
                        .cout(carry[i][j])
                    );
                end
                else if (i > 0 && j == N-1) begin               // last column handling --> No sum as we don't have next column
                    full_adder fa (
                        .a(pp[i][j]),
                        .b(carry[i-1][j]),
                        .c(1'b0),
                        .sum(sum[i][j]),
                        .cout(carry[i][j])
                    );
                end
                else begin                                      // row_adders , cin from the prev row , sum from the prev row + next column 
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

    wire [N-1:0] cin;
    assign cin[0] = 1'b1;
    assign product[0] = sum[0][0];

    // Connect bits of product
    generate
        for (j = 0; j < N ; j = j + 1) begin : Connect_lower_bits_of_product
            assign product[j] = sum[j][0];
        end

        for (i = 0; i < N-1; i = i + 1) begin : Connect_upper_bits_of_product
             full_adder fa (
                        .a(sum[N-1][i+1]),
                        .b(carry[N-1][i]),
                        .c(cin[i]),
            			.sum(product[N+i]),             // Product[i] index i came from index + last_row_index
            			.cout(cin[i+1])
                     );
        end
    endgenerate
    
    // last bit in the product --->  cin from the prev FA 
    assign product[2*N-1] = cin[N-1] + 1;

endmodule