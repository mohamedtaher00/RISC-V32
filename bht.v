module bht (
	input reset_n, 
	input clk, 
	input [4:0]  addr_needs_predition, 
	input [4:0]  previous_prediction_addr, //from EX/MEM 
	input branch_EX_MEM,
	input branch_MEM_WB,
        input final_verdict, // 1 means taken, 0 means not taken -> from MEM/WB 

	output reg [1:0] our_prediction 
	);
       // two consequent branches are not supported 	
	

	initial begin 
		$readmemb("bht.mem", history) ;	
	end 



	reg [1:0] history [0:31];
	wire [1:0] fsm_output ; 
	
	always @(posedge clk) begin 
		our_prediction <= history[addr_needs_predition] ; // read  
			
	  if (branch_EX_MEM | branch_MEM_WB) 	
		history[previous_prediction_addr] <= fsm_output ; //write
	  else 
	  	history[previous_prediction_addr] <= history[previous_prediction_addr] ;  
	end


         localparam strong_not_taken = 2'b00 ;
         localparam weak_not_taken   = 2'b01 ;

         localparam strong_taken = 2'b11 ;
         localparam weak_taken   = 2'b10 ;

	 reg [1:0] current_state, next_state ; 
         // current state logic
         always @(posedge clk) begin
                if (~reset_n)
                   current_state <= 2'b00 ;
                else
                   current_state <= next_state ;
         end

         // next state logic
         always @(*) begin
		 if (branch_MEM_WB) begin 
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
		 
	  else 
		  next_state = history[previous_prediction_addr] ; //from EX/MEM  
         end

         // output logic
	   assign fsm_output[1:0] = current_state[1:0] ; 
endmodule 
