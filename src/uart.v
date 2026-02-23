module uart (
	input clk, 
	input [31:0] write_data, 
	
	input data_in_rx, 

	output data_out_tx, 
	
	input mem_write, 
	input sel_uart, 
	input [3:0] addr, // the LSBs of the addr
	output reg [31:0] readed_data

);
	wire rst ; 
	wire tx_done, rx_done ; 
	wire rx_err; 
	wire tx_en, rx_en ;
	wire [7:0] data_out_rx ; 
	wire [7:0] status_signals ;
	wire [7:0] ctrl_signals ;
        reg [31:0] uart_regs_nxt ; 	

	reg [7:0] uart_regs [15:0] ;
	
	assign status_signals = {5'b0, tx_done, rx_done, rx_err } ; 
	assign ctrl_signals = uart_regs[12] ; 
	assign rst = ctrl_signals[2] ; 	


	tx transmitter(
		.tx_en(tx_en), 
                .rst(rst), 
                .clk(clk),
		.data_in(uart_regs[0]), // assumption nour has to take care of 
                .data_out(data_out_tx), 
                .done(tx_done) 
	); 


	rx receiver( 
		.rx_en(rx_en), 	
                .clk(clk),
                .rst(rst), 
                .data_in(data_in_rx),
		.data_out(data_out_rx),
		.done(rx_done), 
                .err(rx_err)
	);

	// UART registers 


       //write logic 	
	always @(posedge clk) begin 
		        uart_regs[addr]   <= uart_regs_nxt[7:0] ; 
			uart_regs[addr+1] <= uart_regs_nxt[15:8] ; 
			uart_regs[addr+2] <= uart_regs_nxt[23:16] ; 
			uart_regs[addr+3] <= uart_regs_nxt[31:24] ; 
			//status & rx are hardwired to rx o/p and status signals 
			uart_regs[4] <= data_out_rx ; 
			uart_regs[8] <= status_signals ; 
	end 

		// 0x00000000 - 0x00003FFF  : Instruction Memory (16KB)
		// 0x00004000 - 0x00006FFF  : Data Memory        (12KB)
		// 0x80000000 - 0x8000000F  : UART registers
		// 0x80000010 - 0x8000001F  : GPIO registers
	
		
	always @(*) begin 
		if (sel_uart & mem_write ) begin 
			uart_regs_nxt = write_data ; 
		end 
		else begin 
			uart_regs_nxt = {uart_regs[addr+3], uart_regs[addr+2], uart_regs[addr+1], uart_regs[addr]} ; 
		end  
	end 

	//read logic 
	always @(posedge clk) begin 
		readed_data[31:24] <= uart_regs[addr+3] ; 	
                readed_data[23:16] <= uart_regs[addr+2] ;
                readed_data[15:8]  <= uart_regs[addr+1] ; 
                readed_data[7:0]   <= uart_regs[addr] ;
	end

endmodule 	
