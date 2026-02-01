module immgen (
       input [31:0] instruction,
       output reg [31:0]imm 
); 
	//ImmGen selects a 12-bit field for lw, sw, beq that's sign-extended into a 32-bit result 
	//the branch instruction operates by adding the PC with the 12bits of the instruction shifted left by 1
	//simply concatenating 0 to the branch offset accomplishes this shift
	


  always @(*) begin
	  imm = {32{1'b0}} ; 
    case (instruction[6:0])
      7'b0000011 : imm = {{20{instruction[31]}}, instruction[31:20]}; // lw (I-type) 
      7'b0100011 : imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; //sw (S-type)
      7'b1100011 : imm = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0}; //beq (SB-type) // reconstruction of immediate
      default: imm = 32'b0;
    endcase
  end
endmodule

