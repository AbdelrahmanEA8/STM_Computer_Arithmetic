module signed_right_shift_mplier #(
    parameter N = 32
)(
    input                 clk,
    input                 rst_n,      // Active-low reset
    input    [N-1:0]      mcand,
    input    [N-1:0]      mplier,
    output   [2*N-1:0]    product,
    output                done 
);

    reg signed  [2*N-1:0]         partial_product;
    reg signed  [N:0]             mcand_reg;
    reg signed  [N:0]             mplier_reg;
    reg         [$clog2(N):0]     counter;


    reg  [N:0]  mux_out;
    reg  [N:0]  sum;
    reg         cout;

    always @(*) begin
    // Multiplxer
        case (mplier_reg[1:0])  // booth recoding 
          2'b00 , 2'b11 :   mux_out = 0;
          2'b01         :   mux_out = mcand_reg;
          default       :   mux_out = ~mcand_reg + 1;  // 2's complement of mcand_reg
        endcase

    // Adder
        {cout,sum} = partial_product[2*N-1:N-1] + mux_out;

    end
    
    reg LSB;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            partial_product <= 0;
            counter         <= 0;
            LSB             <= 0;
            mcand_reg       <= {mcand[N-1],mcand};
            mplier_reg      <= {mplier,1'b0};
        end else begin
            partial_product <= {sum[N], sum, partial_product[N-2:1]};
            LSB             <= (counter== N-1) ? partial_product[0] : LSB;
            counter         <= counter + 1;
            mplier_reg      <= mplier_reg >>> 1;
        end
    end

        assign done = (counter == N);
        assign product = {partial_product[2*N-2:0],LSB};
        
endmodule