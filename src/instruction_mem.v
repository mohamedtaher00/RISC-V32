module instruction_mem 
	#(parameter INST_MEMORY_SIZE = 1024, parameter ADDR_WIDTH = $clog2(INST_MEMORY_SIZE)
	)
	(
		input clk, 
		input [ADDR_WIDTH-1:0] addr,
	        input stall,	

		output reg [31:0] data 
	); 
	
	initial begin 
		$readmemh("table.mem", mem) ;
	end 	
	localparam DEPTH = 2**ADDR_WIDTH ;
//	reg [31:0] mem [0:DEPTH-1] ;
	(* ramstyle = "M9K" *) reg [7:0] mem [0:DEPTH-1] ;
	always @(posedge clk) begin 
	  if (!stall) begin 	
		data[31:24] <= mem[addr+3] ;
		data[23:16] <= mem[addr+2] ;
		data[15:8]  <= mem[addr+1] ; 
		data[7:0]   <= mem[addr] ;
	  end 
	  else begin 
 	        data[31:24] <= mem[addr-1] ;
		data[23:16] <= mem[addr-2] ;
		data[15:8]  <= mem[addr-3] ; 
		data[7:0]   <= mem[addr-4] ;
	
	end 
	end 	

endmodule 	
