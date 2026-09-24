`timescale 1ns / 1ps

module AD_Processing_tb;

reg clk;
reg rst;
reg [319:0] S;
reg [1023:0] ad;
reg start;
reg [10:0] ad_length;

wire [319:0] State;
wire finish;

AD_Processing DUT(
    .clk(clk),
    .rst(rst),
    .S(S),
    .ad(ad),
    .start(start),
    .ad_length(ad_length),
    .State(State),
    .finish(finish)
);

always #5 clk=~clk;

initial begin
    clk=0;
    rst=1;
    start=0;

    S=320'hf14fef544d836f73a514112d6cc7d6c6a9ecc5e6081e64422280b13b3c6c89e570eaeffef9a3d8d5;

    ad=1024'd0;
    ad[127:0]=128'h00112233445566778899aabbccddeeff;

    ad_length=11'd128;

    #20;
    rst=0;

    #10;
    start=1;

    #10;
    start=0;

    $display("");
    $display("========================================");
    $display("          AD DEBUG");
    $display("========================================");

    repeat(35) begin
        @(posedge clk);
        #1;

        $display("");
        $display("TIME = %0t",$time);
        $display("Phase       = %d",DUT.phase);
        $display("Block       = %d",DUT.block_counter);
        $display("Blocks      = %d",DUT.blocks);
        $display("Start Perm  = %d",DUT.start_perm);
        $display("Finish Perm = %d",DUT.finish_perm);
        $display("Inter S     = %h",DUT.inter_s);
        $display("Perm S_out  = %h",DUT.s);
        $display("State       = %h",State);
        $display("----------------------------------------");

        if(finish==1)
            $display("******** FINISH ********");

    end

    $finish;
end

endmodule