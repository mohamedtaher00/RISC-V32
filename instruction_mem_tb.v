`timescale 1ns/1ps 

module instruction_mem_tb
	#(parameter INST_MEMORY_SIZE = 1024, parameter ADDR_WIDTH = $clog2(INST_MEMORY_SIZE)) () ; 
  

  wire [31:0] data_tb ;
  
  reg [ADDR_WIDTH-1:0] addr_tb ; 
  reg clk_tb ;

  always #5  clk_tb = ~clk_tb ;
  
  instruction_mem #(.INST_MEMORY_SIZE(INST_MEMORY_SIZE), .ADDR_WIDTH(ADDR_WIDTH)) DUT ( 
	  .clk(clk_tb),
	  .addr(addr_tb),
	  .data(data_tb) 
  ); 
  initial begin  
    $dumpfile("dump.vcd") ;
    $dumpvars(0, instruction_mem_tb) ; 
    clk_tb = 0 ;

	  addr_tb = {ADDR_WIDTH{1'b0}} ; 
          #10 
	  addr_tb = {ADDR_WIDTH{1'b1}} ;
	  #10 
	  addr_tb = 10'b 1000000000 ;
	  #20
	  $finish ;
  end 


endmodule	
