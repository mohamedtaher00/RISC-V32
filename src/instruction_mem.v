module instruction_mem 
	#(parameter INST_MEMORY_SIZE = 1024, parameter ADDR_WIDTH = $clog2(INST_MEMORY_SIZE)
	)
	(
		input clk, 
		input [ADDR_WIDTH-1:0] read_addr,
	        input stall,	
		input write_addr, 
		input write_data,
	        input w_en, 
		output reg [31:0] readed_data 
	); 
	
	initial begin 
		$readmemh("table.mem", mem) ;
	end 	
	localparam DEPTH = 2**ADDR_WIDTH ;
//	reg [31:0] mem [0:DEPTH-1] ;
	// read logic
	(* ramstyle = "M9K" *) reg [7:0] mem [0:DEPTH-1] ;
	always @(posedge clk) begin 
	  if (!stall) begin 	
		readed_data[31:24] <= mem[read_addr+3] ;
		readed_data[23:16] <= mem[read_addr+2] ;
		readed_data[15:8]  <= mem[read_addr+1] ; 
		readed_data[7:0]   <= mem[read_addr] ;
	  end 
	  else begin 
 	        readed_data[31:24] <= mem[read_addr-1] ;
		readed_data[23:16] <= mem[read_addr-2] ;
		readed_data[15:8]  <= mem[read_addr-3] ; 
		readed_data[7:0]   <= mem[read_addr-4] ;
	
	end 
	end 

	//write logic
	always @(posedge clk) begin 
		if (w_en) begin // little endian 
			mem[write_addr+3] <= write_data[31:24] ; 
			mem[write_addr+2] <= write_data[23:16] ; 
			mem[write_addr+1] <= write_data[15:8] ; 
			mem[write_addr]   <= write_data[7:0] ;
		end 	

endmodule 	
