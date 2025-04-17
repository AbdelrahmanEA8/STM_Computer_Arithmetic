`timescale 1ns/1ps

module tb_array_mplier;
    parameter N = 32;  // Matches DUT parameter
    
    
    // DUT Signals
    reg signed [N-1:0] mplier;
    reg signed [N-1:0] mcand;
    wire [2*N-1:0] product;
    
    
    reg signed [2*N-1:0] expected_product;
    integer error_count = 0;
    integer test_count = 0;
    real total_delay = 0;
    real max_delay = 0;
    real min_delay = 0;
    real start_time, end_time;
    integer i,a,b;
    
    
    // Instantiate DUT
    signed_array_mplier #(.N(N)) dut (
        .mplier(mplier),
        .mcand(mcand),
        .product(product)
    );
    
    // Test case task
    task automatic test_case;
        input [N-1:0] a;
        input [N-1:0] b;
        begin
            mplier = a;
            mcand = b;
            expected_product = a * b;  // Use behavioral multiplication as reference
            #10;
            
            
            #10;
            // Verification
            if (product !== expected_product) begin
                $display("[ERROR] Test case %0d failed:", test_count);
                $display("Multiplier = %h (%0d)", mplier, mplier);
                $display("Multiplicand = %h (%0d)", mcand, mcand);
                $display("Expected: %h (%0d)", expected_product, expected_product);
                $display("Got:      %h (%0d)", product, product);
                $display("Difference: %0d", expected_product - product);
                error_count = error_count + 1;
            end
            
            test_count = test_count + 1;
        end
    endtask
    
    // Main test sequence
    initial begin
        $display("\nStarting testbench for %0d-bit array multiplier...", N);
        $display("--------------------------------------------------");
        
        // Basic test cases
        test_case(0, 0);                     // 0 × 0
        test_case(0, {N{1'b1}});             // 0 × max
        test_case({N{1'b1}}, 0);             // max × 0
        test_case(1, 1);                     // 1 × 1
        test_case(1, {N{1'b1}});             // 1 × max
        test_case({N{1'b1}}, 1);             // max × 1
        
        // Power-of-two tests
        test_case(2, 2);
        test_case(4, 8);
        test_case(16, 32);
        test_case(1 << (N/2), 1 << (N/2));
        
        // Known-value tests
        test_case(32'h12345678, 32'h87654321);
        test_case(32'hABCDEF01, 32'h01FEDCBA);
        
        // Pattern tests
        test_case({N/2{2'b01}}, {N/2{2'b10}});  // Alternating bits
        test_case({N/4{4'b0011}}, {N/4{4'b1100}});  // Nibble patterns
        
        // Corner cases
        test_case({N{1'b1}}, {N{1'b1}});    // max × max
        test_case(1 << (N-1), 1 << (N-1));  // MSB × MSB
        
        // Random tests
        for (i = 0; i < 100; i = i + 1) begin
            test_case($random, $random);
        end
        
        // Exhaustive tests for smaller N
        if (N <= 8) begin
            $display("Running exhaustive tests for N=%0d...", N);
            for (a = 0; a < (1 << N); a = a + 1) begin
                for (b = 0; b < (1 << N); b = b + 1) begin
                    test_case(a, b);
                end
            end
        end
        
        // Complete testing
        $display("--------------------------------------------------");
        $display("Testbench completed:");
        $display("Total tests run: %0d", test_count);
        $display("Errors detected: %0d", error_count);
        
        if (error_count == 0)
            $display("SUCCESS: All test cases passed!");
        else
            $display("FAILURE: %0d test cases failed", error_count);
        
        $stop;
    end
    
endmodule