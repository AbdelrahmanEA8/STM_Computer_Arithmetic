module Brent_kung_tb #(parameter WIDTH = 64)();
    reg [WIDTH-1:0] a,b;
    reg cin;
    wire [WIDTH-1:0] sum;
    wire cout;

    parameter MAXPOS = 255;
    parameter ZERO = 0;

    Brent_kung_64bit DUV (.a(a),.b(b),.cin(cin),.sum(sum),.cout(cout));

    initial begin
        a=ZERO; b=ZERO; cin=ZERO;
        #10;
        a=MAXPOS; b=ZERO; cin=ZERO;
        #10;
        a=ZERO; b=MAXPOS; cin=ZERO;
        #10;
        a=MAXPOS; b=MAXPOS; cin=ZERO;
        #10;
        a=ZERO; b=ZERO; cin=1;
        #10;
        a=MAXPOS; b=ZERO; cin=1;
        #10;
        a=ZERO; b=MAXPOS; cin=1;
        #10;
        a=MAXPOS; b=MAXPOS; cin=1;
        #10;
        repeat(100)begin
            a=$random;
            b=$random;
            cin=$random;
            #10;
        end
        $stop;
    end
endmodule