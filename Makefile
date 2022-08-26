TARGET=tb_uart
SOURCES?=test/${TARGET}.v

TEST_DIR=Test
OUTPUT_DIR=Debug

.PHONY: wave

all: uvm

iv_build:
	mkdir -p ./Debug
	iverilog -o ${OUTPUT_DIR}/${TARGET}.out ${SOURCES}

iv_sim: iv_build
	vvp ${OUTPUT_DIR}/${TARGET}.out

ms_build:
	vlog ${TEST_DIR}/tb_${TARGET}.sv
	#iverilog -o ${TARGET}.out ${TEST_DIR}/tb_${TARGET}.v

ms_sim: test_build
	mkdir -p ./Debug
	vsim -c tb_${TARGET}
	#vvp ${TARGET}.out

uvm:
	mkdir -p ./Debug
	vlog +incdir+${UVM_HOME}/src ${UVM_HOME}/src/uvm.sv uvm/${TARGET}.sv
	vsim +UVM_NO_RELNOTES -c -sv_lib ${UVM_HOME}/lib/uvm_dpi top -do "run -all"

clean:
	rm main *.o  
	rm -rf work  
	rm transcript   

