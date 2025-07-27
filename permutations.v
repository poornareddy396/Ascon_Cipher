

`timescale 100ps/1ps


module permutation(
    input clk,
    input reset,
    input permutation_start,
    input [319:0] S,
    input [3:0] rnd,
    output reg permutation_ready,
    output reg [319:0] S_new
    
    
);
     reg [3:0] round_index;
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

    // Internal state
//    reg [63:0] S0, S1, S2, S3, S4;
    reg [63:0] S0, S1, S2, S3, S4;

 
    reg processing,constantadd;
    reg sbox_phase;  // Indicates whether we're in the S-box phase
    reg [5:0] bit_index;  // 0 to 63, tracks the current bit

    reg [4:0] sbox_in;
    reg [4:0] sbox_out;

    integer j;

    // S-box function (combinational)
    function [4:0] sbox;
        input [4:0] in;
        begin
            case (in)
                5'h00: sbox = 5'h04;  5'h01: sbox = 5'h0b;
                5'h02: sbox = 5'h1f;  5'h03: sbox = 5'h14;
                5'h04: sbox = 5'h1a;  5'h05: sbox = 5'h15;
                5'h06: sbox = 5'h09;  5'h07: sbox = 5'h02;
                5'h08: sbox = 5'h1b;  5'h09: sbox = 5'h05;
                5'h0A: sbox = 5'h08;  5'h0B: sbox = 5'h12;
                5'h0C: sbox = 5'h1d;  5'h0D: sbox = 5'h03;
                5'h0E: sbox = 5'h06;  5'h0F: sbox = 5'h1c;
                5'h10: sbox = 5'h1e;  5'h11: sbox = 5'h13;
                5'h12: sbox = 5'h07;  5'h13: sbox = 5'h0e;
                5'h14: sbox = 5'h00;  5'h15: sbox = 5'h0d;
                5'h16: sbox = 5'h11;  5'h17: sbox = 5'h18;
                5'h18: sbox = 5'h10;  5'h19: sbox = 5'h0c;
                5'h1A: sbox = 5'h01;  5'h1B: sbox = 5'h19;
                5'h1C: sbox = 5'h16;  5'h1D: sbox = 5'h0a;
                5'h1E: sbox = 5'h0f;  5'h1F: sbox = 5'h17;
                default: sbox = 5'h00;
            endcase
        end
    endfunction

    // Main FSM + logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all states
            S0 <= 0; S1 <= 0; S2 <= 0; S3 <= 0; S4 <= 0;
            round_index <= 0;
            processing <= 0;
            sbox_phase <= 0;
            bit_index <= 0;
            permutation_ready <= 0;
            S_new <= 0;
        end else begin
            if (permutation_start && !processing && !permutation_ready) begin
                // Start new permutation
                S0 <= S[319:256];
                S1 <= S[255:192];
                S2 <= S[191:128];
                S3 <= S[127:64];
                S4 <= S[63:0];
                round_index <= 0;
                constantadd<=1;
                processing <= 1;
              
                bit_index <= 0;   // Reset bit index
                permutation_ready <= 0;
            end else if (processing) begin
   
            if (constantadd) begin 
//                S0 <= S0 ^ const[16 - rnd + round_index];
//                S1 <= S1 ^ const[16 - rnd + round_index];
                S2 <= S2 ^ const[16 - rnd + round_index];
//                S3 <= S3 ^ const[16 - rnd + round_index];
//                S4 <= S4 ^ const[16 - rnd + round_index];
                constantadd<=0;
        end  else if (!constantadd && bit_index != 6'd63) begin
    sbox_phase <= 1;
end


                if (sbox_phase) begin  
                    // Apply S-box bitwise (one bit per clock cycle)
                    sbox_in = {S0[bit_index], S1[bit_index], S2[bit_index], S3[bit_index], S4[bit_index]};
                    sbox_out = sbox(sbox_in);

                    // Apply the S-box output to the corresponding bit of each state variable
                    S0[bit_index] <= sbox_out[4];
                    S1[bit_index] <= sbox_out[3];
                    S2[bit_index] <= sbox_out[2];
                    S3[bit_index] <= sbox_out[1];
                    S4[bit_index] <= sbox_out[0];

                    // Increment bit index, continue applying S-box
                    if (bit_index == 63) begin
                 
                        sbox_phase <= 0;  // End the S-box phase, move to diffusion
                    end else begin
                        bit_index <= bit_index + 1;
                    end
                end else if(!constantadd && !sbox_phase) begin 
                
                    // === Linear Diffusion ===
                    S0 <= S0 ^ {S0[18:0], S0[63:19]} ^ {S0[27:0], S0[63:28]};
                S1 <= S1 ^ {S1[60:0], S1[63:61]} ^ {S1[38:0], S1[63:39]};
                S2 <= S2 ^ {S2[0], S2[63:1]} ^ {S2[5:0], S2[63:6]};
                S3 <= S3 ^ {S3[9:0], S3[63:10]} ^ {S3[16:0], S3[63:17]};
                S4 <= S4 ^ {S4[6:0], S4[63:7]} ^ {S4[40:0], S4[63:41]};
                

                    
                    // Increment round
                    round_index <= round_index + 1;

                    // Check if we finished the round
                    if (round_index == rnd - 1) begin
//                        S0 <= S0;
//                        S1 <= S1;
//                        S2 <= S2;
//                        S3 <= S3;
//                        S4 <= S4;
                        processing <=0 ;
                        
                        permutation_ready <= 1;
                          S_new <= {S0, S1, S2, S3, S4};
                    end 
                end
          end
        end
    end

endmodule
