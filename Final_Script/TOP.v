`timescale 1ns / 1ps

module TOP(
    input clk,
    input rst,
    input start,

    input [127:0] key,
    input [127:0] nonce,

    input [1023:0] ad,
    input [10:0] ad_length,

    input [1023:0] text,
    input [10:0] text_length,

    input [1:0] mode,

    output [1023:0] out_text,
    output [127:0] Tag,
    output reg Done
    );

    localparam IDLE=3'b000;
    localparam INIT=3'b001;
    localparam AD=3'b010;
    localparam PTCT=3'b011;
    localparam FINAL=3'b100;

    reg [2:0] phase;

    reg init_start;
    reg ad_start;
    reg ptct_start;
    reg final_start;

    wire init_finish;
    wire ad_finish;
    wire ptct_finish;
    wire final_done;

    wire [319:0] init_state;
    wire [319:0] ad_state;
    wire [319:0] ptct_state;

    always@(posedge clk)begin
        if(rst)begin
            phase<=IDLE;
            init_start<=0;
            ad_start<=0;
            ptct_start<=0;
            final_start<=0;
            Done<=0;
        end
        else begin
            Done<=0;

            init_start<=0;
            ad_start<=0;
            ptct_start<=0;
            final_start<=0;

            case(phase)

                IDLE:begin
                    if(start)begin
                        init_start<=1;
                        phase<=INIT;
                    end
                end

                INIT:begin
                    if(init_finish)begin
                        ad_start<=1;
                        phase<=AD;
                    end
                end

                AD:begin
                    if(ad_finish)begin
                        ptct_start<=1;
                        phase<=PTCT;
                    end
                end

                PTCT:begin
                    if(ptct_finish)begin
                        final_start<=1;
                        phase<=FINAL;
                    end
                end

                FINAL:begin
                    if(final_done)begin
                        Done<=1;
                        phase<=IDLE;
                    end
                end

                default:begin
                    phase<=IDLE;
                end

            endcase
        end
    end


    initialization INIT_LAYER(
        .key(key),
        .nonce(nonce),
        .clk(clk),
        .rst(rst),
        .start(init_start),
        .finish(init_finish),
        .state(init_state)
    );


    AD_Processing AD_LAYER(
        .clk(clk),
        .rst(rst),
        .S(init_state),
        .ad(ad),
        .start(ad_start),
        .ad_length(ad_length),
        .State(ad_state),
        .finish(ad_finish)
    );


    PT_CT PTCT_LAYER(
        .clk(clk),
        .rst(rst),
        .text(text),
        .text_length(text_length),
        .mode(mode),
        .state(ad_state),
        .start(ptct_start),
        .out_text(out_text),
        .S(ptct_state),
        .finish(ptct_finish)
    );


    Final_layer FINAL_LAYER(
        .state(ptct_state),
        .clk(clk),
        .rst(rst),
        .key(key),
        .start(final_start),
        .Tag(Tag),
        .Done(final_done)
    );

endmodule