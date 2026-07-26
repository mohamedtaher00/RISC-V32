


# RV32I Pipelined Processor with UART Interface



## Overview

A 5-stage pipelined RV32I processor implemented in Verilog, targeting the **Cyclone IV FPGA** (Intel/Altera), featuring a memory-mapped UART peripheral, an address decoder, and byte/halfword load masking — enabling the processor to communicate over serial.

The design achieves **112.6 MHz** on Cyclone IV with a 20 ns clock period constraint (`top.sdc`).


## Architecture

```
         ┌──────┐   ┌──────┐   ┌──────┐   ┌──────┐   ┌──────┐
PC  ────►│  IF  │──►│  ID  │──►│  EX  │──►│ MEM  │──►│  WB  │
         └──────┘   └──────┘   └──────┘   └──────┘   └──────┘
           BHT       RegFile     ALU      Addr Dec    MaskLoad
                     ImmGen      FwdUnit  DataMem      WBmux
           IMEM      CtrlUnit    HazDet   UART
```

### Pipeline stages

| Stage | Key modules |
|-------|-------------|
| **IF** | `prog_count`, `instr_mem_wrapper`, `bht` (2-bit branch predictor) |
| **ID** | `control_unit`, `reg_file`, `immgen`, hazard detection |
| **EX** | `alu`, `alu_control`, `forwarding_unit` |
| **MEM** | `data_mem_wrapper`, `uart`, `address_decoder` |
| **WB** | `mask_loads`, write-back mux |

### Pipeline registers

All inter-stage state is packed into wide bus vectors and documented at the top of `src/top.v`:

| Register | Width | Contents |
|----------|-------|----------|
| `if_id`  | 103 b | PC, instruction, BHT prediction, low PC bits |
| `id_ex`  | 259 b | Control signals, PC, rs1/rs2 data, imm, register addresses, ALU ctrl, return addr, prediction |
| `ex_mem` | 155 b | Control signals, return addr, zero flag, ALU result, store data, rd, branch mispredict, prev_predition_addr, final_verdict, funct3, rs2 |
| `mem_wb` | 81 b  | Control signals, read data, ALU result, rd, mispredict flag, branch, funct3 |

---

## Memory Map

| Address Range | Region | Size |
|---|---|---|
| `0x0000_0000 – 0x0000_3FFF` | Instruction Memory | 16 KB |
| `0x0000_4000 – 0x0000_6FFF` | Data Memory | 12 KB |
| `0x8000_0000 – 0x8000_000F` | UART registers | 16 B |
| `0x8000_0010 – 0x8000_001F` | GPIO registers | 16 B |

---

## UART Peripheral

The UART sits at `0x8000_0000` and is accessible from software via normal `sw`/`lw` instructions. It exposes a 16-byte register file:

| Offset | Register | Description |
|--------|----------|-------------|
| `+0x0` | TX Data | Byte to transmit (written by `tx` module) |
| `+0x4` | RX Data | Received byte (written by `rx` module) |
| `+0x8` | Status | `[2]` rx_err · `[1]` rx_done · `[0]` tx_done |
| `+0xC` | Control | `[2]` rst · `[1]` tx_en · `[0]` rx_en |

The baud rate is derived from the system clock using a hard-coded baud divisor in `tx.v` and `rx.v` (`0x28B0` = 10416 cycles, corresponding to **9600 baud at ~100 MHz** system clock). The RX module uses a 1.5× oversampling period (`0x3D18`) for start-bit centering.

The `rx` module is a 5-state FSM: `IDLE → START → DATA → DONE/ERR`.

---

## Hazard Handling

| Hazard | Mechanism |
|--------|-----------|
| Load-use | `hazard_detection_unit` inserts a 1-cycle stall + NOP bubble |
| Control (branch) | 2-bit saturating BHT; misprediction flushes using `branch_mispredicted_mem` |
| Data (RAW) | `forwarding_unit` with EX→EX and MEM→EX forwarding paths |

The BHT uses 32 entries indexed by the 5 low-order PC bits, each holding a 2-bit saturating counter (`strong_not_taken / weak_not_taken / weak_taken / strong_taken`).

---

## Source Tree

```
RISC-V32/
├── src/
│   ├── top.v                  # Top-level integration
│   ├── prog_count.v           # Program counter
│   ├── instr_mem_wrapper.v    # Instruction memory (M9K wrapper)
│   ├── data_mem_wrapper.v     # Data memory (M9K wrapper)
│   ├── instruction_mem.v      # Raw instruction memory
│   ├── data_mem.v             # Raw data memory
│   ├── control_unit.v         # Main decode/control
│   ├── alu.v                  # 32-bit ALU
│   ├── alu_control.v          # ALU function decoder
│   ├── reg_file.v             # 32×32 register file (write-first)
│   ├── immgen.v               # Immediate generator
│   ├── forwarding_unit.v      # EX/MEM forwarding
│   ├── hazard_detection_unit.v
│   ├── bht.v                  # 2-bit branch history table
│   ├── address_decoder.v      # Memory-mapped address decode
│   ├── uart.v                 # UART wrapper + register file
│   ├── tx.v                   # UART transmitter
│   ├── rx.v                   # UART receiver (FSM)
│   ├── mask_loads.v           # lb/lh/lbu/lhu byte-masking
│   ├── rca.v                  # Ripple-carry adder (branch target)
│   ├── full_adder.v
│   ├── half_adder.v
│   ├── program.mem            # Default program image
│   ├── table.mem / reg_file_table.mem / data_mem_table.mem
│   ├── bht.mem                # BHT initial state
│   └── Makefile
├── sim/
│   ├── top_tb.v               # Top-level testbench
│   ├── forwarding_unit_tb.v
│   ├── data_mem_tb.v
│   └── instruction_mem_tb.v
└── top.sdc                    # Timing constraint (20 ns / 50 MHz base)
```

---

## Simulation

The `Makefile` in `src/` automates the full assembly → simulation flow:

```bash
# Assemble, convert to MIF, and simulate
make SRC=testcode.s

# Open waveform viewer (GTKWave)
make wave

# Clean build artifacts
make clean
```

**Toolchain required:**
- `riscv64-unknown-elf-as` (GNU Binutils for RV32I)
- `riscv32-unknown-linux-gnu-objdump`
- `srec_cat` (srecord)
- ModelSim (with `altera_mf_ver` library for M9K simulation)
- GTKWave (optional, for waveforms)

The flow: `.s` → GNU assembler → `objdump` + `awk` → `.hex` → `srec_cat` → `.mif` → ModelSim.

---

## FPGA Target

| Parameter | Value |
|-----------|-------|
| Board | Cyclone IV (Altera/Intel) |
| Tools | Quartus Prime |
| Clock constraint | 20 ns (`top.sdc`) |
| Achieved Fmax | ~112.6 MHz |
| Memory | Intel M9K blocks (instruction + data memory wrappers) |

---

## Branch Status

This branch (`interfacing`) adds UART I/O on top of the pipelined core. Pending before merge to `main`:

- [ ] GPIO peripheral implementation
- [ ] Bootloader integration (see `feature/bootloader` branch)
- [ ] Full UART loopback / integration test in simulation
- [ ] Final timing closure pass in Quartus

---

