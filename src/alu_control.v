module alu_control (
    input wire [0:1] ALUOp ,
    input wire [3:0] instruction,

    output reg [3:0] alu_control_lines
) ;

  //check out figures 2.18 and 4.12 in the book  
  //0000 AND 
  //0001 OR 
  //0010 add 
  //0110 subtract
  // all of these R-type instructions have func7 field = 0000000, so checking func7 field will not help with them with the lw and sw the func7 doesn't matter if the AluOp comming from the control unit is 00 it's add operation. 
  // I'll just look at wire 30 in the instruction (see fig. 4.12) to tell add and subtract instructions apart
    always @(*) begin
	    alu_control_lines = 4'b0010 ; 
        case(ALUOp)  
            2'b 00 : begin //add operation for lw or sw instructions 
                alu_control_lines = 4'b 0010 ;
            end 

            2'b 01 :  begin //subtract operation for beq instruction
                alu_control_lines = 4'b 0110 ;

            end 

            2'b 10 : begin  
		    if((instruction[3] == 1'b1)) // subtract instruction 
			    alu_control_lines = 4'b0110 ; //subtract operation
                    else begin 
			   case(instruction[2:0]) 
				   3'b000 : // add instruction 
					   alu_control_lines = 4'b 0010 ; // add operation 
				   3'b111 : // and instruction 
					   alu_control_lines = 4'b 0000 ; // and operation 
				   3'b110 : // or instruction 
					   alu_control_lines = 4'b0001 ; // or operation
				  default : 
					   alu_control_lines = 4'b0010  ;
			   endcase 
		    end  
            end

		default : 
			    alu_control_lines = 4'b0010 ;
        endcase

    end 

endmodule
