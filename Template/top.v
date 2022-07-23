module top (
    input clk,
	input rst_n,
     //SPI Interface
    input           CS_N,
    input           SCK,
    input           MOSI,
    output          MISO
);

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


//命令控制状态机
always @(posedge rxd_flag_p or negedge rst_n) begin
    if(!rst_n) begin
        txd_data<=16'd0;
    end
    else begin
        txd_data<=rxd_data;
    end
end

endmodule //top