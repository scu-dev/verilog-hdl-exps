`timescale 1ns / 1ps

module tb_counter;
    reg clk;
    reg rst_n;
    wire [7:0] B;
    wire clk_1hz;

    // Simulation only: divide by 10 to observe a full 0-255 cycle quickly.
    counter #(.DIVISOR(10)) dut(
        .clk(clk),
        .rst_n(rst_n),
        .B(B)
    );

    assign clk_1hz = dut.clk_1hz;

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        rst_n = 1'b0;
        #20;
        rst_n = 1'b1;
        #25832;
        rst_n = 1'b0;
        #18;
        rst_n = 1'b1;
        #350;
        $finish;
    end
endmodule