module bht (
	input reset_n, 
	input clk, 
	input [4:0]  addr_needs_predition, 
	input [4:0]  previous_prediction_addr_ID_EX, //from ID/EX 
	input [4:0]  previous_prediction_addr_MEM_WB,
	input branch_EX_MEM,
	input branch_MEM_WB,
        
	input final_verdict, // 1 means taken, 0 means not taken -> from MEM/WB 

	output reg [1:0] our_prediction 
	);
	

	initial begin 
		$readmemb("bht.mem", history) ;	
	end 



	reg [1:0] history [0:31];
	wire [1:0] fsm_output ;
        reg flag0 ; 	
        reg flag1 ; 	
        reg flag2 ; 	
        reg flag3 ; 	
        reg flag4 ; 	
        reg flag5 ; 	
	always @(posedge clk) begin 
		our_prediction <= history[addr_needs_predition] ; // read 
		flag0 <= 1'b1 ; 
			
		if (branch_MEM_WB ) begin  	
			history[previous_prediction_addr_MEM_WB] <= fsm_output ; //write it'll be written the the start(edge) of the WB, when the beq reaches MEM/WB
		        flag1 <= 1'b1 ;
			flag2 <= 1'b0 ; 	
		end 	
	  	else begin  
		  	history[previous_prediction_addr_MEM_WB] <= history[previous_prediction_addr_MEM_WB] ; 
		        flag2 <= 1'b1 ;
			flag1 <= 1'b0 ;  
	  end 	  
	end

	//state encoding 
         localparam strong_not_taken = 2'b00 ;
         localparam weak_not_taken   = 2'b01 ;

         localparam strong_taken = 2'b11 ;
         localparam weak_taken   = 2'b10 ;

	 reg [1:0] current_state, next_state ; 

	// current state logic
         always @(posedge clk) begin
                if (~reset_n)
                   current_state <= 2'b00 ;
		else begin 
                   current_state <= next_state ;
		   flag3 <= 1'b1 ;
		end 	
         end

         // next state logic
         always @(*) begin
		 flag4 = 1'b0 ; 
		 flag5 = 1'b0 ; 
		 if (branch_EX_MEM) begin 
			 flag4 = 1'b1 ;  
            		 case (current_state )
            		 strong_not_taken :
            		                 next_state = (final_verdict) ?  weak_not_taken : strong_not_taken ;
            		 weak_not_taken   :
            		                 next_state = (final_verdict) ? strong_taken   : strong_not_taken ;
            		 strong_taken     :
            		                 next_state = (final_verdict) ? strong_taken : weak_taken ;
            		 weak_taken       :
            		                 next_state = (final_verdict) ? strong_taken : strong_not_taken ;
            		 endcase
		 end 
		 
		 else begin  
		  	 next_state = history[previous_prediction_addr_ID_EX] ;  
			 flag5 = 1'b1 ; 
		 end  
         end

         // output logic
	   assign fsm_output[1:0] = current_state[1:0] ; 
endmodule 
