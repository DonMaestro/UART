module rx #(
	parameter WIDTH_DATA = 8
) (
	// external pins
	input                   i_rx,
	// inside in the chip
	output reg              o_rdy,
	output [WIDTH_DATA-1:0] o_data,
	output                  o_srst_clk,
	input                   i_re,
	input                   i_nrst,
	input                   i_clk,
	input                   clk_rx
);

localparam [3:0] STATE_DATA_FIRST = 0;
localparam [3:0] STATE_DATA_LAST  = WIDTH_DATA - 1;
localparam [3:0] STATE_STOP       = STATE_DATA_LAST + 1;
localparam [3:0] STATE_IDLE       = STATE_STOP + 1;
localparam [3:0] STATE_START      = STATE_IDLE + 1;

wire i_buf;

reg detr_clk_front;
reg detr_start;
//reg ev_ne;

reg [WIDTH_DATA-1:0] sipo;

reg [3:0] state;

wire ev_pe = clk_rx && ~detr_clk_front;
wire ev_ne = ~i_buf && detr_start;
wire en_sipo = ev_pe && STATE_DATA_FIRST <= state && STATE_DATA_LAST >= state;

assign o_data = sipo;
assign o_srst_clk = STATE_IDLE == state && ev_ne;


// synchronizer
`ifdef DIS_SYNC
	assign i_buf = i_rx;
`else
	reg  [1:0] dsync;

	always @(posedge i_clk, negedge i_nrst) begin
		if (!i_nrst)
			dsync <= 2'b11;
		else begin
			dsync <= {dsync[0], i_rx};
		end
	end
	assign i_buf = dsync[1];
`endif

// front detector
always @(posedge i_clk, negedge i_nrst) begin
	if (!i_nrst)
		detr_clk_front <= 1'b0;
	else begin
		detr_clk_front <= clk_rx;
	end
end

// start detector
always @(posedge i_clk, negedge i_nrst) begin
	if (!i_nrst)
		detr_start <= 1'b1;
	else begin
		detr_start <= i_buf;
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

// state counter
always @(posedge i_clk, negedge i_nrst) begin
	if (!i_nrst)
		state <= STATE_IDLE;
	else begin
		case (state)
		STATE_STOP: begin
			if (ev_ne)
				state <= ev_pe ? STATE_START : state;
			else
				state <= ev_pe ? STATE_IDLE : state;
		end
		STATE_IDLE:  state <= ev_ne ? STATE_START : state;
		STATE_START: state <= ev_pe ? STATE_DATA_FIRST : state;
		default:     state <= ev_pe ? state + 4'b1 : state;
		endcase
	end
end

endmodule

