module controllogic(
	input clk, reset,
	input [7:0] keycode_1, keycode_2, keycode_3, keycode_4, 
	input [9:0]  c1x, c2x, c1y, c2y,
	input death_c1, death_c2,
	output [11:0] hp_c1, hp_c2,
	output life1_c1, life2_c1, life3_c1, life1_c2, life2_c2, life3_c2, hit_on_c1, hit_on_c2,
	output [1:0] current_screen
);

enum logic [1:0] {ready, play, endgame} current_state, next_state;
logic start, gameover, gameover_c1, gameover_c2, reset_hp_c1, reset_hp_c2, hit_c1, hit_c2, touching, death_db_c1, death_db_c2;
logic [1:0] lives_c1, lives_c2;


always_ff @ (posedge clk or posedge reset)
begin
	if (reset)
		current_state <= ready;
	else
		current_state <= next_state;

end


always_comb
begin
	next_state = current_state;

	unique case (current_state)
		ready:
		begin
			if (keycode_1 == 8'h2C || keycode_2 == 8'h2C || keycode_3 == 8'h2C || keycode_4 == 8'h2C)
				next_state = play;
		end
		
		play:
		begin
			if (gameover_c1 || gameover_c2)
				next_state = endgame;
		end
		
		endgame:
		begin
			if (keycode_1 == 8'h15 || keycode_2 == 8'h15 || keycode_3 == 8'h15 || keycode_4 == 8'h15)
				next_state = ready;
		end
		
		default:
		begin
			next_state = ready;
		end
	endcase

end

always_comb
begin
	case(current_state)
		ready:
		begin
			start = 1;
			gameover = 0;
			current_screen = 2'b00;
		end
		play:
		begin
			start = 0;
			gameover = 0;
			current_screen = 2'b01;
		end
		endgame:
		begin
			start = 0;
			gameover = 0;
			if (gameover_c1)
				current_screen = 2'b10;
			else
				current_screen = 2'b11;
		end
		default:
		begin
			start = 1;
			gameover = 0;
			current_screen = 2'b00;
		end
	endcase
	
end

life_counter life_c1 (.clk(clk), .reset(start), .clear(gameover), .trigger(death_db_c1), .data(lives_c1), .gameover(gameover_c1) );

life_counter life_c2 (.clk(clk), .reset(start), .clear(gameover), .trigger(death_db_c2), .data(lives_c2), .gameover(gameover_c2) );

signal_debounce sb1_death ( .clk(clk), .reset(reset), .signal(death_c1), .trigger(death_db_c1) );

signal_debounce sb2_death ( .clk(clk), .reset(reset), .signal(death_c2), .trigger(death_db_c2) );

//signal_debounce sb1_hit ( .clk(clk), .reset(reset), .signal(hit_on_c1), .trigger(hit_c1) );

//signal_debounce sb2_hit ( .clk(clk), .reset(reset), .signal(hit_on_c2), .trigger(hit_c2) );

hp_counter hp_1(.clk(clk), .reset(reset_hp_c1), .trigger(hit_c1), .data(hp_c1) );

hp_counter hp_2(.clk(clk), .reset(reset_hp_c2), .trigger(hit_c2), .data(hp_c2) );

always_comb
begin
	reset_hp_c1 = reset || death_c1 || start || gameover;
	reset_hp_c2 = reset || death_c2 || start || gameover;
	
	if (c1x + 40 >= c2x & c1x <= c2x + 60)
	begin
		if (c1y + 60 >= c2y & c1y <= c2y + 60)
			touching = 1;
		else
			touching = 0;
	end
	else
	begin
		touching = 0;
	end
	
	if (keycode_1 == 8'h08 || keycode_2 == 8'h08 || keycode_3 == 8'h08 || keycode_4 == 8'h08)
	begin
		if (touching)
			hit_c2 = 1;
		else
			hit_c2 = 0;
	end
	else
	begin
		hit_c2 = 0;
	end
	
	if (keycode_1 == 8'h38 || keycode_2 == 8'h38 || keycode_3 == 8'h38 || keycode_4 == 8'h38)
	begin
		if (touching)
			hit_c1 = 1;
		else
			hit_c1 = 0;
	end
	else
	begin
		hit_c1 = 0;
	end
	
	if (lives_c1 == 2'b11)
	begin
		life1_c1 = 1;
		life2_c1 = 1;
		life3_c1 = 1;
	end
	else if (lives_c1 == 2'b10)
	begin
		life1_c1 = 1;
		life2_c1 = 1;
		life3_c1 = 0;
	end
	else if (lives_c1 == 2'b01)
	begin
		life1_c1 = 1;
		life2_c1 = 0;
		life3_c1 = 0;
	end
	else
	begin
		life1_c1 = 0;
		life2_c1 = 0;
		life3_c1 = 0;
	end
	
	
	if (lives_c2 == 2'b11)
	begin
		life1_c2 = 1;
		life2_c2 = 1;
		life3_c2 = 1;
	end
	else if (lives_c2 == 2'b10)
	begin
		life1_c2 = 1;
		life2_c2 = 1;
		life3_c2 = 0;
	end
	else if (lives_c2 == 2'b01)
	begin
		life1_c2 = 1;
		life2_c2 = 0;
		life3_c2 = 0;
	end
	else
	begin
		life1_c2 = 0;
		life2_c2 = 0;
		life3_c2 = 0;
	end
	
end

assign hit_on_c1 = hit_c1;
assign hit_on_c2 = hit_c2;

endmodule

//-------------------------------------------------------

module life_counter(
 input clk, reset, clear, trigger,
 output [1:0] data,
 output gameover
);

	always_ff @ (posedge clk)
	begin
	
		if (reset)
			data <= 2'b11;
		else if (clear)
			data <= 2'b00;
		else if (trigger)
			data <= data - 1;
		else
			data <= data;
	end
	
	always_comb
	begin
		if (data == 2'b00)
			gameover = 1;
		else
			gameover = 0;
	end
	

endmodule

//-----------------------------------------------------------------------------

module hp_counter(
	input clk, reset, trigger,
	output [11:0] data
);

	always_ff @ (posedge clk)
	begin
	
		if (reset)
			data <= 10'd0;
		else if (trigger)
			data <= data + 12'd1;
		else
			data <= data;
			
	end

endmodule


//-----------------------------------------------------------------------
module signal_debounce(
	input clk, reset, signal,
	output trigger
);
logic [1:0] current_state, next_state;

always_ff @ (posedge clk or posedge reset)
begin
	if (reset)
		current_state <= 2'b00;
	else
		current_state <= next_state;

end


always_comb
begin
	next_state = current_state;
	
	unique case(current_state)
		2'b00:
		begin
			if(signal == 1'b1)
				next_state = 2'b01;
		end
		2'b01:
		begin
			if(signal == 1'b0)
				next_state = 2'b10;
		end
		2'b10:
		begin
			next_state = 2'b00;
		end
		default:
		begin
			next_state = 2'b00;
		end
	
	endcase

end


always_comb
begin

	case (current_state)
	
		2'b00:
		begin
			trigger = 0;
		end
		2'b01:
		begin
			trigger = 0;
		end
		2'b10:
		begin
			trigger = 1;
		end
		default:
		begin
			trigger = 0;
		end
	endcase

end

endmodule
