`timescale 1ns / 1ps

module AD_Processing(
    input clk,
    input rst,
    input [319:0] S,
    input [1023:0] ad,
    input start,
    input [10:0] ad_length,
    output reg [319:0] State,
    output reg finish
    );

    localparam ad_layer=1;
    localparam perm=2;
    localparam const=3;
    localparam out=4;
    localparam idle=5;
    localparam wait_done=6;

    localparam [3:0] rnd_type=4'd8;

    reg [2:0] phase;
    reg start_perm;
    reg [3:0] block_counter;
    reg [127:0] last_block;
    reg [319:0] inter_s;

    wire [3:0] blocks;
    wire [319:0] s;
    wire finish_perm;
    wire perm_busy;

    assign blocks=(ad_length+127)/128;

    always@(posedge clk)begin
        if(rst)begin
            phase<=idle;
            finish<=0;
            block_counter<=0;
            inter_s<=0;
            State<=0;
            start_perm<=0;
            last_block<=0;
        end
        else begin
            finish<=0;

            if(start&&phase==idle)begin
                inter_s<=S;
                block_counter<=0;
                start_perm<=0;

                if(ad_length==0)begin
                    last_block<=0;
                    phase<=const;
                end
                else begin
                    last_block<=make_last_block(ad,ad_length,blocks);
                    phase<=ad_layer;
                end
            end
            else begin
                case(phase)

                    ad_layer:begin
                        if(block_counter==blocks-1)begin
                            inter_s[127:0]<=inter_s[127:0]^last_block;
                            phase<=idle;
                        end
                        else begin
                            inter_s[127:0]<=inter_s[127:0]^ad[block_counter*128+:128];
                            block_counter<=block_counter+1;
                            phase<=idle;
                        end
                    end

                    idle:begin
                        start_perm<=1;
                        phase<=perm;
                    end

                    perm:begin
                        start_perm<=0;

                        if(finish_perm)begin
                            inter_s<=s;

                            if(block_counter==blocks-1)
                                phase<=const;
                            else begin
                                block_counter<=block_counter+1;
                                phase<=ad_layer;
                            end
                        end
                    end

                    const:begin
                        inter_s<=inter_s^{319'b0,1'b1};
                        phase<=out;
                    end

                    out:begin
                        State<=inter_s;
                        finish<=1;
                        phase<=wait_done;
                    end

                    wait_done:begin
                        phase<=wait_done;
                        finish<=1;
                    end

                endcase
            end
        end
    end

    function [127:0] make_last_block;
        input [1023:0] ad;
        input [10:0] ad_length;
        input [3:0] blocks;
        integer rem;
        integer i;

        begin
            make_last_block=128'b0;
            rem=ad_length-(blocks-1)*128;

            if(rem==128)
                make_last_block=ad[(blocks-1)*128+:128];
            else begin
                for(i=0;i<128;i=i+1)
                    if(i<rem)
                        make_last_block[i]=ad[(blocks-1)*128+i];

                make_last_block[rem]=1'b1;
            end
        end
    endfunction

    Perm P(
        .clk(clk),
        .rst(rst),
        .S(inter_s),
        .start(start_perm),
        .rnd_type(rnd_type),
        .finish(finish_perm),
        .busy(perm_busy),
        .S_out(s)
    );

endmodule