`timescale 1 ns / 1 ns

`include "src/rx.v"
`include "src/tx.v"
`include "src/clock_gen.v"
`include "src/uart.v"

`include "uvm_macros.svh"
`include "uvm/uart/pkg.svh"

module top;
import uvm_pkg::*;
import uart_pkg::*;

//localparam WIDTH = 8;
logic nrst, clk;

uart_intf #(.WIDTH(WIDTH)) intf(nrst, clk);

// DUT
uart DUT(//external pins
	.i_rx        (intf.rx),
	.o_tx        (intf.tx),
	// inside in the chip
	.o_rdy       (intf.rdy_rx),
	.o_mty       (intf.mty_tx),
	.o_data      (intf.rdata),
	.i_data      (intf.wdata),
	.i_re        (intf.re),
	.i_we        (intf.we),
	.i_nrst      (intf.nrst),
	.i_clk       (intf.clk)
);
defparam DUT.WIDTH_DATA = WIDTH;
defparam DUT.NB_STOP = NB_STOP;

initial
begin
	clk = 1'b1;
	nrst = 1'b0;
	@(negedge clk);
	#1 nrst = 1'b1;
end

initial
begin
	uvm_config_db#(virtual uart_intf #(.WIDTH(WIDTH)))::set(null, "*", "vif", intf);
	run_test("test");
end

initial
begin
	$dumpfile("Debug/tb_uart.vcd");
	$dumpvars;
end

initial forever #10 clk = ~clk;

endmodule

