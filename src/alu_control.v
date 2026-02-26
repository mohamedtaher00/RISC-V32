module alu_control (
    input wire [0:1] ALUOp , // from control unit 
    input wire [3:0] instruction, // {funct7 sixth bit, funct3} 

    output reg [3:0] alu_control_lines
) ;


// ALU operation encoding:
  // 0000 = AND
  // 0001 = OR
  // 0010 = ADD
  // 0110 = SUB
  // 0100 = XOR
  // 0101 = SLL (shift left logical)
  // 0111 = SRL (shift right logical)
  // 1000 = SRA (shift right arithmetic)
  // 1001 = SLT (signed less than)
  // 1010 = SLTU (unsigned less than)

  // ALUOp encoding:
  // 00 = ADD (lw, sw, lb, lh, lbu, lhu, sb, sh, jalr)
  // 01 = branch (use funct3 to pick operation)
  // 10 = R-type or I-type ALU (use funct3/funct7 to pick)


  // all of these R-type instructions have func7 field = 0000000, so checking func7 field will not help with them with the lw and sw the func7 doesn't matter if the AluOp comming from the control unit is 00 it's add operation. 
  // I'll just look at wire 30 in the instruction (see fig. 4.12) to tell add and subtract instructions apart
    always @(*) begin
	    alu_control_lines = 4'b0010 ; 
        case(ALUOp)  
            2'b 00 : begin //add operation for loads, stores, or jalr instructions 
                alu_control_lines = 4'b 0010 ;
            end 

            2'b 01 :  begin //subtract operation for branch instructions - decode funct3
		case (instruction[2:0]) // funct3
		          3'b000: alu_control_lines = 4'b0110; // beq  → SUB
		          3'b001: alu_control_lines = 4'b0110; // bne  → SUB
		          3'b100: alu_control_lines = 4'b1001; // blt  → SLT
		          3'b101: alu_control_lines = 4'b1001; // bge  → SLT
		          3'b110: alu_control_lines = 4'b1010; // bltu → SLTU
		          3'b111: alu_control_lines = 4'b1010; // bgeu → SLTU
		          default: alu_control_lines = 4'b0110;
	        endcase
            end 

            2'b 10 : begin  
		    case (instruction[2:0]) // funct3
         		 3'b000: // add/addi or sub (sub only if funct7[5]=1 and R-type)
         		   if (instruction[3] == 1'b1)
         		     alu_control_lines = 4'b0110; // sub
         		   else
         		     alu_control_lines = 4'b0010; // add / addi
         		
			 3'b001: alu_control_lines = 4'b0101; // sll / slli
         		 3'b100: alu_control_lines = 4'b0100; // xor / xori
         		 3'b101: // srl/srli or sra/srai
         		   if (instruction[3] == 1'b1)
         		     alu_control_lines = 4'b1000; // sra / srai
         		   else
         		     alu_control_lines = 4'b0111; // srl / srli
         		
			 3'b110: alu_control_lines = 4'b0001; // or / ori
         		 3'b111: alu_control_lines = 4'b0000; // and / andi
         		 default: alu_control_lines = 4'b0010;
	        endcase
      end

      default: alu_control_lines = 4'b0010;

    endcase  

    end 

endmodule
