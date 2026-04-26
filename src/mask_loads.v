module mask_loads (

	input [2:0] funct3, 
	input [31:0] raw_data,
	input [1:0] data_addr,

	output reg [31:0] data	

); 
	// another obstacle, this masking would be done on both the data coming from the UART and the data memory(loads) idk, if this's valid or not,
	// i think it's valid 

	always @(*) begin 
	        case (funct3)
	            3'b000: begin  // lb
	                case (data_addr[1:0])
	                    2'b00: data = {{24{raw_data[7]}},  raw_data[7:0]};
	                    2'b01: data = {{24{raw_data[15]}}, raw_data[15:8]};
	                    2'b10: data = {{24{raw_data[23]}}, raw_data[23:16]};
	                    2'b11: data = {{24{raw_data[31]}}, raw_data[31:24]};
	                endcase
	            end
	            3'b001: begin  // lh
	                case (data_addr[1])
	                    1'b0: data = {{16{raw_data[15]}}, raw_data[15:0]};
	                    1'b1: data = {{16{raw_data[31]}}, raw_data[31:16]};
	                endcase
	            end
	            3'b010: data = raw_data;  // lw
	            3'b100: begin  // lbu
	                case (data_addr[1:0])
	                    2'b00: data = {24'b0, raw_data[7:0]};
	                    2'b01: data = {24'b0, raw_data[15:8]};
	                    2'b10: data = {24'b0, raw_data[23:16]};
	                    2'b11: data = {24'b0, raw_data[31:24]};
	                endcase
	            end
	            3'b101: begin  // lhu
	                case (data_addr[1])
	                    1'b0: data = {16'b0, raw_data[15:0]};
	                    1'b1: data = {16'b0, raw_data[31:16]};
	                endcase
	            end
	            default: data = raw_data;
	        endcase
	    end

endmodule 
