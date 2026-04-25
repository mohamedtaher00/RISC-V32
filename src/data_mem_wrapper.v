module data_mem_wrapper (

    // Data load/store port
    input clk, 
    input [13:0] data_addr,  
    input [31:0] w_data_MEM, 
    input        mem_wren,   
    input [2:0]  funct3,   // encodes lb/lh/lw/sb/sh/sw
    output  [31:0] data 
);


    reg [31:0] data_in;
    reg [3:0]  byteena;


    wire [31:0] raw_out;
    always @(*) begin // to handle stores
        case (funct3)
            3'b000: begin  // sb
                data_in = {4{w_data_MEM[7:0]}};
                case (data_addr[1:0])
                    2'b00: byteena = 4'b0001;
                    2'b01: byteena = 4'b0010;
                    2'b10: byteena = 4'b0100;
                    2'b11: byteena = 4'b1000;
                endcase
            end
            3'b001: begin  // sh
                data_in = {2{w_data_MEM[15:0]}};
                case (data_addr[1])
                    1'b0: byteena = 4'b0011;
                    1'b1: byteena = 4'b1100;
                endcase
            end
            default: begin // sw
                data_in = w_data_MEM;
                byteena = 4'b1111;
            end
        endcase
    end



    data_mem dmem (
        .clk        (clk),
        .addr	    (data_addr),
        .w_data_MEM (data_in),
        .we       (mem_wren),
        .byteena    (byteena),
        .data	    (data)
    );



	

endmodule
