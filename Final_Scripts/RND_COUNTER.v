`timescale 1ns / 1ps
module RND_COUNTER(
   input clk,
   input rst,
   input rnd_done,
   output reg finish,
   output reg [3:0] rnd_no
 );
   parameter rnd=8;
   reg [3:0]ct;
   always@(posedge clk)
   begin 
   if (rst)
   ct<=0;
   else begin 
   if(rnd_done&&(ct<rnd))
   ct<=ct+1;
   end
   if(ct==(rnd-1)) begin
   finish<=1'b1;
   rnd_no<= 1;
   end
   else begin
   finish<=1'b0;
   rnd_no<=ct;
   end
   end
   
   endmodule
