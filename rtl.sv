// version 1
// multi module design 

`timescale 1ns / 1ps
module async_FIFO #(parameter WIDTH =8,parameter DEEP =8)
                 (  input wr_clk,
                    input wr_en,
                    input wr_rst_n,
                    input [WIDTH-1:0]wr_data_in,
                    input rd_clk,
                    input rd_en,
                    input rd_rst_n,
                    output reg [WIDTH-1:0]rd_data_out,
                    output reg full,
                    output reg empty);
                   
                   
   
    wire [2:0]rd_b_ptr; //reading binary pointer | memory[ptr]
    wire [3:0]rd_g_ptr; //reading gray pointer   | cnt--sync_in
    wire [2:0]wr_b_ptr; //writing binary ponter  | memory[ptr]
    wire [3:0]wr_g_ptr; //writing gray pointer   | cnt--sync_in
           
    wire [3:0]rd_g_sync_ptr; // reading gray pointer --> sync output  
    wire [3:0]wr_g_sync_ptr; // writing gray pointer --> sync output  
    wire empty_c,full_c;
       
    reg [WIDTH-1:0]mem[0:DEEP-1];
   
    bin_gray_logic rd_cntr(.clk(rd_clk), .en(rd_en), .flag(empty_c), .rst_n(rd_rst_n), .b_cnt(rd_b_ptr), .g_cnt(rd_g_ptr));
    bin_gray_logic wr_cntr(.clk(wr_clk), .en(wr_en), .flag(full_c), .rst_n(wr_rst_n), .b_cnt(wr_b_ptr), .g_cnt(wr_g_ptr));
   
   
    nbit_sync rd_sync(.clk(rd_clk), .rst_n(rd_rst_n), .sync_in(wr_g_ptr),.sync_out(wr_g_sync_ptr));
    nbit_sync wr_sync(.clk(wr_clk), .rst_n(wr_rst_n), .sync_in(rd_g_ptr),.sync_out(rd_g_sync_ptr));  

//----------> EMPTY Signal    
        assign empty_c = (rd_g_ptr==wr_g_sync_ptr);
       
        always@(negedge rd_clk or negedge rd_rst_n)
            begin
                if(!rd_rst_n)
                    empty <= 1;
                else
                    empty <= empty_c;
            end
           
//----------> FULL Signal        
        assign full_c = (   (wr_g_ptr[3] != rd_g_sync_ptr[3]) &&
                            (wr_g_ptr[2] != rd_g_sync_ptr[2]) &&
                            (wr_g_ptr[1:0] == rd_g_sync_ptr[1:0]) );
       
        always@(negedge wr_clk or negedge wr_rst_n)
            begin
                if(!wr_rst_n)
                    full <=0;
                else
                    full <= full_c ;
            end

//----------> FIFO read          
           
       
       // assign  rd_data_out  = (rd_en && !empty)?mem[rd_b_ptr]:'z;
   always @ (posedge rd_clk)
   begin
   if(rd_en && !empty_c) rd_data_out <= mem[rd_b_ptr];
   else rd_data_out <= 'z;
   end
   
     
//----------> FIFO write    
         
    always@(posedge wr_clk)
    begin
        if(wr_en && !full_c)
            mem[wr_b_ptr] <= wr_data_in;
    end
   
   
     
endmodule



module bin_gray_logic(  input clk,
                        input en,
                        input flag,
                        input rst_n,
                        output   [2:0]b_cnt,
                        output   [3:0]g_cnt);
                       
                        reg [3:0] cnt;
                      assign b_cnt = {cnt[2:0]};
                      assign g_cnt = {cnt[3],cnt[2]^cnt[3],cnt[2]^cnt[1],cnt[0]^cnt[1]};
                       
                       
                        always @(posedge clk or negedge rst_n)
                        begin
                            if(!rst_n)
                                begin
                                cnt   <=0;
                               // b_cnt <=0;
                               // g_cnt <=0;
                                end
                            else if (en & !flag)
                                begin
                                cnt <= cnt + 1; 
                               // b_cnt <= {cnt[2:0]};                          
                               // g_cnt <= {cnt[3],cnt[2]^cnt[3],cnt[2]^cnt[1],cnt[0]^cnt[1]};
                                end    
                           //else cnt <= cnt;                              
                         end
                       
endmodule



module nbit_sync#(parameter n=4)(input clk,input rst_n,input [n-1:0]sync_in, output reg [n-1:0]sync_out);

reg [n-1:0] ff;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n) {sync_out,ff} <= 0;
    else        {sync_out,ff} <= {ff,sync_in};
end

endmodule



//module nbit_sync#(parameter n =4)
//                (   input clk,
//                    input rst_n,
//                    input [n-1:0]sync_in,
//                    output [n-1:0]sync_out);

//wire [n-1:0]out1;

//    nbit_dff ff1(.clk(clk), .rst_n(rst_n), .d(sync_in), .q(out1));
//    nbit_dff ff2(.clk(clk), .rst_n(rst_n), .d(out1), .q(sync_out));                          
                               
//endmodule

//module nbit_dff#(parameter n=4)
//                (   input clk,
//                    input rst_n,
//                    input [n-1:0]d,
//                    output reg [n-1:0]q);
                   
//                    always@(posedge clk or negedge rst_n)
//                    begin
//                    if(!rst_n)
//                        q <=0;
//                    else
//                        q <= d;
//                    end
//endmodule
