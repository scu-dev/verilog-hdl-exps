`timescale 1ns / 1ps

module traffic_control #(parameter integer CLOCK_HZ = 100_000_000)(
    input wire clock,
    input wire clear,
    input wire X,
    output wire [1:0] hwy,
    output wire [1:0] cntry
);
    (* ASYNC_REG = "TRUE" *) reg x_meta;
    (* ASYNC_REG = "TRUE" *) reg x_sync;
    always @(posedge clock) begin
        if (clear) begin
            x_meta <= 1'b0;
            x_sync <= 1'b0;
        end
        else begin
            x_meta <= X;
            x_sync <= x_meta;
        end
    end
    sig_control #(
        .Y2RDELAY(3 * CLOCK_HZ),
        .R2GDELAY(2 * CLOCK_HZ)
    ) controller(
        .hwy(hwy),
        .cntry(cntry),
        .X(x_sync),
        .clock(clock),
        .clear(clear)
    );
endmodule