`timescale 1ns / 1ps

module logic_gate(
    input wire a,
    input wire b,
    output wire and_o,
    output wire or_o,
    output wire not_o
    );
    
    assign and_o = a & b;
    assign or_o = a | b;
    assign not_o = ~a;
endmodule
