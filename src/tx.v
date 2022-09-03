
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

localparam [3:0] STATE_DATA_FIRST = 0;
localparam [3:0] STATE_DATA_LAST  = WIDTH_DATA - 1;
localparam [3:0] STATE_STOP_FIRST = WIDTH_DATA;
localparam [3:0] STATE_STOP_LAST  = WIDTH_DATA + NB_STOP - 1;
localparam [3:0] STATE_IDLE       = STATE_STOP_LAST + 1;
localparam [3:0] STATE_START      = STATE_IDLE + 1;

reg [1:0] detr_clk_front;
wire ev_pe = detr_clk_front[1] && ~detr_clk_front[0];
reg ev_start;

reg load;

reg [WIDTH_DATA-1:0] piso;

reg [3:0] state;

wire en_piso = ev_pe && (STATE_DATA_FIRST <= state && STATE_DATA_LAST >= state || STATE_START == state);

always @(*) begin
	if (STATE_STOP_LAST == state || STATE_IDLE == state)
		ev_start = ev_pe && load;
	else
		ev_start = 1'b0;

	if (STATE_STOP_FIRST <= state && STATE_IDLE >= state)
		o_mty = !load;
	else
		o_mty = 1'b0;

end

//tx_ctrl m_tx_ctrl();
//control
//always @(*) begin
//end

// front detector
always @(posedge i_clk, negedge i_nrst) begin
	if (!i_nrst)
		detr_clk_front <= 2'b0;
	else begin
		detr_clk_front <= {clk_tx, detr_clk_front[1]};
	end
end

// busy bit
always @(posedge i_clk, negedge i_nrst) begin
	if (!i_nrst)
		load <= 1'b0;
	else begin
		if (i_we)
			load <= 1'b1;

		if (ev_start)
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
		else if (en_piso)
			piso <= {1'b1, piso[WIDTH_DATA-1:1]};
	end
end
	
// output buffer
always @(posedge i_clk, negedge i_nrst) begin
	if (!i_nrst) // async reset
		o_buf <= 1'b1;
	else begin
		if (ev_start) // sync reset
			o_buf <= 1'b0;
		else if (en_piso)
			o_buf <= piso[0];
		else if (STATE_STOP_FIRST <= state && STATE_IDLE >= state)
			o_buf <= 1'b1;
	end
end

// state counter
always @(posedge i_clk, negedge i_nrst) begin
	if (!i_nrst)
		state <= STATE_STOP_FIRST;
	else begin
		case (state)
		STATE_STOP_LAST: state <= ev_start ? STATE_START : state;
		STATE_IDLE: state <= ev_start ? STATE_START : state;
		STATE_START: state <= ev_pe ? STATE_DATA_FIRST : state;
		default: state <= ev_pe ? state + 4'b1 : state;
		endcase
	end
end

endmodule

