module branch_condition (
    input [2:0]  funct3,
    input        zero,
    input        alu_result_0,  // ALU_result[0], the SLT/SLTU bit

    output reg        branch_taken
);

    always @(*) begin
        case (funct3)
            3'b000: branch_taken = zero;          // beq  — equal
            3'b001: branch_taken = ~zero;         // bne  — not equal
            3'b100: branch_taken = alu_result_0;  // blt  — signed less than
            3'b101: branch_taken = ~alu_result_0; // bge  — signed greater or equal
            3'b110: branch_taken = alu_result_0;  // bltu — unsigned less than
            3'b111: branch_taken = ~alu_result_0; // bgeu — unsigned greater or equal
            default: branch_taken = 1'b0;
        endcase
    end

endmodule
