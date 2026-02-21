module tx(
    input tx_en, 
    input rst, 
    input clk,
    
    input[7:0] data_in,
    output reg data_out,  
    output reg done , 
    output busy
);
    //parameter baud_period = 104;
    reg[31:0] baud_count = 0;
    reg[3:0] baud_tick = 0 ;
    wire [7:0] data_in_tx;

    assign data_in_tx = data_in ;

    
    //baud counter -> to derive baud rate from the system's clock 
    always @(posedge clk) begin 
        if(rst) begin
            baud_count <= 0 ;
            baud_tick <= 0 ;
            done <= 1'b0 ;
        end 
        else if (tx_en) begin
            //can we assert the busy flag here?
            if (baud_count == 32'h 0000_28B0) begin
                if(baud_tick == 4'h9) begin
                    baud_count <= 0 ;
                    done <= 1'b1 ;
                    baud_tick <= 4'h0 ;
                end
                else begin 
                    baud_count <= 0 ;
                    baud_tick <= baud_tick + 1'b1 ;
                end 
            end 
            
            else begin 
                baud_count <= baud_count + 1 ;
            end 
        end 
        
    end 

    // those baud ticks will control the process of sending
    always @(*) begin 
        if (rst) begin 

            data_out = 1'b 1;
        end 
        else if(tx_en) begin 
            case(baud_tick) 
            4'h0 : begin 
                if (done)
                    data_out = 1'b1 ; //IDLE 
                else 
                    data_out = 1'b0 ;
            end
            //data
            4'h1 : data_out = data_in_tx[0] ;
            4'h2 : data_out = data_in_tx[1] ;
            4'h3 : data_out = data_in_tx[2] ;
            4'h4 : data_out = data_in_tx[3] ;
            4'h5 : data_out = data_in_tx[4] ;
            4'h6 : data_out = data_in_tx[5] ;
            4'h7 : data_out = data_in_tx[6] ;
            4'h8 : data_out = data_in_tx[7] ;
            //end bit
            4'h9 : begin 
                data_out = 1'b1 ;
            end 
            default : data_out = 1'b1 ;
            endcase 
        end 
        else begin
            data_out = 1'b1 ;
        end 
    end 


endmodule
