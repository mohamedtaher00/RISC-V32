# This assembler code tests newly implemented instructions
# 
# These instructions are mainly
# addi, andi, lb, sb
#
.set DATA, 0xFFF
start:
# Test addi for a positive number
# (This also tests a load after a store)
	li x18, DATA # Some random address
	addi x19, x0, 0x7F
	sb x19, 0(x18) # Memory should contain 0000007f 
	lb x20, 0(x18) # x20 should contain 0000007f
	
# Test addi for a negative number
	addi x19, x0, 0xFF
	sb x19, 0(x18) # Memory should contain 000000ff 
	lb x20, 0(x18) # x20 should contain ffffffff (sign extension)

# Clear x20
	addi x20, x0, 0

# Try writing to x0
	addi x0, x0, 0x1
	addi x0, x0, 0xffffffff

# Test andi
	addi x21, x0, 0xA5     # 1010 0101 -> only first 12 bits should be used
	                       # 0101 1010
	andi x23, x21, 0x5A	   # x23= 0000 0000 
	andi x23, x21, 0xFF  # Mask off the last byte: x23=0xA5 

# Test a branch
	addi x24, zero, 0x55 # 01010101
	sb x24, 0(x18)
	addi x24, zero, 0xAA # 10101010
	sb x24, 4(x18)
	lb x25, 0(x18) # x25 = 0x00000055
	lb x26, 4(x18) # x26 = 0xFFFFFFAA
	addi x27, zero, 0x55
	beq x27, t0, start # Should branch 

# Test overflows?
# (In both cases, the result should be zero)
	addi x28, zero, 0xffffffff
	addi x28, x28, 1 
	addi x28, zero, 0x0
	addi x28, x28, -1 
