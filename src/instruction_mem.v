module instruction_mem #(
    parameter INST_MEMORY_SIZE = 16384,
    parameter ADDR_WIDTH = $clog2(INST_MEMORY_SIZE)
) (
    // Port A  - fetch (read)
    input clk,
    input [ADDR_WIDTH-1:0] read_addr,  // pc

    output [31:0] readed_data,  // instruction


    // Port B — programming port (write only)
    input [ADDR_WIDTH-1:0] write_addr,
    input [31:0] write_data,
    input w_en

);


  wire [11:0] word_addr_b = read_addr[13:2];
  wire [11:0] word_addr_a = write_addr[13:2];


  altsyncram #(

      .operation_mode("DUAL_PORT"),
      .width_a(32),
      .widthad_a(12),
      .numwords_a(4096),
      .width_b(32),
      .widthad_b(12),
      .numwords_b(4096),  // 16384 bytes / 4 = 4096 words
      .outdata_reg_a("UNREGISTERED"),
      .outdata_reg_b("UNREGISTERED"),
      .read_during_write_mode_mixed_ports("OLD_DATA"),  //This shouldn't happen(software job)
      .intended_device_family("Cyclone IV E"),
      .ram_block_type("AUTO"),
      .init_file("table.mif")

  ) altsyncram_component (

      // Port A — writing (programming)
      .clock0   (clk),
      .clock1   (clk),
      .address_a(word_addr_a),
      .data_a   (write_data),
      .wren_a   (w_en),


      // Port B — read
      .address_b     (word_addr_b),
      .q_b           (readed_data),
      .wren_b        (1'b0),
      .addressstall_b(1'b0),

      // unused
      .aclr0         (1'b0),
      .aclr1         (1'b0),
      .addressstall_a(1'b0),
      .byteena_a     (1'b1),   // no need to make the Instruction MEM byte-addressable
      .byteena_b     (1'b1),   // no need to make the Instruction MEM byte-addressable
      .clocken0      (1'b1),
      .clocken1      (1'b1),
      .data_b        (32'b0),
      .q_a           (),
      .eccstatus     ()
  );

endmodule
