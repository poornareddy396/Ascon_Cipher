`timescale 1ns / 1ps
module Perm(
    input clk,
    input [319:0] S,
    input start,
    input [3:0]rnd_type,
    output reg finish,
    output reg [319:0] S_out
    );
    wire [63:0] x0,x1,x2,x3,x4;
    reg [63:0] x0_t,x1_t,x2_t,x3_t,x4_t;
    reg [3:0] type,rnd_no;
    always@(posedge clk)begin
    if(start==1)begin
    {x4_t,x3_t,x2_t,x1_t,x0_t}<=S;
    type<=rnd_type;
    rnd_no<=0;
    finish<=0;
    end
    else if(start!=1 && rnd_no<type) begin
    x0_t <= x0;
    x1_t <= x1;
    x2_t <= x2;
    x3_t <= x3;
    x4_t <= x4;
    rnd_no<=rnd_no+1;
    end
    if(rnd_no==type)begin
    finish<=1;
    S_out<={x4,x3,x2,x1,x0};
    end
    end
    
    wire [63:0]a1;
    RND_Const  L1(.rnds(type),.x2_in(x2_t),.rnd(rnd_no),.x2_out(a1));
    wire [63:0] b0,b1,b2,b3,b4;
    sbox L2(.x0(x0_t),.x1(x1_t),.x2(a1),.x3(x3_t),.x4(x4_t),
            .sl0(b0),.sl1(b1),.sl2(b2),.sl3(b3),.sl4(b4));
    linear_sub L3(.x0(b0),.x1(b1),.x2(b2),.x3(b3),.x4(b4),
            .o0(x0),.o1(x1),.o2(x2),.o3(x3),.o4(x4));
                 
 endmodule           
            
    
    
    
    
    
    
    
    

