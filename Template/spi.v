/***********************************************
* function：  SPI通信 16bit版本  CHOL=1 CPHA=1
* input:      CUBEMX CPOL=HIGH CPHA=2Edge
* output:
* notes:       
**********************************************/
//use SPI 3 mode,CHOL = 1,CHAL = 1
module spi(
  input               clk,
  input               rst_n,

  input               CS_N,
  input               SCK,
  input               MOSI,
  output reg          MISO,

  output              rxd_flag_p,//上升沿为1
  output reg [15:0]   rxd_data,
  input [15:0]        txd_data
);

//-----------------------spi_slaver read data-------------------------------
reg rxd_flag_r;
reg [3:0] rxd_state;
always@(posedge SCK or posedge CS_N) begin
  if(CS_N) begin
    rxd_data <= 16'd0;
    rxd_flag_r <= 1'b0;
    rxd_state <= 4'b0000;
  end else begin
    case(rxd_state)
        4'b0000:begin
                  rxd_data[15] <= MOSI;
				          rxd_state <= 4'b0001;
                  rxd_flag_r <= 1'b0;
                end
        4'b0001:begin
                  rxd_data[14] <= MOSI;
                  rxd_state <= 4'b0011;
                end
        4'b0011:begin
                  rxd_data[13] <= MOSI;
                  rxd_state <= 4'b0010;
                end
        4'b0010:begin
                  rxd_data[12] <= MOSI;
                  rxd_state <= 4'b0110;
                end
        4'b0110:begin
                  rxd_data[11] <= MOSI;
                  rxd_state <= 4'b0111;
                end
        4'b0111:begin
                  rxd_data[10] <= MOSI;
                  rxd_state <= 4'b0101;
                 end
        4'b0101:begin
                  rxd_data[9] <= MOSI;
                  rxd_state <= 4'b0100;
                end
        4'b0100:begin
                  rxd_data[8] <= MOSI;
                  rxd_state <= 4'b1100;
                end
        4'b1100:begin
                  rxd_data[7] <= MOSI;
                  rxd_state <= 4'b1101;
                end
        4'b1101:begin
                  rxd_data[6] <= MOSI;
                  rxd_state <= 4'b1111;
                end
        4'b1111:begin
                  rxd_data[5] <= MOSI;
                  rxd_state <= 4'b1110;
                end
        4'b1110:begin
                  rxd_data[4] <= MOSI;
                  rxd_state <= 4'b1010;
                end
        4'b1010:begin
                  rxd_data[3] <= MOSI;
                  rxd_state <= 4'b1011;
                end
        4'b1011:begin
                  rxd_data[2] <= MOSI;
                  rxd_state <= 4'b1001;
                end
        4'b1001:begin
                  rxd_data[1] <= MOSI;
                  rxd_state <= 4'b1000;
                end
        4'b1000:begin
                  rxd_data[0] <= MOSI;
                  rxd_state <= 4'b0000;		
                  rxd_flag_r <= 1'b1;						
                end
        default: begin
                  rxd_state <= 4'b0000;
                  rxd_flag_r <= 1'b0;
	             end
    endcase
  end	  
end


//--------------------capture spi_flag posedge--------------------------------
reg rxd_flag_r0,rxd_flag_r1;
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        begin
            rxd_flag_r0 <= 1'b0;
            rxd_flag_r1 <= 1'b0;
        end
    else
        begin
            rxd_flag_r0 <= rxd_flag_r;
            rxd_flag_r1 <= rxd_flag_r0;
        end
end

assign rxd_flag_p = (~rxd_flag_r1 & rxd_flag_r0)? 1'b1:1'b0;   




//---------------------spi_slaver send data---------------------------
reg [3:0] txd_state;

always@(negedge SCK or posedge CS_N) begin
  if(CS_N) begin
		txd_state <= 4'b0000;
		MISO <= 1'd0;
  end else begin
    case(txd_state)
        4'b0000:begin
                  MISO <= txd_data[15];
                  txd_state <= 4'b0001;
                end
        4'b0001:begin
                  MISO <= txd_data[14];
                  txd_state <= 4'b0011;
                end
        4'b0011:begin
                  MISO <= txd_data[13];
                  txd_state <= 4'b0010;
                end
        4'b0010:begin
                  MISO <= txd_data[12];
                  txd_state <= 4'b0110;
                end
        4'b0110:begin
                  MISO <= txd_data[11];
                  txd_state <= 4'b0111;
                end
        4'b0111:begin
                  MISO <= txd_data[10];
                  txd_state <= 4'b0101;
                end
        4'b0101:begin
                  MISO <= txd_data[9];
                  txd_state <= 4'b0100;
                end
        4'b0100:begin
                  MISO <= txd_data[8];
                  txd_state <= 4'b1100;
                end
        4'b1100:begin
                  MISO <= txd_data[7];
                  txd_state <= 4'b1101;
                end
        4'b1101:begin
                  MISO <= txd_data[6];
                  txd_state <= 4'b1111;
                end
        4'b1111:begin
                  MISO <= txd_data[5];
                  txd_state <= 4'b1110;
                end
        4'b1110:begin
                  MISO <= txd_data[4];
                  txd_state <= 4'b1010;
                end
        4'b1010:begin
                  MISO <= txd_data[3];
                  txd_state <= 4'b1011;
                end
        4'b1011:begin
                  MISO <= txd_data[2];
                  txd_state <= 4'b1001;
                end
        4'b1001:begin
                  MISO <= txd_data[1];
                  txd_state <= 4'b1000;
                end
        4'b1000:begin
                  MISO <= txd_data[0];
                  txd_state <= 4'b0000;
                end
        default:begin 
                  txd_state <= 4'b0000;
                end
    endcase
  end
end

endmodule