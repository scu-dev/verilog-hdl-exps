`timescale 1ns / 1ps

module counter #(parameter integer DIVISOR = 100_000_000)(
    input wire clk,
    input wire rst_n,
    output reg [7:0] B
 );
    reg [26:0] div_count;
    reg clk_1hz;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            div_count <= 0;
            clk_1hz <= 1'b0;
        end
        else if (div_count == DIVISOR - 1) begin
            div_count <= 0;
            clk_1hz <= 1'b1;
        end
        else begin
            div_count <= div_count + 1'b1;
            clk_1hz <= 1'b0;
        end
    end

    always @(posedge clk_1hz or negedge rst_n) begin
        if (!rst_n)
            B <= 8'd0;
        else if (B == 8'd255)
            B <= 8'd0;
        else
            B <= B + 1'b1;
    end
endmodule