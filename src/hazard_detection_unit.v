module hazard_detection_unit (
	input ID_EX_MemRead, 
	input [4:0] ID_EX_RegisterRd, 
	input [4:0] IF_ID_Rs1, 
	input [4:0] IF_ID_Rs2,  
	input [1:0] boot_cnt, 
	input MEM_WB_we_were_wrong, 
	input MEM_WB_branch,
        input our_prediction_ID_EX, 
	input branch_ID_EX, 
	input we_were_wrong_EX_MEM, 	
	output reg stall_ctrl,
        output reg stall_cnt	
);
	always @(*) begin
	  stall_ctrl = 1'b0 ; 
	  if (boot_cnt <= 2'b01)
	  	  stall_ctrl = 1'b0 ; 	  
	  else if (((ID_EX_MemRead) && ((ID_EX_RegisterRd[4:0] == IF_ID_Rs1[4:0]) || (ID_EX_RegisterRd[4:0] == IF_ID_Rs2[4:0]) ) ) | (MEM_WB_we_were_wrong & MEM_WB_branch) | (our_prediction_ID_EX & branch_ID_EX))  
		  stall_ctrl = 1'b1 ; 
	  else 
		  stall_ctrl = 1'b0 ; 
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
