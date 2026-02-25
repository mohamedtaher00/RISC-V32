module immgen (
       input [31:0] instruction,
       output reg [31:0]imm 
); 
	//ImmGen selects a 12-bit field for lw, sw, beq that's sign-extended into a 32-bit result 
	//the branch instruction operates by adding the PC with the 12bits of the instruction shifted left by 1
	//simply concatenating 0 to the branch offset accomplishes this shift
	


  always @(*) begin
    case (instruction[6:0])

      	    7'b0000011 : imm = {{20{instruction[31]}}, instruction[31:20]}; // I-type lw, lb, lh, lbu, lhu 
	    7'b0010011 : imm = {{20{instruction[31]}}, instruction[31:20]}; // I-type addi, slli, xori, srli, srai, ori, andi 
	    7'b1100111 : imm = {{20{instruction[31]}}, instruction[31:20]}; //jalr
	    7'b0100011 : imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; //sw, sh, sb (S-type)
      	    7'b1100011 : imm = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0}; //beq, bne, blt, bge, bltu, bgeu (SB-type) // reconstruction of immediate
      	    7'b0110111 : imm = {instruction[31:12], 12'b0}; // U-type lui 
      	    7'b0010111 : imm = {instruction[31:12], 12'b0}; // U-type auipc
	    7'b1101111 : imm = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0}; // UJ-type jal
	    
      default: imm = 32'b0;
    endcase
  end
endmodule
