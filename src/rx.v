module rx #(
	parameter WIDTH_DATA = 8
) (
	// external pins
	input                   i_rx,
	// inside in the chip
	output                  o_rdy,
	output [WIDTH_DATA-1:0] o_data,
	input                   i_re,
	input                   i_nrst,
	input                   i_clk
);

reg [WIDTH_DATA-1:0] sipo, rx;


endmodule

