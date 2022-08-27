module rx #(
	parameter WIDTH_DATA = 8,
	parameter NB_STOP = 2
) (
	// external pins
	input                   i_buf,
	// inside in the chip
	output reg              o_rdy,
	output [WIDTH_DATA-1:0] o_data,
	input                   i_re,
	input                   i_nrst,
	input                   i_clk,
	input                   clk_rx
);

localparam NB_STATE = 1 + WIDTH_DATA + NB_STOP;

reg [1:0] fr_det;
reg [1:0] start_det;
wire pe_ev = fr_det[1] && ~fr_det[0];
wire start_ev = ~start_det[1] && start_det[0];

reg [WIDTH_DATA-1:0] sipo;

reg [3:0] state;

wire c_start = 4'b0 == state && ~o_rdy && pe_ev;
wire c_sipo = pe_ev;

assign o_data = sipo;

// front detector
always @(posedge i_clk, negedge i_nrst) begin
	if (!i_nrst)
		fr_det <= 2'b0;
	else begin
		fr_det <= {clk_rx, fr_det[1]};
	end
end

// start detector
always @(posedge i_clk, negedge i_nrst) begin
	if (!i_nrst)
		start_det <= 2'b0;
	else begin
		start_det <= {i_buf, start_det[1]};
	end
end

// ready bit
always @(posedge i_clk, negedge i_nrst) begin
	if (!i_nrst)
		o_rdy <= 1'b0;
	else begin
		if (i_re)
			o_rdy <= 1'b0;

		if (WIDTH_DATA + 2 == state)
			o_rdy <= 1'b1;
	end
end

// SIPO register
always @(posedge i_clk, negedge i_nrst) begin
	if (!i_nrst)
		sipo <= {WIDTH_DATA{1'b1}};
	else begin
		if (c_sipo)
			sipo <= {i_buf, sipo[WIDTH_DATA-1:1]};
	end
end

always @(posedge i_clk, negedge i_nrst) begin

end

// state counter
always @(posedge i_clk, negedge i_nrst) begin
	if (!i_nrst)
		state <= 4'b0;
	else begin
		if (NB_STATE == state && pe_ev)
			state <= 4'b0;
		else if ((start_ev && !state) || (state && pe_ev))
			state <= state + 4'b1;
	end
end


endmodule

