
interface uart_intf #(parameter WIDTH = 4)
                    (input nrst, clk);
        logic             rx;
        logic             tx;
        // inside in the chip
        logic             rdy_rx;
        logic             mty_tx;
	logic [WIDTH-1:0] rdata;
	logic [WIDTH-1:0] wdata;
	logic             re, we;
endinterface

