`timescale 1ns / 1ps

module initialization(
    input [127:0]key,
    input [127:0]nonce,
    input clk,
    input rst,
    input start,
    output reg finish,
    output reg [319:0] state
    );

    reg [319:0]S;
    wire [319:0]perm_out;
    reg [1:0]layer;
    reg perm_start;
    wire perm_done;
    wire perm_busy;

    localparam [63:0] IV=64'h00001000808c0001;
    localparam [3:0] rnd=4'd12;

    localparam Idle=2'd0;
    localparam Permu=2'd1;
    localparam key_xor=2'd2;
    localparam done=2'd3;

    always@(posedge clk)begin
        if(rst)begin
            layer<=Idle;
            perm_start<=0;
            finish<=0;
            state<=0;
            S<=0;
        end
        else begin

            case(layer)

                Idle:begin
                    finish<=0;
                    if(start)begin
                        S<={IV,key,nonce};
                        perm_start<=1;
                        layer<=Permu;
                    end
                end

                Permu:begin
                    perm_start<=0;
                    if(perm_done)begin
                        S<=perm_out;
                        layer<=key_xor;
                    end
                end

                key_xor:begin
                    S<=S^{192'b0,key};
                    layer<=done;
                end

                done:begin
                    state<=S;
                    finish<=1;
                    layer<=Idle;
                end

            endcase
        end
    end

    Perm P(
        .clk(clk),
        .rst(rst),
        .S(S),
        .start(perm_start),
        .rnd_type(rnd),
        .finish(perm_done),
        .busy(perm_busy),
        .S_out(perm_out)
    );

endmodule
