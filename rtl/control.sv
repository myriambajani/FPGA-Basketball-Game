////////////////////////////////////////////////////////////////////////////////////////////////////
// Filename: control.sv
// Author: Myriam Bajani, Javier Ralat
// Date: 23 April 2026
// Version: 1
// Description: Main FSM that controls the game state.
////////////////////////////////////////////////////////////////////////////////////////////////////

module control(
	input clk,
	input reset_n,
	input start_pulse,
	input game_over,
	
	output logic ready,
	output logic progress,
	output logic finished
);

	typedef enum logic [1:0] {
		READY,
		PLAY,
		DONE
	} state_t;
	
	state_t state, next_state;
	
	// State register
	always_ff @(posedge clk or negedge reset_n) begin
		if(!reset_n)
			state <= READY;
		else
			state <= next_state;
	end
	
	// Next state logic
	always_comb begin
		case(state)
			READY: begin
				if(start_pulse)
					next_state = PLAY;
				else
					next_state = READY;
			end
			
			PLAY: begin
				if(game_over)
					next_state = DONE;
				else
					next_state = PLAY;
			end
			
			DONE:
				next_state = DONE;
			
			default:
				next_state = READY;
		endcase
	end
	
	// Outputs
	always_comb begin
		ready = 1'b0;
		progress = 1'b0;
		finished = 1'b0;
		
		case(state)
			READY: ready = 1'b1;
	
			PLAY: progress = 1'b1;
	
			DONE: finished = 1'b1;
		endcase
	end
	
endmodule