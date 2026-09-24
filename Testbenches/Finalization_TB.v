`timescale 1ns / 1ps

module FINAL_LAYER_TB;

    reg [319:0] state;
    reg clk;
    reg rst;
    reg [127:0] key;
    reg start;

    wire [127:0] Tag;
    wire Done;


    Final_layer DUT(
        .state(state),
        .clk(clk),
        .rst(rst),
        .key(key),
        .start(start),
        .Tag(Tag),
        .Done(Done)
    );


    always #5 clk=~clk;


    initial begin

        clk=0;
        rst=1;
        start=0;

        state=320'hc3ec7ecbadd9c7989773a53c85f77c71b481f98ecc5bbcd72c4bf3a7baa0b56b0d181c379f9c2a5a;

        key=128'h000102030405060708090a0b0c0d0e0f;


        $display("==========================================");
        $display("            FINAL LAYER TEST");
        $display("==========================================");

        #20;

        rst=0;

        $display("Input State = %h",state);
        $display("Key         = %h",key);


        start=1;

        #10;

        start=0;


        wait(Done);

        #1;

        $display("");
        $display("Final Layer Finished");
        $display("Tag = %h",Tag);

        $display("==========================================");

        #20;

        $finish;

    end

endmodule