module RND_Const(
    input  [63:0] x2_in,
    input  [3:0]  rnd,
    input [3:0] rnds,
    output [63:0] x2_out
);
reg [63:0] out_buf;
reg [7:0] rc;
assign x2_out = out_buf;
always @(*) begin
    if(rnds==6) begin
        rc = 8'h96 - rnd*8'h0F;
        end
    else if(rnds==8) begin
        rc = 8'hB4 - rnd*8'h0F;
        end
    else if(rnds==12) begin
        rc = 8'hF0 - rnd*8'h0F;
        end
        else begin
        rc = 8'h00;
        end
       
    out_buf = x2_in ^ {56'd0, rc};

end
endmodule