module top (
       input clk,
       input reset_n,


	//for the sake of tricking quartus to generate the resources reports without dump optimization (single-cycle) 
	
//	output [31:0] prog_counter_addr_test, 
//	output branch_ctrl_test ,
//	output Memwrite_ctrl_test ,
//	output Memtoreg_ctrl_test ,
//	output Memread_ctrl_test ,
//	output [1:0] AluOp_ctrl_test ,
//	output Alusrc_ctrl_test ,
//	output Regwrite_ctrl_test ,	
//	output [31:0] instruction_test , 
//	output [31:0] alu_src_1_test,
//      output [31:0] alu_src_2_test ,
//	output zero_flag_test ,
//	output [31:0] alu_result_test ,
//	output [3:0] alu_sel_test 
	// tricking (pipelined) 
	output [31:0] instruction_test  	,	
        output [31:0] write_back_data_test	, 
        output [9:0] pc_addr_test 		, 
        output [3:0] alu_ctrl_lines_test	,


	output [31:0] prog_counter_addr ,
        output reg [31:0] prog_counter_next_addr ,
        output [63:0] prog_counter_64_bit_addr  ,


	output [1:0] alu_op_test 		, 
        output alu_src_test     		, 
        output branch_test      		, 
        output mem_write_ctrl_test  		,
        output reg_write_ctrl_test		, 
        output mem2reg_ctrl_test 				

);
  reg [1:0] boot_cnt;

  always @(posedge clk or negedge reset_n) begin
      if (!reset_n)
          boot_cnt <= 2'd0;
      else if (boot_cnt < 2'd3)
          boot_cnt <= boot_cnt + 1;
  end

  wire pipeline_valid ;
  assign pipeline_valid = (boot_cnt >= 2'd3);

  // we'll instantiate the data path then the control path then connecting them 
	//intermediate signals 
	
	// prog_count/data path interface 
//	wire [31:0] prog_counter_addr = 0;
//	wire [31:0] prog_counter_next_addr = 0;
//	wire [63:0] prog_counter_64_bit_addr = 0 ; 

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
	reg [31:0] alu_src_1;
        wire [31:0] alu_src_2 ;
	wire [31:0] alu_muxA_src;
        reg [31:0] 	alu_muxB_src ; 
	wire zero_flag ;
	wire [31:0] alu_result ;
	wire [3:0] alu_sel ;	


	wire [31:0] immgen_out ; // ImmGen/data path interface

	wire [31:0] reg_file_second_dest ;//alu source mux 
	wire [63:0] PC_mux_pluse4_source ;//branch mux
	reg  [63:0] return_addr ;//branch mux
	wire [63:0] branch_target_addr ; 
	wire branch_condition ;
	wire [31:0] third_mux_true_src ;
	wire [31:0] write_back_data ;
 
	// IF stage intermediate signals 
	wire [102:0] IF_ID_pipeline_register ; 
	reg [63:0] IF_ID_inst_addr ;

	reg [4:0] previous_prediction_addr ; 
	wire [1:0] our_prediction ; 

	// ID stage intermediate signals 
	wire [257:0] ID_EX_pipeline_register ; // 32(register1)+ 32(register2)+ 32(imm) +64(PC) +15(addresses of two sources and dest)+ 4(alu_ctrl)+ 8(ctrl lines)
	
	reg [7:0] ID_EX_pipeline_register_ctrl_unit   ;   
        reg [63:0] IF_ID_pipeline_register_pc 	      ; 
        reg [31:0] ID_EX_pipeline_register_immgen     ;  
        reg [4:0] ID_EX_pipeline_register_rs1	      ;      
        reg [4:0] ID_EX_pipeline_register_rs2	      ;         
        reg [4:0] ID_EX_pipeline_register_rd	      ; 
	reg [3:0] ID_EX_pipeline_register_alu_ctrl    ;
	reg [63:0] ID_EX_pipeline_register_return_addr;
        reg [1:0] ID_EX_pipeline_register_our_prediction ; 
	reg [4:0] ID_EX_pipeline_register_previous_prediction_addr ; 	
	wire stall_ctrl ;
	wire stall_cnt ; 
        wire [7:0] stall_mux_out ;	


	wire [1:0] our_prediction_ID_EX ; 
	// EX stage intermediate signals 
	wire [145:0] EX_MEM_pipeline_register ; //64(calculated address) + 32(alu_o/p) + 1(zero_flag) + 5(destination_reg) + 32(store data if sw) + 5 (rest of ctrl_unit) 
	wire [4:0] ctrl_rest ;
	wire [31:0] write_data ; 
	wire [4:0] rd ; 	
	reg [145:0] EX_MEM_pipeline_register_current_state ; // we modify it to include we_were_wong it was [138:0]  the same w/ EX_MEM_pipeline_register 
	wire [63:0] return_addr_EX ;
	 
	reg [4:0] EX_MEM_pipeline_register_previous_prediction_addr ; 	

	// MEM stage intermediate signals 
	wire [77:0] MEM_WB_pipeline_register ; //32(read data) + 32(alu_result_MEM_stage) + 2(WB control signals) + Rd = 71 

	wire [31:0] readed_data 	;
	wire [1:0]  ctrl_write_back	;
	wire branch_MEM ; 
	wire [4:0] rd_			; 
	wire [31:0] alu_result_MEM_stage; 
	wire we_were_wrong 	; 
	wire [4:0] previous_prediction_addr_MEM_WB ; 
        wire final_verdict ; 	
	//WB stage intermediate signals 
	reg [45:0] MEM_WB_pipeline_register_current_state ; 
	
	wire we_were_wrong_wb 	; 

	wire Regwrite_ctrl_WB_stage    ;

  // IF stage 
	//branch mux	
	//assign prog_counter_next_addr = branch_condition ? EX_MEM_pipeline_register [68:5] : PC_mux_pluse4_source ; // old one before the starting the CPU thing 
	always @(*) begin 
		if (!pipeline_valid) 
			prog_counter_next_addr = PC_mux_pluse4_source ;
	        else if (EX_MEM_pipeline_register [139] & EX_MEM_pipeline_register[4]) // EX_MEM_pipeline_register [139]: we_were_wrong, EX_MEM_pipeline_register[4]  :branch
			prog_counter_next_addr = EX_MEM_pipeline_register[68:5]  ; //  EX_MEM_pipeline_register[68:5]: return addr 
		else if (our_prediction[1] & branch_ctrl) 
			prog_counter_next_addr = branch_target_addr ; 
		else 
			prog_counter_next_addr = PC_mux_pluse4_source ; 	
	end 	
	
	
	
	rca # (.n(64)) adder1(
		.x(64'h0000_0000_0000_0004),
		.y(prog_counter_64_bit_addr),
		.c_in(1'b0),
		.s(PC_mux_pluse4_source),
		.c_out()//we'll ignore the overflow for now 
	);
    // program counter
	prog_count  # (.INST_MEMORY_SIZE(1024)) Program_counter(
		.clk(clk),
		.reset_n(reset_n),
		.stall(stall_cnt), 
		.addr_in(prog_counter_next_addr),
		.addr_2_INST_MEM(prog_counter_addr),
		.addr_2_IF_ID_pipeline_reg(prog_counter_64_bit_addr)
	);
	// instruction memory 	
	instruction_mem #(.INST_MEMORY_SIZE(1024)) Instruction_MEM(
		.clk(clk),
		.stall(stall_cnt), 
		.addr(prog_counter_addr), 
		.data(instruction) 
	); // this gives us 32 bits of our 96 bits IF/ID pipeline register 
	    	  
       // o/p logic four IF/ID pipeline register 	
	assign IF_ID_pipeline_register [95:64] = instruction ; 
	assign IF_ID_pipeline_register [63:0] = IF_ID_inst_addr ;
	assign IF_ID_pipeline_register [97:96] = our_prediction ; 	


	assign IF_ID_pipeline_register [102:98] = previous_prediction_addr  ;

	always @(posedge clk) begin 
		if(!stall_cnt) begin 	
	         IF_ID_inst_addr <= prog_counter_64_bit_addr;// this part is needed to be clocked, the reg_file o/p is already clocked
		 previous_prediction_addr <= prog_counter_addr[4:0] ;
		end 
		else begin  
	         IF_ID_inst_addr <= IF_ID_inst_addr ;
	         previous_prediction_addr <= previous_prediction_addr ; 
		end 	
	end 		
	bht predictor(
		.reset_n(reset_n), 
		.clk(clk), 
		.addr_needs_predition(prog_counter_addr[4:0]), //low order bits from the pc 
		.previous_prediction_addr_ID_EX(ID_EX_pipeline_register [257:253]) ,//from EX/MEM -> I changed it to ID/EX
	        .previous_prediction_addr_MEM_WB(MEM_WB_pipeline_register[77:73]), 
		.branch_EX_MEM(EX_MEM_pipeline_register[4]), 
		.branch_MEM_WB(MEM_WB_pipeline_register[72]) , 
		.final_verdict(EX_MEM_pipeline_register[145]) ,// 1 means taken, 0 means not taken -> from MEM/WB 
		.our_prediction(our_prediction)
	); 	
                    
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

	assign stall_mux_out = stall_ctrl ? 8'b0 :  {AluOp_ctrl, Alusrc_ctrl, branch_ctrl,  Memread_ctrl, Memwrite_ctrl, Regwrite_ctrl, Memtoreg_ctrl} ;  

    // register file 

	reg_file # (.WIDTH(32), .ADDR_WIDTH(5)) Reg_file(
		.clk(clk), 
		.we(Regwrite_ctrl_WB_stage), 
		.r_addr1(instruction[19:15]),
		.r_addr2(instruction[24:20]),
		.w_addr(MEM_WB_pipeline_register [70:66]),
		.w_data_reg_file(write_back_data),
		.read_reg1(alu_muxA_src),
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
	assign ID_EX_pipeline_register [103:72] = alu_muxA_src 			   ; // not clocked by pipeline register, clocked by reg_file ; rs1 register(not address)
	assign ID_EX_pipeline_register [135:104] = reg_file_second_dest 	   ; //not clocked by pipeline register, clocked by reg_file  ; rs2 register(not address)
	assign ID_EX_pipeline_register [167:136] = ID_EX_pipeline_register_immgen  ;
	assign ID_EX_pipeline_register [172:168] = ID_EX_pipeline_register_rs1     ;
	assign ID_EX_pipeline_register [177:173] = ID_EX_pipeline_register_rs2     ;
	assign ID_EX_pipeline_register [182:178] = ID_EX_pipeline_register_rd      ;
	assign ID_EX_pipeline_register [186:183] = ID_EX_pipeline_register_alu_ctrl;
	assign ID_EX_pipeline_register [250:187] = ID_EX_pipeline_register_return_addr	;
        assign ID_EX_pipeline_register [252:251] = ID_EX_pipeline_register_our_prediction ; 	
	assign ID_EX_pipeline_register [257:253] = ID_EX_pipeline_register_previous_prediction_addr ; 
	always @(posedge clk) begin //stuff that needed to be clocked  
		ID_EX_pipeline_register_alu_ctrl  <= {IF_ID_pipeline_register[94], IF_ID_pipeline_register[78:76]} ;
		ID_EX_pipeline_register_ctrl_unit <= stall_mux_out ;
		IF_ID_pipeline_register_pc 	  <= IF_ID_pipeline_register[63:0] ; 
		ID_EX_pipeline_register_immgen    <= immgen_out ;
		ID_EX_pipeline_register_rd	  <= IF_ID_pipeline_register[75:71] ; 
		ID_EX_pipeline_register_rs1	  <= IF_ID_pipeline_register[83:79] ; 
		ID_EX_pipeline_register_rs2	  <= IF_ID_pipeline_register[88:84] ;
	        ID_EX_pipeline_register_return_addr <= return_addr ; 
		ID_EX_pipeline_register_our_prediction <= our_prediction_ID_EX ; 
		ID_EX_pipeline_register_previous_prediction_addr <= IF_ID_pipeline_register[102:98] ;  	
	end
	assign our_prediction_ID_EX = IF_ID_pipeline_register [97:96] ; 	
  // hazard detection unit 
	hazard_detection_unit lw_use_hazard( 
		.ID_EX_MemRead(ID_EX_pipeline_register[3]),
		.MEM_WB_branch(MEM_WB_pipeline_register[72]), 
		.MEM_WB_we_were_wrong(MEM_WB_pipeline_register[71]), 
		.boot_cnt(boot_cnt),
		.our_prediction_EX(),
		.branch_EX(EX_MEM_pipeline_register[4]),
		.ID_EX_RegisterRd(ID_EX_pipeline_register[182:178]),
		.IF_ID_Rs1(IF_ID_pipeline_register[83:79]),
		.IF_ID_Rs2( IF_ID_pipeline_register[88:84]     ),
		.we_were_wrong(EX_MEM_pipeline_register[139]), 
		.stall_cnt(stall_cnt), 
		.stall_ctrl(stall_ctrl)
	); 


	 //target address adder/calculator 

	rca # (.n(64)) adder2(
		.x({32'b0, immgen_out}), // immed 
		.y(IF_ID_pipeline_register[63:0]), //PC address 
		.c_in(1'b0),
		.s(branch_target_addr),// check this when building EX_MEM_pipeline_reg 
		.c_out()//we'll ignore the overflow for now 
	);

	// return address mux 
	always @(*) begin 
		if(our_prediction[1]) //taken  
			return_addr = prog_counter_64_bit_addr ; 
		else // not taken 
			return_addr = branch_target_addr ; 
	end 	

  // EX stage
	wire [4:0] previous_prediction_addr_EX_MEM ;  	
	//next state logic 
	assign rd = ID_EX_pipeline_register [182:178] ;
	assign write_data = ID_EX_pipeline_register[135:104] ;
	assign ctrl_rest = ID_EX_pipeline_register [4:0] ;
	assign return_addr_EX = ID_EX_pipeline_register [250:187] ; 
	assign previous_prediction_addr_EX_MEM = ID_EX_pipeline_register [257:253] ; 

	always @(posedge clk) begin 
		//current_state logic
		//EX_MEM_pipeline_reg[139] is we_were_wrong, and MEM_WB_pipeline_register[71] also. EX_MEM_pipeline_register[4] and MEM_WB_pipeline_register[72] are branch
		if ((EX_MEM_pipeline_register[139] & EX_MEM_pipeline_register[4] ) | (MEM_WB_pipeline_register[71] & MEM_WB_pipeline_register[72] ) )  
			EX_MEM_pipeline_register_current_state [4:0] <= 5'b00000 ;
		else 
			EX_MEM_pipeline_register_current_state [4:0]    <= ctrl_rest           ;


		EX_MEM_pipeline_register_current_state [68:5]     <= return_addr_EX ;
		EX_MEM_pipeline_register_current_state [69]	   <= zero_flag 	     ; 
		EX_MEM_pipeline_register_current_state [101:70]    <= alu_result 	     ;
		EX_MEM_pipeline_register_current_state [133:102]   <= write_data     ;
		EX_MEM_pipeline_register_current_state [138:134]   <= rd 	     ;
		EX_MEM_pipeline_register_current_state [139]	   <= we_were_wrong  ;
		EX_MEM_pipeline_register_current_state [144:140]   <= previous_prediction_addr_EX_MEM ;
		EX_MEM_pipeline_register_current_state [145]	   <= final_verdict ;  
	end
       // output logic 
	assign EX_MEM_pipeline_register = {
		EX_MEM_pipeline_register_current_state [145] , 
		EX_MEM_pipeline_register_current_state [144:140] , 
		EX_MEM_pipeline_register_current_state  [139],  
		EX_MEM_pipeline_register_current_state  [138:134]    , 
		EX_MEM_pipeline_register_current_state [133:102], 
		EX_MEM_pipeline_register_current_state  [101:70]     , 
		EX_MEM_pipeline_register_current_state  [69]	     ,  
		EX_MEM_pipeline_register_current_state  [68:5]       ,  
		EX_MEM_pipeline_register_current_state  [4:0]          
	}; 	

    // ALU 
	assign alu_src_2 = (ID_EX_pipeline_register[5]) ? ID_EX_pipeline_register [167:136] : alu_muxB_src ;// [167:136] for immed, [135:104] reg_file_second_dest.
	
		  	
	alu ALU(
		.alu_control_lines(alu_sel),
		.operand1(alu_src_1),
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
  
	
	and (branch_condition, zero_flag , ID_EX_pipeline_register[4]); 
	assign we_were_wrong =  ID_EX_pipeline_register[4] & (branch_condition ^ ID_EX_pipeline_register[252] ) ;
	assign final_verdict = branch_condition ; 
  // forwarding unit
	wire [1:0] forwardA, forwardB ; 
	forwarding_unit Forwarding_Unit(
		.ID_EX_RegisterRs1(ID_EX_pipeline_register[172:168]),
	        .ID_EX_RegisterRs2(ID_EX_pipeline_register[177:173]),
	                           
	        .EX_MEM_RegisterRd(EX_MEM_pipeline_register[138:134]),
	        .MEM_WB_RegisterRd(MEM_WB_pipeline_register[70:66]),
	                           
	        .EX_MEM_RegWrite(EX_MEM_pipeline_register[1]),
	        .MEM_WB_RegWrite(MEM_WB_pipeline_register[1]),

		.ForwardA(forwardA), 
                .ForwardB(forwardB)
	);
	//forwarding muxs check out FIGURE 4.57 @ the book
	always @(*) begin
		case (forwardA)  
		  2'b00 :  
			alu_src_1 = ID_EX_pipeline_register [103:72]	;
		  2'b10 :  
			alu_src_1 = EX_MEM_pipeline_register [101:70]   ; 
		  2'b01 : 
			alu_src_1 = MEM_WB_pipeline_register [65:34]    ; 
			default : alu_src_1 = ID_EX_pipeline_register [103:72] ; 
		endcase 
	end 
	always @(*) begin
		case (forwardB)  
		  2'b00 :  
			alu_muxB_src = ID_EX_pipeline_register [135:104]	;
		  2'b10 :  
			alu_muxB_src = EX_MEM_pipeline_register [101:70]   ; 
		  2'b01 : 
			alu_muxB_src = MEM_WB_pipeline_register [65:34]    ; 
		
		default : alu_muxB_src = ID_EX_pipeline_register [135:104] ; 
		endcase 
	end 


  // MEM stage 
	
	//output logic 
	assign MEM_WB_pipeline_register = { 	MEM_WB_pipeline_register_current_state [45:41], 
						MEM_WB_pipeline_register_current_state [40], 	
						MEM_WB_pipeline_register_current_state [39]  , 	
						MEM_WB_pipeline_register_current_state [38:34], 
						MEM_WB_pipeline_register_current_state [33:2], 
                                                readed_data, // doesn't need to be clocked, already clocked from the data_memory
                                                MEM_WB_pipeline_register_current_state [1:0]
	} ; 

	//next state logic 
	assign ctrl_write_back = EX_MEM_pipeline_register [1:0]; 
	assign alu_result_MEM_stage = EX_MEM_pipeline_register [101:70] ; 
	assign rd_ = EX_MEM_pipeline_register [138:134] ; 
	assign we_were_wrong_wb = EX_MEM_pipeline_register [139] ; 
	assign branch_MEM = EX_MEM_pipeline_register[4] ;
	assign previous_prediction_addr_MEM_WB [4:0] = EX_MEM_pipeline_register[144:140]	; 
	// current sate logic 
	
	always @(posedge clk) begin
	       // current_state_logic	
		MEM_WB_pipeline_register_current_state [1:0]   <= ctrl_write_back ;	
		MEM_WB_pipeline_register_current_state [33:2] <= alu_result_MEM_stage ; 
		MEM_WB_pipeline_register_current_state [38:34] <= rd_		;
		MEM_WB_pipeline_register_current_state [39]    <= we_were_wrong_wb ; 
		MEM_WB_pipeline_register_current_state [40]    <= branch_MEM 	; 
		MEM_WB_pipeline_register_current_state [45:41] <= previous_prediction_addr_MEM_WB[4:0] ; 
	end 

	data_mem # (.MEMORY_SIZE(2048)) Data_MEM(
	.clk(clk),
	.addr(alu_result_MEM_stage[$clog2(2048)-1:0]),
	.we(EX_MEM_pipeline_register[2]),
	.re(EX_MEM_pipeline_register[3]), // it's no effect on the data_mem really, but maybe the logic appeaers in the future and we add it (i predict the nop)	
	.w_data_data_MEM(EX_MEM_pipeline_register_current_state [133:102]),
	.data(readed_data) 
	); 	



     
     

  //WB stage 

	// third mux (write back mux)
	assign write_back_data  = MEM_WB_pipeline_register[0] ? MEM_WB_pipeline_register [33:2] : MEM_WB_pipeline_register [65:34] ;
	assign Regwrite_ctrl_WB_stage = MEM_WB_pipeline_register[1] ; 

	// trick assignment (pipelined)
//	wire [31:0] instruction_test ; 
//        wire [31:0] write_back_data_test ;
//	wire [9:0] pc_addr_test ; 
//	wire [3:0] alu_ctrl_lines_test ;
//
//	wire [1:0] alu_op_test ; 
//	wire alu_src_test      ;
//	wire branch_test       ;
//	wire mem_write_ctrl_test ; 
//	wire reg_write_ctrl_test ;
//	wire mem2reg_ctrl_test ;		

	assign alu_op_test = ID_EX_pipeline_register [7:6] ;
	assign alu_src_test= ID_EX_pipeline_register[5] ;
	assign branch_test = branch_condition	 ;
	assign mem_write_ctrl_test = EX_MEM_pipeline_register[2]  ;
	assign reg_write_ctrl_test = Regwrite_ctrl_WB_stage ; 
	assign mem2reg_ctrl_test   = MEM_WB_pipeline_register[0]  ;


	assign alu_ctrl_lines_test = alu_sel ; 	
	assign pc_addr_test = prog_counter_addr [9:0] ;	
	assign instruction_test = instruction ;
	assign write_back_data_test = write_back_data ; 
endmodule 
