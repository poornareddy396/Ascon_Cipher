`timescale 1ns/1ps
module tb_linear;
reg [63:0] x0,x1,x2,x3,x4;
wire [63:0] o0,o1,o2,o3,o4;
linear_sub DUT(
.x0(x0),
.x1(x1),
.x2(x2),
.x3(x3),
.x4(x4),
.o0(o0),
.o1(o1),
.o2(o2),
.o3(o3),
.o4(o4)
);
initial
begin
x0=64'h0123456789ABCDEF;
x1=64'h1111111111111111;
x2=64'h2222222222222222;
x3=64'h3333333333333333;
x4=64'h4444444444444444;
#20;
$display("%h",o0);
$display("%h",o1);
$display("%h",o2);
$display("%h",o3);
$display("%h",o4);
$finish;
end
endmodule