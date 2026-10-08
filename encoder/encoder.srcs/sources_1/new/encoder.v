`timescale 1ns / 1ps

module encoder(
    input wire EN,
    input wire [2:0] D,
    output reg [1:0] B
);
    always @* begin
        B = 2'b00;
        if (EN) begin
            casex (D)
                3'b1xx: B = 2'b11;
                3'b01x: B = 2'b10;
                3'b001: B = 2'b01;
                default: B = 2'b00;
            endcase
        end
    end
endmodule