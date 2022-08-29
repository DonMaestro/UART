
module tx #(
	parameter WIDTH_DATA = 8,
	parameter NB_STOP = 2
) (
	// external pins
	output reg              o_buf,
	// inside in the chip
	output reg              o_mty,
	input                   i_we,
	input  [WIDTH_DATA-1:0] i_data,
	input                   i_nrst,
	input                   i_clk, clk_tx
);

localparam NB_STATE = 1 + WIDTH_DATA + NB_STOP;

reg [1:0] fr_det;
wire pe_ev = fr_det[1] && ~fr_det[0];

reg load;

reg [WIDTH_DATA-1:0] piso;

reg [3:0] state;

wire c_start = 4'b0 == state && ~o_mty && pe_ev;
wire c_pise = pe_ev && 4'b0 != state;

//tx_ctrl m_tx_ctrl();
//control
//always @(*) begin
//end

// front detector
always @(posedge i_clk, negedge i_nrst) begin
	if (!i_nrst)
		fr_det <= 2'b0;
	else begin
		fr_det <= {clk_tx, fr_det[1]};
	end
end

// busy bit
always @(*) o_mty = 4'b0 == state && !load;
always @(posedge i_clk, negedge i_nrst) begin
	if (!i_nrst)
		load <= 1'b0;
	else begin
		if (i_we)
			load <= 1'b1;

		if (c_start)
			load <= 1'b0;
	end
end

// PISO register
always @(posedge i_clk, negedge i_nrst) begin
	if (!i_nrst)
		piso <= {WIDTH_DATA{1'b1}};
	else begin
		if (i_we) // load piso
			piso <= i_data;
		else if (c_pise)
			piso <= {1'b1, piso[WIDTH_DATA-1:1]};
	end
end
	
// output buffer
always @(posedge i_clk, negedge i_nrst) begin
	if (!i_nrst) // async set
		o_buf <= 1'b1;
	else begin
		if (c_start) // sync reset
			o_buf <= 1'b0;
		else if (c_pise)
			o_buf <= piso[0];
	end
end

// state counter
always @(posedge i_clk, negedge i_nrst) begin
	if (!i_nrst)
		state <= 4'b0;
	else begin
		if (NB_STATE - 1 == state && pe_ev)
			state <= 4'b0;
		else if ((c_start || state) && pe_ev)
			state <= state + 4'b1;
	end
end

endmodule

