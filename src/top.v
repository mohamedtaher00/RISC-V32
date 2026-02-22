//============================================================================
// Pipeline Register Bit Field Map
//============================================================================
// if_id [102:0]: 
//   [63:0] = inst_addr_if 
//   [95:64] = instruction     
//   [97:96] = our_prediction ;IF/ID [102:0]
//   [102:98] = pc_addr_low_bits
// 
//
// id_ex [257:0]:
//   [7:0] =     id_ex_ctrl_unit_current    
//   [71:8] =    id_ex_pc_current    
//   [103:72] =  reg_file_out1_id 			 
//   [135:104] = reg_file_out2_id 	   
//   [167:136] = id_ex_immgen_current  
//   [172:168] = id_ex_rs1_current     
//   [177:173] = id_ex_rs2_current     
//   [182:178] = id_ex_rd_current      
//   [186:183] = id_ex_alu_ctrl_current 
//   [250:187] = id_ex_return_addr_current	
//   [252:251] = id_ex_our_prediction_current  	
//   [257:253] = id_ex_previous_prediction_addr_current 
//
//
// ex_mem [145:0] :  
//   [4:0] = ctrl_signals_ex 
//   [68:5]     = return_addr_ex
//   [69]	   = zero_flag 	      
//   [101:70]    = alu_result_ex 
//   [133:102]   = write_data_ex   
//   [138:134]   = rd_ex 	   
//   [139]	   = branch_mispredicted_mem  
//   [144:140]   = previous_prediction_addr_ex_mem 
//   [145]	   = final_verdict 
//
//
// mem_wb [77:0] :
//   [1:0]   = ctrl_signals_mem ;	
//   [33:2] = readed_data_mem ; 
//   [65:34] = alu_result_mem ; 
//   [70:66] = rd_mem		;
//   [71]    = we_were_wrong_wb ; 
//   [72]    = branch_mem 	; 
//   [77:73] = previous_prediction_addr_mem 
//
//
//============================================================================


