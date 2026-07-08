`timescale 1ns/1ps
module tb_RND_Const;
reg [63:0] x2_in;
reg [3:0] rnd;
reg [3:0] rnds;
wire [63:0] x2_out;
RND_Const DUT(
    .x2_in(x2_in),
    .rnd(rnd),
    .rnds(rnds),
    .x2_out(x2_out)
);
integer i;
initial begin
x2_in = 64'h0123456789ABCDEF;
rnds = 12;
for(i=0;i<12;i=i+1)
begin
    rnd=i;
    #10;
    $display("Round=%0d Output=%h",rnd,x2_out);
end
$finish;
end
endmodule