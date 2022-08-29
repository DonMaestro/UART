
class uart_scoreboard extends uvm_scoreboard;

	`uvm_component_utils(uart_scoreboard)
	uvm_analysis_imp #(uart_seq_item, uart_scoreboard) item_analysis_imp;

	logic start;
	logic [WIDTH-1:0] data[$];
	logic [WIDTH-1:0] data_origin;
	logic [WIDTH-1:0] data_actual; // expected

	int clk;
	logic tx_old;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		item_analysis_imp = new("item_analysis_imp", this);
	endfunction

	virtual function write(uart_seq_item pkt);
		if (15 == clk++) begin
			data_actual = {pkt.tx, data_actual};
		end

		if (!tx_old && pkt.tx)
			clk = 1;
		tx_old = pkt.tx;

		if (pkt.we)
			data_origin = pkt.wdata;

		if (pkt.mty_tx) begin
			if (data_actual != data_origin)
				`uvm_error("TX", "does not correspond to the value")
			else
				`uvm_info("TX", "the data is correct", UVM_MEDIUM)
		end

		if (pkt.rdy_rx) begin
			if (pkt.rdata != data_origin)
				`uvm_error("RX", "does not correspond to the value")
			else
				`uvm_info("RX", "the data is correct", UVM_MEDIUM)
		end

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

