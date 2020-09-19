`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: MAHESH BHAT K
// 
// Create Date: 09/19/2020 03:59:37 PM
// Design Name: 
// Module Name: spi_master_tb
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


module spi_master_tb(

    );
    
reg clk;
reg rst;
reg [7:0]datain;
reg start;
reg CPOL;
reg CPHA;
reg miso;
wire sclk;
wire ss;
wire mosi;
wire finish;
wire [7:0]dataout;
  
spi_master master1(clk,rst,datain,start,CPOL,CPHA,miso,sclk,ss,mosi,finish,dataout);
always
#2 clk=~clk;
initial
begin
clk=0;
rst=0;
CPOL=0;
CPHA=0;
start=0;
datain=8'b10101010;
#10 rst=1;
start=1;
end
endmodule
