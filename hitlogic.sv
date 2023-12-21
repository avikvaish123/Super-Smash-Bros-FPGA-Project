module hitlogic (
	input clk, reset,
	input [7:0] keycode, 
	input [9:0]  c1x, c2x, c1y, c2y,
	input death_1, death_2, 
	output life_c1, life_c2
);

enum logic [1:0] {ready, play, endgame} current_state, next_state; // States

logic [1:0] lives_c1, lives_c2, next_lives_c1, next_lives_c2;

always_ff @ (posedge clk or posedge reset)
begin
	if (reset)
	begin
		current_state <= ready;
		lives_c1 <= 2'b11;
		lives_c2 <= 2'b11;
	end
	else
	begin
		current_state <= next_state;
		lives_c1 <= next_lives_c1;
		lives_c2 <= next_lives_c2;
	end

end


//next state logic
always_comb
begin
	next_state = current_state;
	next_lives_c1 = lives_c1;
	next_lives_c2 = lives_c2;
				
	unique case (current_state)
			ready: 
			begin
				if (keycode == 8'h2C)
					next_state = play;
				else
					next_state = ready;
				next_lives_c2 = 2'b11;
				next_lives_c1 = 2'b11;
			end
			play:
			begin
				if (lives_c1 == 0 || lives_c2 == 0)
					next_state = endgame;
				else
					next_state = play;
				if (death_1)
				begin
					next_lives_c1 = next_lives_c1 - 1;
				end
				
				if(death_2)
				begin
					next_lives_c2 = next_lives_c2 - 1;
				end
				
			end
			endgame: 
			begin
				if (keycode == 8'h2C)
					next_state = ready;
				else
					next_state = endgame;
				next_lives_c1 = 2'b00;
				next_lives_c1 = 2'b00;
			end
			default:
			begin
				next_state = ready;
				next_lives_c1 = 2'b00;
				next_lives_c1 = 2'b00;
			end
	endcase
end

assign life_c1 = lives_c1;
assign life_c2 = lives_c2;



endmodule

