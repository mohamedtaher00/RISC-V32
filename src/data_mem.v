module data_mem
	#(parameter MEMORY_SIZE = 12288, parameter ADDR_WIDTH = $clog2(MEMORY_SIZE)
	)
	(
		input [ADDR_WIDTH-1:0] addr,
	        input we,
		input re,
		input [31:0] w_data_MEM, // data_in
		input clk,
		


		// Embedded memory configuration signals
//		input [13:0] byte_addr, 
                input [3:0]  byteena,

		output [31:0] data // data_out  
	); 

      
	wire [11:0] word_addr = addr[13:2];

	altsyncram altsyncram_component (
       		 .clock0         (clk),
       		 .address_a      (word_addr),
       		 .data_a         (w_data_MEM),
       		 .wren_a         (we),
       		 .byteena_a      (byteena),
       		 .q_a            (data)

        // unused
       // .aclr0          (1'b0),
       // .aclr1          (1'b0),
       // .addressstall_a (1'b0),
       // .clocken0       (1'b1),
       // .clocken1       (1'b1)
    );


    defparam
        altsyncram_component.operation_mode                = "SINGLE_PORT",
        altsyncram_component.width_a                       = 32,
        altsyncram_component.widthad_a                     = 12,
        altsyncram_component.numwords_a                    = 3072 , // 12288 bytes / 4 = 3072 
        altsyncram_component.width_byteena_a               = 4,
        altsyncram_component.byte_size                     = 8,
        altsyncram_component.outdata_reg_a                 = "CLOCK0",
        altsyncram_component.read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ", // don't care really (it'll never gonna happen) 
        altsyncram_component.intended_device_family        = "Cyclone V",
        altsyncram_component.ram_block_type                = "AUTO";




endmodule
