
class uart_seq_item extends uvm_sequence_item;

	`uvm_object_utils(uart_seq_item)

             logic             rx;
             logic             tx;
	rand logic [WIDTH-1:0] wdata;
	rand logic             re, we;
	     logic [WIDTH-1:0] rdata;
             logic             rdy_rx;
             logic             mty_tx;
	     logic             rst, clk;

	/*
	`uvm_object_utils_begin(uart_seq_item)
		`uvm_field_int(wdata, UVM_ALL_ON)
		`uvm_field_int(re, UVM_ALL_ON)
		`uvm_field_int(we, UVM_ALL_ON)
	`uvm_object_utils_end
	*/

	function new(string name = "uart_seq_item");
		super.new(name);
	endfunction

endclass: uart_seq_item


class uart_sequence extends uvm_sequence#(uart_seq_item);

	`uvm_object_utils(uart_sequence)

	int unsigned n_times = 3000;

	function new(string name = "uart_sequence");
		super.new(name);
	endfunction

	// task pre_body
	// task post_body
	virtual task body;
		repeat (n_times) begin
			req = uart_seq_item::type_id::create("req");
			start_item(req);
			//`uvm_create(req);
			req.wdata = $urandom;
			req.we    = $urandom;
			req.re    = $urandom;
			//`uvm_send(req);
			//wait_for_item_done();
			finish_item(req);
		end
	endtask: body

endclass: uart_sequence

