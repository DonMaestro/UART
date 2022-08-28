
class uart_monitor extends uvm_monitor;

	`uvm_component_utils(uart_monitor)

	uvm_analysis_port #(uart_seq_item) aport;
	virtual uart_intf #(.WIDTH(WIDTH)) vif;
	uart_seq_item tx;

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
		forever
		begin
			@(posedge vif.clk);
			tx = uart_seq_item::type_id::create("tx", this);
			tx.rx       = vif.rx;
			tx.tx       = vif.tx;
			tx.wdata    = vif.wdata;
			tx.we       = vif.we;
			tx.rdata    = vif.rdata;
			tx.rdy_rx   = vif.rdy_rx;
			tx.mty_tx   = vif.mty_tx;
			tx.re       = vif.re;
			aport.write(tx);
		end
	endtask
endclass

