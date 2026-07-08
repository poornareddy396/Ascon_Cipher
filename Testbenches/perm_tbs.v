`timescale 1ns/1ps
module tb_Perm;
reg clk;
reg start;
reg [319:0] S;
reg [3:0] rnd_type;
wire finish;
wire [319:0] S_out;
Perm DUT(
    .clk(clk),
    .S(S),
    .start(start),
    .rnd_type(rnd_type),
    .finish(finish),
    .S_out(S_out)
);
always #5 clk = ~clk;
initial begin
    clk = 0;
    start = 0;
    rnd_type = 12;
    S = {
        64'h1111111111111111,
        64'h2222222222222222,
        64'h3333333333333333,
        64'h4444444444444444,
        64'h5555555555555555
    };
    #20;
    start = 1;
    #10;
    start = 0;
    wait(finish);
    #10;
    $display("\n===========================================");
    $display("Permutation Finished");
    $display("Final State = %h", S_out);
    $display("===========================================\n");
    #20;
    $finish;
end
always @(posedge clk) begin
    $display("----------------------------------------");
    $display("Time    = %0t", $time);
    $display("Start   = %b", start);
    $display("Round   = %0d", DUT.rnd_no);
    $display("Type    = %0d", DUT.type);
    $display("Finish  = %b", finish);
    $display("x4 = %h", DUT.x4_t);
    $display("x3 = %h", DUT.x3_t);
    $display("x2 = %h", DUT.x2_t);
    $display("x1 = %h", DUT.x1_t);
    $display("x0 = %h", DUT.x0_t);
    $display("RC Out = %h", DUT.a1);
    $display("SBOX:");
    $display("b4 = %h", DUT.b4);
    $display("b3 = %h", DUT.b3);
    $display("b2 = %h", DUT.b2);
    $display("b1 = %h", DUT.b1);
    $display("b0 = %h", DUT.b0);
    $display("Linear:");
    $display("x4 = %h", DUT.x4);
    $display("x3 = %h", DUT.x3);
    $display("x2 = %h", DUT.x2);
    $display("x1 = %h", DUT.x1);
    $display("x0 = %h", DUT.x0);
end
endmodule