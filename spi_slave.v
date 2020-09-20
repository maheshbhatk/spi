`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mahesh Bhat K
// 
// Create Date: 
// Design Name: 
// Module Name: spi_slave
// Project Name: SPI
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module spi_slave
#(parameter CLK_FREQUENCE	= 50_000_000		,	//system clk frequence
			SPI_FREQUENCE	= 5_000_000			)	//spi clk frequence
( input clk,
  input rst_n,
  input [7:0]datain,
  input CPOL,
  input CPHA,
  
  input sclk,
  input ss,
  input mosi,
  output miso,
  
  output data_valid,
  output reg [7:0]dataout
    );

localparam shift_num=3;

reg [7:0] data_reg;
reg [2:0] sample_num;
reg sclk_a;
reg sclk_b;
wire sclk_posedge;
wire sclk_negedge;
reg ss_a;
reg ss_b;
wire ss_negedge;
reg shift_en;
reg sample_en;

always@(posedge clk or negedge rst_n)
begin
    if (!rst_n) begin
		sclk_a <= CPOL;
		sclk_b <= CPOL;
	end else if (!ss) begin
		sclk_a <= sclk;
		sclk_b <= sclk_a;
	end
end 
    
assign sclk_posedge = ~sclk_b & sclk_a;
assign sclk_negedge = ~sclk_a & sclk_b;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		ss_a	<= 1'b1;
		ss_b	<= 1'b1;
	end else begin
		ss_a	<= ss	;
		ss_b	<= ss_a	;
	end
end

assign ss_negedge = ~ss_a & ss_b;

always@(CPHA)
case(CPHA)
0: begin assign sample_en = sclk_posedge;assign shift_en = sclk_negedge; end
1: begin assign sample_en = sclk_posedge;assign shift_en = sclk_negedge; end
default: begin assign sample_en = sclk_posedge;assign shift_en = sclk_negedge; end
endcase

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) 
		data_reg <= 'd0;
	else if(ss_negedge)
		data_reg <= datain;
	else if (!ss & shift_en) 
		data_reg <= {data_reg[6:0],1'b0};
	else
		data_reg <= data_reg;
end

assign miso = !ss ? data_reg[7] : 1'd0;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) 
		dataout <= 8'd0;
	else if (!ss & sample_en) 
		dataout <= {dataout[6:0],mosi};
	else
		dataout <= dataout;
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) 
		sample_num <= 3'd0;
	else if (ss)
		sample_num <=3'd0;
	else if (!ss & sample_en) 
		if (sample_num == 8)
			sample_num <= 3'd1;
		else
			sample_num <= sample_num + 1'b1;
	else
		sample_num <= sample_num;
end

assign data_valid = sample_num == 8;
endmodule
