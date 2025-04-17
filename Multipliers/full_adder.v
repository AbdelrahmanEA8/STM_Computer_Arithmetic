module full_adder (
    input  a, b, c,
    output sum, cout
);
    // Sum is OR operation for 3 operands
    assign sum = a ^ b ^ c;

    // Carry is AND operation for all combinatios  
    assign cout = (a & b) | (b & c) | (c & a);
    
endmodule