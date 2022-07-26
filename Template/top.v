module top (
    input clk,
	input rst_n,
    //AD9226 0 Interface
    input ad9226_otr_0,
    input [11:0] ad9226_data_in_0,
    output ad9226_clk_0,
    //AD9226 1 Interface
    input ad9226_otr_1,
    input [11:0] ad9226_data_in_1,
    output ad9226_clk_1,
    //DAC902 Interface
    output dac_clk,
    output dac_pd,
    output [11:0] dac_data,
    //SPI Interface
    input           CS_N,
    input           SCK,
    input           MOSI,
    output          MISO
);


parameter ADC_9226_0=16'hADC0;      //选择ADC:ADC0-AD9226_0
parameter ADC_9226_1=16'hADC1;      //选择ADC:ADC1-AD9226_1

parameter DATA_START=16'h0000;      //状态机初始状态

parameter CMD_HEAD=16'hABCD;        //命令数据包头标志
parameter READ_HEAD=16'hABBB;        //读取数据包头标志
parameter CMD_ADC=16'hFADC;         //数据类型：操作ADC

parameter CMD_ADC_SELECT=16'hAF00;  //操作ADC：选择ADC
parameter CMD_ADC_FREQ=16'hAF01;    //操作ADC：设置ADC时钟频率
parameter CMD_ADC_POINTS=16'hAF02;  //操作ADC：设置ADC连续采样点数
parameter CMD_TAIL=16'hCDEF;        //数据包尾标志
parameter CONV_WAIT=16'hF2F3;
parameter CONV_END=16'hE2E3;
parameter TXD_START=16'hDCBA;
parameter TXD_WAIT=16'hC2C3;
parameter TXD_END=16'hB2B3;

//pll clk interface
wire clk_256M;
wire clk_165M;
wire clk_64M;
pll u_pll(
    .inclk0 (clk ),
    .c0     (clk_256M),
    .c1     (clk_64M)
);
pll_dac u_pll_dac(
    .inclk0 (clk ),
    .c0     (clk_165M     )
);

//spi slave interface
wire rxd_flag_p;
wire txd_flag_p;
wire [15:0]  rxd_data;
reg [15:0]  txd_data;
spi u_spi(
    .clk        (clk        ),
    .rst_n      (rst_n      ),
    .CS_N       (CS_N       ),
    .SCK        (SCK        ),
    .MOSI       (MOSI       ),
    .MISO       (MISO       ),
    .rxd_flag_p (rxd_flag_p ),
    .rxd_data   (rxd_data   ),
    .txd_data   (txd_data   )
);

//ADC TO SPI fifo
wire fifo_rd_en;
wire fifo_wr_busy;
wire fifo_rdreq;
wire fifo_rdempty;
wire fifo_wrclk;
wire fifo_wrreq;
wire fifo_wrfull;
wire [12:0] fifo_rd_num;
wire [12:0] fifo_wr_num;
wire [15:0] fifo_di;
wire [15:0] fifo_do;
reg fifo_aclr;

assign fifo_rdreq = (adc_select==ADC_9226_0)?ad9226_fifo_rdreq_0:((adc_select==ADC_9226_1)?ad9226_fifo_rdreq_1:0);
assign fifo_wrclk = (adc_select==ADC_9226_0)?ad9226_fifo_wrclk_0:((adc_select==ADC_9226_1)?ad9226_fifo_wrclk_1:0);
assign fifo_wrreq = (adc_select==ADC_9226_0)?ad9226_fifo_wrreq_0:((adc_select==ADC_9226_1)?ad9226_fifo_wrreq_1:0);
assign fifo_di = (adc_select==ADC_9226_0)?ad9226_fifo_di_0:((adc_select==ADC_9226_1)?ad9226_fifo_di_1:0);
assign fifo_rd_en=(adc_select==ADC_9226_0)?ad9226_fifo_rd_en_0:((adc_select==ADC_9226_1)?ad9226_fifo_rd_en_1:0);

fifo_16b_8192w u_fifo_16b_8192w(
    .aclr    (fifo_aclr    ),
    .data    (fifo_di    ),
    .rdclk   (rdclk   ),
    .rdreq   (fifo_rdreq   ),
    .wrclk   (fifo_wrclk   ),
    .wrreq   (fifo_wrreq   ),
    .q       (fifo_do       ),
    .rdempty (fifo_rdempty ),
    .rdusedw (fifo_rd_num ),
    .wrfull  (fifo_wrfull  ),
    .wrusedw (fifo_wr_num )
);

