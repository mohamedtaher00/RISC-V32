`timescale 1ns/1ps 

module data_mem_tb
	#(parameter MEMORY_SIZE = 2048, parameter ADDR_WIDTH = $clog2(MEMORY_SIZE)) () ; 
  

  wire [31:0] data_tb ;
  
  reg [ADDR_WIDTH-1:0] addr_tb ;
  reg we_tb ;
  reg re_tb ;
 
  reg [31:0] write_data_tb ;

  reg clk_tb ;

  always #5  clk_tb = ~clk_tb ;
  
  data_mem #(.MEMORY_SIZE(MEMORY_SIZE), .ADDR_WIDTH(ADDR_WIDTH)) DUT ( 
	  .clk(clk_tb),
	  .addr(addr_tb),
	  .we(we_tb),
	  .re(re_tb),
	  .write_data(write_data_tb),
	  .data(data_tb) 
  ); 
  initial begin  
    $dumpfile("dump.vcd") ;
    $dumpvars(0, data_mem_tb) ; 
    clk_tb = 0 ;

	  addr_tb = {ADDR_WIDTH{1'b0}} ; 
          #10 
	  addr_tb = {ADDR_WIDTH{1'b1}} ;
	  #10 
	  addr_tb = 11'b 10000000000 ;
	  #20
	  $finish ;
  end 


endmodule	
