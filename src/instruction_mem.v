module instruction_mem 
	#(parameter INST_MEMORY_SIZE = 16384, parameter ADDR_WIDTH = $clog2(INST_MEMORY_SIZE)
	)
	(
		// Port A  - fetch (read)
		input clk, 
		input [ADDR_WIDTH-1:0] read_addr, // pc
		
		output [31:0] readed_data,  // instruction  
	        
			
    		// Port B — programming port (write only)
		input [ADDR_WIDTH-1:0] write_addr, 
		input [31:0] write_data,
	        input w_en 

	); 
	

    wire [11:0] word_addr_b = read_addr[13:2];
    wire [11:0] word_addr_a = write_addr[13:2];


    altsyncram altsyncram_component (
	
        // Port A — writing (programming) 
        .clock0         (clk),
	.clock1		(clk), 
        .address_a      (word_addr_a),
        .data_a 	(write_data),
        .wren_a         (w_en),

        // Port B — read 
        .address_b      (word_addr_b),
        .q_b		(readed_data),
        .wren_b         (1'b0)

        // unused
      // .aclr0          (1'b0),
      // .aclr1          (1'b0),
      // .addressstall_a (1'b0),
      // .addressstall_b (1'b0),
      // .byteena_a      (1'b1), // no need to make the Instruction MEM byte-addressable
      // .byteena_b      (1'b1), // no need to make the Instruction MEM byte-addressable
      // .clocken0       (1'b1),
      // .clocken1       (1'b1),
      // .data_a         (32'b0),
    );

    defparam
        altsyncram_component.operation_mode                     = "DUAL_PORT",
        altsyncram_component.width_a                            = 32,
        altsyncram_component.widthad_a                          = 12,
        altsyncram_component.numwords_a                         = 4096,
        altsyncram_component.width_b                            = 32,
        altsyncram_component.widthad_b                          = 12,
        altsyncram_component.numwords_b                         = 4096, // 16384 bytes / 4 = 4096 words 
        altsyncram_component.outdata_reg_a                      = "CLOCK0",
        altsyncram_component.outdata_reg_b                      = "CLOCK0",
        altsyncram_component.read_during_write_mode_mixed_ports = "OLD_DATA", //This shouldn't happen, it's software responsibility
        altsyncram_component.intended_device_family             = "Cyclone V",
        altsyncram_component.ram_block_type                     = "AUTO", 
    	altsyncram_component.init_file 				= "table.hex" ; 

endmodule
