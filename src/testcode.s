## =========================================================================
## RISC-V 32-bit Pipelined Core Verification Test
## Supported ISA subset: add, sub, and, or, lw, lb, lh, lbu, lhu, 
##                       addi, slli, xori, srli, srai, ori, andi, sw, sb, sh, beq
## =========================================================================
#.option push
#.option nocompress
#.text
#.globl _start
#_start:
## =========================================================================
## RISC-V 32-bit Pipelined Core Verification Test
## Memory Map:
##   0x00000000 : Instruction Memory Base
##   0x00004000 : Data Memory Base
## Supported ISA: add, sub, and, or, lw, lb, lh, lbu, lhu, 
##                addi, slli, xori, srli, srai, ori, andi, sw, sb, sh, beq
## =========================================================================
#
#    # 0. Initialize Base Address for Data Memory (0x4000)
#    # Constructing 0x4000 using addi + slli to stay within the strict subset
#    addi x10, x0, 1         # x10 = 1
#    slli x10, x10, 14       # x10 = 0x00004000 (Points directly to Data Memory)
#
#    # =====================================================================
#    # PHASE 1: R-Type / I-Type Data Hazards & Forwarding
#    # =====================================================================
#    
#    # 1a. Test Immediate Logic & EX-to-EX Forwarding
#    addi x1, x0, -1         # x1 = 0xFFFFFFFF 
#    ori  x2, x0, 0x0F0      # x2 = 0x000000F0
#    andi x3, x2, 0x0FF      # x3 = 0x000000F0 (Trigger: EX-to-EX forward from x2)
#    xori x4, x3, 0x0AA      # x4 = 0x0000005A (Trigger: EX-to-EX forward from x3)
#
#    # 1b. Test MEM-to-EX Forwarding & Standard ALU
#    add  x5, x2, x3         # x5 = 0x000001E0 (Trigger: MEM-to-EX for x2, EX-to-EX for x3)
#    sub  x6, x5, x4         # x6 = 0x00000186 (Trigger: EX-to-EX for x5, MEM-to-EX for x4)
#    and  x7, x6, x2         # x7 = 0x00000080 (Trigger: EX-to-EX for x6)
#    or   x8, x7, x4         # x8 = 0x000000DA (Trigger: EX-to-EX for x7)
#
#    # 1c. Test Shifts (Logical and Arithmetic)
#    slli x9, x8, 4          # x9 = 0x00000DA0 (Logical shift left)
#    srli x11, x9, 2         # x11 = 0x00000368 (Logical shift right)
#    
#    # Setup for arithmetic shift right (requires MSB = 1 to test sign extension)
#    addi x12, x0, 1         # x12 = 1
#    slli x12, x12, 31       # x12 = 0x80000000 (Shift into MSB)
#    ori  x12, x12, 0x0A0    # x12 = 0x800000A0
#    srai x13, x12, 4        # x13 = 0xF800000A (Arithmetic shift right, MSB extended)
#
#    # =====================================================================
#    # PHASE 2: Load/Store & Load-Use Stalls (Targeting Data Memory)
#    # =====================================================================
#    
#    # 2a. Word Store/Load and the Load-Use Hazard
#    sw   x9, 0(x10)         # DataMem[0x4000] = 0x00000DA0
#    lw   x14, 0(x10)        # x14 = 0x00000DA0 
#   
#    # i think this may fail
#    # lw x14, 0(x10) 
#    # sw x12, 0(x14) 
# 
#    # >> PIPELINE STALL EXPECTED HERE <<
#    # Hazard unit must NOP 1 cycle while x14 fetches from Data Memory
#    add  x15, x14, x0       # x15 = 0x00000DA0 
#
#    # 2b. Sub-word Store/Load (Sign & Zero Extension Verification)
#    addi x16, x0, -1        # x16 = 0xFFFFFFFF
#    addi x17, x0, 0x7F      # x17 = 0x0000007F (127)
#    addi x18, x0, 0x80      # x18 = 0x00000080 (128)
#    
#    # Store layout (Little Endian):
#    sh   x16, 4(x10)        # DataMem[0x4004] = 0xFF, DataMem[0x4005] = 0xFF
#    sb   x17, 6(x10)        # DataMem[0x4006] = 0x7F
#    sb   x18, 7(x10)        # DataMem[0x4007] = 0x80
#
#    # Load and extend
#    lh   x19, 4(x10)        # x19 = 0xFFFFFFFF (Sign extended 0xFFFF)
#    lhu  x20, 4(x10)        # x20 = 0x0000FFFF (Zero extended 0xFFFF)
#    lb   x21, 7(x10)        # x21 = 0xFFFFFF80 (Sign extended 0x80)
#    lbu  x22, 7(x10)        # x22 = 0x00000080 (Zero extended 0x80)
#
#    # =====================================================================
#    # PHASE 3: Control Hazards (Branches & Flushing)
#    # =====================================================================
#    
#    # 3a. Taken Branch Test
#    addi x23, x0, 5         # x23 = 5
#    addi x24, x0, 5         # x24 = 5
#    beq  x23, x24, branch_taken # EX-to-EX/ID forwarding to branch comparator
#    
#    # >> PIPELINE FLUSH EXPECTED HERE <<
#    addi x25, x0, -1        # SHOULD FLUSH
#    sw   x25, 20(x10)       # SHOULD FLUSH (Verify DataMem[0x4014] remains untouched)
#
#branch_taken:
#    # 3b. Not-Taken Branch Test
#    addi x26, x0, 1         # x26 = 1
#    beq  x23, x26, end_fail # 5 != 1, branch NOT taken. Should fall through.
#    
#    # Safe landing (Verify this executes)
#    addi x27, x0, 0x99      # x27 = 0x00000099
#
#end_pass:
#    # Infinite loop to signal successful completion
#    beq x0, x0, end_pass
#
#end_fail:
#    # Trap for failed branches
#    addi x31, x0, -1        # x31 = 0xFFFFFFFF (Indicates failure state)
#    beq x0, x0, end_fail
#.option pop









