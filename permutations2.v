`timescale 1ns / 1ps

module permutation2(
    input clk,
    input reset,
    input permutation_start,
    input [319:0] S,
    input [3:0] rnd,
    output reg permutation_ready,
    output reg [319:0] S_new
  
   
);

    reg [63:0] const [0:15];

    initial begin
        const[0]  = 64'h000000000000003c;
        const[1]  = 64'h000000000000002d;
        const[2]  = 64'h000000000000001e;
        const[3]  = 64'h000000000000000f;
        const[4]  = 64'h00000000000000f0;
        const[5]  = 64'h00000000000000e1;
        const[6]  = 64'h00000000000000d2;
        const[7]  = 64'h00000000000000c3;
        const[8]  = 64'h00000000000000b4;
        const[9]  = 64'h00000000000000a5;
        const[10] = 64'h0000000000000096;
        const[11] = 64'h0000000000000087;
        const[12] = 64'h0000000000000078;
        const[13] = 64'h0000000000000069;
        const[14] = 64'h000000000000005a;
        const[15] = 64'h000000000000004b;
    end

    // Internal state registers
    reg [63:0] S0, S1, S2, S3, S4;
    reg processing, constantadd, sbox_phase;
    reg [5:0] bit_index;
    reg [4:0] sbox_in, sbox_out;
    reg [3:0] state, next_state; // FSM state
    reg [3:0] round_index ;

    // Define states (simple numbers for the states)
    localparam IDLE = 4'b0000,
               INIT = 4'b0001,
               CONSTANT_ADD = 4'b0010,
               SBOX = 4'b0011,
               DIFFUSION = 4'b0100,
               DONE = 4'b0101;

    // S-box function
    function [4:0] sbox;
        input [4:0] in;
        begin
            case (in)
                5'h00: sbox = 5'h04;
                5'h01: sbox = 5'h0b;
                5'h02: sbox = 5'h1f;
                5'h03: sbox = 5'h14;
                5'h04: sbox = 5'h1a;
                5'h05: sbox = 5'h15;
                5'h06: sbox = 5'h09;
                5'h07: sbox = 5'h02;
                5'h08: sbox = 5'h1b;
                5'h09: sbox = 5'h05;
                5'h0A: sbox = 5'h08;
                5'h0B: sbox = 5'h12;
                5'h0C: sbox = 5'h1d;
                5'h0D: sbox = 5'h03;
                5'h0E: sbox = 5'h06;
                5'h0F: sbox = 5'h1c;
                default: sbox = 5'h00;
            endcase
        end
    endfunction

    // FSM Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            S0 <= 0; S1 <= 0; S2 <= 0; S3 <= 0; S4 <= 0;
            round_index <= 0;
            processing <= 0;
            sbox_phase <= 0;
            bit_index <= 0;
            permutation_ready <= 0;
            S_new <= 0;
            state <= IDLE;
        end else begin
            state <= next_state;  // Update the current state
        end
    end

    // FSM next state logic
    always @(*) begin
        case (state)
            IDLE: next_state = (permutation_start) ? INIT : IDLE;
            INIT: next_state = CONSTANT_ADD;
            CONSTANT_ADD: next_state =(!constantadd)? SBOX : CONSTANT_ADD ;
            SBOX: next_state = (bit_index == 63) ? DIFFUSION : SBOX;
            DIFFUSION: next_state = (round_index == rnd - 1) ? DONE : CONSTANT_ADD;
            DONE: next_state = (permutation_start)? DONE: IDLE ;
            default: next_state = IDLE;
        endcase
    end

    // Main FSM actions based on the current state
    always @(posedge clk) begin
        case (state)
            IDLE: begin
                S_new <= 0;
            end
            INIT: begin
                S0 <= S[319:256];
                S1 <= S[255:192];
                S2 <= S[191:128];
                S3 <= S[127:64];
                S4 <= S[63:0];
                round_index <= 0 ;
                constantadd <= 1;
                processing <= 1;
                bit_index <= 0;
            end
            CONSTANT_ADD: begin
                if (constantadd) begin
                    S0 <= S0 ^ const[16 - rnd + round_index];
                    S1 <= S1 ^ const[16 - rnd + round_index];
                    S2 <= S2 ^ const[16 - rnd + round_index];
                    S3 <= S3 ^ const[16 - rnd + round_index];
                    S4 <= S4 ^ const[16 - rnd + round_index];
                    constantadd <= 0;
                    sbox_phase <= 1 ;
                end
            end
            SBOX: begin
            if(sbox_phase) begin 
                sbox_in = {S0[bit_index], S1[bit_index], S2[bit_index], S3[bit_index], S4[bit_index]};
                sbox_out = sbox(sbox_in);
                S0[bit_index] <= sbox_out[4];
                S1[bit_index] <= sbox_out[3];
                S2[bit_index] <= sbox_out[2];
                S3[bit_index] <= sbox_out[1];
                S4[bit_index] <= sbox_out[0];
                 if (bit_index == 63) begin
                    sbox_phase <= 0;
                end else begin
                    bit_index <= bit_index + 1;
                end
                end 
               
            end
            DIFFUSION: begin
            
                S0 <= S0 ^ {S0[18:0], S0[63:19]} ^ {S0[27:0], S0[63:28]};
                S1 <= S1 ^ {S1[60:0], S1[63:61]} ^ {S1[38:0], S1[63:39]};
                S2 <= S2 ^ {S2[0], S2[63:1]} ^ {S2[5:0], S2[63:6]};
                S3 <= S3 ^ {S3[9:0], S3[63:10]} ^ {S3[16:0], S3[63:17]};
                S4 <= S4 ^ {S4[6:0], S4[63:7]} ^ {S4[40:0], S4[63:41]};
                
                round_index <= round_index + 1;
            end
            DONE: begin
                processing <= 0;
                permutation_ready <= 1;
                S_new <= {S0, S1, S2, S3, S4};
            end
            default: begin
                state <= IDLE;
            end
        endcase
    end

endmodule
