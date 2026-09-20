`timescale 1ns / 1ps

module tb_encoder;
    reg EN;
    reg [2:0] D;
    wire [1:0] procedural_B;
    wire [1:0] behavioral_B;

    encoder dut(EN, D, procedural_B);
    encoder_behavioral expression_dut(EN, D, behavioral_B);

    initial begin
        {EN, D} = 4'b0000;
        #10;
        {EN, D} = 4'b0001;
        #10;
        {EN, D} = 4'b0010;
        #10;
        {EN, D} = 4'b0011;
        #10;
        {EN, D} = 4'b0100;
        #10;
        {EN, D} = 4'b0101;
        #10;
        {EN, D} = 4'b0110;
        #10;
        {EN, D} = 4'b0111;
        #10;
        {EN, D} = 4'b1000;
        #10;
        {EN, D} = 4'b1001;
        #10;
        {EN, D} = 4'b1010;
        #10;
        {EN, D} = 4'b1011;
        #10;
        {EN, D} = 4'b1100;
        #10;
        {EN, D} = 4'b1101;
        #10;
        {EN, D} = 4'b1110;
        #10;
        {EN, D} = 4'b1111;
    end
endmodule