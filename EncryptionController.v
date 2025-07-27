`timescale 1ns / 1ps

module EncryptionController(
    input clk , 
    input rst ,
    input [63:0] IV ,
    input [127:0] key ,
    input [127:0] nonce ,
    input [255:0] associated_data ,
    input [255:0] plain_text ,
    input encryption_start , 
    input permutation_ready ,
    output reg [319:0] S ,
    output reg encryption_ready , 
    output reg permutation_start ,
    
    output reg [255:0] cipher_text,
    output reg [127:0] tag
);

reg [3:0] rounds ;
reg [3:0] i ;
reg [319:0] P_in;
wire [319:0] P_out;
reg [3:0] state;
permutation p2 (clk, rst, permutation_start, P_in, rounds, permutation_ready, P_out);

reg [127:0] ad_bits;
reg [3:0] next_state;


parameter RESET           = 4'b0000,
          IDLE            = 4'b0001,
         INITIALIZE_1      = 4'b0010,
          INITIALIZE_2      = 4'b0011,
          ASSOCIATED_DATA_1 = 4'b0100,
          ASSOCIATED_DATA_2  = 4'b0101,
          ASSOCIATED_DATA_3     = 4'b0110,
          PTCT_1         = 4'b0111,
          PTCT_2    = 4'b1000,
          PTCT_3    = 4'b1001,
          PTCT_4           = 4'b1010,
          FINALIZE_1          = 4'b1011,
          FINALIZE_2          = 4'b1100,
          DONE = 4'b1101 ;


always @(*) begin
    case (i)
        0: ad_bits = associated_data[255:128];
        1: ad_bits = associated_data[127:0];
        default: ad_bits = 128'h0;
    endcase
end



always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= RESET;
        encryption_ready <= 0;
        permutation_start<=0 ;
       
        rounds <= 0;
        i <= 0;
        S <= 0;
        P_in <= 0;
        cipher_text <= 0;
        tag <= 0;
       
    end else begin
        state<=next_state ;
        end 
         end 
         
         always @(*) begin
         case(state) 
         RESET : next_state = (rst)? RESET : IDLE ;
         IDLE : next_state = (encryption_start)? INITIALIZE_1 : IDLE ;
         INITIALIZE_1 : next_state = INITIALIZE_2 ;
         INITIALIZE_2 : next_state = (permutation_ready)? ASSOCIATED_DATA_1 : INITIALIZE_2 ;
         ASSOCIATED_DATA_1 : next_state = ASSOCIATED_DATA_2 ;
         ASSOCIATED_DATA_2 : next_state = (permutation_ready)?  ASSOCIATED_DATA_3 :  ASSOCIATED_DATA_2 ;
          ASSOCIATED_DATA_3 : if (i<2) begin 
                              next_state= ASSOCIATED_DATA_1 ;
                              end else if (i==2) begin
                              next_state= PTCT_1 ;
                              end  
         PTCT_1 : next_state = PTCT_2 ;
         PTCT_2 : next_state = PTCT_3 ;
         PTCT_3 : next_state = (permutation_ready)? PTCT_4 : PTCT_3 ;
         PTCT_4 : next_state = FINALIZE_1 ;
         FINALIZE_1 : next_state= FINALIZE_2 ;
         FINALIZE_2 : next_state= (permutation_ready)? DONE : FINALIZE_2 ;
         DONE : next_state = (encryption_start) ? RESET : DONE ;
         default : next_state = RESET ;
         endcase 
         end 
         
         
         
         
         
   always @(posedge clk)  begin     
  case(state) 
   RESET : begin 
   
  end
   
   IDLE: begin 
   S<= {IV,key,nonce} ;
   end 
   INITIALIZE_1 : begin 
   rounds<=12 ;
   permutation_start<=1 ;
   P_in<= S ;
   end 
   INITIALIZE_2 : begin 
   if(permutation_ready) begin 
   S<= P_out ^ {{192{1'b0}},key };
   permutation_start<=0 ;
   end
   end 
   ASSOCIATED_DATA_1 : begin 
   rounds<=8 ;
   permutation_start<= 1 ;
   P_in<= {S[127:0]^ad_bits , S[319:128]} ;
 
   end 
   ASSOCIATED_DATA_2: begin 
   if(permutation_ready) begin 
   S<= P_out ;
   i<=i+1 ;
  
   end 
   end 
   ASSOCIATED_DATA_3: begin 
   if (i==2) begin 
   i<=0 ;
   S<= S ^ {{319{1'b0}} , 1'b1 } ;
   permutation_start<=0;
   end 
   end 
   PTCT_1 : begin 
   S[127:0]<= S[127:0] ^ plain_text[255:128] ;
   cipher_text[255:128] <= S[127:0] ^ plain_text[255:128] ;
   
   end 
   PTCT_2 : begin 
   permutation_start<=1 ;
   rounds<=8 ;
   P_in <= S ;
   end 
   PTCT_3 : begin 
   if(permutation_ready) begin 
   S<=P_out ;
   permutation_start<= 0 ;
  
  end 
  end 
  PTCT_4 : begin 
  S[127:0] <= S[127:0] ^ plain_text[127:0] ;
  cipher_text[127:0] <= S[127:0] ^ plain_text[127:0] ;
  
  end 
  FINALIZE_1 : begin 
  rounds<= 12 ;
  P_in <= S ^ {{128{1'b0}},key,{64{1'b0}} } ;
  permutation_start<=1 ;
  end 
  FINALIZE_2 : begin 
  if (permutation_ready) begin 
  S <= P_out ;
  tag <= P_out[319:192] ^  key ;
  permutation_start<= 0 ;
  end 
  end 
  DONE : begin 
  encryption_ready <= 1 ;
  end 
  endcase
  end 
 
 endmodule
