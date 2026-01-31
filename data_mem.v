module data_mem 
	#(parameter MEMORY_SIZE = 2048, parameter ADDR_WIDTH = $clog2(MEMORY_SIZE)
	)
	(
		input [ADDR_WIDTH-1:0] addr,
	        input we,
		input re,
		input [31:0] w_data_data_MEM, 	
		input clk,

		output reg [31:0] data 
	); 
	initial begin 
		$readmemb("data_mem_table.mem", mem) ;
	end 
	localparam DEPTH = 2**ADDR_WIDTH ;
	(* ramstyle = "M9K" *) reg [31:0] mem [0:DEPTH-1] ;
	//reg [WIDTH-1:0] mem [0:DEPTH-1] ;
	//write logic - sync write 
	always @(posedge clk) begin 
		if (we) 
			mem[addr] <= w_data_data_MEM;
		else // either memory read or will'not deal with memory (write back to the reg file), read enable is insignificant here 
			data <= mem[addr] ;	
	end 

endmodule 	
