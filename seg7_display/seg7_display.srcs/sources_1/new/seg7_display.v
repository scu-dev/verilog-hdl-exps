`timescale 1ns / 1ps

module seg7_display #(
    parameter integer SCAN_CYCLES = 100_000
)(
    input wire clk,
    input wire rst,
    input wire [15:0] sw,
    output reg [3:0] an,
    output reg [6:0] seg,
    output wire dp
);
    // One slot includes one blank clock; at 100MHz, four slots take 4ms.
    localparam integer SLOT_CYCLES = (SCAN_CYCLES < 2) ? 2 : SCAN_CYCLES;
    localparam integer COUNT_WIDTH = $clog2(SLOT_CYCLES);

    (* ASYNC_REG = "TRUE" *) reg [15:0] sw_meta;
    (* ASYNC_REG = "TRUE" *) reg [15:0] sw_sync;
    reg [COUNT_WIDTH - 1:0] scan_count;
    reg [1:0] digit_index;
    reg blank;
    reg [3:0] digit_value;

    assign dp = 1'b1;

    // Synchronize the physical switches before using their values.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sw_meta <= 16'd0;
            sw_sync <= 16'd0;
        end
        else begin
            sw_meta <= sw;
            sw_sync <= sw_meta;
        end
    end

    // Use a clock enable rather than creating a second clock domain.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            scan_count <= {COUNT_WIDTH{1'b0}};
            digit_index <= 2'd0;
            blank <= 1'b1;
        end
        else if (scan_count == SLOT_CYCLES - 1) begin
            scan_count <= {COUNT_WIDTH{1'b0}};
            digit_index <= digit_index + 1'b1;
            blank <= 1'b1;
        end
        else begin
            scan_count <= scan_count + 1'b1;
            blank <= 1'b0;
        end
    end

    // seg[6:0] = {g, f, e, d, c, b, a}; all outputs are active low.
    function [6:0] decode_decimal;
        input [3:0] value;
        begin
            case (value)
                4'd0: decode_decimal = 7'b1000000;
                4'd1: decode_decimal = 7'b1111001;
                4'd2: decode_decimal = 7'b0100100;
                4'd3: decode_decimal = 7'b0110000;
                4'd4: decode_decimal = 7'b0011001;
                4'd5: decode_decimal = 7'b0010010;
                4'd6: decode_decimal = 7'b0000010;
                4'd7: decode_decimal = 7'b1111000;
                4'd8: decode_decimal = 7'b0000000;
                4'd9: decode_decimal = 7'b0010000;
                default: decode_decimal = 7'b1111111;
            endcase
        end
    endfunction

    always @* begin
        digit_value = 4'd0;
        an = 4'b1111;
        case (digit_index)
            2'd0: begin
                digit_value = sw_sync[3:0];
                an = 4'b1110;
            end
            2'd1: begin
                digit_value = sw_sync[7:4];
                an = 4'b1101;
            end
            2'd2: begin
                digit_value = sw_sync[11:8];
                an = 4'b1011;
            end
            2'd3: begin
                digit_value = sw_sync[15:12];
                an = 4'b0111;
            end
        endcase

        // Prepare the next segment pattern while all digits are disabled.
        seg = decode_decimal(digit_value);
        if (blank)
            an = 4'b1111;
        if (rst) begin
            an = 4'b1111;
            seg = 7'b1111111;
        end
    end
endmodule