`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module tb_logic_gate();
reg a_in;
reg b_in;
wire and_out;
wire or_out;
wire not_out;

initial begin
    a_in = 0;
    b_in = 0;
    #10;
    a_in = 1;
    b_in = 0;
    #10;
    a_in = 0;
    b_in = 1;
    #10;
    a_in = 1;
    b_in = 1;
    #10;
    a_in = 0;
    b_in = 0;
end

    logic_gate U1 (
        .a(a_in),
        .b(b_in),
        .and_o(and_out),
        .or_o(or_out),
        .not_o(not_out)
    );
endmodule