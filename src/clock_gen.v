
module clock_gen #(
	parameter ICLK = 50000,
	parameter BAUN = 9600
) (
	output o_clk,
	input  i_nrst,
	input  i_clk
);

localparam WIDTH = 4;
localparam SIZE = 2 ** WIDTH;

reg [WIDTH-1:0] cnt;

assign o_clk = cnt[WIDTH-1];

always @(posedge i_clk, negedge i_nrst) begin
	if (!i_nrst)
		cnt <= {WIDTH{1'b0}};
	else begin
		if (SIZE - 1 == cnt)
			cnt <= {WIDTH{1'b0}};
		else
			cnt <= cnt + 1;
	end
end

endmodule

