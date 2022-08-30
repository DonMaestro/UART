
`include "uvm/uart/interface.svh"

package uart_pkg;
import uvm_pkg::*;

parameter WIDTH = 8;
parameter NB_STOP = 2;

`include "uvm/uart/sequence.svh"
`include "uvm/uart/driver.svh"
`include "uvm/uart/monitor.svh"
`include "uvm/uart/agent.svh"
`include "uvm/uart/scoreboard.svh"
`include "uvm/uart/env.svh"
`include "uvm/uart/test.svh"

endpackage: uart_pkg

