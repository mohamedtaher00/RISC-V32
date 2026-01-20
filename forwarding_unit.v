module forwarding_unit (
  input ID_EX_RegisterRs1, 
  input ID_EX_RegisterRs2, 
  
  input EX_MEM_RegisterRd, 
  input MEM_WB_RegisterRd,
  
  input EX_MEM_RegWrite,
  input MEM_WB_RegWrite, 
  
  output reg [1:0] ForwardA, 
  output reg [1:0] ForwardB
);
  // ForwardA logic 	
    always @(*) begin 
      if (EX_MEM_RegWrite & ~(EX_MEM_RegisterRd == 0 ) ) begin //EX hazard
        if (EX_MEM_RegisterRd == ID_EX_RegisterRs1) 
          ForwardA = 2'b10 ; 
        else 
       	  ForwardA = 2'b00 ;
      end 

      else if (MEM_WB_RegWrite & ~(MEM_WB_RegisterRd == 0 ) & ~(EX_MEM_RegWrite & ~(EX_MEM_RegisterRd == 0) & (EX_MEM_RegisterRd == ID_EX_RegisterRs1)) ) begin // MEM hazard  
        if ( MEM_WB_RegisterRd == ID_EX_RegisterRs1 ) 
	  ForwardA = 2'b01 ;
        else 
          ForwardA = 2'b00 ; 
      end 	      

      else 
        ForwardA = 2'b00 ;

      end

  // ForwardB logic 
     always @(*) begin 
      if (EX_MEM_RegWrite & ~(EX_MEM_RegisterRd == 0 ) ) begin //EX hazard
        if (EX_MEM_RegisterRd == ID_EX_RegisterRs2) 
          ForwardB = 2'b10 ; 
        else 
       	  ForwardB = 2'b00 ;
      end 

      else if (MEM_WB_RegWrite & ~(MEM_WB_RegisterRd == 0 ) & ~(EX_MEM_RegWrite & ~(EX_MEM_RegisterRd == 0) & (EX_MEM_RegisterRd == ID_EX_RegisterRs2)) ) begin // MEM hazard  
        if ( MEM_WB_RegisterRd == ID_EX_RegisterRs2 ) 
	  ForwardB = 2'b01 ;
        else 
          ForwardB = 2'b00 ; 
      end 	      

      else 
        ForwardB = 2'b00 ;

      end
endmodule 	
