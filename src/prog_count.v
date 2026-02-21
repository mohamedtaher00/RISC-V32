// Do I need to load this counter with some value then to start from there?
// if so(branch), no I don't I'll get the offset from the ALU
// I need a counter that count just up and always counting (till now, but I'll add a en signal for the future (stalls)  


module prog_count #(parameter INST_MEMORY_SIZE = 16384, 

	parameter ADDR_WIDTH = $clog2(INST_MEMORY_SIZE)
)
	(
    	input clk,
    	input  reset_n,
	input stall, 

  	input [63:0] addr_in, 
    	output  reg [ADDR_WIDTH-1:0] addr_2_INST_MEM,
	output [63:0] addr_2_IF_ID_pipeline_reg	
);

	reg [ADDR_WIDTH-1:0] addr_reg ;
	reg [ADDR_WIDTH-1:0] addr_next ;




	wire [31:0] prog_counter_addr_tb ;
        wire [31:0] prog_counter_next_addr_tb ;
        wire [63:0] prog_counter_64_bit_addr_tb ; 

	assign addr_2_IF_ID_pipeline_reg = {{54{1'b0}}, {addr_2_INST_MEM}} ; 
	// current state logic
	always @(posedge clk) begin 
		if (~reset_n) begin 
			addr_reg <= {ADDR_WIDTH{1'b0}};
		end
	        else if (stall) begin 
			addr_reg <= addr_reg ; 
		end 	
		else begin 
			addr_reg <= addr_next;
		end 
	end
       // next state logic 
	always @(*) begin
		addr_next = {ADDR_WIDTH{1'b0}} ;// default value 	
		addr_next = addr_in[ADDR_WIDTH-1:0] ;
	end
       // output logic 
	always @(*) begin
		addr_2_INST_MEM = {ADDR_WIDTH{1'b0}} ; // default value 	
		addr_2_INST_MEM = addr_reg ;
	end 	
endmodule
