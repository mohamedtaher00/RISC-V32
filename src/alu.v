module alu(
    input wire[3:0] alu_control_lines,
    input wire[31:0] operand1,
    input wire[31:0] operand2, 

    output reg[31:0] ALU_result,
    output zero
    
);

	
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


    always @(*) begin 
	    ALU_result = 'b0 ;
        case(alu_control_lines)  

            4'b0000 : begin // AND 
                ALU_result = operand1 & operand2 ;

            end
            4'b0001 : begin // OR 
                ALU_result = operand1 | operand2 ;
            end 

            4'b0010 : begin // ADD 
                ALU_result = operand1 + operand2 ;
            end 
            4'b0100 : begin // XOR  
                ALU_result = operand1 ^ operand2 ;
            end 
            4'b0101 : begin // SLL  
                ALU_result = operand1 << operand2[4:0] ;
            end 
            4'b0111 : begin // SRL  
                ALU_result = operand1 >> operand2[4:0] ;
            end 
            4'b1000 : begin // SRA  
                ALU_result = $signed(operand1) >>> operand2[4:0] ;
            end 
            4'b1001 : begin // SLT 
                ALU_result = $signed(operand1) < $signed(operand2) ;
            end 
            4'b1010 : begin // SLTU  
                ALU_result = $unsigned(operand1) < $unsigned(operand2) ;
            end 

            4'b0110 : begin // SUB  
                ALU_result = operand1 - operand2 ;
            end   

        default : ALU_result = 0 ;      
        endcase
    end 
        assign zero =(ALU_result== 0) ? 1'b1 : 1'b0 ;


endmodule
