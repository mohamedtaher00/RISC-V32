module address_decoder (
    input   [31:0] addr,
    output         sel_imem,    // Instruction memory
    output         sel_dmem,    // Data memory
    output         sel_uart,    // UART peripheral
    output         sel_gpio    // GPIO peripheral
);
//===========================================================================
// Address Map
//===========================================================================
// 0x00000000 - 0x00003FFF  : Instruction Memory (16KB)
// 0x00004000 - 0x00006FFF  : Data Memory        (12KB)
// 0x80000000 - 0x8000000F  : UART registers
// 0x80000010 - 0x8000001F  : GPIO registers
//

// the address decoder purpose is to manage the memory 
assign sel_imem  = (addr >= 32'h0000_0000 && addr <= 32'h0000_3FFF);
assign sel_dmem  = (addr >= 32'h0000_4000 && addr <= 32'h0000_6FFF);
assign sel_uart  = (addr >= 32'h8000_0000 && addr <= 32'h8000_000F);
assign sel_gpio  = (addr >= 32'h8000_0010 && addr <= 32'h0000_801F);

endmodule
