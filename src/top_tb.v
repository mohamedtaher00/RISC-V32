`timescale 1ns/1ns 

module top_tb ;
	
	reg clk_tb ; 
	reg reset_n_tb ;
	
	
	
	
	
	
	wire [31:0] prog_counter_addr_tb ;
        wire [31:0] prog_counter_next_addr_tb ;
        wire [63:0] prog_counter_64_bit_addr_tb ; 






	wire [31:0] instruction_test_tb  	; 		
        wire [31:0] write_back_data_test_tb	;
        wire [9:0] pc_addr_test_tb 		;
        wire [3:0] alu_ctrl_lines_test_tb	;
	
	wire [1:0] alu_op_test_tb 		;
        wire alu_src_test_tb     		;
        wire branch_test_tb      		;
        wire mem_write_ctrl_test_tb  		;	
        wire reg_write_ctrl_test_tb		;
        wire mem2reg_ctrl_test_tb 		;


	wire tx_tb ; 
	reg rx_tb ; 

	top DUT (
	.clk			(clk_tb), 
	.reset_n		(reset_n_tb),

	.instruction_test	( instruction_test_tb), 	
	.write_back_data_test	( write_back_data_test_tb), 	
	.pc_addr_test 		(pc_addr_test_tb), 	
	.alu_ctrl_lines_test	(alu_ctrl_lines_test_tb), 


	.alu_op_test		(alu_op_test_tb), 	
	.alu_src_test     	(alu_src_test_tb     	), 	
	.branch_test      	(branch_test_tb      	), 	
	.mem_write_ctrl_test  	(mem_write_ctrl_test_tb 	), 	
	.reg_write_ctrl_test	(reg_write_ctrl_test_tb	), 	
	.mem2reg_ctrl_test 	(mem2reg_ctrl_test_tb 	),

	.rx			(rx_tb), 
	.tx			(tx_tb)
	
	); 

  always #5 clk_tb = ~clk_tb ;

  initial begin  
    $dumpfile("top_dump.vcd") ;
    $dumpvars(0, top_tb) ; 
    clk_tb = 0 ;
    reset_n_tb = 0 ;
    #10 reset_n_tb = 1 ;
    #250 
    $finish ; 
  end 
// 8 bytes (64 bits) to hold up to 8 ASCII characters for GTKWave
reg [63:0] instr_mnemonic; 
// 32 bytes (256 bits) to hold up to 32 ASCII characters for GTKWave


always @(*) begin
    if (reset_n_tb) begin
        // Catch common NOPs (ADDI x0, x0, 0) or uninitialized memory
        if (instruction_test_tb == 32'h00000013 || instruction_test_tb == 32'h00000000) begin
            instr_mnemonic = "NOP     ";
            // Optional: $display("IF/ID: NOP");
        end else begin
            case (instruction_test_tb[6:0]) // Opcode field
                
                // -----------------------------------------
                // R-Type
                // -----------------------------------------
                7'b0110011: begin
                    case ({instruction_test_tb[31:25], instruction_test_tb[14:12]}) // funct7 + funct3
                        10'b0000000_000: begin instr_mnemonic = "ADD     "; $display("IF/ID: ADD   rd=x%0d rs1=x%0d rs2=x%0d", instruction_test_tb[11:7], instruction_test_tb[19:15], instruction_test_tb[24:20]); end
                        10'b0100000_000: begin instr_mnemonic = "SUB     "; $display("IF/ID: SUB   rd=x%0d rs1=x%0d rs2=x%0d", instruction_test_tb[11:7], instruction_test_tb[19:15], instruction_test_tb[24:20]); end
                        10'b0000000_001: begin instr_mnemonic = "SLL     "; $display("IF/ID: SLL   rd=x%0d rs1=x%0d rs2=x%0d", instruction_test_tb[11:7], instruction_test_tb[19:15], instruction_test_tb[24:20]); end
                        10'b0000000_010: begin instr_mnemonic = "SLT     "; $display("IF/ID: SLT   rd=x%0d rs1=x%0d rs2=x%0d", instruction_test_tb[11:7], instruction_test_tb[19:15], instruction_test_tb[24:20]); end
                        10'b0000000_011: begin instr_mnemonic = "SLTU    "; $display("IF/ID: SLTU  rd=x%0d rs1=x%0d rs2=x%0d", instruction_test_tb[11:7], instruction_test_tb[19:15], instruction_test_tb[24:20]); end
                        10'b0000000_100: begin instr_mnemonic = "XOR     "; $display("IF/ID: XOR   rd=x%0d rs1=x%0d rs2=x%0d", instruction_test_tb[11:7], instruction_test_tb[19:15], instruction_test_tb[24:20]); end
                        10'b0000000_101: begin instr_mnemonic = "SRL     "; $display("IF/ID: SRL   rd=x%0d rs1=x%0d rs2=x%0d", instruction_test_tb[11:7], instruction_test_tb[19:15], instruction_test_tb[24:20]); end
                        10'b0100000_101: begin instr_mnemonic = "SRA     "; $display("IF/ID: SRA   rd=x%0d rs1=x%0d rs2=x%0d", instruction_test_tb[11:7], instruction_test_tb[19:15], instruction_test_tb[24:20]); end
                        10'b0000000_110: begin instr_mnemonic = "OR      "; $display("IF/ID: OR    rd=x%0d rs1=x%0d rs2=x%0d", instruction_test_tb[11:7], instruction_test_tb[19:15], instruction_test_tb[24:20]); end
                        10'b0000000_111: begin instr_mnemonic = "AND     "; $display("IF/ID: AND   rd=x%0d rs1=x%0d rs2=x%0d", instruction_test_tb[11:7], instruction_test_tb[19:15], instruction_test_tb[24:20]); end
                        default:         begin instr_mnemonic = "R-UNK   "; $display("IF/ID: Unknown R-Type"); end
                    endcase
                end
                
                // -----------------------------------------
                // I-Type (ALU)
                // -----------------------------------------
                7'b0010011: begin
                    case (instruction_test_tb[14:12]) // funct3
                        3'b000: begin instr_mnemonic = "ADDI    "; $display("IF/ID: ADDI  rd=x%0d rs1=x%0d imm=%0d", instruction_test_tb[11:7], instruction_test_tb[19:15], $signed(instruction_test_tb[31:20])); end
                        3'b010: begin instr_mnemonic = "SLTI    "; $display("IF/ID: SLTI  rd=x%0d rs1=x%0d imm=%0d", instruction_test_tb[11:7], instruction_test_tb[19:15], $signed(instruction_test_tb[31:20])); end
                        3'b011: begin instr_mnemonic = "SLTIU   "; $display("IF/ID: SLTIU rd=x%0d rs1=x%0d imm=%0d", instruction_test_tb[11:7], instruction_test_tb[19:15], instruction_test_tb[31:20]); end
                        3'b100: begin instr_mnemonic = "XORI    "; $display("IF/ID: XORI  rd=x%0d rs1=x%0d imm=%0d", instruction_test_tb[11:7], instruction_test_tb[19:15], $signed(instruction_test_tb[31:20])); end
                        3'b110: begin instr_mnemonic = "ORI     "; $display("IF/ID: ORI   rd=x%0d rs1=x%0d imm=%0d", instruction_test_tb[11:7], instruction_test_tb[19:15], $signed(instruction_test_tb[31:20])); end
                        3'b111: begin instr_mnemonic = "ANDI    "; $display("IF/ID: ANDI  rd=x%0d rs1=x%0d imm=%0d", instruction_test_tb[11:7], instruction_test_tb[19:15], $signed(instruction_test_tb[31:20])); end
                        3'b001: begin instr_mnemonic = "SLLI    "; $display("IF/ID: SLLI  rd=x%0d rs1=x%0d shamt=%0d", instruction_test_tb[11:7], instruction_test_tb[19:15], instruction_test_tb[24:20]); end
                        3'b101: begin
                            if (instruction_test_tb[30] == 1'b0) begin 
                                instr_mnemonic = "SRLI    "; $display("IF/ID: SRLI  rd=x%0d rs1=x%0d shamt=%0d", instruction_test_tb[11:7], instruction_test_tb[19:15], instruction_test_tb[24:20]); 
                            end else begin 
                                instr_mnemonic = "SRAI    "; $display("IF/ID: SRAI  rd=x%0d rs1=x%0d shamt=%0d", instruction_test_tb[11:7], instruction_test_tb[19:15], instruction_test_tb[24:20]); 
                            end
                        end
                    endcase
                end
                
                // -----------------------------------------
                // I-Type (Load)
                // -----------------------------------------
                7'b0000011: begin
                    case (instruction_test_tb[14:12]) // funct3
                        3'b000: begin instr_mnemonic = "LB      "; $display("IF/ID: LB    rd=x%0d rs1=x%0d imm=%0d", instruction_test_tb[11:7], instruction_test_tb[19:15], $signed(instruction_test_tb[31:20])); end
                        3'b001: begin instr_mnemonic = "LH      "; $display("IF/ID: LH    rd=x%0d rs1=x%0d imm=%0d", instruction_test_tb[11:7], instruction_test_tb[19:15], $signed(instruction_test_tb[31:20])); end
                        3'b010: begin instr_mnemonic = "LW      "; $display("IF/ID: LW    rd=x%0d rs1=x%0d imm=%0d", instruction_test_tb[11:7], instruction_test_tb[19:15], $signed(instruction_test_tb[31:20])); end
                        3'b100: begin instr_mnemonic = "LBU     "; $display("IF/ID: LBU   rd=x%0d rs1=x%0d imm=%0d", instruction_test_tb[11:7], instruction_test_tb[19:15], $signed(instruction_test_tb[31:20])); end
                        3'b101: begin instr_mnemonic = "LHU     "; $display("IF/ID: LHU   rd=x%0d rs1=x%0d imm=%0d", instruction_test_tb[11:7], instruction_test_tb[19:15], $signed(instruction_test_tb[31:20])); end
                        default:begin instr_mnemonic = "L-UNK   "; $display("IF/ID: Unknown Load"); end
                    endcase
                end

                // -----------------------------------------
                // S-Type (Store)
                // -----------------------------------------
                7'b0100011: begin
                    case (instruction_test_tb[14:12]) // funct3
                        3'b000: begin instr_mnemonic = "SB      "; $display("IF/ID: SB    rs1=x%0d rs2=x%0d imm=%0d", instruction_test_tb[19:15], instruction_test_tb[24:20], $signed({instruction_test_tb[31:25], instruction_test_tb[11:7]})); end
                        3'b001: begin instr_mnemonic = "SH      "; $display("IF/ID: SH    rs1=x%0d rs2=x%0d imm=%0d", instruction_test_tb[19:15], instruction_test_tb[24:20], $signed({instruction_test_tb[31:25], instruction_test_tb[11:7]})); end
                        3'b010: begin instr_mnemonic = "SW      "; $display("IF/ID: SW    rs1=x%0d rs2=x%0d imm=%0d", instruction_test_tb[19:15], instruction_test_tb[24:20], $signed({instruction_test_tb[31:25], instruction_test_tb[11:7]})); end
                        default:begin instr_mnemonic = "S-UNK   "; $display("IF/ID: Unknown Store"); end
                    endcase
                end

                // -----------------------------------------
                // B-Type (Branch)
                // -----------------------------------------
                7'b1100011: begin
                    case (instruction_test_tb[14:12]) // funct3
                        3'b000: begin instr_mnemonic = "BEQ     "; $display("IF/ID: BEQ   rs1=x%0d rs2=x%0d", instruction_test_tb[19:15], instruction_test_tb[24:20]); end
                        3'b001: begin instr_mnemonic = "BNE     "; $display("IF/ID: BNE   rs1=x%0d rs2=x%0d", instruction_test_tb[19:15], instruction_test_tb[24:20]); end
                        3'b100: begin instr_mnemonic = "BLT     "; $display("IF/ID: BLT   rs1=x%0d rs2=x%0d", instruction_test_tb[19:15], instruction_test_tb[24:20]); end
                        3'b101: begin instr_mnemonic = "BGE     "; $display("IF/ID: BGE   rs1=x%0d rs2=x%0d", instruction_test_tb[19:15], instruction_test_tb[24:20]); end
                        3'b110: begin instr_mnemonic = "BLTU    "; $display("IF/ID: BLTU  rs1=x%0d rs2=x%0d", instruction_test_tb[19:15], instruction_test_tb[24:20]); end
                        3'b111: begin instr_mnemonic = "BGEU    "; $display("IF/ID: BGEU  rs1=x%0d rs2=x%0d", instruction_test_tb[19:15], instruction_test_tb[24:20]); end
                        default:begin instr_mnemonic = "B-UNK   "; $display("IF/ID: Unknown Branch"); end
                    endcase
                end

                // -----------------------------------------
                // J-Type & U-Type
                // -----------------------------------------
                7'b1101111: begin instr_mnemonic = "JAL     "; $display("IF/ID: JAL   rd=x%0d", instruction_test_tb[11:7]); end
                7'b1100111: begin instr_mnemonic = "JALR    "; $display("IF/ID: JALR  rd=x%0d rs1=x%0d", instruction_test_tb[11:7], instruction_test_tb[19:15]); end
                7'b0110111: begin instr_mnemonic = "LUI     "; $display("IF/ID: LUI   rd=x%0d imm=0x%0h", instruction_test_tb[11:7], instruction_test_tb[31:12]); end
                7'b0010111: begin instr_mnemonic = "AUIPC   "; $display("IF/ID: AUIPC rd=x%0d imm=0x%0h", instruction_test_tb[11:7], instruction_test_tb[31:12]); end
                7'b1110011: begin instr_mnemonic = "SYS     "; $display("IF/ID: ECALL/EBREAK"); end
                
                default: begin 
                    instr_mnemonic = "UNKNOWN "; 
                    $display("IF/ID: UNKNOWN OPCODE 0x%0h", instruction_test_tb[6:0]); 
                end
            endcase
        end
    end
end
endmodule 
