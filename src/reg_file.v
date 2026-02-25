module reg_file 
	#(parameter WIDTH = 32, parameter ADDR_WIDTH = 5 ) 
	(
		input clk,
		input we, 	
		input [ADDR_WIDTH-1:0] r_addr1, 
		input [ADDR_WIDTH-1:0] r_addr2, 
		input [ADDR_WIDTH-1:0] w_addr, 
		input [WIDTH-1:0] w_data_reg_file, 	

		output reg [WIDTH-1:0] read_reg1,
		output reg [WIDTH-1:0] read_reg2
	); 
	initial begin 
		$readmemh("reg_file_table.mem", mem) ;	
	end 
	localparam DEPTH = 2**ADDR_WIDTH ;
	(* ramstyle = "M9K" *) reg [WIDTH-1:0] mem [0:DEPTH-1] ;
	//reg [WIDTH-1:0] mem [0:DEPTH-1] ;
	//write logic - sync write and read logic sync  
	always @(posedge clk) begin //write before read
		if (we) begin  
			mem[w_addr] <= w_data_reg_file;
		end 
	       		read_reg1 <= mem[r_addr1] ;
		 	read_reg2 <= mem[r_addr2] ; 
	end 
endmodule 	
