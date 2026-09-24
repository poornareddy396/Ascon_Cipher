`timescale 1ns / 1ps

module PT_CT(
    input clk,
    input rst,
    input [1023:0] text,
    input [10:0] text_length,
    input [1:0] mode,
    input [319:0] state,
    input start,
    output [1023:0] out_text,
    output reg [319:0] S,
    output reg finish
    );

    localparam IDLE=3'b000;
    localparam PROCESS=3'b001;
    localparam STATE_UPDATE=3'b010;
    localparam PERM=3'b011;
    localparam FINAL=3'b100;
    localparam DONE=3'b101;

    localparam[3:0] RND_TYPE=4'd8;

    reg [2:0] phase;
    reg [319:0] inter_s;
    reg [3:0] block_counter;
    reg perm_start;
    reg [127:0] final_block;
    reg [1023:0] ct_pt;

    wire [319:0] perm_state;
    wire finish_perm;
    wire perm_busy;
    wire [3:0] full_blocks;
    wire [6:0] rem;

    integer i;

    assign full_blocks=text_length/128;
    assign rem=text_length%128;
    assign out_text=ct_pt;

    always@(posedge clk)begin
        if(rst)begin
            phase<=IDLE;
            inter_s<=0;
            block_counter<=0;
            perm_start<=0;
            final_block<=0;
            ct_pt<=0;
            S<=0;
            finish<=0;
        end
        else begin
            finish<=0;

            if(start&&phase==IDLE)begin
                phase<=PROCESS;
                ct_pt<=0;
                inter_s<=state;
                block_counter<=0;
                perm_start<=0;
                final_block<=make_final_block(text,text_length);
            end
            else begin
                case(phase)

                    PROCESS:begin
                        if(block_counter<full_blocks)begin
                            if(mode==1)begin
                                inter_s[127:0]<=inter_s[127:0]^text[block_counter*128+:128];
                                ct_pt[block_counter*128+:128]<=inter_s[127:0]^text[block_counter*128+:128];
                            end
                            else if(mode==2)begin
                                ct_pt[block_counter*128+:128]<=inter_s[127:0]^text[block_counter*128+:128];
                                inter_s[127:0]<=text[block_counter*128+:128];
                            end

                            block_counter<=block_counter+1;
                            phase<=STATE_UPDATE;
                        end
                        else begin
                            phase<=FINAL;
                        end
                    end

                    STATE_UPDATE:begin
                        perm_start<=1;
                        phase<=PERM;
                    end

                    PERM:begin
                        perm_start<=0;

                        if(finish_perm)begin
                            inter_s<=perm_state;
                            phase<=PROCESS;
                        end
                    end

                    FINAL:begin
                        if(mode==1)begin
                            inter_s[127:0]<=inter_s[127:0]^final_block;

                            for(i=0;i<128;i=i+1)begin
                                if(i<rem)
                                    ct_pt[full_blocks*128+i]<=inter_s[i]^final_block[i];
                            end
                        end

                        else if(mode==2)begin
                            for(i=0;i<128;i=i+1)begin
                                if(i<rem)
                                    ct_pt[full_blocks*128+i]<=inter_s[i]^text[full_blocks*128+i];
                            end

                            for(i=0;i<128;i=i+1)begin
                                if(i<rem)
                                    inter_s[i]<=text[full_blocks*128+i];
                                else if(i==rem)
                                    inter_s[i]<=inter_s[i]^1'b1;
                            end
                        end

                        phase<=DONE;
                    end

                    DONE:begin
                        S<=inter_s;
                        finish<=1;
                        phase<=IDLE;
                    end

                    IDLE:begin
                        phase<=IDLE;
                    end

                    default:begin
                        phase<=IDLE;
                    end

                endcase
            end
        end
    end

    Perm P(
        .clk(clk),
        .rst(rst),
        .S(inter_s),
        .start(perm_start),
        .rnd_type(RND_TYPE),
        .finish(finish_perm),
        .busy(perm_busy),
        .S_out(perm_state)
    );

    function [127:0] make_final_block;
        input [1023:0] text;
        input [10:0] text_length;
        integer i;
        integer rem_length;
        integer base;

        begin
            make_final_block=128'b0;
            rem_length=text_length%128;
            base=(text_length/128)*128;

            for(i=0;i<128;i=i+1)begin
                if(i<rem_length)
                    make_final_block[i]=text[base+i];
            end

            make_final_block[rem_length]=1'b1;
        end
    endfunction

endmodule