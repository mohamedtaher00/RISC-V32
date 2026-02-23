`timescale 1ns/1ns 

module top_tb ;
	
	reg clk_tb ; 
	reg reset_n_tb ;
	
	
	
	
	
	
	wire [31:0] prog_counter_addr_tb ;
        wire [31:0] prog_counter_next_addr_tb ;
        wire [63:0] prog_counter_64_bit_addr_tb ; 






	wire [31:0] instruction_test_tb  	; 		
        wire [31:0] write_back_data_test_tb	;
        wire [9:0] pc_addr_test_tb 		;
        wire [3:0] alu_ctrl_lines_test_tb	;
	
	wire [1:0] alu_op_test_tb 		;
        wire alu_src_test_tb     		;
        wire branch_test_tb      		;
        wire mem_write_ctrl_test_tb  		;	
        wire reg_write_ctrl_test_tb		;
        wire mem2reg_ctrl_test_tb 		;


	wire tx_tb ; 
	reg rx_tb ; 

	top DUT (
	.clk			(clk_tb), 
	.reset_n		(reset_n_tb),

	.instruction_test	( instruction_test_tb), 	
	.write_back_data_test	( write_back_data_test_tb), 	
	.pc_addr_test 		(pc_addr_test_tb), 	
	.alu_ctrl_lines_test	(alu_ctrl_lines_test_tb), 


	.alu_op_test		(alu_op_test_tb), 	
	.alu_src_test     	(alu_src_test_tb     	), 	
	.branch_test      	(branch_test_tb      	), 	
	.mem_write_ctrl_test  	(mem_write_ctrl_test_tb 	), 	
	.reg_write_ctrl_test	(reg_write_ctrl_test_tb	), 	
	.mem2reg_ctrl_test 	(mem2reg_ctrl_test_tb 	),

	.rx			(rx_tb), 
	.tx			(tx_tb)
	
	); 

  always #5 clk_tb = ~clk_tb ;

  initial begin  
    $dumpfile("top_dump.vcd") ;
    $dumpvars(0, top_tb) ; 
    clk_tb = 0 ;
    reset_n_tb = 0 ;
    #10 reset_n_tb = 1 ;
    #250 
    $finish ; 
  end 

endmodule 
