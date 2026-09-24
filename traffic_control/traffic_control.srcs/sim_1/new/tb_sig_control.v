`timescale 1ns / 1ps

module tb_sig_control;
    reg clock;
    reg clear;
    reg X;
    wire [1:0] hwy;
    wire [1:0] cntry;

    sig_control dut(
        .hwy(hwy), .cntry(cntry), .X(X), .clock(clock), .clear(clear)
    );

    initial clock = 1'b0;
    always #5 clock = ~clock;

    initial begin
        clear = 1'b1;
        X = 1'b0;
        #20 clear = 1'b0;
        #50 X = 1'b1;
        #150 X = 1'b0;
        #60 X = 1'b1;
        #10 X = 1'b0; // A withdrawn request does not skip S1 or S2.
        #120 X = 1'b1;
        #17; // Reset during S1, between rising edges.
        clear = 1'b1;
        X = 1'b0;
        #10 clear = 1'b0;
        #23 X = 1'b1;
        #47; // Reset during S2.
        clear = 1'b1;
        X = 1'b0;
        #10 clear = 1'b0;
        #23 X = 1'b1;
        #80; // Reset during S3.
        clear = 1'b1;
        X = 1'b0;
        #10 clear = 1'b0;
        #20 X = 1'b1;
        #70 X = 1'b0;
        #17 clear = 1'b1; // Reset during S4.
        #10 clear = 1'b0;
        #33;
        $finish;
    end
endmodule