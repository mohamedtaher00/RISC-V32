module instruction_mem 
	#(parameter INST_MEMORY_SIZE = 1024, parameter ADDR_WIDTH = $clog2(INST_MEMORY_SIZE)
	)
	(
		input clk, 
		input [ADDR_WIDTH-1:0] addr, 

		output reg [31:0] data 
	); 
	
	initial begin 
		$readmemb("table.mem", mem) ;
	end 	
	localparam DEPTH = 2**ADDR_WIDTH ;
//	reg [31:0] mem [0:DEPTH-1] ;
	(* ramstyle = "M9K" *) reg [31:0] mem [0:DEPTH-1] ;
	always @(posedge clk) 
		data <= mem[addr] ;

endmodule 	
