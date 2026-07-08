`timescale 1ns / 1ps
module initialization(
    input [127:0]key,
    input [127:0]nonce,
    input clk,
    input start,
    output reg finish,
    output reg [319:0] state
 );
   reg [319:0]S;
   wire[319:0] perm_out;
   reg [2:0]layer;
   reg perm_start;
   wire perm_done;
   reg rst;
   localparam [63:0] IV= 64'h00001000808c0001;
   localparam [3:0] rnd= 4'd12;
   localparam Idle=2'd0;
   localparam Permu=2'd1;
   localparam key_xor =2'd2;
   localparam done =2'd3;
              
   always@(posedge clk)begin
   if(rst) begin
   layer<= Idle;
   perm_start<=0;
   rst<=0;
   end
   else begin
   case(layer)
       Idle: begin
       if(start) begin
       finish<=0;
       S<={IV,key,nonce};
       perm_start <=1'b1;
       layer<=Permu;
       end
       end
       Permu: begin
       perm_start<=0;
       if(perm_done)begin
       layer<=key_xor;
       S<=perm_out;
       end
       end
       key_xor:begin
       S<=S^{192'b0,key};
       layer<=done;
       end
       done: begin
       state<=S;
       finish<=1;
       rst<=1;
       end
       endcase
       end
       end
       
       Perm P(.clk(clk),.S(S),.start(perm_start),.rnd_type(rnd),.finish(perm_done),.S_out(perm_out));
       
   
endmodule
