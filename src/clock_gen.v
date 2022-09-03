
module clock_gen #(
	parameter WIDTH = 9,
	parameter SIZE = 434
) (
	output o_clk,
	input  i_srst,
	input  i_nrst,
	input  i_clk
);

localparam [WIDTH-1:0] ONE = 1;
reg [WIDTH-1:0] cnt;

assign o_clk = cnt == 0;

always @(posedge i_clk, negedge i_nrst) begin
	if (!i_nrst)
		cnt <= {WIDTH{1'b0}};
	else begin
		if (i_srst)
			cnt <= 4;
		else begin
			if (SIZE - 1 == cnt)
				cnt <= {WIDTH{1'b0}};
			else
				cnt <= cnt + ONE;
		end
	end
end

endmodule

