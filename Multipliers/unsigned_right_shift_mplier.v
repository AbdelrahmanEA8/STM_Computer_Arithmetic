module mplier #(parameter N = 32) (
    input                      clk,reset,
    input       [N-1:0]    mcand,mplier,
    output reg  [2*N-1:0]  product
);
    reg    [N-1:0]    mplier_reg;
    reg    [N-1:0]    partial_product;
    reg    [N-1:0]    counter;
    wire   [N:0]      adder_out; // adder_out,adder_cout

    assign adder_out = (mplier_reg[0]) ?  partial_product+mcand : partial_product ;
    
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            product <= 0;
            counter <= 0;
            partial_product <= 0;
            mplier_reg <= 0;
        end
        else begin
            mplier_reg <= mplier;
            if (counter<N) begin
                counter<=counter+1;
                {partial_product,mplier_reg} <= {adder_out,mplier_reg} >> 1;
            end
            else begin
                counter<=0;
                product<={partial_product,mplier_reg};
            end
        end
    end
endmodule