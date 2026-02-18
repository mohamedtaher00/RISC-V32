module address_decoder (
    input   [31:0] addr,
    output         sel_imem,    // Instruction memory
    output         sel_dmem,    // Data memory
    output         sel_uart,    // UART peripheral
    output         sel_gpio,    // GPIO peripheral
    output         sel_timer    // Timer peripheral
);
//===========================================================================
// Address Map
//===========================================================================
// 0x00000000 - 0x00003FFF  : Instruction Memory (16KB)
// 0x00004000 - 0x00006FFF  : Data Memory        (12KB)
// 0x00008000 - 0x0000800F  : UART registers
// 0x00008010 - 0x0000801F  : GPIO registers
// 0x00008020 - 0x0000802F  : Timer registers
//


// the address decoder purpose is to manage the memory 
assign sel_imem  = (addr >= 32'h0000_0000 && addr <= 32'h0000_3FFF);
assign sel_dmem  = (addr >= 32'h0000_4000 && addr <= 32'h0000_6FFF);
assign sel_uart  = (addr >= 32'h0000_8000 && addr <= 32'h0000_800F);
assign sel_gpio  = (addr >= 32'h0000_8010 && addr <= 32'h0000_801F);
assign sel_timer = (addr >= 32'h0000_8020 && addr <= 32'h0000_802F);

endmodule
