`timescale 1ns / 1ps
module initialization(
    input [127:0]key,
    input [127:0]nonce,
    input clk,
    input start,
    output finish,
    output [319:0] state
 );
   reg [319:0]S;
   reg [2:0]layer;
   reg perm_start;
   reg perm_done;
   parameter [63:0] IV= 64'h00001000808c0001;
   parameter [3:0] rnd= 4'd12;
   parameter Idle=2'd0;
   parameter Permu=2'd1;
   parameter key_xor =2'd2;
   parameter done =2'd3;
              
   always@(posedge clk)begin
   if(start) begin
   layer<= Idle;
   perm_done<=0;
   end
   else begin
   case(layer)
       Idle: begin
       S<={IV,key,nonce};
       perm_start <=1'b1;
       layer<=Permu;
       end
       Permu: begin
       Perm_start<=0;
       if(perm_done)begin
       layer<=key_xor;
       end
       end
       
       
       
   
  
     
   
   
   
   
endmodule
