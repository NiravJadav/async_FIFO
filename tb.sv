async_FIFO FIFO1 (  wr_clk,
                    wr_en,
                    wr_rst_n,
                    wr_data_in,
                    rd_clk,
                    rd_en,
                    rd_rst_n,
                    rd_data_out,
                    full,
                    empty
                    );
                    
     initial 
     repeat(100) 
     #5 wr_clk <= !wr_clk;
     
     initial 
     repeat(100)
     #10 rd_clk <= !rd_clk;            

     
     
     initial 
     begin
     #2 wr_rst_n =1;
        rd_rst_n =1;
        wr_en =1;
        rd_en =1;
      wr_data_in =100;
     #10 wr_data_in =101;
     #10 wr_data_in =102;
     #10 wr_data_in =103;
     #10 wr_data_in =104;
     
     #10 wr_data_in =105;
     #10 wr_data_in =106;
     #10 wr_data_in =107;
     //#10 rd_en =1;
     #5 wr_en=0;
     //#10rd_en =0;
     

     
     end
     
     
     
