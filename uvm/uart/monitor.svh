
class uart_monitor extends uvm_monitor;

	`uvm_component_utils(uart_monitor)

	uvm_analysis_port #(uart_seq_item) aport;
	virtual uart_intf #(.WIDTH(WIDTH)) vif;
	uart_seq_item tx;

	int clk;

	function new(string name, uvm_component parent);
		super.new(name, parent);
		tx = new();
		aport = new("aport", this);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if (!uvm_config_db #(virtual uart_intf #(.WIDTH(WIDTH)))
			::get(this, "", "vif", vif)) begin
			`uvm_fatal(get_type_name(), "DUT interface not found")
		end
	endfunction

	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		//`uvm_warning(get_type_name(), "RUN PHASE")
		tx = uart_seq_item::type_id::create("tx", this);
		fork
			forever @(negedge vif.rx) begin
				`uvm_info("RX", "negedge", UVM_MEDIUM)
				clk = 0;
			end
			forever @(posedge vif.clk) begin
				tx.wdata    = vif.wdata;
				tx.we       = vif.we;
				tx.rdata    = vif.rdata;
				tx.rdy_rx   = vif.rdy_rx;
				tx.mty_tx   = vif.mty_tx;
				tx.re       = vif.re;

				tx.rx = vif.rx;
				tx.tx = vif.tx;
				//if (!tx.rdy_rx && vif.rdy_rx)

				aport.write(tx);
			end
		join_none
	endtask
endclass