module top (
       input clk,
       input reset_n,



	// tricking (pipelined) 
	output [31:0] instruction_test  	,	
        output [31:0] write_back_data_test	, 
        output [9:0] pc_addr_test 		, 
        output [3:0] alu_ctrl_lines_test	,



//	output [31:0] pc_addr_if ,
//        output reg [63:0] pc_nxt_addr_if ,
//        output [63:0] pc_64_addr_if  ,


	output [1:0] alu_op_test 		, 
        output alu_src_test     		, 
        output branch_test      		, 
        output mem_write_ctrl_test  		,
        output reg_write_ctrl_test		,	
        output mem2reg_ctrl_test, 
	
	// memory interface 
//	output [:] addr, // calculated at ex stage, then available at ex_mem  
//	output [31:0] write_data, // sw -> register file provides the data at id stage, then available at id_ex  
//	input [31:0] read_data, // lw -> data mem provides the data at mem stage, then available at mem_wb  
//	output write_enable, // in case of sw, when do we need this to be on? simply when we write a periphral (mem stage) 
//	output read_enable // in case of lw, when do we need this to be on? simply when we read a periphral (wb stage)
	
	// UART(tty) interface
	input rx, 	
	output tx

);


  reg [1:0] boot_cnt;

  always @(posedge clk or negedge reset_n) begin
      if (!reset_n)
          boot_cnt <= 2'd0;
      else if (boot_cnt < 2'd3)
          boot_cnt <= boot_cnt + 2'd1;
  end

  wire pipeline_valid ;
  assign pipeline_valid = (boot_cnt >= 2'd3);

	 
	// IF stage intermediate signals 
	wire [102:0] if_id ; 
	reg [63:0] inst_addr_if ;

	wire [63:0] inst_addr_plus4_if ;//branch mux
	
	wire [31:0] instruction ; //instruction_mem/data path interface
	
	wire [63:0] pc_64_addr_if ; 	
	reg [63:0] pc_nxt_addr_if ; 
	wire [13:0]  pc_addr_if ; // it should be [ADDR_WIDRH-1:0]  
	reg [4:0] pc_addr_low_bits ; 
	wire [1:0] our_prediction ; 	
	
	
	// ID stage intermediate signals 
	wire [257:0] id_ex ; // 32(register1)+ 32(register2)+ 32(imm) +64(PC) +15(addresses of two sources and dest)+ 4(alu_ctrl)+ 8(ctrl lines)
	
	
	// control_unit/data path interface
	wire branch_ctrl_id ;
	wire mem_write_ctrl_id ;
	wire memtoreg_ctrl_id ;
	wire mem_read_ctrl_id ;
	wire [1:0] alu_op_ctrl_id ;
	wire alu_src_ctrl_id ;
	wire reg_write_ctrl_id ;	

	
	wire [63:0] branch_target_addr_id ; 

	reg  [63:0] return_addr_id ;

	wire [31:0] immgen_out_id ; 


	reg [7:0] id_ex_ctrl_unit_current ;   
        reg [63:0] id_ex_pc_current; 
        reg [31:0] id_ex_immgen_current ;  
        reg [4:0] id_ex_rs1_current   ;      
        reg [4:0] id_ex_rs2_current   ;         
        reg [4:0] id_ex_rd_current      ;
	reg [3:0] id_ex_alu_ctrl_current ;
	reg [63:0]id_ex_return_addr_current	;
        reg [1:0] id_ex_our_prediction_current ; 	
	reg [4:0] id_ex_previous_prediction_addr_current ; 	
	
	wire [7:0]  id_ex_ctrl_unit_nxt ;   
        wire [63:0] id_ex_pc_nxt; 
        wire [31:0] id_ex_immgen_nxt ;  
        wire [4:0]  id_ex_rs1_nxt   ;      
        wire [4:0]  id_ex_rs2_nxt   ;         
        wire [4:0]  id_ex_rd_nxt      ;
	wire [3:0]  id_ex_alu_ctrl_nxt ;
	wire [63:0] id_ex_return_addr_nxt	;
        wire [1:0]  id_ex_our_prediction_nxt ; 	
	wire [4:0]  id_ex_previous_prediction_addr_nxt ; 
	
	
	
	
	
	wire stall_ctrl ;
	wire stall_cnt ; 
        wire [7:0] stall_mux_out ;	

	
	wire [31:0] reg_file_out1_id 	;		 
	wire [31:0] reg_file_out2_id 	   ; 


	// EX stage intermediate signals 
	wire [145:0] ex_mem ; //64(calculated address) + 32(alu_o/p) + 1(zero_flag) + 5(destination_reg) + 32(store data if sw) + 5 (rest of ctrl_unit)
	
	
	// Alu/data path interface
	reg [31:0] alu_src_1;
        wire [31:0] alu_src_2 ;
        reg [31:0]  alu_muxB_src ; 
	wire zero_flag ;
	wire [31:0] alu_result_ex ;
	wire [3:0] alu_sel ;

	
	
	wire final_verdict ;


	wire [4:0] ctrl_signals_ex ;
	wire [31:0] write_data_ex ; 
	wire [4:0] rd_ex ; 	
	reg [145:0] ex_mem_current_state ;  
	wire [63:0] return_addr_ex ;
	 
	wire [1:0] forwardA, forwardB ;
	wire [4:0] previous_prediction_addr_ex_mem ;
	
	
	// MEM stage intermediate signals 
	wire [77:0] mem_wb ; //32(read data) + 32(alu_result_mem) + 2(WB control signals) + Rd = 71 
	
	wire [31:0] readed_data_mem ; 
	wire [31:0] readed_data_mem_mem 	;
	wire [1:0]  ctrl_signals_mem	;
	wire branch_mem ; 
	wire [4:0] rd_mem			; 
	wire [31:0] alu_result_mem; 
	wire branch_mispredicted_mem 	; 
	wire [4:0] previous_prediction_addr_mem ; 
	
	wire sel_imem_mem ;	 
        wire sel_dmem_mem ;      
        wire sel_uart_mem ;       
        wire sel_gpio_mem ;	
        wire sel_timer_mem; 	

	wire [31:0] readed_data_uart ; 
	
	//WB stage intermediate signals 
	reg [45:0] mem_wb_current_state ; 
	
	wire we_were_wrong_wb 	; 

	wire regwrite_ctrl_wb    ;

	wire [31:0] write_back_data ;

  // IF stage 
	// next_addr_mux ; we may have stall, not valid pipeline, a branch, a correction of a branch 	
	always @(*) begin 
		if (!pipeline_valid) 
			pc_nxt_addr_if = inst_addr_plus4_if ;
	        else if (ex_mem [139] & ex_mem[4]) // ex_mem [139]: branch_mispredicted_mem, ex_mem[4]: branch
			pc_nxt_addr_if = ex_mem[68:5]  ; //  ex_mem[68:5]: return addr 
		else if (our_prediction[1] & branch_ctrl_id) 
			pc_nxt_addr_if = branch_target_addr_id ; 
		else 
			pc_nxt_addr_if = inst_addr_plus4_if ; 	
	end 	
	
	
	
	rca # (.n(64)) adder1(
		.x(64'h0000_0000_0000_0004),
		.y(pc_64_addr_if),
		.c_in(1'b0),
		.s(inst_addr_plus4_if),
		.c_out()//we'll ignore the overflow for now 
	);
    // program counter
	prog_count  # (.INST_MEMORY_SIZE(1024)) Program_counter(
		.clk(clk),
		.reset_n(reset_n),
		.stall(stall_cnt), 
		.addr_in(pc_nxt_addr_if),
		.addr_2_INST_MEM(pc_addr_if),
		.addr_2_IF_ID_pipeline_reg(pc_64_addr_if)
	);
	// instruction memory 	
	instruction_mem #(.INST_MEMORY_SIZE(1024)) Instruction_MEM(
		.clk(clk),
		.stall(stall_cnt), 
		.read_addr(pc_addr_if), 
		.write_addr(ex_mem[101:70] ),// [101:70] alu_result 
		.write_data(ex_mem[133:102]), // write data
		.w_en(sel_imem_mem & ex_mem[2] ), // ex_mem[2] mem_write ctrl signal 
		.readed_data(instruction) 
	);  
	    	  
       // o/p logic for IF/ID pipeline register 	
	assign if_id [95:64] = instruction ; 
	assign if_id [63:0] = inst_addr_if ;
	assign if_id [97:96] = our_prediction ; 	


	assign if_id [102:98] = pc_addr_low_bits  ;

	always @(posedge clk) begin 
		if(!stall_cnt) begin 	
	         inst_addr_if <= pc_64_addr_if;// this part is needed to be clocked, the reg_file o/p is already clocked
		 pc_addr_low_bits <= pc_addr_if[4:0] ;
		end 
		else begin  
	         inst_addr_if <= inst_addr_if ;
	         pc_addr_low_bits <= pc_addr_low_bits ; 
		end 	
	end 		
	bht predictor(
		.reset_n(reset_n), 
		.clk(clk), 
		.addr_needs_predition(pc_addr_if[4:0]), //low order bits from the pc 
		.previous_prediction_addr_ID_EX(id_ex [257:253]) ,//from ID/EX
	        .previous_prediction_addr_MEM_WB(mem_wb[77:73]), 
		.branch_EX_MEM(ex_mem[4]), 
		.branch_MEM_WB(mem_wb[72]) , 
		.final_verdict(ex_mem[145]) ,// 1 means taken, 0 means not taken -> from MEM/WB 
		.our_prediction(our_prediction)
	); 	
                    
  // ID stage 
    // control unit
	control_unit Control_Unit(
		.instruction(instruction[6:0]),
		.branch(branch_ctrl_id),
                .Memread(mem_read_ctrl_id), 
                .Memtoreg(memtoreg_ctrl_id), 
                .AluOp(alu_op_ctrl_id), 
		.Memwrite(mem_write_ctrl_id),
	       	.Alusrc(alu_src_ctrl_id),
	       	.Regwrite(reg_write_ctrl_id)
	);

	assign stall_mux_out = stall_ctrl ? 8'b0 :  {alu_op_ctrl_id, alu_src_ctrl_id, branch_ctrl_id,  mem_read_ctrl_id, mem_write_ctrl_id, reg_write_ctrl_id, memtoreg_ctrl_id} ;  

    // register file 

	reg_file # (.WIDTH(32), .ADDR_WIDTH(5)) Reg_file(
		.clk(clk), 
		.we(regwrite_ctrl_wb), 
		.r_addr1(instruction[19:15]),
		.r_addr2(instruction[24:20]),
		.w_addr(mem_wb [70:66]),
		.w_data_reg_file(write_back_data),
		.read_reg1(reg_file_out1_id),
		.read_reg2(reg_file_out2_id)
	);

    // ImmGen
	immgen ImmGen(
	       .instruction(instruction), 
	       .imm(immgen_out_id)
	);

	// output logic 	
	assign id_ex [7:0] =     id_ex_ctrl_unit_current   ; 
	assign id_ex [71:8] =    id_ex_pc_current ;   
	assign id_ex [103:72] =  reg_file_out1_id 			   ; // not clocked by pipeline register, clocked by reg_file ; rs1 register(not address)
	assign id_ex [135:104] = reg_file_out2_id 	   ; //not clocked by pipeline register, clocked by reg_file  ; rs2 register(not address)
	assign id_ex [167:136] = id_ex_immgen_current  ;
	assign id_ex [172:168] = id_ex_rs1_current     ;
	assign id_ex [177:173] = id_ex_rs2_current     ;
	assign id_ex [182:178] = id_ex_rd_current      ;
	assign id_ex [186:183] = id_ex_alu_ctrl_current ;
	assign id_ex [250:187] = id_ex_return_addr_current	;
        assign id_ex [252:251] = id_ex_our_prediction_current ; 	
	assign id_ex [257:253] = id_ex_previous_prediction_addr_current ; 


	always @(posedge clk) begin //stuff that needed to be clocked  ; current state logic  
		id_ex_alu_ctrl_current  <= id_ex_alu_ctrl_nxt    ;  
		id_ex_ctrl_unit_current <= id_ex_ctrl_unit_nxt;
		id_ex_pc_current        <= id_ex_pc_nxt ;   
		id_ex_immgen_current    <= id_ex_immgen_nxt ; 
		id_ex_rd_current	<= id_ex_rd_nxt ;  
		id_ex_rs1_current	<= id_ex_rs1_nxt ; 
		id_ex_rs2_current	<= id_ex_rs2_nxt ; 
	        id_ex_return_addr_current <= id_ex_return_addr_nxt ; 
		id_ex_our_prediction_current <= id_ex_our_prediction_nxt ; 
		id_ex_previous_prediction_addr_current <= id_ex_previous_prediction_addr_nxt ;  	
	end

	// next state logic 	
        assign id_ex_our_prediction_nxt = if_id [97:96] ; 	
	assign id_ex_ctrl_unit_nxt = stall_mux_out 	; 
	assign id_ex_alu_ctrl_nxt = {if_id[94], if_id[78:76]} ;
	assign id_ex_pc_nxt =  if_id[63:0] ;
        assign id_ex_immgen_nxt = immgen_out_id ;                	
        assign id_ex_rd_nxt   = if_id[75:71] ; 
        assign id_ex_rs1_nxt  = if_id[83:79] ; 
        assign id_ex_rs2_nxt  = if_id[88:84] ;
        assign id_ex_return_addr_nxt = return_addr_id ; 
        assign id_ex_previous_prediction_addr_nxt = if_id[102:98] ; 







  // hazard detection unit 
	hazard_detection_unit lw_use_hazard( 
		.ID_EX_MemRead(id_ex[3]),
		.MEM_WB_branch(mem_wb[72]), 
		.MEM_WB_we_were_wrong(mem_wb[71]), 
		.boot_cnt(boot_cnt),
		.our_prediction_ID_EX(id_ex[252]),
		.branch_ID_EX(id_ex[4]),
		.ID_EX_RegisterRd(id_ex[182:178]),
		.IF_ID_Rs1(if_id[83:79]),
		.IF_ID_Rs2( if_id[88:84]     ),
		.we_were_wrong_EX_MEM(ex_mem[139]), 
		.stall_cnt(stall_cnt), 
		.stall_ctrl(stall_ctrl)
	); 


	 //target address adder/calculator 

	rca # (.n(64)) adder2(
		.x({32'b0, immgen_out_id}), // immed 
		.y(if_id[63:0]), //PC address 
		.c_in(1'b0),
		.s(branch_target_addr_id),
		.c_out()//we'll ignore the overflow for now 
	);

	// return address mux 
	always @(*) begin 
		if(our_prediction[1]) //taken  
			return_addr_id = pc_64_addr_if ; 
		else // not taken 
			return_addr_id = branch_target_addr_id ; 
	end 	

  // EX stage
	  	
	//next state logic 
	assign rd_ex = id_ex [182:178] ;
	assign write_data_ex = id_ex[135:104] ;
	assign ctrl_signals_ex = id_ex [4:0] ;
	assign return_addr_ex = id_ex [250:187] ; 
	assign previous_prediction_addr_ex_mem = id_ex [257:253] ; 

	always @(posedge clk) begin 
		//current_state logic
		//EX_MEM_pipeline_reg[139] is branch_mispredicted_mem, and mem_wb[71] also. ex_mem[4] and mem_wb[72] are branch
		if ((ex_mem[139] & ex_mem[4] ) | (mem_wb[71] & mem_wb[72] ) )  
			ex_mem_current_state [4:0] <= 5'b00000 ;
		else 
			ex_mem_current_state [4:0]    <= ctrl_signals_ex           ;


		ex_mem_current_state [68:5]     <= return_addr_ex ;
		ex_mem_current_state [69]	   <= zero_flag 	     ; 
		ex_mem_current_state [101:70]    <= alu_result_ex 	     ;
		ex_mem_current_state [133:102]   <= write_data_ex     ;
		ex_mem_current_state [138:134]   <= rd_ex 	     ;
		ex_mem_current_state [139]	   <= branch_mispredicted_mem  ;
		ex_mem_current_state [144:140]   <= previous_prediction_addr_ex_mem ;
		ex_mem_current_state [145]	   <= final_verdict ;  
	end
       // output logic 
	assign ex_mem = {
		ex_mem_current_state [145] , 
		ex_mem_current_state [144:140] , 
		ex_mem_current_state  [139],  
		ex_mem_current_state  [138:134]    , 
		ex_mem_current_state [133:102], 
		ex_mem_current_state  [101:70]     , 
		ex_mem_current_state  [69]	     ,  
		ex_mem_current_state  [68:5]       ,  
		ex_mem_current_state  [4:0]          
	}; 	

    // ALU 
	assign alu_src_2 = (id_ex[5]) ? id_ex [167:136] : alu_muxB_src ;// [167:136] for immed, [135:104] reg_file_out2_id.
	
		  	
	alu ALU(
		.alu_control_lines(alu_sel),
		.operand1(alu_src_1),
		.operand2(alu_src_2),
		.ALU_result(alu_result_ex), 
		.zero(zero_flag)
	);

  // ALU control
 
	alu_control ALU_Control(
		.ALUOp(id_ex [7:6]),
		.instruction(id_ex [186:183]),
		.alu_control_lines(alu_sel)
	); 
  
	
	and (final_verdict, zero_flag , id_ex[4]); 
	assign branch_mispredicted_mem =  id_ex[4] & (final_verdict ^ id_ex[252] ) ;
  
	// forwarding unit
	 
	forwarding_unit Forwarding_Unit(
		.ID_EX_RegisterRs1(id_ex[172:168]),
	        .ID_EX_RegisterRs2(id_ex[177:173]),
	                           
	        .EX_MEM_RegisterRd(ex_mem[138:134]),
	        .MEM_WB_RegisterRd(mem_wb[70:66]),
	                           
	        .EX_MEM_RegWrite(ex_mem[1]),
	        .MEM_WB_RegWrite(mem_wb[1]),

		.ForwardA(forwardA), 
                .ForwardB(forwardB)
	);
	//forwarding muxs check out FIGURE 4.57 @ the book
	always @(*) begin
		case (forwardA)  
		  2'b00 :  
			alu_src_1 = id_ex [103:72]	;
		  2'b10 :  
			alu_src_1 = ex_mem [101:70]   ; 
		  2'b01 : 
			alu_src_1 = mem_wb [65:34]    ; 
			default : alu_src_1 = id_ex [103:72] ; 
		endcase 
	end 
	always @(*) begin
		case (forwardB)  
		  2'b00 :  
			alu_muxB_src = id_ex [135:104]	;
		  2'b10 :  
			alu_muxB_src = ex_mem [101:70]   ; 
		  2'b01 : 
			alu_muxB_src = mem_wb [65:34]    ; 
		
		default : alu_muxB_src = id_ex [135:104] ; 
		endcase 
	end 


  // MEM stage 


	assign readed_data_mem = (sel_uart_mem) ? readed_data_uart : readed_data_mem_mem ; 	
	//output logic 
	assign mem_wb = { 	mem_wb_current_state [45:41], 
						mem_wb_current_state [40], 	
						mem_wb_current_state [39]  , 	
						mem_wb_current_state [38:34], 
						mem_wb_current_state [33:2], 
                                                readed_data_mem, // doesn't need to be clocked, already clocked from the data_memory
                                                mem_wb_current_state [1:0]
	} ; 

	//next state logic 
	assign ctrl_signals_mem = ex_mem [1:0]; 
	assign alu_result_mem = ex_mem [101:70] ; 
	assign rd_mem = ex_mem [138:134] ; 
	assign we_were_wrong_wb = ex_mem [139] ; 
	assign branch_mem = ex_mem[4] ;
	assign previous_prediction_addr_mem [4:0] = ex_mem[144:140]	; 
	// current sate logic 
	
	always @(posedge clk) begin
	       // current_state_logic	
		mem_wb_current_state [1:0]   <= ctrl_signals_mem ;	
		mem_wb_current_state [33:2] <= alu_result_mem ; 
		mem_wb_current_state [38:34] <= rd_mem		;
		mem_wb_current_state [39]    <= we_were_wrong_wb ; 
		mem_wb_current_state [40]    <= branch_mem 	; 
		mem_wb_current_state [45:41] <= previous_prediction_addr_mem[4:0] ; 
	end 

	data_mem # (.MEMORY_SIZE(12288)) Data_MEM(
	.clk(clk),
	.addr(alu_result_mem[$clog2(2048)-1:0]),
	.we(ex_mem[2] & sel_dmem_mem), //memory write ctrl signal 
	.re(ex_mem[3]), //memory read ctrl signal  it's no effect on the data_mem really, but maybe the logic appeaers in the future and we add it (i predict the nop)	
	.w_data_MEM(ex_mem [133:102]),
	.data(readed_data_mem_mem) 
	); 	





	// Address decoder 
	//===========================================================================
	// Address Map
	//===========================================================================
	// 0x00000000 - 0x00003FFF  : Instruction Memory (16KB)
	// 0x00004000 - 0x00006FFF  : Data Memory        (12KB)
	// 0x80000000 - 0x8000000F  : UART registers
	// 0x80000010 - 0x8000001F  : GPIO registers
	
	address_decoder addr_decoder( 
		.addr(ex_mem[101:70]), 		//   [101:70]    = alu_result_ex 
                .sel_imem(sel_imem_mem), 
                .sel_dmem(sel_dmem_mem), 
                .sel_uart(sel_uart_mem), 
                .sel_gpio(sel_gpio_mem)
	);


	// UART
	uart uart_wrapper(
		.clk(clk) ,             	
                .write_data(ex_mem [133:102]), 
                .data_in_rx(rx), 
		.data_out_tx(tx) , 
                .mem_write(ex_mem[2]) , 
                .sel_uart(sel_uart_mem) , 
                .addr(alu_result_mem[3:0]), 
		.readed_data(readed_data_uart) 
	); 	

  //WB stage 

	// third mux (write back mux)
	assign write_back_data  = mem_wb[0] ? mem_wb [33:2] : mem_wb [65:34] ;
	assign regwrite_ctrl_wb = mem_wb[1] ; 

		

	assign alu_op_test = id_ex [7:6] ;
	assign alu_src_test= id_ex [5] ;
	assign branch_test = final_verdict	 ;
	assign mem_write_ctrl_test = ex_mem[2]  ;
	assign reg_write_ctrl_test = regwrite_ctrl_wb ; 
	assign mem2reg_ctrl_test   = mem_wb[0]  ;


	assign alu_ctrl_lines_test = alu_sel ; 	
	assign pc_addr_test = pc_addr_if [9:0] ;	
	assign instruction_test = instruction ;
	assign write_back_data_test = write_back_data ; 
endmodule 
