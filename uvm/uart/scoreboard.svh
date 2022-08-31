
class uart_scoreboard extends uvm_scoreboard;

	`uvm_component_utils(uart_scoreboard)
	uvm_analysis_imp #(uart_seq_item, uart_scoreboard) item_analysis_imp;

	localparam STATE_STOP_LAST = WIDTH + NB_STOP - 1;
	localparam STATE_START = WIDTH + NB_STOP;

	logic start;
	logic [WIDTH-1:0] data[$];
	logic [WIDTH-1:0] data_origin;
	logic [WIDTH-1:0] data_actual; // expected
	logic tx_actual; // expected

	int clk;
	logic tx_old;
	int nd, ns;
	int state;

	function new(string name, uvm_component parent);
		super.new(name, parent);
		clk = CLK_SIZE / 2 - 2;
		state = STATE_STOP_LAST;
		tx_actual = 1;
		data_origin = {(WIDTH-1){1'b1}};
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		item_analysis_imp = new("item_analysis_imp", this);
	endfunction

	virtual function write(uart_seq_item pkt);
		if (tx_old && !pkt.tx) begin
			clk = 0;
			if (STATE_STOP_LAST == state)
				state++;
		end
		tx_old = pkt.tx;

		if (CLK_SIZE - 1 == clk++) begin
			if (WIDTH > state)
				tx_actual = data_origin[state];
			else if (WIDTH + NB_STOP > state)
				tx_actual = 1'b1;
			else
				tx_actual = 1'b0;

			if (pkt.tx != tx_actual) begin
				`uvm_error("TX", $sformatf("does not correspond to the value",
				"expected %b actual %b", tx_actual, pkt.tx))
			end
			else begin
				if (WIDTH > state)
					`uvm_info("TX", "data bit is correct", UVM_MEDIUM)
				else if (WIDTH + NB_STOP > state)
					`uvm_info("TX", "STOP bit is correct", UVM_MEDIUM)
				else
					`uvm_info("TX", "START bit is correct", UVM_MEDIUM)
			end

			if (STATE_STOP_LAST != state)
				state++;
			if (STATE_START + 1 == state)
				state = 0;
			clk = 0;
		end

		if (pkt.we) begin
			data_origin = pkt.wdata;
			`uvm_info("TX", $sformatf("write data %b", data_origin), UVM_MEDIUM)
		end

		/*
		if (pkt.rdy_rx) begin
			if (pkt.rdata != data_origin)
				`uvm_error("RX", "does not correspond to the value")
			else
				`uvm_info("RX", "the data is correct", UVM_MEDIUM)
		end
		*/

//			data.push_back(pkt.wdata);
//		if (pkt.overflow) begin
//			`uvm_info(get_type_name(), "OVERFLOW", UVM_MEDIUM)
//			`uvm_error(get_type_name(), "data don't match")
//		end
	endfunction

	virtual task run_phase(uvm_phase phase);
		uart_seq_item rb_pkt;
	endtask

endclass

