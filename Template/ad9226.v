module ad9226 (
    input clk,
    input rst_n,
    input [11:0] data_in,
    input adc_otr,
    output adc_clk,
    output reg [11:0] data_out
);

assign adc_clk = clk;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        data_out <= 12'd0;
    end
    else begin
        data_out <= data_in;
    end
end

endmodule //ad9226