module radix8_mplier #(
    parameter N = 32,
    parameter RADIX = 8,
    parameter EXTRA_BITS = $clog2(RADIX),
    localparam TOTAL_CYCLES = 11  // ceil(33 / 3) = 11
) (
    input                         clk,rst,
    input  signed 	[N-1:0] 	  mcand, 			
    input  signed   [N-1:0]		  mplier,			
    output signed  	[2*N-1:0]	  product, 			
    output                        done
);

///////////////////////// Forming Logic /////////////////////////

    reg signed  [N-1:0]             mcand_reg; 			
    reg signed  [N:0]	            mplier_reg;         // Extended with 1-bit on the left on RSB
    reg signed  [N+EXTRA_BITS-1:0]  generate_pp;

    reg signed  [N+EXTRA_BITS-1:0]   mux_a;
    reg signed  [N+EXTRA_BITS-1:0]   mux_2a;
    reg signed  [N+EXTRA_BITS-1:0]   mux_3a;
    reg signed  [N+EXTRA_BITS-1:0]   mux_4a;
    reg signed  [N+EXTRA_BITS-1:0]   mux_a_neg;
    reg signed  [N+EXTRA_BITS-1:0]   mux_2a_neg;
    reg signed  [N+EXTRA_BITS-1:0]   mux_3a_neg;
    reg signed  [N+EXTRA_BITS-1:0]   mux_4a_neg;

    // Precompute a and its multiples
    always @(*) begin
        mux_a = {{3{mcand_reg[N-1:0]}},mcand_reg};
        mux_2a = mux_a << 1;
        mux_3a = mux_2a + mux_a;
        mux_4a = mux_a << 2;
        mux_a_neg = ~(mux_a) + 1;
        mux_2a_neg = mux_a_neg << 1;
        mux_3a_neg = mux_a_neg + mux_2a_neg;
        mux_4a_neg = mux_a_neg << 2;
    end

    // Generate PP based on booth_code
    wire [3:0] booth_code;
    assign booth_code = mplier_reg[3:0];

    always @(*) begin
      case (booth_code)
        4'b0000: generate_pp = 0;          // 0a
        4'b0001: generate_pp = mux_a;      // +1a
        4'b0010: generate_pp = mux_a;      // +1a
        4'b0011: generate_pp = mux_2a;       // +2a
        4'b0100: generate_pp = mux_2a;       // +2a
        4'b0101: generate_pp = mux_3a;       // +3a
        4'b0110: generate_pp = mux_3a;       // +3a
        4'b0111: generate_pp = mux_4a;       // +4a
        4'b1000: generate_pp = mux_4a_neg;   // -4a
        4'b1001: generate_pp = mux_3a_neg;   // -3a
        4'b1010: generate_pp = mux_3a_neg;   // -3a
        4'b1011: generate_pp = mux_2a_neg;   // -2a
        4'b1100: generate_pp = mux_2a_neg;   // -2a
        4'b1101: generate_pp = mux_a_neg;     // -1a
        4'b1110: generate_pp = mux_a_neg;     // -1a
        4'b1111: generate_pp = 0;         // 0a
      endcase
    end


////////////////////////// Adder Network ////////////////////////

    reg signed  [N+EXTRA_BITS-1:0]  sum_reg; 			
    reg signed  [N+EXTRA_BITS-1:0]	carry_reg;
    reg signed  [2*N-1:0]           final_product;
    reg         [$clog2(N)-1:0]     count;
    reg                             cout_reg;

    wire        [EXTRA_BITS-1:0]    add_in1 , add_in2;
    wire        [EXTRA_BITS-1:0]    add_out;
    wire                            add_cout;
    wire        [N+EXTRA_BITS:0]    cpa;
    
    wire        [N+EXTRA_BITS-1:0]  csa_sum;
    wire        [N+EXTRA_BITS-1:0]  csa_carry;

    CSA #(.WIDTH(N+EXTRA_BITS)) csa (.a(sum_reg),.b(carry_reg),.c(generate_pp),.sum(csa_sum),.carry(csa_carry));

    assign add_in1 = sum_reg[EXTRA_BITS-1:0];
    assign add_in2 = carry_reg[EXTRA_BITS-1:0];
    assign {add_cout,add_out} = add_in1 + add_in2 + cout_reg;
  
    always@(posedge clk) begin
      if(rst)
        cout_reg <=0;
      else
        cout_reg <= add_cout;
    end 


    always @(posedge clk) begin
        if (rst) begin
            mplier_reg <= {mplier,1'b0};
            mcand_reg  <= mcand;
            sum_reg    <= 0;
            carry_reg  <= 0;
            count      <= 0;
        end 
        else begin
            sum_reg    <= { {3{csa_sum[N+EXTRA_BITS-1]}} , csa_sum[N+EXTRA_BITS-1:3] };
            carry_reg  <= { {3{csa_carry[N+EXTRA_BITS-1]}}, csa_carry[N+EXTRA_BITS-1:3] };
            mplier_reg <= mplier_reg >>> $clog2(RADIX);
            count      <= count + 1;
        end
    end

  
    always@(posedge clk) begin
        if(rst)
            final_product <=0;
        else begin
            if (count == 0)
                final_product[2:0] <= add_out; 
            else if (count == 1)
                final_product[5:3] <= add_out;  
            else if (count == 2)
                final_product[8:6] <= add_out;  
            else if (count == 3)
                final_product[11:9] <= add_out; 
            else if (count == 4)
                final_product[14:12] <= add_out;
            else if (count == 5)
                final_product[17:15] <= add_out;
            else if (count == 6)
                final_product[20:18] <= add_out;
            else if (count == 7)
                final_product[23:21] <= add_out;
            else if (count == 8)
                final_product[26:24] <= add_out;
            else if (count == 9)
                final_product[29:27] <= add_out;
            else if (count == 10)
                final_product[32:30] <= add_out;
            else
                final_product <= final_product;        
        end
 end
  

  assign cpa = sum_reg + carry_reg + cout_reg;
  assign product = {cpa , final_product[(TOTAL_CYCLES*EXTRA_BITS)-1:0]};
  assign done = count == TOTAL_CYCLES;

endmodule