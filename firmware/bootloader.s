# Set up a basic read-only bootloader in the top of memory. It sets up execution by loading a program from
# user terminal through UART and then sets execution at the start of the text.
# RISC-V CPU jumps here on boot/reset 

# The binary format used

# ------------------------------------------
# | MAGIC | SIZE | 		  PROGRAM          |
# ------------------------------------------

# Supported instructions: lw, sw, beq, add, sub, and, or, addi, lui, jal, jal, andi, lb, sb

# Memory map
##
# 0x00 00 00 00 	0x00 00 08 00		Bootloader (2 KiB)		[ Text ]
# 0x00 00 08 00 	0x00 00 3F FF		Program (11700 bytes)	
# 0x00 00 40 00		0x00 00 6F FF		Data
# 0x00 00 70 00		0x00 00 7F FF		Stack
# 0x80 00 00 00		0x80 00 00 0F		UART
# 0x80 00 00 10		0x80 00 00 1F		GPIO

STACK_BASE  = 0x00008000
PROG_START	= 0x00000800
UART_BASE   = 0x80000000
GPIO_BASE   = 0x80000010
UART_TX     = UART_BASE + 0x00 
UART_RX     = UART_BASE + 0x04 
UART_STATUS = UART_BASE + 0x08
UART_CTRL   = UART_BASE + 0x0C

.set UART_RX_DONE, 0x02
.set UART_TX_DONE, 0x04
.set UART_RX_ERR , 0x01
.set UART_RST    , 0x04
.set UART_TX_EN  , 0x02
.set UART_RX_EN  , 0x01
.set SYNC_WORD   , 0xEF

# Reset vector jumps here
entry:
	li sp, STACK_BASE
	jal ra, uart_reset
	jal ra, wait_sync
	jal ra, read_byte # Read size
	add s0, a0, zero
	beq s0, zero, err
	li s1, PROG_START

# Store the program from UART to the text section of the memory
receive_loop:
    beq s0, zero, done_loading
    jal read_byte
    sb a0, 0(s1)
    addi s1, s1, 1
    addi s0, s0, -1
    jal x0, receive_loop

# Jump to the start of the program
done_loading:
	li t1, PROG_START
    jalr x0, t1, 0

## Helpers

# Read a word from the UART
read_byte:
	addi sp, sp, -4
	sw ra, 0(sp)
    li t0, UART_BASE
    li t1, UART_RX
wait_rx:
	jal ra, read_verify
    lb a0, 0(t1)
	lw ra, 0(sp)
	addi sp, sp, 4
    jalr x0, ra, 0


# Wait for magic word from the UART
wait_sync:
	addi sp, sp, -4
	sw ra, 0(sp)
    li t2, SYNC_WORD
wait_loop:
    jal ra, read_byte
    beq a0, t2, sync_found
    jal x0, wait_loop
sync_found:
	lw ra, 0(sp)
	addi sp, sp, 4
    jalr x0, ra, 0


# Reset the UART
uart_reset:
	addi sp, sp, -8
	sw s1, 0(sp)
	sw s2, 4(sp)

	li s1, UART_CTRL
	li s2, UART_RST
	sb s2, 0(s1) #100 -> CON
	sb x0, 0(s1) #000 -> CON

	lw s1, 0(sp)
	lw s2, 4(sp)
	addi sp, sp, 8
	jalr x0, ra, 0


# Verify UART read or spin if no confirmation
# clear the status register
read_verify:
	li t1, UART_STATUS
	li t3, UART_RX_ERR # mask to check error
loop:
	lw t2, 0(t1)
	andi t2, t2, UART_RX_ERR
	beq t2,t3,err
	andi t4, t2, UART_RX_DONE
	beq t4, zero, loop # loop until received
	sb zero, 0(t1) # clear the flag
	jalr x0, ra, 0

# Enable the UART transmitter
tx_enable:
	li t1, UART_CTRL
	li t2, UART_TX_EN
	sb t2, 0(t1)
	jalr x0, ra, 0

# Enable the UART receiver
rx_enable:
	li t1, UART_CTRL
	li t2, UART_RX_EN
	sb t2, 0(t1)
	jalr x0, ra, 0


# Spin
err:
spin:
	jal x0, spin