wire ad9226_fifo_rd_en_0;
wire ad9226_fifo_rdreq_0;
wire ad9226_fifo_wrclk_0;
wire ad9226_fifo_wrreq_0;
wire [15:0] ad9226_fifo_di_0;

adc_module_9226 u0_adc_module_9226(
    .rst_n                  ((adc_select==ADC_9226_0)?1'b1:1'b0),
    .clk_256M               (clk_256M               ),
    .rxd_flag_p             (rxd_flag_p             ),

    .ad9226_otr             (ad9226_otr_0             ),
    .ad9226_data_in         (ad9226_data_in_0         ),
    .ad9226_clk             (ad9226_clk_0             ),

    .ad9226_sample_freq     ((adc_select==ADC_9226_0)?adc_sample_freq:0),
    .ad9226_sample_num      ((adc_select==ADC_9226_0)?adc_sample_num:0),
    .ad9226_fifo_rd_control ((adc_select==ADC_9226_0)?adc_fifo_rd_control:0),
    .ad9226_fifo_wr_control ((adc_select==ADC_9226_0)?adc_fifo_wr_control:0),
    .ad9226_fifo_rd_num     ((adc_select==ADC_9226_0)?fifo_rd_num:0),
    .ad9226_fifo_wrfull     ((adc_select==ADC_9226_0)?fifo_wrfull:0),
    .ad9226_fifo_wr_num     ((adc_select==ADC_9226_0)?fifo_wr_num:0),

    .ad9226_fifo_rd_en      (ad9226_fifo_rd_en_0      ),
    .ad9226_fifo_rdreq      (ad9226_fifo_rdreq_0      ),
    .ad9226_fifo_wrclk      (ad9226_fifo_wrclk_0      ),
    .ad9226_fifo_wrreq      (ad9226_fifo_wrreq_0      ),
    .ad9226_fifo_di         (ad9226_fifo_di_0         )
);

wire ad9226_fifo_rd_en_1;
wire ad9226_fifo_rdreq_1;
wire ad9226_fifo_wrclk_1;
wire ad9226_fifo_wrreq_1;
wire [15:0] ad9226_fifo_di_1;

adc_module_9226 u1_adc_module_9226(
    .rst_n                  ((adc_select==ADC_9226_1)?1'b1:1'b0),
    .clk_256M               (clk_256M               ),
    .rxd_flag_p             (rxd_flag_p             ),

    .ad9226_otr             (ad9226_otr_1             ),
    .ad9226_data_in         (ad9226_data_in_1         ),
    .ad9226_clk             (ad9226_clk_1             ),

    .ad9226_sample_freq     ((adc_select==ADC_9226_1)?adc_sample_freq:0),
    .ad9226_sample_num      ((adc_select==ADC_9226_1)?adc_sample_num:0),
    .ad9226_fifo_rd_control ((adc_select==ADC_9226_1)?adc_fifo_rd_control:0),
    .ad9226_fifo_wr_control ((adc_select==ADC_9226_1)?adc_fifo_wr_control:0),
    .ad9226_fifo_rd_num     ((adc_select==ADC_9226_1)?fifo_rd_num:0),
    .ad9226_fifo_wrfull     ((adc_select==ADC_9226_1)?fifo_wrfull:0),
    .ad9226_fifo_wr_num     ((adc_select==ADC_9226_1)?fifo_wr_num:0),

    .ad9226_fifo_rd_en      (ad9226_fifo_rd_en_1      ),
    .ad9226_fifo_rdreq      (ad9226_fifo_rdreq_1      ),
    .ad9226_fifo_wrclk      (ad9226_fifo_wrclk_1      ),
    .ad9226_fifo_wrreq      (ad9226_fifo_wrreq_1      ),
    .ad9226_fifo_di         (ad9226_fifo_di_1         )
);

reg [15:0] adc_select;
reg adc_fifo_rd_control;
reg adc_fifo_wr_control;
reg [31:0] adc_sample_freq;
reg [15:0] adc_sample_num;
reg [15:0] txd_sample_num;
reg [15:0] cmd_data_length;
reg [15:0] cmd_state;


