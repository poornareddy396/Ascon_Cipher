`timescale 1ns / 1ps

module PT_CT_TB;

    reg clk;
    reg rst;
    reg start;

    reg [1023:0] text;
    reg [10:0] text_length;

    reg [1:0] mode;

    reg [319:0] state;

    wire [1023:0] out_text;
    wire [319:0] S;
    wire finish;


    PT_CT DUT(
        .clk(clk),
        .rst(rst),
        .text(text),
        .text_length(text_length),
        .mode(mode),
        .state(state),
        .start(start),
        .out_text(out_text),
        .S(S),
        .finish(finish)
    );


    always #5 clk=~clk;


    initial begin

        clk=0;
        rst=1;
        start=0;

        // AD output state
        state=320'he9326a98b359039f9fe5b906711e3f7918b113f2c01f9afa4ac3cee0a4de7d5ad0d223f7dfb63539;

        // Plaintext
        text=1024'b0;
        text[127:0]=128'h112233445566778899aabbccddeeff00;

        text_length=11'd128;

        // 01 = Encryption
        mode=2'b01;


        $display("==========================================");
        $display("          PT/CT ENCRYPTION TEST");
        $display("==========================================");

        #20;

        rst=0;

        $display("Input State = %h",state);
        $display("Plaintext   = %h",text[127:0]);
        $display("Text Length = %0d",text_length);
        $display("Mode        = %b",mode);

        start=1;

        #10;

        start=0;

        wait(finish);

        #1;

        $display("");
        $display("Encryption Finished");
        $display("Ciphertext  = %h",out_text[127:0]);
        $display("Output State = %h",S);

        $display("==========================================");

        #20;

        $finish;

    end

endmodule