module multiplier #(
    parameter N = 32
) (
    input  [N-1:0]      mplier,
    input  [N-1:0]      mcand,
    output [2*N-1:0]    product
);

    assign product = mplier * mcand;
    
endmodule