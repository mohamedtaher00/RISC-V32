module alu(
    input wire[3:0] alu_control_lines,
    input wire[31:0] operand1,
    input wire[31:0] operand2, 

    output reg[31:0] ALU_result,
    output zero
    
);


    always @(*) begin 
	    ALU_result = 'b0 ;
        case(alu_control_lines)  

            4'b0000 : begin 
                ALU_result = operand1 & operand2 ;

            end

            4'b0001 : begin 
                ALU_result = operand1 | operand2 ;
            end 

            4'b0010 : begin 
                ALU_result = operand1 + operand2 ;
            end 

            4'b0110 : begin 
                ALU_result = operand1 - operand2 ;
            end   

        default : ALU_result = 0 ;      
        endcase
    end 
        assign zero =(ALU_result== 0) ? 1'b1 : 1'b0 ;


endmodule
