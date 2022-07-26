module adc_module_9226 (
    input   rst_n, 
    input   clk_256M, 
    input   rxd_flag_p, 

    input   ad9226_otr,
    input   [11:0]  ad9226_data_in,
    output  ad9226_clk,

    input   [31:0]  ad9226_sample_freq,
    input   [15:0]  ad9226_sample_num,

    input   ad9226_fifo_rd_control,
    input   ad9226_fifo_wr_control,

    input   [12:0] ad9226_fifo_rd_num,
    input   ad9226_fifo_wrfull,
    input   [12:0] ad9226_fifo_wr_num,
    output   ad9226_fifo_rd_en,
    output   ad9226_fifo_rdreq,
    output  ad9226_fifo_wrclk, 
    output   ad9226_fifo_wrreq,
    output  [15:0] ad9226_fifo_di
);

wire ad9226_clk_drv;
assign ad9226_fifo_wrclk=ad9226_clk_drv;

assign ad9226_fifo_rd_en=(ad9226_fifo_rd_num > ad9226_sample_num)?1'b1:1'b0;
assign ad9226_fifo_rdreq=(ad9226_fifo_rd_num==13'd0)?1'b0:ad9226_fifo_rd_control;
assign ad9226_fifo_wrreq=(ad9226_fifo_wr_num>=ad9226_sample_num)?1'b0:ad9226_fifo_wr_control&(!ad9226_fifo_wrfull);

clk_div u_clk_div(
    .clk      (clk_256M ),
    .rst_n    (rst_n    ),
    .freq_set (ad9226_sample_freq),
    .clk_div  (ad9226_clk_drv)
);

ad9226 u_ad9226(
    .clk      (ad9226_clk_drv),
    .rst_n    (rst_n    ),
    .data_in  (ad9226_data_in  ),
    .adc_otr  (ad9226_otr  ),
    .adc_clk  (ad9226_clk  ),
    .data_out (ad9226_fifo_di )
);

endmodule //adc_module_9226