module rx #(
	parameter WIDTH_DATA = 8,
	parameter NB_STOP = 2
) (
	// external pins
	input                   i_buf,
	// inside in the chip
	output reg              o_rdy,
	output [WIDTH_DATA-1:0] o_data,
	output                  o_srst_clk,
	input                   i_re,
	input                   i_nrst,
	input                   i_clk,
	input                   clk_rx
);

localparam STATE_DATA_FIRST = 0;
localparam STATE_DATA_LAST  = WIDTH_DATA - 1;
localparam STATE_STOP_FIRST = WIDTH_DATA;
localparam STATE_STOP_LAST  = WIDTH_DATA + NB_STOP - 1;
localparam STATE_IDLE       = STATE_STOP_LAST + 1;
localparam STATE_START      = STATE_IDLE + 1;

reg [1:0] detr_clk_front;
reg [1:0] detr_start;
reg ev_start;

reg [WIDTH_DATA-1:0] sipo;

reg [3:0] state;

wire ev_pe = detr_clk_front[1] && ~detr_clk_front[0];
wire en_sipo = ev_pe && STATE_DATA_FIRST <= state && STATE_DATA_LAST >= state;

assign o_data = sipo;
assign o_srst_clk = ev_start;

always @(*) begin
	if (STATE_STOP_LAST == state || STATE_IDLE == state)
		ev_start = ~detr_start[1] && detr_start[0];
	else
		ev_start = 1'b0;
end

// front detector
always @(posedge i_clk, negedge i_nrst) begin
	if (!i_nrst)
		detr_clk_front <= 2'b0;
	else begin
		detr_clk_front <= {clk_rx, detr_clk_front[1]};
	end
end

// start detector
always @(posedge i_clk, negedge i_nrst) begin
	if (!i_nrst)
		detr_start <= 2'b0;
	else begin
		detr_start <= {i_buf, detr_start[1]};
	end
end

// ready bit
always @(posedge i_clk, negedge i_nrst) begin
	if (!i_nrst)
		o_rdy <= 1'b0;
	else begin
		if (i_re)
			o_rdy <= 1'b0;

		if (STATE_DATA_LAST == state && ev_pe)
			o_rdy <= 1'b1;
	end
end

// SIPO register
always @(posedge i_clk, negedge i_nrst) begin
	if (!i_nrst)
		sipo <= {WIDTH_DATA{1'b1}};
	else begin
		if (en_sipo)
			sipo <= {i_buf, sipo[WIDTH_DATA-1:1]};
	end
end

always @(posedge i_clk, negedge i_nrst) begin

end

// state counter
always @(posedge i_clk, negedge i_nrst) begin
	if (!i_nrst)
		state <= STATE_IDLE;
	else begin
		case (state)
		STATE_IDLE: state <= ev_start ? STATE_START : state;
		STATE_START: state <= ev_pe ? STATE_DATA_FIRST : state;
		default: state <= ev_pe ? state + 1 : state;
		endcase
	end
end

endmodule

