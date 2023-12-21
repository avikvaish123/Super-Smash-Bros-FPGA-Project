//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 298 Lab 7                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  ball ( input Reset, frame_clk, hit,
input [7:0] keycode_1, keycode_2, keycode_3, keycode_4,
input [12:0] launch_dist,
               output [9:0]  BallX, BallY, BallW, BallH,
						output death_status);
   
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion, Ball_Width, Ball_Height;
	 logic falling, death;

    parameter [9:0] Ball_X_reset = 460;  // start position if reset
    parameter [9:0] Ball_Y_reset = 230;  
    parameter [9:0] Ball_X_Min= 0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=620;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min= 0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max= 450;     // Bottommost point on the Y axis

	 parameter [9:0] Ball_X_revive = 320;  //start position if death
	 parameter [9:0] Ball_Y_revive = 100;
	 
	 parameter[9:0] big_platform_left = 102;
	 parameter [9:0] big_platform_right = 494;
	 parameter [9:0] big_platform_top = 294;
	 parameter [9:0] big_platform_bottom = 286;

    assign Ball_Width = 40;	 // assigns the value 4 as a 10-digit binary number, ie "0000000100"
	 assign Ball_Height = 60;	 // assigns the value 4 as a 10-digit binary number, ie "0000000100"
	
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Ball
        if (Reset)  // Asynchronous Reset
        begin
            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
				Ball_X_Motion <= 10'd0; //Ball_X_Step;
				Ball_Y_Pos <= Ball_Y_reset;
				Ball_X_Pos <= Ball_X_reset;
        end
           
        else
        begin
 

				if (keycode_1 == 8'h04 || keycode_2 == 8'h04 || keycode_3 == 8'h04 || keycode_4 == 8'h04)  //A
				begin
						if (hit)
						begin
							if (Ball_X_Pos >= 320)
								Ball_X_Motion <= launch_dist[11:5];
							else
								Ball_X_Motion <= -1 * launch_dist[11:5];
						end
						else
							Ball_X_Motion <= -3;
						
						if(falling)
							Ball_Y_Motion <= 3;
						else
							Ball_Y_Motion <= 0;
				end
				else if ( keycode_1 == 8'h07 || keycode_2 == 8'h07 || keycode_3 == 8'h07 || keycode_4 == 8'h07 ) //D
				begin 
						if (hit)
						begin
							if (Ball_X_Pos >= 320)
								Ball_X_Motion <= launch_dist[11:5];
							else
								Ball_X_Motion <= -1 * launch_dist[11:5];
						end
						else
							Ball_X_Motion <= 3;
							
							
						if(falling)
							Ball_Y_Motion <= 3;
						else
							Ball_Y_Motion <= 0;
				end
				else if (keycode_1 == 8'h16 || keycode_2 == 8'h16 || keycode_3 == 8'h16 || keycode_4 == 8'h16 ) //S
				begin
						if ((Ball_X_Pos > 153) & (Ball_X_Pos < 255) & (Ball_Y_Pos < 224 - Ball_Height) & (Ball_Y_Pos > 216 - Ball_Height)
							|| (Ball_X_Pos > 324) & (Ball_X_Pos < 443) & (Ball_Y_Pos < 224 - Ball_Height) & (Ball_Y_Pos > 216 - Ball_Height))
							Ball_Y_Motion <= 3;
						else
						begin
					      if(falling)
								Ball_Y_Motion <= 3;
							else	
								Ball_Y_Motion <= 0;
						end
								
						if (hit)
						begin
							if (Ball_X_Pos >= 320)
								Ball_X_Motion <= launch_dist[11:5];
							else
								Ball_X_Motion <= -1 * launch_dist[11:5];
						end
						else
							Ball_X_Motion <= 0;
				end
				else if (keycode_1 == 8'h1A || keycode_2 == 8'h1A || keycode_3 == 8'h1A || keycode_4 == 8'h1A)
				begin
						if((Ball_X_Pos > big_platform_left) & (Ball_X_Pos < big_platform_right - Ball_Width) & (Ball_Y_Pos > 300) )
							Ball_Y_Motion <= 0;
						else
							Ball_Y_Motion <= -3;//up arrow
						
						if (hit)
						begin
							if (Ball_X_Pos >= 320)
								Ball_X_Motion <= launch_dist[11:5];
							else
								Ball_X_Motion <= -1 * launch_dist[11:5];
						end
						else
							Ball_X_Motion <= 0;
				end
				else
				begin
						if(falling)
							Ball_Y_Motion <= 3;
						else
							Ball_Y_Motion <= 0;
						
						if (hit)
						begin
							if (Ball_X_Pos >= 320)
								Ball_X_Motion <= launch_dist[11:5];
							else
								Ball_X_Motion <= -1 * launch_dist[11:5];
						end
						else
							Ball_X_Motion <= 0;
						
				end
				
			
			//----final decisions ------- 
			if ( Ball_Y_Pos >= Ball_Y_Max )
			begin
				Ball_X_Pos <= Ball_X_revive - 30;
				Ball_Y_Pos <= Ball_Y_revive;
				death <= 1;
			end
			else if ( Ball_Y_Pos <= Ball_Y_Min ) 
			begin
				Ball_X_Pos <= Ball_X_revive - 30;
				Ball_Y_Pos <= Ball_Y_revive;
				death <= 1;
			end
			else if ( Ball_X_Pos >= Ball_X_Max )
			begin
				Ball_X_Pos <= Ball_X_revive - 30;
				Ball_Y_Pos <= Ball_Y_revive;
				death <= 1;
			end
			else if ( Ball_X_Pos <= Ball_X_Min )
			begin
				Ball_X_Pos <= Ball_X_revive - 30;
				Ball_Y_Pos <= Ball_Y_revive;
				death <= 1;
			end
			else
			begin
				Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion);  // Update ball position
				Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion);
				death <= 0;
			end


		end  
    end
       
    assign BallX = Ball_X_Pos;
   
    assign BallY = Ball_Y_Pos;
   
    assign BallW = Ball_Width;
	 
	 assign BallH = Ball_Height;
	 
	 assign death_status = death;
	 
	 
   always_comb
	begin
		if ((Ball_X_Pos > big_platform_left) & (Ball_X_Pos < big_platform_right) & (Ball_Y_Pos < big_platform_top - Ball_Height) & (Ball_Y_Pos > big_platform_bottom - Ball_Height))
				falling = 0;
			else if ((Ball_X_Pos > 153) & (Ball_X_Pos < 255) & (Ball_Y_Pos < 224 - Ball_Height) & (Ball_Y_Pos > 216 - Ball_Height)
				|| (Ball_X_Pos > 324) & (Ball_X_Pos < 443) & (Ball_Y_Pos < 224 - Ball_Height) & (Ball_Y_Pos > 216 - Ball_Height))
				falling = 0;
			else
				falling = 1;
	end

endmodule
