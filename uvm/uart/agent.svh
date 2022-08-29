
class uart_agent extends uvm_agent;

	`uvm_component_utils(uart_agent)

	uvm_analysis_port #(uart_seq_item) aport;

	uvm_sequencer #(uart_seq_item) sequencer;
	uart_driver    driver;
	uart_monitor   monitor;

	function new(string name = "uart_agent", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		aport = new("aport", this);
		monitor = uart_monitor::type_id::create("monitor", this);
		if(get_is_active() == UVM_ACTIVE) begin
			driver = uart_driver::type_id::create("driver", this);
			sequencer = uvm_sequencer#(uart_seq_item)
				::type_id::create("sequencer", this);
		end
	endfunction

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		if (get_is_active() == UVM_ACTIVE) begin
			driver.seq_item_port.connect(sequencer.seq_item_export);
			//monitor.aport.connect(aport);
		end
	endfunction

	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		begin
			uart_sequence seq;
			seq = uart_sequence::type_id::create("seq");
			seq.start(sequencer);
		end
		phase.drop_objection(this);
	endtask

endclass

