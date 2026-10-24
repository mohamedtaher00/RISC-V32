module bht (
    input reset_n,
    input clk,
    input [4:0] addr_needs_predition,
    input [4:0] previous_prediction_addr_ID_EX,  //from ID/EX
    input [4:0] previous_prediction_addr_MEM_WB,
    input [4:0] previous_prediction_addr_ex_mem,
    input branch_EX_MEM,
    input branch_MEM_WB,

    input final_verdict,  // 1 means taken, 0 means not taken -> from MEM/WB

    output reg [1:0] our_prediction
);


  initial begin
    $readmemb("bht.mem", history);
  end



  reg [1:0] history[0:31];
  wire [1:0] fsm_output;
  always @(posedge clk) begin
    our_prediction <= history[addr_needs_predition];  // read

    if (branch_MEM_WB) begin
      //write it'll be written the the start(edge) of the WB, when the beq reaches MEM/WB
      history[previous_prediction_addr_MEM_WB] <= fsm_output;
    end else begin
      history[previous_prediction_addr_MEM_WB] <= history[previous_prediction_addr_MEM_WB];
    end
  end

  //state encoding
  localparam [1:0] STRONG_NOT_TAKEN = 2'b00;
  localparam [1:0] WEAK_NOT_TAKEN = 2'b01;

  localparam [1:0] STRONG_TAKEN = 2'b11;
  localparam [1:0] WEAK_TAKEN = 2'b10;

  reg [1:0] current_state, next_state;

  // current state logic
  always @(posedge clk) begin
    if (~reset_n) current_state <= 2'b00;
    else begin
      current_state <= next_state;
    end
  end

  // next state logic
  always @(*) begin
    case (history[previous_prediction_addr_ex_mem])
      STRONG_NOT_TAKEN: next_state = (final_verdict) ? WEAK_NOT_TAKEN : STRONG_NOT_TAKEN;
      WEAK_NOT_TAKEN:   next_state = (final_verdict) ? STRONG_TAKEN : STRONG_NOT_TAKEN;
      STRONG_TAKEN:     next_state = (final_verdict) ? STRONG_TAKEN : WEAK_TAKEN;
      WEAK_TAKEN:       next_state = (final_verdict) ? STRONG_TAKEN : STRONG_NOT_TAKEN;
      default:          next_state = STRONG_NOT_TAKEN;
    endcase
  end

  // output logic
  assign fsm_output[1:0] = current_state[1:0];
endmodule
