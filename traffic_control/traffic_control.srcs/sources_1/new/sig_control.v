`timescale 1ns / 1ps

// Lecture 7.9: delays are positive numbers of rising clock edges.
module sig_control #(
    parameter integer Y2RDELAY = 3,
    parameter integer R2GDELAY = 2
    )(
    output reg [1:0] hwy,
    output reg [1:0] cntry,
    input wire X,
    input wire clock,
    input wire clear
    );

    localparam [1:0] RED = 2'd0, YELLOW = 2'd1, GREEN = 2'd2;
    localparam [2:0] S0 = 3'd0, S1 = 3'd1, S2 = 3'd2,
                     S3 = 3'd3, S4 = 3'd4;
    reg [2:0] state;
    reg [2:0] next_state;
    reg [31:0] delay_count;

    always @(posedge clock) begin
        if (clear) begin
            state <= S0;
            delay_count <= 0;
        end
        else begin
            state <= next_state;
            if (state != next_state)
                delay_count <= 0;
            else if (state == S1 || state == S2 || state == S4)
                delay_count <= delay_count + 1'b1;
            else
                delay_count <= 0;
        end
    end

    always @* begin
        next_state = S0;
        case (state)
            S0: begin
                if (X) next_state = S1;
                else next_state = S0;
            end
            S1: begin
                if (delay_count == Y2RDELAY - 1) next_state = S2;
                else next_state = S1;
            end
            S2: begin
                if (delay_count == R2GDELAY - 1) next_state = S3;
                else next_state = S2;
            end
            S3: begin
                if (X) next_state = S3;
                else next_state = S4;
            end
            S4: begin
                if (delay_count == Y2RDELAY - 1) next_state = S0;
                else next_state = S4;
            end
            default: next_state = S0;
        endcase
    end

    always @* begin
        hwy = GREEN;
        cntry = RED;
        case (state)
            S0: begin
                hwy = GREEN;
                cntry = RED;
            end
            S1: hwy = YELLOW;
            S2: hwy = RED;
            S3: begin
                hwy = RED;
                cntry = GREEN;
            end
            S4: begin
                hwy = RED;
                cntry = YELLOW;
            end
            default: begin
                hwy = RED;
                cntry = RED;
            end
        endcase
    end
endmodule