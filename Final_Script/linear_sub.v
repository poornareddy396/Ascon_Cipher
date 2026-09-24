`timescale 1ns / 1ps
module linear_sub(
        input [63:0] x0, x1, x2, x3, x4,
    output [63:0] o0, o1, o2, o3, o4

    );
   assign o0 = x0 ^ ROTR(x0,19) ^ ROTR(x0,28);
   assign o1 = x1 ^ ROTR(x1,61) ^ ROTR(x1,39);
   assign o2 = x2 ^ ROTR(x2,1)  ^ ROTR(x2,6);
   assign o3 = x3 ^ ROTR(x3,10) ^ ROTR(x3,17);
   assign o4 = x4 ^ ROTR(x4,7)  ^ ROTR(x4,41);
    function [63:0] ROTR;
    input [63:0] x;
    input integer n;
    begin
        ROTR = (x >> n) | (x << (64-n));
    end
endfunction
endmodule
