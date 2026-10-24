module data_mem #(
    parameter MEMORY_SIZE = 12288,
    parameter ADDR_WIDTH  = $clog2(MEMORY_SIZE)
) (
    input [ADDR_WIDTH-1:0] addr,
    input we,
    input re,
    input [31:0] w_data_MEM,  // data_in
    input clk,



    // Embedded memory configuration signals
    //		input [13:0] byte_addr,
    input [3:0] byteena,

    output [31:0] data  // data_out
);


  wire [11:0] word_addr = addr[13:2];

  altsyncram #(

      .operation_mode("SINGLE_PORT"),
      .width_a(32),
      .widthad_a(12),
      .numwords_a(3072),  // 12288 bytes / 4 = 3072
      .width_byteena_a(4),
      .byte_size(8),
      .outdata_reg_a("UNREGISTERED"),
      .read_during_write_mode_port_a("DONT_CARE"),  // don't care really (it'll never gonna happen)
      .intended_device_family("Cyclone IV E"),
      .ram_block_type("AUTO")

  ) altsyncram_component (
      .clock0   (clk),
      .address_a(word_addr),
      .data_a   (w_data_MEM),
      .wren_a   (we),
      .byteena_a(byteena),
      .q_a      (data),

      // unused
      .aclr0         (1'b0),
      .aclr1         (1'b0),
      .addressstall_a(1'b0),
      .clocken0      (1'b1),
      .clocken1      (1'b1)
  );

endmodule
