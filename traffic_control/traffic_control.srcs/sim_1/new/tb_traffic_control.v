`timescale 1ns / 1ps

module tb_traffic_control;
    reg clock;
    reg clear;
    reg X;
    wire [1:0] hwy;
    wire [1:0] cntry;
    traffic_control #(.CLOCK_HZ(2)) dut(
        .clock(clock), .clear(clear), .X(X), .hwy(hwy), .cntry(cntry)
    );
    initial clock = 1'b0;
    always #5 clock = ~clock;
    initial begin
        clear = 1'b1;
        X = 1'b0;
        #20 clear = 1'b0;
        #50 X = 1'b1;
        #250 X = 1'b0;
        #120 X = 1'b1;
        #200 clear = 1'b1; // Reset while the sensor remains asserted.
        #20;
        clear = 1'b0;
        X = 1'b0;
        #40 X = 1'b1;
        #20 X = 1'b0;
        #200;
        $finish;
    end
endmodule