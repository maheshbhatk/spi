`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/20/2020 11:22:30 AM
// Design Name: 
// Module Name: spi_slave_tb
// Project Name: 
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


//Not using it.

module spi_slave_tb(
    );
    
reg clk;
reg rst_n;
reg [7:0]datain;
reg CPOL;
reg CPHA;
wire miso;
reg sclk;
reg ss;
reg mosi;
wire data_valid;
wire [7:0]dataout;

spi_slave slave1(clk,rst_n,datain,CPOL,CPHA,sclk,ss,mosi,miso,data_valid,dataout);
always
#2clk=~clk;
initial
begin
clk=0;
rst_n=0;
datain=8'b01110011;
CPOL=0;
CPHA=0;
#10 rst_n=1;
end
endmodule
