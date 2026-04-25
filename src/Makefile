# Config
AS = riscv64-unknown-elf-as 
OBJDUMP = riscv32-unknown-linux-gnu-objdump
SRC     ?= testcode.s       # change as needed
HEX     ?= table.hex         # change as needed
MIF     ?= table.mif

# Default target: full flow
all: sim

# Stream 1: .s → .hex → .mif
$(HEX): $(SRC)
	$(AS) -march=rv32i $(SRC) -o code.o  
	$(OBJDUMP) -d code.o | awk '$$2 ~ /^[0-9a-f]+$$/ { \
		code = $$2; pad = 8 - length(code); \
		while (pad-- > 0) code = "0" code; print code }' > $(HEX)
	rm code.o

$(MIF): $(HEX)
	srec_cat $(HEX) -vmem --line-length 20 -o $(MIF) -mif 32

# Stream 2: compile, simulate, view
sim: $(MIF)
	vlog *.v
	vsim -L altera_mf_ver -c -do "run -all;quit" top_tb > log.log

wave:
	GTK_THEME=Adwaita:dark gtkwave top_dump.vcd top.gtkw

clean:
	rm -f code.o $(HEX) $(MIF) *.vcd log.log work/ -r

.PHONY: all sim wave clean
