module instr_mem_wrapper (
    input clk,

    // Port A  - fetch (read) - Instruction fetch port
    input  [13:0] read_addr,
    output [31:0] readed_data,

    // Port B — programming port (write only) - Programming port (for bootloader)
    input [13:0] write_addr,
    input [31:0] write_data,
    input        w_en, 
    input 	 stall 
    
);

    // Write side: replicate data + generate byteena
    reg [31:0] data_in;
    reg [3:0]  byteena;

    // Memory instances
    wire [31:0] raw_out;

    wire [13:0] r_addr ; 
    assign r_addr = (stall) ? readed_addr - 3'd4 : readed_addr  ; 
    instr_mem imem (
        .clk        	(clk),
        .read_addr  	(read_addr),
        .readed_data 	(readed_data),
        .write_addr 	(write_addr),
        .write_data	(write_data),
        .w_en		(w_en), 
    );

endmodule
