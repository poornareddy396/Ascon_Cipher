`timescale 1ns / 1ps

module INITIALIZATION_TB;

    reg [127:0] key;
    reg [127:0] nonce;
    reg clk;
    reg rst;
    reg start;

    wire finish;
    wire [319:0] state;


    initialization DUT(
        .key(key),
        .nonce(nonce),
        .clk(clk),
        .rst(rst),
        .start(start),
        .finish(finish),
        .state(state)
    );


    always #5 clk=~clk;


    initial begin

        clk=0;
        rst=1;
        start=0;

        key=128'h000102030405060708090a0b0c0d0e0f;
        nonce=128'h000102030405060708090a0b0c0d0e0f;


        $display("==========================================");
        $display("        INITIALIZATION TEST");
        $display("==========================================");

        #20;

        rst=0;

        $display("Key   = %h",key);
        $display("Nonce = %h",nonce);


        start=1;

        #10;

        start=0;


        wait(finish);

        #1;

        $display("");
        $display("Initialization Finished");
        $display("Output State = %h",state);

        $display("==========================================");


        #20;

        $finish;

    end

endmodule