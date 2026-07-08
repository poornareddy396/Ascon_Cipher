`timescale 1ns/1ps

module tb_SBOX;
reg [63:0] x0,x1,x2,x3,x4;
wire [63:0] sl0,sl1,sl2,sl3,sl4;
sbox DUT(
.x0(x0),
.x1(x1),
.x2(x2),
.x3(x3),
.x4(x4),

.sl0(sl0),
.sl1(sl1),
.sl2(sl2),
.sl3(sl3),
.sl4(sl4)
);
initial
begin
x0=64'h0123456789ABCDEF;
x1=64'h1111111111111111;
x2=64'h2222222222222222;
x3=64'h3333333333333333;
x4=64'h4444444444444444;
#20;
$display("%h",sl0);
$display("%h",sl1);
$display("%h",sl2);
$display("%h",sl3);
$display("%h",sl4);
$finish;
end
endmodule
