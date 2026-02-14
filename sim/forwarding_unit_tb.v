`timescale 1ns/1ns 
module forwarding_unit_tb ;

	reg [4:0] ID_EX_RegisterRs1_tb ; 
	reg [4:0] ID_EX_RegisterRs2_tb ; 
                             
	reg [4:0] EX_MEM_RegisterRd_tb ; 
	reg [4:0] MEM_WB_RegisterRd_tb ; 
  
	reg EX_MEM_RegWrite_tb ; 
	reg MEM_WB_RegWrite_tb ; 
	
	wire flag0_tb ; 
        wire flag1_tb ;
        wire flag2_tb ;
        wire flag3_tb ;
        wire flag4_tb ;
	wire flagB0_tb; 
        wire flagB1_tb;
        wire flagB2_tb;
        wire flagB3_tb;
        wire flagB4_tb;
	wire [1:0] ForwardingA_tb ;  
	wire [1:0] ForwardingB_tb ;
	forwarding_unit DUT ( 
		.ID_EX_RegisterRs1(ID_EX_RegisterRs1_tb), 
		.ID_EX_RegisterRs2(ID_EX_RegisterRs2_tb),
		.EX_MEM_RegisterRd(EX_MEM_RegisterRd_tb),
		.MEM_WB_RegisterRd(MEM_WB_RegisterRd_tb),
		.EX_MEM_RegWrite(EX_MEM_RegWrite_tb),
		.MEM_WB_RegWrite(MEM_WB_RegWrite_tb),
		.flag0(flag0_tb),
		.flag1(flag1_tb),
		.flag2(flag2_tb),
		.flag3(flag3_tb),
		.flag4(flag4_tb),
		.flagB0(flagB0_tb), 
                .flagB1(flagB1_tb),
                .flagB2(flagB2_tb),
                .flagB3(flagB3_tb),
		.flagB4(flagB4_tb),
		.ForwardA(ForwardingA_tb),
                .ForwardB(ForwardingB_tb) 
	);

	initial begin

	        $dumpfile("dump.vcd") ;
    		$dumpvars(0, forwarding_unit_tb) ; 	

		ID_EX_RegisterRs1_tb = 5'b00000 ; 
		ID_EX_RegisterRs2_tb = 5'b00000 ;
                            
		EX_MEM_RegisterRd_tb = 5'b00000 ; 
		MEM_WB_RegisterRd_tb = 5'b00000 ; 
                                     
		EX_MEM_RegWrite_tb = 1'b0 ;  
		MEM_WB_RegWrite_tb = 1'b0 ; 

		#10 ;  

		ID_EX_RegisterRs1_tb = 5'b00001 ;  	
                ID_EX_RegisterRs2_tb = 5'b00010 ;
                            
                EX_MEM_RegisterRd_tb = 5'b00001 ; 
                MEM_WB_RegisterRd_tb = 5'b00011 ; 
                                     
                EX_MEM_RegWrite_tb = 1'b1 ;  
                MEM_WB_RegWrite_tb = 1'b1 ; 


		#10 ; 
		ID_EX_RegisterRs1_tb = 5'b00000 ;  
                ID_EX_RegisterRs2_tb = 5'b00101 ;
                            
                EX_MEM_RegisterRd_tb = 5'b00101 ; 
                MEM_WB_RegisterRd_tb = 5'b00001 ; 
                                     
                EX_MEM_RegWrite_tb = 1'b1;  
                MEM_WB_RegWrite_tb = 1'b1;  


		#10 ; 
		ID_EX_RegisterRs1_tb = 5'b00101 ; 
                ID_EX_RegisterRs2_tb = 5'b00010 ;
                            
                EX_MEM_RegisterRd_tb = 5'b00001 ; 
                MEM_WB_RegisterRd_tb = 5'b00101 ; 
                                     
                EX_MEM_RegWrite_tb = 1'b1 ;  
                MEM_WB_RegWrite_tb = 1'b1 ;  
	        #10 ; 	
		#10 $finish ;
	end 

endmodule 	
