`timescale 1 ns / 1 ns

`include "src/rx.v"
`include "src/tx.v"
`include "src/clock_gen.v"
`include "src/uart.v"

module tb_uart;

localparam WIDTH = 8;

reg clk, nrst;
reg             we;
reg [WIDTH-1:0] data;

wire o_tx;
wire ready;
wire o_mty;

uart m_uart (
	// external pins
	.i_rx   (o_tx),
	.o_tx   (o_tx),
	// inside in the chip
	.o_data (),
	.o_rdy  (ready),
	.o_mty  (o_mty),
	.i_re   (ready),
	.i_we   (we),
	.i_data (data),
	.i_nrst (nrst),
	.i_clk  (clk)
);
defparam m_uart.WIDTH_DATA = WIDTH;

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

	nrst = 1'b0;
	nrst <= #1 1'b1;

	we = 1'b0;

	we <= #610 1'b1;
	we <= #630 1'b0;

	we <= #5370 1'b1;
	we <= #5390 1'b0;
end

initial forever #10 clk = ~clk;

initial begin
	$dumpfile("Debug/tb_uart.vcd");
	$dumpvars;
	#10000 $finish;
end

endmodule

