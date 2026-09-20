`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/09/17 20:26:45
// Design Name: 
// Module Name: logic_gate
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


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
