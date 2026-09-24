`timescale 1ns / 1ps

module PERM_TB;

    reg clk;
    reg rst;
    reg start;

    reg [319:0] S;
    reg [3:0] rnd_type;

    wire finish;
    wire busy;
    wire [319:0] S_out;


    Perm DUT(
        .clk(clk),
        .rst(rst),
        .S(S),
        .start(start),
        .rnd_type(rnd_type),
        .finish(finish),
        .busy(busy),
        .S_out(S_out)
    );


    always #5 clk=~clk;


    initial begin

        clk=0;
        rst=1;
        start=0;

        S=0;
        rnd_type=4'd12;

        $display("==========================================");
        $display("              PERM TEST");
        $display("==========================================");

        #20;

        rst=0;

        S=320'h00001000808c0001000102030405060708090a0b0c0d0e0f000102030405060708090a0b0c0d0e0f;

        $display("Input State = %h",S);
        $display("Round Type  = %d",rnd_type);

        start=1;

        #10;

        start=0;

        wait(finish);

        #1;

        $display("");
        $display("Permutation Finished");
        $display("Output State = %h",S_out);

        $display("==========================================");

        #20;

        $finish;

    end

endmodule