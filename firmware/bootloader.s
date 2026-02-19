# Set up a basic read-only bootloader in the top of memory. It sets up execution by loading a program from
# user terminal through UART and then sets execution at the start of the text.
# RISC-V CPU jumps here on boot/reset 

# The binary format used

# ------------------------------------------
# | MAGIC | SIZE | 		  PROGRAM          |
# ------------------------------------------

# Supported instructions: lw, sw, beq, add, sub, and, or, addi, lui, jal

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

.set UART_RX_DONE, 0x01  
.set UART_TX_DONE, 0x01  
.set SYNC_WORD, 0xDEADBEEF

# Reset vector jumps here
entry:
	li sp, STACK_BASE
	jal wait_sync
	jal read_word # Read size
	mv s0, a0
	beqz s0, err
	li s1, PROG_START

# Store the program from UART to the text section of the memory
receive_loop:
    beqz s0, done_loading
    call read_word
    sw a0, 0(s1)
    addi s1, s1, 1
    addi s0, s0, -1
    j receive_loop

# Jump to the start of the program
done_loading:
    j program_start

## Helpers

# Read a word from the UART
read_word:
    li t0, UART_BASE
    li t1, UART_RX
wait_rx:
    li t2, UART_STATUS
    lw t3, 0(t2)
    andi t3, t3, UART_RX_DONE
    beqz t3, wait_rx
    lw a0, 0(t1)
    ret


# Wait for magic word from the UART
wait_sync:
    li t2, SYNC_WORD
wait_loop:
    call read_word
    beq a0, t2, sync_found
    j wait_loop
sync_found:
    ret


# Spin 
err:
loop:
	jal x0, loop
