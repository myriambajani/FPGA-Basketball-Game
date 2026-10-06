////////////////////////////////////////////////////////////////////////////////////////////////////
// Filename:    vga_game_sync.sv
// Author:      Myriam Bajani, Javier Ralat
// Date:        4 May 2026
// Version:     1
// Description: Synchronizes gameplay-domain signals into the VGA clock domain.
//              Also converts launch toggles into one-cycle VGA-domain launch pulses.
////////////////////////////////////////////////////////////////////////////////////////////////////

module vga_game_sync(
	input       vga_clock,
	input       reset_n,
	
	input       ready_in,
	input       progress_in,
	input       finished_in,
	
	input [1:0] left_position_in, right_position_in,
	
	input [7:0] left_fill_height_in, right_fill_height_in,
	
	input [1:0] left_launch_position_in, right_launch_position_in,
	
	input [7:0] left_launch_fill_in, right_launch_fill_in,
	
	input       left_launch_toggle_in, right_launch_toggle_in,
	
	output logic       ready,
	output logic       progress,
	output logic       finished,
	
	output logic [1:0] left_position,
	output logic [1:0] right_position,
	
	output logic [7:0] left_fill_height,
	output logic [7:0] right_fill_height,
	
	output logic [1:0] left_launch_position,
	output logic [1:0] right_launch_position,
	
	output logic [7:0] left_launch_fill,
	output logic [7:0] right_launch_fill,
	
	output logic       launch_left_pulse,
	output logic       launch_right_pulse
);

	logic ready_sync1, progress_sync1, finished_sync1;
	
	logic [1:0] left_position_sync1, right_position_sync1;
	
	logic [7:0] left_fill_height_sync1, right_fill_height_sync1;
	
	logic [1:0] left_launch_position_sync1, right_launch_position_sync1;
	
	logic [7:0] left_launch_fill_sync1, right_launch_fill_sync1;
	
	logic left_launch_toggle_sync1, left_launch_toggle_sync2;
	logic right_launch_toggle_sync1, right_launch_toggle_sync2;
	
	logic left_launch_toggle_d, right_launch_toggle_d;
	
	always_ff @(posedge vga_clock or negedge reset_n) begin
		if (!reset_n) begin
			ready_sync1       <= 1'b0;
			ready             <= 1'b0;
			progress_sync1    <= 1'b0;
			progress          <= 1'b0;
			finished_sync1    <= 1'b0;
			finished          <= 1'b0;
			
			left_position_sync1  <= 2'd1;
			left_position        <= 2'd1;
			right_position_sync1 <= 2'd1;
			right_position       <= 2'd1;
			
			left_fill_height_sync1  <= 8'd0;
			left_fill_height        <= 8'd0;
			right_fill_height_sync1 <= 8'd0;
			right_fill_height       <= 8'd0;
			
			left_launch_position_sync1  <= 2'd1;
			left_launch_position        <= 2'd1;
			right_launch_position_sync1 <= 2'd1;
			right_launch_position       <= 2'd1;
			
			left_launch_fill_sync1  <= 8'd0;
			left_launch_fill        <= 8'd0;
			right_launch_fill_sync1 <= 8'd0;
			right_launch_fill       <= 8'd0;
			
			left_launch_toggle_sync1  <= 1'b0;
			left_launch_toggle_sync2  <= 1'b0;
			right_launch_toggle_sync1 <= 1'b0;
			right_launch_toggle_sync2 <= 1'b0;
			left_launch_toggle_d      <= 1'b0;
			right_launch_toggle_d     <= 1'b0;
		end
		else begin
			ready_sync1    <= ready_in;
			ready          <= ready_sync1;
			progress_sync1 <= progress_in;
			progress       <= progress_sync1;
			finished_sync1 <= finished_in;
			finished       <= finished_sync1;
			
			left_position_sync1  <= left_position_in;
			left_position        <= left_position_sync1;
			right_position_sync1 <= right_position_in;
			right_position       <= right_position_sync1;
			
			left_fill_height_sync1  <= left_fill_height_in;
			left_fill_height        <= left_fill_height_sync1;
			right_fill_height_sync1 <= right_fill_height_in;
			right_fill_height       <= right_fill_height_sync1;
			
			left_launch_position_sync1  <= left_launch_position_in;
			left_launch_position        <= left_launch_position_sync1;
			right_launch_position_sync1 <= right_launch_position_in;
			right_launch_position       <= right_launch_position_sync1;
			
			left_launch_fill_sync1  <= left_launch_fill_in;
			left_launch_fill        <= left_launch_fill_sync1;
			right_launch_fill_sync1 <= right_launch_fill_in;
			right_launch_fill       <= right_launch_fill_sync1;
			
			left_launch_toggle_sync1  <= left_launch_toggle_in;
			left_launch_toggle_sync2  <= left_launch_toggle_sync1;
			right_launch_toggle_sync1 <= right_launch_toggle_in;
			right_launch_toggle_sync2 <= right_launch_toggle_sync1;
			
			left_launch_toggle_d  <= left_launch_toggle_sync2;
			right_launch_toggle_d <= right_launch_toggle_sync2;
		end
	end
	
	assign launch_left_pulse  = left_launch_toggle_sync2  ^ left_launch_toggle_d;
	assign launch_right_pulse = right_launch_toggle_sync2 ^ right_launch_toggle_d;

endmodule