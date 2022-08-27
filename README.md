# UART

![uart](docs/img/UART.png)

## Dependencies

### Requirements

- Modelsim or [Icarus Verilog][1]

### Recommends

- [UVM][uvm](requires Modelsim)

## Building

```bash
$ git clone https://github.com/DonMaestro/UART.git
$ cd UART
```

### UVM

```bash
$ make uvm_test TARGET=module_name
```

## DOCUMENTATION(EN/[UA][4])

[1]: http://iverilog.icarus.com/
[4]: docs/ua/README.md
[uvm]: https://www.accellera.org/downloads/standards/uvm

## Repository tree
```bash
.
├── docs
│   ├── img
│   │   └── ...
│   ├── Makefile
│   ├── ua
│   │   ├── README.md
│   │   └── ...
│   └── src
│       └── ...
├── Makefile
├── README.md
├── src
│   ├── uart.v
│   └── ...
├── test
│   ├── tb_uart.v
│   └── ...
├── uvm
│   ├── uart
│   │   ├── agent.svh
│   │   ├── driver.svh
│   │   ├── env.svh
│   │   ├── interface.svh
│   │   ├── pkg.svh
│   │   ├── scoreboard.svh
│   │   ├── sequence.svh
│   │   └── test.svh
│   ├── uart.sv
│   └── ...
└── ...
```

