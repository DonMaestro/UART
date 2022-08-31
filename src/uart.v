
module uart #(
	parameter WIDTH_DATA = 8,
	parameter NB_STOP = 2,
	parameter CLK_SIZE = 434,
	parameter WIDTH_CLK = 9
) (
	// external pins
	input                   i_rx,
	output                  o_tx,
	// inside in the chip
	output [WIDTH_DATA-1:0] o_data,
	output                  o_rdy,
	output                  o_mty,
	input                   i_re,
	input                   i_we,
	input  [WIDTH_DATA-1:0] i_data,
	input                   i_nrst,
	input                   i_clk
);

//localparam NB_STATE = 1 + WIDTH_DATA + NB_STOP;

wire clk_gen;

rx #(
	.WIDTH_DATA (WIDTH_DATA),
	.NB_STOP    (NB_STOP)
) m_rx (
	.i_buf  (i_rx),
	.o_rdy  (o_rdy),
	.o_data (o_data),
	.i_re   (i_re),
	.i_nrst (i_nrst),
	.i_clk  (i_clk),
	.clk_rx (clk_gen)
);

tx #(
	.WIDTH_DATA (WIDTH_DATA),
	.NB_STOP    (NB_STOP)
) m_tx (
	.o_buf  (o_tx),
	.o_mty  (o_mty),
	.i_we   (i_we),
	.i_data (i_data),
	.i_nrst (i_nrst),
	.clk_tx (clk_gen),
	.i_clk  (i_clk)
);

clock_gen #(
	.WIDTH(WIDTH_CLK),
	.SIZE(CLK_SIZE)
) clock (
	.o_clk (clk_gen),
	.i_nrst(i_nrst),
	.i_clk (i_clk)
);

endmodule

