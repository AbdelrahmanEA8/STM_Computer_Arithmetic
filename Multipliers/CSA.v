module CSA #(parameter WIDTH = 32) (
    input   [WIDTH-1:0] a,b,c,
    output  [WIDTH-1:0] sum,carry
);

    // Sum is OR operation for 3 operands
    assign sum =  (a ^ b ^ c);

    // Carry is AND operation for all combinatios shifted left by 1     
    assign carry = {(a & b) | (b & c) | (c & a), 1'b0};
    
endmodule