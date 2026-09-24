`timescale 1ns / 1ps

module encoder(
    input wire EN,
    input wire [2:0] D,
    output reg [1:0] B
);
    always @* begin
        B = 2'b00;
        if (EN) begin
            case (D)
                3'b001: B = 2'b01;
                3'b010: B = 2'b10;
                3'b100: B = 2'b11;
                default: B = 2'b00;
            endcase
        end
    end
endmodule

module encoder_behavioral(
    input wire EN,
    input wire [2:0] D,
    output wire [1:0] B
);
    assign B[1] = EN & ~D[0] & (D[2] ^ D[1]);
    assign B[0] = EN & ~D[1] & (D[2] ^ D[0]);
endmodule