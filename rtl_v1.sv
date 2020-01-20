`timescale 1ns / 1ps
`include "nbit_sync.sv"
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
    reg [3:0]rd_cnt,wr_cnt;
   
       
    nbit_sync rd_sync(.clk(rd_clk), .rst_n(rd_rst_n), .sync_in(wr_g_ptr),.sync_out(wr_g_sync_ptr));
    nbit_sync wr_sync(.clk(wr_clk), .rst_n(wr_rst_n), .sync_in(rd_g_ptr),.sync_out(rd_g_sync_ptr));  


    assign wr_g_ptr = bin_gray_4bit(wr_cnt);
    //assign wr_g_ptr = {wr_cnt[3],wr_cnt[2]^wr_cnt[3],wr_cnt[2]^wr_cnt[1],wr_cnt[0]^wr_cnt[1]};
    assign wr_b_ptr = {wr_cnt[2:0]};
    
    //assign rd_b_ptr = bin_gray_4bit(rd_cnt);
    assign rd_b_ptr = {rd_cnt[2:0]};
    assign rd_g_ptr = {rd_cnt[3],rd_cnt[2]^rd_cnt[3],rd_cnt[2]^rd_cnt[1],rd_cnt[0]^rd_cnt[1]};
    
    

//----------> EMPTY Signal    
        assign empty_c = (rd_g_ptr==wr_g_sync_ptr);
       
        always@(posedge rd_clk or negedge rd_rst_n)
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
       
        always@(posedge wr_clk or negedge wr_rst_n)
            begin        
                if(!wr_rst_n)
                    full <=0;
                else
                    full <= full_c ;
            end
//----------> FIFO read          
           
       
       // assign  rd_data_out  = (rd_en && !empty)?mem[rd_b_ptr]:'z;
   always @ (posedge rd_clk or negedge rd_rst_n)
   begin
   if(!rd_rst_n)
        rd_cnt <=0;
   else if(rd_en && !empty_c)
        begin
        rd_data_out <= mem[rd_b_ptr];
        rd_cnt <= rd_cnt+1;
        //rd_b_ptr <= {rd_cnt[2:0]};
        //rd_g_ptr <= {rd_cnt[3],rd_cnt[2]^rd_cnt[3],rd_cnt[2]^rd_cnt[1],rd_cnt[0]^rd_cnt[1]};
        end
   else rd_data_out <= 0;
   end
   
     
//----------> FIFO write    
         
    always@(posedge wr_clk or negedge wr_rst_n)
    begin
        if(!wr_rst_n)
            wr_cnt <=0;
        else if(wr_en && !full_c)
        begin
            mem[wr_b_ptr] <= wr_data_in;
            wr_cnt <= wr_cnt+1;
            //wr_g_ptr <= {wr_cnt[3],wr_cnt[2]^wr_cnt[3],wr_cnt[2]^wr_cnt[1],wr_cnt[0]^wr_cnt[1]};
            //wr_b_ptr <= {wr_cnt[2:0]};
        end
    end
   
   
   function [3:0]bin_gray_4bit(input [3:0]cnt);
        
        assign bin_gray_4bit = {cnt[3],cnt[2]^cnt[3],cnt[2]^cnt[1],cnt[0]^cnt[1]};
                                                                          
    endfunction
     
endmodule











