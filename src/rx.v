module rx(
    input rx_en,
    input clk,
    input rst,

    input data_in,
    output [7:0] data_out,

    output done,
    output busy,
    output err
);



    reg [2:0] next_state, current_state ;
    parameter IDLE = 3'b000 ;
    parameter START = 3'b001 ;
    parameter DATA = 3'b010 ;
    parameter ERR = 3'b011 ;
    parameter DONE = 3'b100 ;

    //baud counter 
    reg[31:0] baud_count = 0;
    reg[3:0] baud_tick = 0 ;
    always @(posedge clk) begin 
        if(rst) begin 
            baud_count <= 0 ;
            baud_tick <= 4'h0 ;
        end
        else if (rx_en) begin 
            if (current_state == START) begin
                if (baud_count == 32'h0000_3D18) begin 
                    baud_count <= 0 ;
                    baud_tick <= baud_tick + 1'b1 ; 
                end 
                else begin
                    baud_count <= baud_count + 1 ;
                end 
            end 

            else if (current_state == DATA) begin 
                if (baud_count == 32'h0000_28B0) begin 
                    baud_count <= 0 ;
                    baud_tick <= baud_tick + 1'b1 ;
                end 
                else begin 
                    baud_count <= baud_count + 1 ;
                end

            end

            else begin 
                baud_count <= 0 ;
                baud_tick <= 4'h0 ;
            end
        end

        else begin 
            baud_count <= 0 ;
            baud_tick <= 4'h 0 ;
        end 

    end 


    //fsm 
    always @(posedge clk) begin 
        if(rst) begin 
            current_state <= IDLE ;
        end 
        else begin 
            current_state <= next_state ;
        end 
    end 

    always @(*) begin 
        case(current_state) 
        IDLE : begin 
            if (data_in) 
                next_state = IDLE ;
            else 
                next_state = START ;
        end 

        START : begin 
            if(baud_tick == 4'h1 )
                next_state = DATA ;
            else 
                next_state = START ;
        end 

        DATA : begin 
            if(baud_tick == 4'h9) begin 
                if (data_in) 
                    next_state = DONE ;
                else
                    next_state = ERR ;
            end 
            else 
                next_state = DATA ; 

        end
        default : next_state = IDLE ;

        endcase 



    end 

    reg[7:0] data_in_rx = 8'h00 ;

    //Serializer
    always @(posedge clk) begin 
        if(rst) begin 
            data_in_rx <= 8'h00 ;
        end

        else if (rx_en) begin
            if((baud_count == 32'h0000_3D18) && (current_state == START)) begin 
                data_in_rx[7] <= data_in ; //LSB first 
            end 
            else if ((baud_count == 32'h0000_28B0) && (current_state == DATA) && (baud_tick < 4'h8)) begin 
                data_in_rx <= data_in_rx >> 1 ;
                data_in_rx[7] <= data_in ;

            end 

        end

    end 

    assign data_out = data_in_rx ;
    assign err = (current_state == ERR) ;
    assign done = (current_state == DONE) ;

endmodule
