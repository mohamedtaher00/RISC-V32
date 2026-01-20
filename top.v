module top (
       input clk,
       input reset_n,


	//for the sake of tricking quartus to generate the resources reports without dump optimization 
	
	output [31:0] prog_counter_addr_test, 
	output branch_ctrl_test ,
	output Memwrite_ctrl_test ,
	output Memtoreg_ctrl_test ,
	output Memread_ctrl_test ,
	output [1:0] AluOp_ctrl_test ,
	output Alusrc_ctrl_test ,
	output Regwrite_ctrl_test ,	
	output [31:0] instruction_test , 
	output [31:0] alu_src_1_test,
        output [31:0] alu_src_2_test ,
	output zero_flag_test ,
	output [31:0] alu_result_test ,
	output [3:0] alu_sel_test 	
);
	//trick assignments 
	assign branch_ctrl_test = branch_ctrl ;
        assign Memwrite_ctrl_test= Memwrite_ctrl ;
        assign Memtoreg_ctrl_test= Memtoreg_ctrl ;
        assign Memread_ctrl_test=Memread_ctrl ;
	assign AluOp_ctrl_test=AluOp_ctrl ;
        assign Alusrc_ctrl_test=Alusrc_ctrl ;
        assign Regwrite_ctrl_test = Regwrite_ctrl;  
        assign instruction_test = instruction ; 

	assign alu_src_1_test = alu_src_1 ;
	assign alu_src_2_test = alu_src_2 ;
	assign zero_flag_test = zero_flag ; 
	assign alu_result_test = alu_result ;
	assign alu_sel_test = alu_sel_test ; 


  // we'll instantiate the data path then the control path then connecting them 
	//intermediate signals 
	
	// prog_count/data path interface 
	wire [31:0] prog_counter_addr ;
	wire [31:0] prog_counter_next_addr;
	wire [63:0] prog_counter_64_bit_addr; 

	// control_unit/data path interface
	wire branch_ctrl ;
	wire Memwrite_ctrl ;
	wire Memtoreg_ctrl ;
	wire Memread_ctrl ;
	wire [1:0] AluOp_ctrl ;
	wire Alusrc_ctrl ;
	wire Regwrite_ctrl ;	

	

	wire [31:0] instruction ; //instruction_mem/data path interface

	// Alu/data path interface
	wire [31:0] alu_src_1, alu_src_2 ;
	wire zero_flag ;
	wire [31:0] alu_result ;
	wire [3:0] alu_sel ;	


	wire [31:0] immgen_out ; // ImmGen/data path interface

	wire [31:0] reg_file_second_dest ;//alu source mux 
	wire [63:0] PC_mux_false_source ;//branch mux
	wire [63:0] PC_mux_true_source ;//branch mux
	wire branch_condition ;
	wire [31:0] third_mux_true_src ;
	wire [31:0] write_back_data ;
 
	// IF stage intermediate signals 
	wire [95:0] IF_ID_pipeline_register ; 
	reg [63:0] IF_ID_rest ;

	// ID stage intermediate signals 
	wire [186:0] ID_EX_pipeline_register ; // 32(register1)+ 32(register2)+ 32(imm) +64(PC) +15(addresses of two sources and dest)+ 4(alu_ctrl)+ 8(ctrl lines)
	
	reg [7:0] ID_EX_pipeline_register_ctrl_unit   ;   
        reg [63:0] IF_ID_pipeline_register_pc 	      ; 
        reg [31:0] ID_EX_pipeline_register_immgen     ;  
        reg [4:0] ID_EX_pipeline_register_rs1	      ;      
        reg [4:0] ID_EX_pipeline_register_rs2	      ;         
        reg [4:0] ID_EX_pipeline_register_rd	      ; 
	reg [3:0] ID_EX_pipeline_register_alu_ctrl    ;

	// EX stage intermediate signals 
	wire [138:0] EX_MEM_pipeline_register ; //64(calculated address) + 32(alu_o/p) + 1(zero_flag) + 5(destination_reg) + 32(store data if sw) + 5 (rest of ctrl_unit) 
	wire [4:0] ctrl_rest ;
	wire [31:0] write_data ; 
	wire [4:0] rd ; 	
	reg [138:0] EX_MEM_pipeline_register_current_state ;

	// MEM stage intermediate signals 
	wire [70:0] MEM_WB_pipeline_register ; //32(read data) + 32(alu_result_MEM_stage) + 2(WB control signals) + Rd = 71 

	wire [31:0] readed_data 	;
	wire [1:0]  ctrl_write_back	;
	wire [4:0] rd_			; 
	wire [31:0] alu_result_MEM_stage; 



	reg [38:0] MEM_WB_pipeline_register_current_state ; 
	//WB stage intermediate signals
	 

  // IF stage 
	//branch mux	
	assign prog_counter_next_addr = branch_condition ? EX_MEM_pipeline_register [68:5] : PC_mux_false_source ; 
	rca # (.n(64)) adder1(
		.x(64'h0000_0000_0000_0004),
		.y(prog_counter_64_bit_addr),
		.c_in(1'b0),
		.s(PC_mux_false_source),
		.c_out()//we'll ignore the overflow for now 
	);
    // program counter
	prog_count  # (.INST_MEMORY_SIZE(1024)) Program_counter(
		.clk(clk),
		.reset_n(reset_n),
		.addr_in(prog_counter_next_addr),
		.addr_2_INST_MEM(prog_counter_addr),
		.addr_2_IF_ID_pipeline_reg(prog_counter_64_bit_addr)
	);
	// instruction memory 	
	instruction_mem #(.INST_MEMORY_SIZE(1024)) Instruction_MEM(
		.clk(clk),
		.addr(prog_counter_addr), 
		.data(instruction) 
	); // this gives us 32 bits of our 96 bits IF/ID pipeline register 
	
       // o/p logic four IF/ID pipeline register 	
	assign IF_ID_pipeline_register [95:64] = instruction ; 
	assign IF_ID_pipeline_register [63:0] = IF_ID_rest ;	
	
	always @(posedge clk) 
		IF_ID_rest <= prog_counter_64_bit_addr;// this part is needed to be clocked, the reg_file o/p is already clocked


  // ID stage 
    // control unit
	control_unit Control_Unit(
		.instruction(instruction[6:0]),
		.branch(branch_ctrl),
                .Memread(Memread_ctrl), 
                .Memtoreg(Memtoreg_ctrl), 
                .AluOp(AluOp_ctrl), 
		.Memwrite(Memwrite_ctrl),
	       	.Alusrc(Alusrc_ctrl),
	       	.Regwrite(Regwrite_ctrl)
	);

    // register file 

	reg_file # (.WIDTH(32), .ADDR_WIDTH(5)) Reg_file(
		.clk(clk), 
		.we(Regwrite_ctrl), 
		.r_addr1(instruction[19:15]),
		.r_addr2(instruction[24:20]),
		.w_addr(instruction[11:7]),
		.write_data(write_back_data),
		.read_reg1(alu_src_1),
		.read_reg2(reg_file_second_dest)
	);
       // second source logic (alu mux) ->  it's now shifted to the EX stage  
	//assign alu_src_2 = (Alusrc_ctrl) ? immgen_out : reg_file_second_dest; 

    // ImmGen
	immgen ImmGen(
	       .instruction(instruction), 
	       .imm(immgen_out)
	); 
	
	assign ID_EX_pipeline_register [7:0] = ID_EX_pipeline_register_ctrl_unit   ; 
	assign ID_EX_pipeline_register [71:8] = IF_ID_pipeline_register_pc         ;
	assign ID_EX_pipeline_register [103:72] = alu_src_1 			   ; // not clocked by pipeline register, clocked by reg_file ; rs1 register(not address)
	assign ID_EX_pipeline_register [135:104] = reg_file_second_dest 	   ; //not clocked by pipeline register, clocked by reg_file  ; rs2 register(not address)
	assign ID_EX_pipeline_register [167:136] = ID_EX_pipeline_register_immgen  ;
	assign ID_EX_pipeline_register [172:168] = ID_EX_pipeline_register_rs1     ;
	assign ID_EX_pipeline_register [177:173] = ID_EX_pipeline_register_rs2     ;
	assign ID_EX_pipeline_register [182:178] = ID_EX_pipeline_register_rd      ;
	assign ID_EX_pipeline_register [186:183] = ID_EX_pipeline_register_alu_ctrl; 

	always @(posedge clk) begin //stuff that needed to be clocked  
		ID_EX_pipeline_register_alu_ctrl  <= {IF_ID_pipeline_register[94], IF_ID_pipeline_register[78:76]} ;
		ID_EX_pipeline_register_ctrl_unit <= {AluOp_ctrl, Alusrc_ctrl, branch_ctrl,  Memread_ctrl, Memwrite_ctrl, Regwrite_ctrl, Memtoreg_ctrl} ;
		IF_ID_pipeline_register_pc 	  <= IF_ID_pipeline_register[63:0] ; 
		ID_EX_pipeline_register_immgen    <= immgen_out ;
		ID_EX_pipeline_register_rd	  <= IF_ID_pipeline_register[75:71] ; 
		ID_EX_pipeline_register_rs1	  <= IF_ID_pipeline_register[83:79] ; 
		ID_EX_pipeline_register_rs2	  <= IF_ID_pipeline_register[88:84] ; 
	end	





  // EX stage
	

	assign rd = ID_EX_pipeline_register [182:178] ;
	assign write_data = ID_EX_pipeline_register[135:104] ; 
	assign ctrl_rest = ID_EX_pipeline_register [4:0] ;


	always @(posedge clk) begin 
		//current_state logic 
		EX_MEM_pipeline_register_current_state [4:0]    <= ctrl_rest           ;	
		EX_MEM_pipeline_register_current_state [68:5]     <= PC_mux_true_source ;
		EX_MEM_pipeline_register_current_state [69]	   <= zero_flag 	     ; 
		EX_MEM_pipeline_register_current_state [101:70]    <= alu_result 	     ;
		EX_MEM_pipeline_register_current_state [133:102]   <= write_data     ; 
		EX_MEM_pipeline_register_current_state [138:134]   <= rd 	     ;
	end
       // output logic 
	assign EX_MEM_pipeline_register = {
		EX_MEM_pipeline_register_current_state  [4:0]        ,  
		EX_MEM_pipeline_register_current_state  [68:5]       ,  
		EX_MEM_pipeline_register_current_state  [69]	     ,  
		EX_MEM_pipeline_register_current_state  [101:70]     ,  
		EX_MEM_pipeline_register_current_state  [133:102]    ,  
		EX_MEM_pipeline_register_current_state  [138:134]     
	}; 	

    // ALU 
	assign alu_src_2 = (ID_EX_pipeline_register[5]) ? ID_EX_pipeline_register [167:136] : ID_EX_pipeline_register [135:104] ;// [167:136] for immed, [135:104] reg_file_second_dest. 
	alu ALU(
		.alu_control_lines(alu_sel),
		.operand1(ID_EX_pipeline_register [103:72]),
		.operand2(alu_src_2),
		.ALU_result(alu_result), 
		.zero(zero_flag)
	);

  // ALU control
 
	alu_control ALU_Control(
		.ALUOp(ID_EX_pipeline_register [7:6]),
		.instruction(ID_EX_pipeline_register [186:183]),
		.alu_control_lines(alu_sel)
	); 
  
	//target address adder/calculator 
			
	rca # (.n(64)) adder2(
		.x(ID_EX_pipeline_register [167:136]), // immed  
		.y(ID_EX_pipeline_register [71:8]), //PC address 
		.c_in(1'b0),
		.s(PC_mux_true_source),// check this when building EX_MEM_pipeline_reg 
		.c_out()//we'll ignore the overflow for now 
	);
	 
		


  // MEM stage 
	
	//output logic 
	assign MEM_WB_pipeline_register = { 	MEM_WB_pipeline_register_current_state [1:0]  , 
                                                readed_data, // doesn't need to be clocked, already clocked from the data_memory
						MEM_WB_pipeline_register_current_state [33:2], 
                                                MEM_WB_pipeline_register_current_state [38:34]
	} ; 

	//next state logic 
	assign ctrl_write_back = EX_MEM_pipeline_register [1:0] ; 
	assign alu_result_MEM_stage = EX_MEM_pipeline_register [101:70] ; 



	// current sate logic 
	
	always @(posedge clk) begin
	       // current_state_logic	
		MEM_WB_pipeline_register_current_state [1:0]   <= ctrl_write_back ;	
		MEM_WB_pipeline_register_current_state [33:2] <= alu_result_MEM_stage ; 
		MEM_WB_pipeline_register_current_state [38:34] <= rd_		;
	end 

	data_mem # (.MEMORY_SIZE(2048)) Data_MEM(
	.addr(alu_result_MEM_stage[$clog2(2048)-1:0]),
	.we(EX_MEM_pipeline_register[2]),
	.re(EX_MEM_pipeline_register[3]),	
	.write_data(EX_MEM_pipeline_register_current_state [133:102]),
	.data(readed_data) 
	); 	


	and (branch_condition, EX_MEM_pipeline_register [69] , EX_MEM_pipeline_register[4]); // in MEM stage 
     
     

  //WB stage 

	// third mux (write back mux)
	assign write_back_data  = MEM_WB_pipeline_register[0] ? MEM_WB_pipeline_register [33:2] : MEM_WB_pipeline_register [65:34] ;
	assign Regwrite_ctrl = MEM_WB_pipeline_register[1] ; 

endmodule 
