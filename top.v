module top(
    input wire clk, rst,
    input wire [63:0] IV,
    input wire [127:0] key,
    input wire [127:0] nonce,
    input wire [255:0] associated_data,
    input wire [255:0] plain_text,
    input encryption_start,
    
    output wire [319:0] S,           // CHANGED from reg to wire
    output wire [255:0] cipher_text,  // CHANGED from reg to wire
    output wire [127:0] tag           // CHANGED from reg to wire
);

wire permutation_ready;
wire encryption_ready;
wire permutation_start;

EncryptionController e(
    .clk(clk),
    .rst(rst),
    .IV(IV),
    .key(key),
    .nonce(nonce),
    .associated_data(associated_data),
    .plain_text(plain_text),
    .encryption_start(encryption_start),
    .S(S),
    .cipher_text(cipher_text),
    .tag(tag),
    .permutation_ready(permutation_ready),
    .encryption_ready(encryption_ready),
    .permutation_start(permutation_start)
);

endmodule