//命令控制状态机
always @(posedge rxd_flag_p or negedge rst_n) begin
    if(!rst_n) begin
        cmd_state <= DATA_START;
        cmd_data_length <= 4'd0;
        adc_select <= 16'h0000;
        // adc_sample_freq<=32'd200_000;
        adc_sample_num=16'd512;
        txd_sample_num=16'd512;
        // adc_txd_en <= 1'b0;
        // adc_txd_head <= 1'b0;
        fifo_aclr <=1'b0;
        txd_data<= 16'h0;
        adc_fifo_wr_control<=1'd1;
        adc_fifo_rd_control<=1'd0;
    end else begin
        case(cmd_state)
            DATA_START://接收命令数据包头标志
                begin
                    fifo_aclr <=1'b0;
                    txd_data<= 16'h0;
                    if(rxd_data == CMD_HEAD)
                        cmd_state <= CMD_HEAD;
                    else
                        cmd_state <= cmd_state;
                 end
            CMD_HEAD://接收数据类型
                begin
                    if(rxd_data == CMD_ADC)
                        cmd_state <= CMD_ADC;  
                    else
                        cmd_state <= cmd_state;  
                end
            CMD_ADC://接收操作ADC命令
                begin
                    if(rxd_data == CMD_ADC_SELECT) begin
                        cmd_data_length <= 4'd1;
                        cmd_state <= CMD_ADC_SELECT;
                    end
                    else if(rxd_data == CMD_ADC_FREQ) begin
                        cmd_data_length <= 4'd2;
                        cmd_state <= CMD_ADC_FREQ;
                    end
                    else if(rxd_data == CMD_ADC_POINTS) begin
                        cmd_data_length <= 4'd1;
                        cmd_state <= CMD_ADC_POINTS;
                    end  
                    else if(rxd_data == CMD_TAIL) begin
                        cmd_data_length <= 4'd0;
                        cmd_state <= READ_HEAD;
                    end 
                    else begin
                        cmd_state <= cmd_state; 
                    end  
                end
            CMD_ADC_SELECT://接收选择ADC操作对象字 长度1
                begin
                    adc_select <= rxd_data;
                    if(cmd_data_length > 4'd1) begin
                        cmd_state <= cmd_state;
                        cmd_data_length <= cmd_data_length - 4'd1;
                    end
                    else begin
                        cmd_state <= CMD_ADC;
                    end
                end
            CMD_ADC_FREQ://接收ADC操作对象频率字 长度2
                begin
                    adc_sample_freq <= (adc_sample_freq<<16) | rxd_data;

                    if(cmd_data_length > 4'd1) begin
                        cmd_state <= cmd_state;
                        cmd_data_length <= cmd_data_length - 4'd1;
                    end
                    else begin
                        cmd_state <= CMD_ADC;
                    end
                end
            CMD_ADC_POINTS://接收ADC操作对象采样数字 长度1
                begin
                    adc_sample_num <= rxd_data;
                    if(cmd_data_length > 4'd1) begin
                        cmd_state <= cmd_state;
                        cmd_data_length <= cmd_data_length - 4'd1;
                    end
                    else begin
                        cmd_state <= CMD_ADC;
                    end
                end
            CMD_TAIL://数据包尾标志
                begin
                    cmd_state <= DATA_START;
                    txd_data<= 16'h0;
                end
            READ_HEAD:
                begin
                    if(fifo_rd_en)begin
                        cmd_state <= TXD_START;
                        txd_data <= 16'h0;//波形数据标志头
                    end
                    else begin
                        cmd_state <= cmd_state;    
                    end
                end
            TXD_START://开始读取FIFO
                begin
                    if(fifo_rd_en)begin
                        txd_data <= 16'hABCD;//波形数据标志头
                        adc_fifo_rd_control<=1'd1;
                        adc_fifo_wr_control<=1'd0;
                        cmd_state<=TXD_WAIT;
                        txd_sample_num <= adc_sample_num;
                    end
                    else begin
                        cmd_state <= cmd_state;
                        txd_data<= 16'h0;
                    end
                end
            TXD_WAIT://等待发送完成
                begin
                    if(txd_sample_num!=16'd0) begin
                        txd_sample_num <= txd_sample_num-1'b1;
                        txd_data <= fifo_do;
                        cmd_state <= cmd_state;
                    end 
                    else begin
                        fifo_aclr <=1'b1;
                        adc_fifo_rd_control <= 1'd0;
                        adc_fifo_wr_control <= 1'd1;
                        cmd_state <= TXD_END; 
                        txd_data<= 16'hDCBA;
                        adc_select<=16'h0;
                    end
                end
             TXD_END://等待发送完成
                begin
                    txd_data<= 16'h0;
                    if(rxd_data==16'hDCAB) begin
                        cmd_state <= DATA_START; 
                    end
                    else begin
                        cmd_state <= cmd_state;
                    end
                end
            default: 
                begin
                    cmd_state <= 4'b0000;
                end
        endcase
    end
end



//测试用例:收啥发啥
always @(posedge rxd_flag_p or negedge rst_n) begin
    if(!rst_n) begin
        txd_data<=16'd0;
    end
    else begin
        txd_data<=rxd_data;
    end
end



endmodule //top