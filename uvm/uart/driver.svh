
class uart_driver extends uvm_driver #(uart_seq_item);

	`uvm_component_utils(uart_driver)

	virtual uart_intf #(.WIDTH(WIDTH)) vif;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if (!uvm_config_db#(virtual uart_intf #(.WIDTH(WIDTH)))::get(this, "", "vif", vif))
			`uvm_fatal(get_type_name(), "Could not get vif")
	endfunction

	task run_phase(uvm_phase phase);
//		vif.rst = 1'b0;
//		@(posedge vif.clk);
//		#1
//		vif.rst = 1'b1;
		forever begin
			seq_item_port.get_next_item(req);

			vif.rx = vif.tx;

			vif.wdata = req.wdata;

			vif.we = req.we;
			if (!vif.mty_tx)
				vif.we = 1'b0;

			vif.re = req.re;
			if (!vif.rdy_rx)
				vif.re = 1'b0;

			seq_item_port.item_done();
			@(posedge vif.clk);
		end
	endtask

endclass

