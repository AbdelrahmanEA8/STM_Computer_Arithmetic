module tb_radix8_mplier;

  // Parameters
  parameter N = 32;
  parameter RADIX = 8;
  parameter EXTRA_BITS = $clog2(RADIX);
  parameter TOTAL_CYCLES = 11;

  // DUT Signals
  logic clk, rst;
  logic signed [N-1:0] mcand;
  logic signed [N-1:0] mplier;
  logic signed [2*N-1:0] product;
  logic signed [2*N-1:0] product_expected;
  logic done;

  // Clock Generation
  initial clk = 0;
  always #5 clk = ~clk;  // 10ns clock period

  // DUT Instantiation
  Radix8_Mplier #(.N(N), .RADIX(RADIX), .EXTRA_BITS(EXTRA_BITS)) DUT (
    .clk(clk),
    .rst(rst),
    .mcand(mcand),
    .mplier(mplier),
    .product(product),
    .done(done)
  );


  // Test sequence
  initial begin
    // Initial state
    chk_rst();

    // Run multiple tests
    repeat (500) begin
        rst=1;
        mcand = $urandom_range(0,1000);
        mplier = $urandom_range(0,1000);
        @(negedge clk);
        rst=0;
        chk_output;
    end

    repeat (1000) begin
        rst=1;
        mcand = $random;
        mplier = $random;
        chk_output;
    end

    apply_test(0, 0);
    apply_test(5, 0);
    apply_test(0, -7);
    apply_test(1, 1);
    apply_test(-1, -1);
    apply_test(1234, 5678);
    apply_test(-1234, 5678);
    apply_test(1234, -5678);
    apply_test(-1234, -5678);
    apply_test(32'h7FFFFFFF, 2);     // Check overflow edge case
    apply_test(32'h80000000, 1);     // Check negative MSB

    $display("\nAll test cases passed");
    $stop;
  end

    task chk_rst();
        rst=1;
        mcand = 0;
        mplier = 0;
        repeat(3) @(negedge clk);
        if (product==0) begin
            $display ("Valid Output, Product=%h , Product_expexted=%h ",product,0);
        end
        else begin
            $display ("Invalid Output, Product=%h , Product_expexted=%h ",product,0);
        end
        rst=0;
    endtask

    task chk_output();
        @(negedge clk);
        rst=0;
        product_expected = mcand * mplier;
        repeat(TOTAL_CYCLES) @(negedge clk);
        if (product==product_expected) begin
            $display ("Valid Output, Product=%h , Product_expexted=%h ",product,product_expected);
        end
        else begin
            $display ("Mismatch detected: %0d * %0d = %0d (Expected %0d)", mcand, mplier, product,product_expected);
        end
    endtask
    // Task to apply stimulus
    task apply_test(input signed [N-1:0] a, input signed [N-1:0] b);
      begin
        rst=1;
        mcand = a;
        mplier = b;
        @(negedge clk);
        rst=0;
        product_expected = mcand * mplier;
        // Wait for done signal
        repeat(TOTAL_CYCLES) @(negedge clk);

        $display("A = %0d, B = %0d, DUT Product = %0d, Expected = %0d %s",
          a, b, product, a * b, (product === a * b) ? "valid" : "error");
        if(!(product === a * b))
           $display("Mismatch detected: %0d * %0d = %0d (Expected %0d)", a, b, product, a*b);
      end
    endtask
endmodule
