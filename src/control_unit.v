module control_unit (
	input [6:0] instruction, 

	output reg branch,
       	output reg Memread, 
	output reg Memtoreg, 
	output reg [1:0] AluOp, 
	output reg Memwrite, Alusrc, Regwrite
);
  
  always @(*) begin
	  {branch, Memread, Memtoreg, AluOp, Memwrite, Alusrc, Regwrite} ='b 0 ; 
      	  case(instruction[6:0])
		  7'b0110011 : begin // R-format b
			  Alusrc = 1'b0 ;
			  Memtoreg = 1'b0 ;
			  Regwrite = 1'b1 ;
			  Memread = 1'b0 ;
			  Memwrite = 1'b0 ;
			  branch = 1'b0 ;
			  AluOp = 2'b10 ;
		  end 
		  7'b0000011 : begin // lw 
			  Alusrc = 1'b1 ;
			  Memtoreg = 1'b1 ;
			  Regwrite = 1'b1 ;
			  Memread = 1'b1 ;
			  Memwrite = 1'b0 ;
			  branch = 1'b0 ;
			  AluOp = 2'b00 ;
		  end 
		  7'b0100011 : begin //sw 
			  Alusrc = 1'b1 ;
			  Memtoreg = 1'b0 ; //don't care
			  Regwrite = 1'b0 ;
			  Memread = 1'b0 ;
			  Memwrite = 1'b1 ;
			  branch = 1'b0 ;
			  AluOp = 2'b00 ;
		  end 
		  7'b1100011 : begin //beq 
			  Alusrc = 1'b0 ;
			  Memtoreg = 1'b0 ; // don't care
			  Regwrite = 1'b0 ;
			  Memread = 1'b0 ;
			  Memwrite = 1'b0 ;
			  branch = 1'b1 ;
			  AluOp = 2'b01 ;
		  end
		 default {branch, Memread, Memtoreg, AluOp, Memwrite, Alusrc, Regwrite} ='b 0 ; 


	  endcase 

  end 


endmodule 
