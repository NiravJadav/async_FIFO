module nbit_sync#(parameter n=4)(input clk,input rst_n,input [n-1:0]sync_in, output reg [n-1:0]sync_out);

reg [n-1:0] ff;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n) {sync_out,ff} <= 0;
    else        {sync_out,ff} <= {ff,sync_in};
end

endmodule
