`timescale 1ns / 1ps

module Final_layer(
    input [319:0] state,
    input clk,
    input rst,
    input [127:0] key,
    input start,
    output [127:0] Tag,
    output Done
    );

    localparam IDLE=0;
    localparam key_xor=1;
    localparam perm=2;
    localparam perm_done=3;
    localparam tag_gen=4;
    localparam finished=5;

    localparam[3:0] RND_TYPE=4'd12;

    reg [2:0] phase;
    reg [319:0] s;
    reg [127:0] tag;
    reg done;
    reg perm_start;

    wire finish_perm;
    wire perm_busy;
    wire [319:0] inter_s;


    always@(posedge clk) begin

        if(rst) begin
            phase<=IDLE;
            s<=0;
            tag<=0;
            done<=0;
            perm_start<=0;
        end

        else begin

            done<=0;

            case(phase)

                IDLE: begin
                    if(start) begin
                        s<=state;
                        phase<=key_xor;
                    end
                end


                key_xor: begin
                    s<=state^{128'b0,key,64'b0};
                    phase<=perm;
                end


                perm: begin
                    perm_start<=1;
                    phase<=perm_done;
                end


                perm_done: begin
                    perm_start<=0;

                    if(finish_perm) begin
                        s<=inter_s;
                        phase<=tag_gen;
                    end
                end


                tag_gen: begin
                    tag<=s[319:192]^key;
                    phase<=finished;
                end


                finished: begin
                    done<=1;
                    phase<=IDLE;
                end


                default: begin
                    phase<=IDLE;
                end

            endcase
        end
    end


    assign Tag=tag;
    assign Done=done;


    Perm P(
        .clk(clk),
        .rst(rst),
        .S(s),
        .start(perm_start),
        .rnd_type(RND_TYPE),
        .finish(finish_perm),
        .busy(perm_busy),
        .S_out(inter_s)
        );

endmodule