module clk_div #(
	parameter CLKREF = 32'd256_000_000
)(
    input clk,
    input rst_n, 
	input [31:0]freq_set,
	output reg clk_div
);

reg [31:0]div_cnt;
reg [48:0]freq_word;

always@(*)
begin
	freq_word <= (freq_set*32'd1099512)>>5'd16;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
		div_cnt <= 16'd0;
	end
	else begin
		div_cnt <= div_cnt + freq_word;
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
		clk_div <= 1'b0;
	end
	else begin
		if(div_cnt < 32'h7fff_ffff) begin
			clk_div <= 1'b0;
		end
		else begin
			clk_div <= 1'b1;
		end
	end
end

endmodule //clk_div