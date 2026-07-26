module hazard_detection_unit (
	input ID_EX_MemRead,
	input [4:0] ID_EX_RegisterRd,
	input [4:0] IF_ID_Rs1,
	input [4:0] IF_ID_Rs2,
	input [1:0] boot_cnt,
	input MEM_WB_we_were_wrong,
	input MEM_WB_branch,
    input our_prediction_ID_EX,
	input branch_id_ex,
	input we_were_wrong_EX_MEM,

    input reg_w_id_ex,
    input is_jalr_id_ex,
    input branch_ex_mem,
    input reg_w_ex_mem,
    input is_jalr_ex_mem,

	output reg flush,
    output reg stall_cnt
);
	always @(*) begin
	  flush = 1'b0 ;
	  if (boot_cnt <= 2'b01)
	  	  flush = 1'b0 ;
	  else if (((ID_EX_MemRead) && ((ID_EX_RegisterRd[4:0] == IF_ID_Rs1[4:0]) || (ID_EX_RegisterRd[4:0] == IF_ID_Rs2[4:0]) ) ) // lw-use
          | ((MEM_WB_we_were_wrong & MEM_WB_branch) | (our_prediction_ID_EX & branch_id_ex)) // prev. misprediction or current prediction
          | (is_jalr_ex_mem | is_jalr_id_ex) // jalr has penalty of 2 clock-cycles
          | (branch_id_ex & reg_w_id_ex & ~is_jalr_id_ex)) // jal has penalty of 1 clock-cycle
		  flush = 1'b1 ;
	  else
		  flush = 1'b0 ;
	end

	always @(*) begin
		stall_cnt = 1'b0 ;
		if (boot_cnt <= 2'b01)
			stall_cnt = 1'b0 ;
		else if ((~we_were_wrong_EX_MEM) && (ID_EX_MemRead) && ((ID_EX_RegisterRd[4:0] == IF_ID_Rs1[4:0]) || (ID_EX_RegisterRd[4:0] == IF_ID_Rs2[4:0]) ))
			stall_cnt = 1'b1 ;
		else
			stall_cnt = 1'b0 ;

	end


endmodule
