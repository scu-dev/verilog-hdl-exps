`timescale 1ns / 1ps

module tb_seg7_display #(
    parameter integer SCAN_CYCLES = 8,
    parameter integer CHECK_DEFAULT = 0
);
    reg clk;
    reg rst;
    reg [15:0] sw;
    wire [3:0] an;
    wire [6:0] seg;
    wire dp;
    integer value;
    integer checked_frames;
    localparam integer SLOT_CYCLES = (SCAN_CYCLES < 2) ? 2 : SCAN_CYCLES;

    generate
        if (CHECK_DEFAULT) begin : default_scan
            seg7_display dut(
                .clk(clk), .rst(rst), .sw(sw), .an(an), .seg(seg), .dp(dp)
            );
        end
        else begin : fast_scan
            seg7_display #(.SCAN_CYCLES(SCAN_CYCLES)) dut(
                .clk(clk), .rst(rst), .sw(sw), .an(an), .seg(seg), .dp(dp)
            );
        end
    endgenerate

    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Describe each segment independently of the DUT's binary lookup table.
    function [6:0] expected_segments;
        input [3:0] digit;
        begin
            expected_segments[0] = !(digit == 0 || digit == 2 || digit == 3 ||
                digit == 5 || digit == 6 || digit == 7 || digit == 8 || digit == 9);
            expected_segments[1] = !(digit == 0 || digit == 1 || digit == 2 ||
                digit == 3 || digit == 4 || digit == 7 || digit == 8 || digit == 9);
            expected_segments[2] = !(digit == 0 || digit == 1 || digit == 3 ||
                digit == 4 || digit == 5 || digit == 6 || digit == 7 ||
                digit == 8 || digit == 9);
            expected_segments[3] = !(digit == 0 || digit == 2 || digit == 3 ||
                digit == 5 || digit == 6 || digit == 8 || digit == 9);
            expected_segments[4] = !(digit == 0 || digit == 2 || digit == 6 || digit == 8);
            expected_segments[5] = !(digit == 0 || digit == 4 || digit == 5 ||
                digit == 6 || digit == 8 || digit == 9);
            expected_segments[6] = !(digit == 2 || digit == 3 || digit == 4 ||
                digit == 5 || digit == 6 || digit == 8 || digit == 9);
        end
    endfunction

    task reset_display;
        begin
            // Assert reset between clock edges to check asynchronous blanking.
            @(negedge clk);
            #2 rst = 1'b1;
            #1;
            if (an !== 4'b1111 || seg !== 7'b1111111 || dp !== 1'b1)
                $fatal(1, "Reset must immediately turn off every segment and digit");
            repeat (2) @(posedge clk);
            #1;
            if (an !== 4'b1111 || seg !== 7'b1111111)
                $fatal(1, "Display must remain blank while reset is held");
            @(negedge clk);
            rst = 1'b0;
            @(posedge clk);
            #1;
            if (an !== 4'b1110)
                $fatal(1, "Scanning must restart at the rightmost digit");
        end
    endtask

    task check_display;
        input [15:0] switches;
        integer slot;
        integer tick;
        reg [3:0] seen;
        reg [3:0] active_an;
        reg [3:0] previous_an;
        reg [3:0] digit;
        begin
            @(negedge clk);
            sw = switches;
            repeat (3) @(posedge clk);
            #1;
            // Align to the next blanking interval without using DUT internals.
            while (an !== 4'b1111) begin
                @(posedge clk);
                #1;
            end
            seen = 4'b0000;
            previous_an = 4'b1111;
            for (slot = 0; slot < 4; slot = slot + 1) begin
                if (an !== 4'b1111)
                    $fatal(1, "A blank clock is required between adjacent digits");
                @(posedge clk);
                #1;
                active_an = an;
                if (slot > 0 && active_an !== {previous_an[2:0], previous_an[3]})
                    $fatal(1, "Incorrect digit scan order");
                case (active_an)
                    4'b1110: digit = switches[3:0];
                    4'b1101: digit = switches[7:4];
                    4'b1011: digit = switches[11:8];
                    4'b0111: digit = switches[15:12];
                    default: $fatal(1, "Exactly one digit must be enabled");
                endcase
                seen = seen | ~active_an;
                for (tick = 1; tick < SLOT_CYCLES; tick = tick + 1) begin
                    if (an !== active_an || seg !== expected_segments(digit) || dp !== 1'b1)
                        $fatal(1, "Display mismatch: sw=%h an=%b seg=%b expected=%b",
                            switches, an, seg, expected_segments(digit));
                    @(posedge clk);
                    #1;
                end
                previous_an = active_an;
            end
            if (an !== 4'b1111 || seen !== 4'b1111)
                $fatal(1, "Incorrect slot duration or incomplete four-digit frame");
            checked_frames = checked_frames + 1;
        end
    endtask

    always @(posedge clk) begin
        #1;
        if (dp !== 1'b1)
            $fatal(1, "The decimal point must remain off");
    end

    initial begin
        rst = 1'b0;
        sw = 16'h1234;
        checked_frames = 0;
        reset_display;
        check_display(16'h1234);
        if (!CHECK_DEFAULT) begin
            check_display(16'h5678);
            check_display(16'h90AF);
            for (value = 0; value < 16; value = value + 1)
                check_display({4{value[3:0]}});
        end
        // Reset during an active scan after changing all four switch groups.
        @(negedge clk);
        sw = 16'hF609;
        reset_display;
        check_display(16'hF609);
        $display("PASS: %0d frames; slot=%0d clocks; default=%0d",
            checked_frames, SLOT_CYCLES, CHECK_DEFAULT);
        $finish;
    end

    initial begin
        repeat (300 * SLOT_CYCLES + 100) @(posedge clk);
        $fatal(1, "Simulation timeout");
    end
endmodule