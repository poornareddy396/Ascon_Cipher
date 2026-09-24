`timescale 1ns / 1ps

module TOP_TB;

reg clk;
reg rst;
reg start;

reg [127:0] key;
reg [127:0] nonce;

reg [1023:0] ad;
reg [10:0] ad_length;

reg [1023:0] text;
reg [10:0] text_length;

reg [1:0] mode;

wire [1023:0] out_text;
wire [127:0] Tag;
wire Done;

reg [127:0] plaintext_original;
reg [127:0] ciphertext_enc;
reg [127:0] tag_enc;
reg [127:0] plaintext_dec;
reg [127:0] tag_dec;

TOP DUT(
    .clk(clk),
    .rst(rst),
    .start(start),
    .key(key),
    .nonce(nonce),
    .ad(ad),
    .ad_length(ad_length),
    .text(text),
    .text_length(text_length),
    .mode(mode),
    .out_text(out_text),
    .Tag(Tag),
    .Done(Done)
);

always #5 clk=~clk;

initial begin

    clk=0;
    rst=1;
    start=0;

    key=128'h000102030405060708090a0b0c0d0e0f;
    nonce=128'h000102030405060708090a0b0c0d0e0f;

    ad=1024'b0;
    ad_length=128;

    text=1024'b0;
    text_length=128;

    mode=2'b01;

    plaintext_original=128'h112233445566778899aabbccddeeff00;

    #20;
    rst=0;

    //========================================
    // ENCRYPTION
    //========================================

    ad=1024'b0;
    ad[127:0]=128'h000102030405060708090a0b0c0d0e0f;

    ad_length=128;

    text=1024'b0;
    text[127:0]=plaintext_original;

    text_length=128;

    mode=2'b01;

    #10;
    start=1;

    #10;
    start=0;

    wait(Done==1);

    #10;

    ciphertext_enc=out_text[127:0];
    tag_enc=Tag;

    $display("");
    $display("========================================");
    $display("          ENCRYPTION RESULT");
    $display("========================================");

    $display("Key        = %h",key);
    $display("Nonce      = %h",nonce);
    $display("AD         = %h",ad[127:0]);
    $display("Plaintext  = %h",plaintext_original);
    $display("Ciphertext = %h",ciphertext_enc);
    $display("Tag_enc    = %h",tag_enc);
    $display("Done_enc   = %b",Done);

    $display("========================================");


    //========================================
    // RESET BEFORE DECRYPTION
    //========================================

    #20;

    rst=1;

    #10;

    rst=0;


    //========================================
    // DECRYPTION
    //========================================

    text=1024'b0;
    text[127:0]=ciphertext_enc;

    text_length=128;

    mode=2'b10;

    #10;
    start=1;

    #10;
    start=0;

    wait(Done==1);

    #10;

    plaintext_dec=out_text[127:0];
    tag_dec=Tag;

    $display("");
    $display("========================================");
    $display("          DECRYPTION RESULT");
    $display("========================================");

    $display("Key          = %h",key);
    $display("Nonce        = %h",nonce);
    $display("AD           = %h",ad[127:0]);
    $display("Ciphertext   = %h",ciphertext_enc);
    $display("Plaintext_dec= %h",plaintext_dec);
    $display("Tag_dec      = %h",tag_dec);
    $display("Done_dec     = %b",Done);

    $display("========================================");


    //========================================
    // VERIFICATION
    //========================================

    $display("");
    $display("========================================");
    $display("          VERIFICATION");
    $display("========================================");

    if(ciphertext_enc==128'hb4606c5bd9d564008db24363aff45731)
        $display("PASS: Encryption ciphertext");
    else
        $display("FAIL: Encryption ciphertext");

    if(plaintext_dec==plaintext_original)
        $display("PASS: Decrypted plaintext");
    else
        $display("FAIL: Decrypted plaintext");

    if(tag_enc==tag_dec)
        $display("PASS: Tag ENC == Tag DEC");
    else
        $display("FAIL: Tag ENC != Tag DEC");

    if(Done==1)
        $display("PASS: Done signal");
    else
        $display("FAIL: Done signal");

    if((ciphertext_enc==128'hb4606c5bd9d564008db24363aff45731) &&
       (plaintext_dec==plaintext_original) &&
       (tag_enc==tag_dec) &&
       (Done==1)) begin
        $display("");
        $display("========================================");
        $display("          ASCON TEST PASSED");
        $display("========================================");
    end
    else begin
        $display("");
        $display("========================================");
        $display("          ASCON TEST FAILED");
        $display("========================================");
    end

    #20;
    $finish;

end

endmodule