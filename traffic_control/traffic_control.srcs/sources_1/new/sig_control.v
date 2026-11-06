module sig_control(hwy, cntry, X, clock, clear);
    output [1:0] hwy, cntry;
    reg [1:0] hwy, cntry;
    input X;
    input clock, clear;

    parameter integer CLOCK_HZ = 100_000_000;
    localparam integer Y2RDELAY = 3 * CLOCK_HZ;
    localparam integer R2GDELAY = 2 * CLOCK_HZ;
    parameter RED = 2'd0, YELLOW = 2'd1, GREEN = 2'd2;
    parameter S0 = 3'd0, S1 = 3'd1, S2 = 3'd2, S3 = 3'd3, S4 = 3'd4;

    reg [2:0] state, next_state;
    reg [$clog2(Y2RDELAY)-1:0] delay_count;
    (* ASYNC_REG = "TRUE" *) reg x_meta, x_sync;

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

    always @(posedge clock)
        if (clear)
            state <= S0;
        else
            state <= next_state;

    always @(posedge clock) begin
        if (clear || state != next_state)
            delay_count <= 0;
        else if (state == S1 || state == S2 || state == S4)
            delay_count <= delay_count + 1'b1;
    end

    always @(state) begin
        hwy = GREEN;
        cntry = RED;
        case (state)
            S0: ;
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
            default: hwy = RED;
        endcase
    end

    always @* begin
        next_state = state;
        case (state)
            S0: if (x_sync) next_state = S1;
            S1: if (delay_count == Y2RDELAY - 1) next_state = S2;
            S2: if (delay_count == R2GDELAY - 1) next_state = S3;
            S3: if (!x_sync) next_state = S4;
            S4: if (delay_count == Y2RDELAY - 1) next_state = S0;
            default: next_state = S0;
        endcase
    end
endmodule