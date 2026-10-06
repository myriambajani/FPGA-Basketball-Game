////////////////////////////////////////////////////////////////////////////////////////////////////
// Filename:    shot_result_controller.sv
// Author:      Myriam Bajani, Javier Ralat
// Date:        4 May 2026
// Version:     1
// Description: Evaluates shot results and commits scores after each animation finishes.
////////////////////////////////////////////////////////////////////////////////////////////////////

module shot_result_controller(
	input     			 clk,
	input      			 reset_n,
	
	input      			 progress,
	
	input     			 left_shoot_valid,
	input    		    right_shoot_valid,
	
	input     			 left_shot_done,
	input      			 right_shot_done,
	
	input      			 left_shot_active_sync,
	input     			 right_shot_active_sync,
	
	input 		 [1:0] left_position,
	input 		 [1:0] right_position,
	
	input 		 [7:0] left_fill_height,
	input 		 [7:0] right_fill_height,
	
	output logic       left_made,
	output logic       right_made,
	
	output logic [1:0] left_points,
	output logic [1:0] right_points,
	
	output logic       left_shot_locked,
	output logic       right_shot_locked,
	
	output logic       left_score_commit_pending,
	output logic       right_score_commit_pending,
	
	output logic       left_pending_make,
	output logic       right_pending_make
);

	localparam logic [7:0] EASY_ORANGE_START   = 8'd122;
	localparam logic [7:0] EASY_RED_START      = 8'd169;
	
	localparam logic [7:0] MEDIUM_ORANGE_START = 8'd122;
	localparam logic [7:0] MEDIUM_RED_START    = 8'd152;
	
	localparam logic [7:0] HARD_ORANGE_START   = 8'd122;
	localparam logic [7:0] HARD_RED_START      = 8'd137;
	
	logic [1:0] left_pending_points;
	logic [1:0] right_pending_points;

	function automatic logic [1:0] points_for_position(input [1:0] position_sel);
		begin
			unique case (position_sel)
				 2'd0:    points_for_position = 2'd1;
				 2'd1:    points_for_position = 2'd2;
				 default: points_for_position = 2'd3;
			endcase
		end
	endfunction

	function automatic logic [7:0] get_orange_start(input [1:0] difficulty_sel);
		begin
			unique case (difficulty_sel)
				2'd0:    get_orange_start = EASY_ORANGE_START;
				2'd1:    get_orange_start = MEDIUM_ORANGE_START;
				default: get_orange_start = HARD_ORANGE_START;
			endcase
		end
	endfunction

	function automatic logic [7:0] get_red_start(input [1:0] difficulty_sel);
		begin
			unique case (difficulty_sel)
				2'd0:    get_red_start = EASY_RED_START;
				2'd1:    get_red_start = MEDIUM_RED_START;
				default: get_red_start = HARD_RED_START;
			endcase
		end
	endfunction

	always_ff @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			left_made                    <= 1'b0;
			right_made                   <= 1'b0;
			left_points                  <= 2'd0;
			right_points                 <= 2'd0;
			left_shot_locked             <= 1'b0;
			right_shot_locked            <= 1'b0;
			left_score_commit_pending    <= 1'b0;
			right_score_commit_pending   <= 1'b0;
			left_pending_make            <= 1'b0;
			right_pending_make           <= 1'b0;
			left_pending_points          <= 2'd0;
			right_pending_points         <= 2'd0;
		end
		else begin
			left_made    <= 1'b0;
			right_made   <= 1'b0;
			left_points  <= 2'd0;
			right_points <= 2'd0;
		
			if (!progress &&
				!left_shot_locked &&
				!right_shot_locked &&
				!left_score_commit_pending &&
				!right_score_commit_pending &&
				!left_shot_active_sync &&
				!right_shot_active_sync) begin
		
			left_shot_locked           <= 1'b0;
			right_shot_locked          <= 1'b0;
			left_score_commit_pending  <= 1'b0;
			right_score_commit_pending <= 1'b0;
			left_pending_make          <= 1'b0;
			right_pending_make         <= 1'b0;
			left_pending_points        <= 2'd0;
			right_pending_points       <= 2'd0;
			end
			else begin
				if (left_shoot_valid) begin
					left_shot_locked          <= 1'b1;
					left_score_commit_pending <= 1'b1;
					left_pending_points       <= points_for_position(left_position);
					left_pending_make         <= (left_fill_height >= get_orange_start(left_position)) && (left_fill_height <  get_red_start(left_position));
				end
		
				if (right_shoot_valid) begin
					right_shot_locked          <= 1'b1;
					right_score_commit_pending <= 1'b1;
					right_pending_points       <= points_for_position(right_position);
					right_pending_make         <= (right_fill_height >= get_orange_start(right_position)) && (right_fill_height <  get_red_start(right_position));
				end
		
				if (left_shot_done) begin
					left_shot_locked <= 1'b0;
				
					if (left_score_commit_pending) begin
						left_made   <= left_pending_make;
						left_points <= left_pending_points;
					end
				
					left_score_commit_pending <= 1'b0;
				end
			
				if (right_shot_done) begin
					right_shot_locked <= 1'b0;
					
					if (right_score_commit_pending) begin
						right_made   <= right_pending_make;
						right_points <= right_pending_points;
				end
				
				right_score_commit_pending <= 1'b0;
			end
		end
	end
end

endmodule