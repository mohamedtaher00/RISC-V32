# This assembler code tests the basic interface between the CPU and the bootloader
#
# The UART is at 0x80000000 and ends at 0x8000000F

# At the start, I suggest that the RX register is initialized with some random value so that we can read it.

# s2 (x18) -> 0x80000000
# s3 (x19) -> 1
# s4 (x20) -> 2
# s5 (x21) -> 4
# s6 (x22) -> 0x00000055
# s7 (x23) -> -1 
# s8 (x24) -> 3

# Test from UART -> CPU (CPU reads)

# Reset the UART
sw s5, 12(s2) #100 -> CON
sw x0, 12(s2) #000 -> CON

# Enable reception
sw s3, 12(s2) # 001 -> CON

# Test reading the RX register 
lw t0, 4(s2) 
# Test reading the STATUS register
lw t0, 8(s2)
# Test reading specific bits from the STATUS register
# err_rx
and t1, t0, s3 # 110 and 001 = 000
# done_rx
and t1, t0, s4 # 110 and 010 = 010 >> 1 = 1
# done_tx
and t1, t0, s5

# Test writing to the TX register

# First test writing without enable
sw s6, 0(s2)
add x0, x0, x0 # nop
add x0, x0, x0 # nop
add x0, x0, x0 # nop

# Test writing properly
sw s6, 0(s2)
add x0, x0, x0 # nop
sw s8, 12(s2) # TX enable = 1 # 011

# Test sending 4 words in a row
	mv t2, s5
loop:
	beq x0, t2, done	
	sw s6, 0(s2)
	add t2, t2, s7 # s7 = -1 
	beq x0, x0, loop	
done:
