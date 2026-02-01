module forwarding_unit (
  input [4:0] ID_EX_RegisterRs1, 
  input [4:0] ID_EX_RegisterRs2, 
  
  input [4:0] EX_MEM_RegisterRd, 
  input [4:0] MEM_WB_RegisterRd,
  
  input EX_MEM_RegWrite,
  input MEM_WB_RegWrite, 
 

  output reg [1:0] ForwardA, 
  output reg [1:0] ForwardB
);
  // ForwardA logic 	
    always @(*) begin
      ForwardA = 2'b00 ;
      if (EX_MEM_RegWrite && ~(EX_MEM_RegisterRd[4:0] == 5'b0 ) && (EX_MEM_RegisterRd[4:0] == ID_EX_RegisterRs1[4:0])) begin //EX hazard
       		  ForwardA = 2'b10 ;
	      end  

      else if (MEM_WB_RegWrite && ~(MEM_WB_RegisterRd[4:0] == 5'b0 ) && ~(EX_MEM_RegWrite && ~(EX_MEM_RegisterRd[4:0] == 5'b0) && (EX_MEM_RegisterRd[4:0] == ID_EX_RegisterRs1[4:0])) && (MEM_WB_RegisterRd[4:0] == ID_EX_RegisterRs1[4:0])) begin // MEM hazard  
		  ForwardA = 2'b01 ;
	      end  
      else begin  
        ForwardA = 2'b00 ;
      end  

    end 
  // ForwardB logic

     always @(*) begin 
      ForwardB = 2'b00 ;  
      if (EX_MEM_RegWrite && ~(EX_MEM_RegisterRd[4:0] == 5'b0 ) && (EX_MEM_RegisterRd[4:0] == ID_EX_RegisterRs2[4:0]) ) begin //EX hazard
	          ForwardB = 2'b10 ;
      end 

      else if (MEM_WB_RegWrite && ~(MEM_WB_RegisterRd[4:0] == 5'b0 ) && ~(EX_MEM_RegWrite && ~(EX_MEM_RegisterRd[4:0] == 5'b0) && (EX_MEM_RegisterRd[4:0] == ID_EX_RegisterRs2[4:0])) && (MEM_WB_RegisterRd[4:0] == ID_EX_RegisterRs2[4:0])) begin // MEM hazard  
	 	 ForwardB = 2'b01 ;
	      end  

      else begin  
             ForwardB = 2'b00 ;
      end  
     end 
endmodule 	