#-----------new_by_claude------------
# =========================================================================
# RISC-V 32-bit Pipelined Core Verification Test  — Extended
# Supported ISA subset: add, sub, and, or, lw, lb, lh, lbu, lhu,
#                       addi, slli, xori, srli, srai, ori, andi,
#                       sw, sb, sh, beq, bne
# Memory Map:
#   0x00000000 : Instruction Memory Base
#   0x00004000 : Data Memory Base
# =========================================================================
.option push
.option nocompress
.text
.globl _start
_start:

    # 0. Initialize Base Address for Data Memory (0x4000)
    addi x10, x0, 1          # x10 = 1
    slli x10, x10, 14         # x10 = 0x00004000

    # =====================================================================
    # PHASE 1: R-Type / I-Type Data Hazards & Forwarding
    # =====================================================================

    addi x1,  x0, -1          # x1  = 0xFFFFFFFF
    ori  x2,  x0, 0x0F0       # x2  = 0x000000F0
    andi x3,  x2, 0x0FF       # x3  = 0x000000F0  (EX-to-EX fwd x2)
    xori x4,  x3, 0x0AA       # x4  = 0x0000005A  (EX-to-EX fwd x3)
    add  x5,  x2, x3          # x5  = 0x000001E0  (MEM-to-EX x2, EX-to-EX x3)
    sub  x6,  x5, x4          # x6  = 0x00000186
    and  x7,  x6, x2          # x7  = 0x00000080
    or   x8,  x7, x4          # x8  = 0x000000DA
    slli x9,  x8, 4            # x9  = 0x00000DA0
    srli x11, x9, 2            # x11 = 0x00000368
    addi x12, x0, 1            # x12 = 1
    slli x12, x12, 31          # x12 = 0x80000000
    ori  x12, x12, 0x0A0       # x12 = 0x800000A0
    srai x13, x12, 4           # x13 = 0xF800000A

    # =====================================================================
    # PHASE 2: Load/Store & Load-Use Stalls
    # =====================================================================

    sw   x9,  0(x10)           # mem[0x4000] = 0x00000DA0
    lw   x14, 0(x10)           # x14 = 0x00000DA0  (load-use stall)
    add  x15, x14, x0          # x15 = 0x00000DA0  (uses stalled load result)

    addi x16, x0, -1           # x16 = 0xFFFFFFFF
    addi x17, x0, 0x7F         # x17 = 0x0000007F
    addi x18, x0, 0x80         # x18 = 0x00000080

    sh   x16, 4(x10)           # mem[0x4004..5] = 0xFF 0xFF
    sb   x17, 6(x10)           # mem[0x4006]    = 0x7F
    sb   x18, 7(x10)           # mem[0x4007]    = 0x80

    lh   x19, 4(x10)           # x19 = 0xFFFFFFFF  (sign-ext 0xFFFF)
    lhu  x20, 4(x10)           # x20 = 0x0000FFFF  (zero-ext 0xFFFF)
    lb   x21, 7(x10)           # x21 = 0xFFFFFF80  (sign-ext 0x80)
    lbu  x22, 7(x10)           # x22 = 0x00000080  (zero-ext 0x80)

    # =====================================================================
    # PHASE 3: Control Hazards — BEQ taken & not-taken
    # =====================================================================

    addi x23, x0, 5            # x23 = 5
    addi x24, x0, 5            # x24 = 5
    beq  x23, x24, p3_taken    # taken  -> flush next 2

    addi x25, x0, -1           # MUST FLUSH
    sw   x25, 20(x10)          # MUST FLUSH

