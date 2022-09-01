`timescale 1 ns / 1 ns

`include "src/rx.v"
`include "src/tx.v"
`include "src/clock_gen.v"
`include "src/uart.v"

module tb_uart;

localparam WIDTH = 8;
localparam NB_STOP = 2;

// 20 ns == 50 MHz
localparam BAUDS = 115200;
localparam CLK_SIZE = 50_000_000 / BAUDS;
localparam WIDTH_CLK = $clog2(CLK_SIZE);

reg clk, nrst;
reg             we;
reg [WIDTH-1:0] data;

reg rx;

wire o_tx;
wire ready;
wire o_mty;
wire [WIDTH-1:0] o_data;

uart #(
	.WIDTH_DATA (WIDTH),
	.NB_STOP    (NB_STOP),
	.WIDTH_CLK  (WIDTH_CLK),
	.CLK_SIZE   (CLK_SIZE)
) m_uart (
	// external pins
	.i_rx   (rx),
	.o_tx   (o_tx),
	// inside in the chip
	.o_data (o_data),
	.o_rdy  (ready),
	.o_mty  (o_mty),
	.i_re   (ready),
	.i_we   (o_mty),
	.i_data (data),
	.i_nrst (nrst),
	.i_clk  (clk)
);

always @(o_tx) #2935 rx = o_tx;
//always @(o_tx) rx = o_tx;

always @(posedge clk, negedge nrst) begin
	if (!nrst)
		data <= $random;
	else begin
		if (we && o_mty)
			data <= $random;
	end
end

initial begin
	clk = 1'b1;
	rx = 1'b1;

	nrst = 1'b0;
	nrst <= #1 1'b1;


	/*
	we <= #610 1'b1;
	we <= #630 1'b0;

	we <= #5370 1'b1;
	we <= #5390 1'b0;
	*/
end

initial forever #10 clk = ~clk;

initial begin
	$dumpfile("Debug/tb_uart.vcd");
	$dumpvars;
	#1000000 $finish;
end

endmodule

