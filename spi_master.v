`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: MAHESH BHAT K
// 
// Create Date: 09/19/2020 02:47:40 PM
// Design Name: 
// Module Name: spi_master
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


module spi_master
#(parameter	CLK_FREQUENCE	= 50_000_000,	//system clk frequence
			SPI_FREQUENCE	= 1_000_000	    //spi clk frequence
 )
( input clk,
  input rst,
  input [7:0]datain,
  input start,
  input CPOL,
  input CPHA,
  
  input miso,
  output reg sclk,
  output reg ss,
  output mosi,
  
  output reg finish,
  output reg [7:0]dataout 
);
//localparam FREQUENCE_CNT= CLK_FREQUENCE/SPI_FREQUENCE - 1,
//          CNT_WIDTH		= log2(FREQUENCE_CNT)	;       //real time
localparam FREQUENCE_CNT=1,
           CNT_WIDTH=2;     //for simulations 
localparam idle=3'b000,
           load=3'b001,
           shift=3'b011,
           done=3'b010;
reg [2:0] PS;
reg [2:0] NS;         
reg clk_cnt_en;
reg sclk_a;
reg sclk_b;
wire sclk_posedge;
wire sclk_negedge;
reg shift_en;
reg sample_en;
reg [CNT_WIDTH-1:0]clk_cnt;
reg [2:0]shift_cnt;
reg [7:0]data_reg;

always@(posedge clk or negedge rst)
begin if(rst==0)
            clk_cnt<=0;
      else if(clk_cnt_en)
                if(clk_cnt==FREQUENCE_CNT)
                    clk_cnt<=0;
                else 
                    clk_cnt<=clk_cnt+1'b1;
           else clk_cnt<=0;
end

always@(posedge clk or negedge rst)
begin
     if(rst==0)
        sclk<=CPOL;
     else if(clk_cnt_en)
            if(clk_cnt==FREQUENCE_CNT)
                sclk <= ~sclk;
            else 
                sclk <=sclk;
          else
            sclk<=CPOL;
end

always @(posedge clk or negedge rst) 
begin
	if (!rst) begin
		sclk_a <= CPOL;
		sclk_b <= CPOL;
	end else if (clk_cnt_en) begin
		sclk_a <= sclk;
		sclk_b <= sclk_a;
	end
end

assign sclk_posedge = ~sclk_b & sclk_a;
assign sclk_negedge = ~sclk_a & sclk_b;

always @(CPHA)
case(CPHA)
0: begin assign shift_en = sclk_negedge;assign sample_en = sclk_posedge;  end
1: begin assign shift_en = sclk_posedge;assign sample_en = sclk_negedge;  end
default: begin assign shift_en = sclk_posedge;assign sample_en = sclk_negedge;  end
endcase

always @(posedge clk or negedge rst) begin
	if (!rst) 
		PS <= idle;
	else 
		PS <= NS;
end

always @(*) begin
	case (PS)
		idle	: NS = start ? load : idle;
		load	: NS = shift;
		shift	: NS = (shift_cnt == 8) ? done : shift;
		done	: NS = idle;
		default : NS = idle;
	endcase
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		clk_cnt_en	<= 1'b0	;
		data_reg	<= 8'd0	;
		ss    		<= 1'b1	;
		shift_cnt	<= 3'd0	;
		finish      <= 1'b0	;          end
    else 
        case(NS)
            idle: begin
				clk_cnt_en	<= 1'b0	;
				data_reg	<= 8'd0	;
				ss  		<= 1'b1	;
				shift_cnt	<= 3'd0	;
				finish 		<= 1'b0	;
			     end
            load: begin
				clk_cnt_en	<= 1'b1		;
				data_reg	<= datain	;
				ss  		<= 1'b0		;
				shift_cnt	<= 3'd0		;
				finish 		<= 1'b0		;
			     end
			shift: begin
				if (shift_en) begin
					shift_cnt	<= shift_cnt + 1'b1 ;
					data_reg	<= {data_reg[6:0],1'b0};
				end else begin
					shift_cnt	<= shift_cnt	;
					data_reg	<= data_reg		;
				end
				clk_cnt_en	<= 1'b1	;
				ss  		<= 1'b0	;
				finish 		<= 1'b0	;
			     end
            done: begin
				clk_cnt_en	<= 1'b0	;
				data_reg	<= 8'd0	;
				ss  		<= 1'b1	;
				data_reg	<= 3'd0	;
				finish 		<= 1'b1	;
			     end
			default: begin
			    clk_cnt_en	<= 1'b0	;
				data_reg	<= 8'd0	;
				ss  		<= 1'b1	;
				data_reg	<= 3'd0	;
				finish 		<= 1'b0	;
			end			 
     endcase
end

assign mosi = data_reg[7];
always @(posedge clk or negedge rst) 
begin
	if (!rst) 
		dataout <= 8'd0;
	else if (sample_en) 
		dataout <= {dataout[6:0],miso};
	else
		dataout <= dataout;
end

function integer log2(input integer v);
  begin
	log2=0;
	while(v>>log2) 
	  log2=log2+1;
  end
endfunction

endmodule
