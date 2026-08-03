module control_unit (
	input [6:0] instruction,

	output reg branch,
    output reg Memread,
	output reg Memtoreg,
	output reg [1:0] AluOp,
	output reg Memwrite, Alusrc, Regwrite,
    output reg is_jalr,
    output reg is_auipc,
    output reg is_lui
);

  always @(*) begin
	  {is_lui, is_auipc, is_jalr, branch, Memread, Memtoreg, AluOp, Memwrite, Alusrc, Regwrite} ='b 0 ;
      	  case(instruction[6:0])
		  7'b0110011 : begin // R-format
			  Alusrc = 1'b0 ;
			  Memtoreg = 1'b0 ;
			  Regwrite = 1'b1 ;
			  Memread = 1'b0 ;
			  Memwrite = 1'b0 ;
			  branch = 1'b0 ;
			  AluOp = 2'b10 ;
              is_jalr = 1'b0 ;
              is_auipc = 1'b0;
		  end
		  7'b0000011 : begin // I-type  lw, lb, lh, lbu, lhu
			  Alusrc = 1'b1 ;
			  Memtoreg = 1'b1 ;
			  Regwrite = 1'b1 ;
			  Memread = 1'b1 ;
			  Memwrite = 1'b0 ;
			  branch = 1'b0 ;
			  AluOp = 2'b00 ;
              is_jalr = 1'b0 ;
              is_lui = 1'b0 ;
              is_auipc = 1'b0;
		  end
		  7'b1100111 : begin // I-type jalr
			  Alusrc = 1'b1 ;
			  Memtoreg = 1'b0 ;
			  Regwrite = 1'b1 ;
			  Memread = 1'b0 ;
			  Memwrite = 1'b0 ;
			  branch = 1'b1 ;
			  AluOp = 2'b00 ;
              is_jalr = 1'b1 ;
              is_lui = 1'b0 ;
              is_auipc = 1'b0;
		  end
	 	  7'b0010011 : begin // I-type  addi, slli, xori, srli, srai, ori, andi.
			  Alusrc = 1'b1 ;
			  Memtoreg = 1'b0 ;
			  Regwrite = 1'b1 ;
			  Memread = 1'b0 ;
			  Memwrite = 1'b0 ;
			  branch = 1'b0 ;
			  AluOp = 2'b11 ;
              is_jalr = 1'b0 ;
              is_lui = 1'b0 ;
              is_auipc = 1'b0;
		  end
		  7'b0100011 : begin // S-type sw, sb, sh
			  Alusrc = 1'b1 ;
			  Memtoreg = 1'b0 ; //don't care
			  Regwrite = 1'b0 ;
			  Memread = 1'b0 ;
			  Memwrite = 1'b1 ;
			  branch = 1'b0 ;
			  AluOp = 2'b00 ;
              is_jalr = 1'b0 ;
              is_lui = 1'b0 ;
              is_auipc = 1'b0;
		  end
		  7'b1100011 : begin // SB-type beq, bne, blt, bge, bltu, bgeu
			  Alusrc = 1'b0 ;
			  Memtoreg = 1'b0 ; // don't care
			  Regwrite = 1'b0 ;
			  Memread = 1'b0 ;
			  Memwrite = 1'b0 ;
			  branch = 1'b1 ;
			  AluOp = 2'b01 ;
              is_jalr = 1'b0 ;
              is_lui = 1'b0 ;
              is_auipc = 1'b0;
		  end
          7'b1101111 : begin // jal, J-type
              Alusrc = 1'b1 ;// don't care; the additoin would be done by separate adder not the ALU
              Memtoreg = 1'b0 ;
              Regwrite = 1'b1 ;
              Memread = 1'b0 ;
              Memwrite = 1'b0 ;
              branch = 1'b1 ;
              AluOp = 2'b00 ;
              is_jalr = 1'b0 ;
              is_lui = 1'b0 ;
              is_auipc = 1'b0;
          end
          7'b0110111 : begin // lui, U-type
              Alusrc = 1'b1 ;//
              Memtoreg = 1'b0 ;
              Regwrite = 1'b1 ;
              Memread = 1'b0 ;
              Memwrite = 1'b0 ;
              branch = 1'b0 ;
              AluOp = 2'b00 ;
              is_jalr = 1'b0 ;
              is_lui = 1'b1 ;
              is_auipc = 1'b0;
          end
          7'b0010111 : begin // auipc, U-type
              Alusrc = 1'b1 ;//
              Memtoreg = 1'b0 ;
              Regwrite = 1'b1 ;
              Memread = 1'b0 ;
              Memwrite = 1'b0 ;
              branch = 1'b0 ;
              AluOp = 2'b00 ;
              is_jalr = 1'b0 ;
              is_lui = 1'b0 ;
              is_auipc = 1'b1;
              end
		 default : {is_lui, is_auipc, is_jalr, branch, Memread, Memtoreg, AluOp, Memwrite, Alusrc, Regwrite, is_jalr} ='b 0 ;


	  endcase

  end


endmodule