p3_taken:
    addi x26, x0, 1            # x26 = 1
    beq  x23, x26, end_fail    # 5 != 1, NOT taken -> fall through
    addi x27, x0, 0x99         # x27 = 0x00000099  (must execute)

    # =====================================================================
    # PHASE 4: Forwarding Stress — 5-deep EX-to-EX chain
    # Each instruction depends on the immediately preceding result
    # =====================================================================

    addi x28, x0,  1           # x28 = 1
    addi x28, x28, 1           # x28 = 2  (EX-to-EX)
    addi x28, x28, 1           # x28 = 3  (EX-to-EX)
    addi x28, x28, 1           # x28 = 4  (EX-to-EX)
    addi x28, x28, 1           # x28 = 5  (EX-to-EX)
    # x28 = 0x00000005

    # =====================================================================
    # PHASE 5: Store with Tight Forwarding on rs2
    # The store's data (rs2) is produced by the immediately preceding ADDI
    # This tests that the forwarding unit resolves rs2 for stores
    # =====================================================================

    addi x29, x0, 0x42         # x29 = 0x42
    sw   x29, 8(x10)           # mem[0x4008] = 0x42  (rs2=x29 forwarded)
    lw   x28, 8(x10)           # x28 = 0x42  (verify store landed correctly)
    # x28 = 0x00000042

    # =====================================================================
    # PHASE 6: Load -> Branch
    # The branch operand is the result of the immediately preceding load
    # Hazard unit must stall AND forwarding must feed the branch comparator
    # =====================================================================

    sw   x9,  12(x10)          # mem[0x400C] = 0x00000DA0
    lw   x29, 12(x10)          # x29 = 0x00000DA0  (load-use stall)
    # now use x29 immediately as a branch operand
    beq  x29, x9, p6_taken     # 0xDA0 == 0xDA0 -> taken, flush next instr

    addi x28, x0, -1           # MUST FLUSH  (x28 must stay 0x42 from phase 5)

p6_taken:
    # x28 still = 0x00000042 if flush worked
    # (no new write to x28 here — watchpoint checks it stayed 0x42)

    # =====================================================================
    # PHASE 7: Load -> Store
    # Loaded value immediately used as store data (rs2 = load result)
    # Tests WB-to-MEM forwarding for stores
    # =====================================================================

    lw   x28, 0(x10)           # x28 = 0x00000DA0  (load-use stall)
    sw   x28, 16(x10)          # mem[0x4010] = 0x00000DA0  (rs2 forwarded from load WB)
    lw   x29, 16(x10)          # x29 = 0x00000DA0  (verify)
    # x28 = 0x00000DA0
    # x29 = 0x00000DA0

    # =====================================================================
    # PHASE 8: BNE — Taken and Not-Taken
    # =====================================================================

    addi x28, x0, 7            # x28 = 7
    addi x29, x0, 3            # x29 = 3
    bne  x28, x29, p8_bne_taken  # 7 != 3 -> taken, flush next instr

    addi x30, x0, -1           # MUST FLUSH

p8_bne_taken:
    addi x30, x0, 0xAB         # x30 = 0x000000AB  (must execute)
    bne  x28, x28, end_fail    # 7 == 7 -> NOT taken, fall through
    addi x29, x0, 0xCD         # x29 = 0x000000CD  (must execute)
    # x28 = 0x00000007
    # x29 = 0x000000CD
    # x30 = 0x000000AB

    # =====================================================================
    # PHASE 9: Shift Corner Cases — shift by 0 and shift by 31
    # =====================================================================

    slli x28, x1, 0            # x28 = 0xFFFFFFFF  (shift by 0, passthrough)
    srli x29, x1, 31           # x29 = 0x00000001  (logical, unsigned MSB only)
    srai x30, x12, 31          # x30 = 0xFFFFFFFF  (arith, all sign bits, x12=0x800000A0)

    # =====================================================================
    # PHASE 10: ALU Corner Values — overflow, AND/OR with zero
    # =====================================================================

    add  x28, x1, x17          # x28 = 0xFFFFFFFF + 0x7F = 0x0000007E  (wrap)
    sub  x29, x0, x17          # x29 = 0x00000000 - 0x7F = 0xFFFFFF81  (negate)
    and  x30, x1, x0           # x30 = 0xFFFFFFFF & 0x00000000 = 0x00000000
    or   x28, x0, x1           # x28 = 0x00000000 | 0xFFFFFFFF = 0xFFFFFFFF

end_pass:
    beq  x0, x0, end_pass      # infinite loop — successful completion

end_fail:
    addi x31, x0, -1           # x31 = 0xFFFFFFFF — failure trap
    beq  x0, x0, end_fail

.option pop
