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


module  ball2 ( input Reset, frame_clk, hit,
input [7:0] keycode_1, keycode_2, keycode_3, keycode_4,
input [12:0] launch_dist,
               output [9:0]  BallX, BallY, BallW, BallH, 
					output death_status);
   
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion, Ball_Width, Ball_Height;
	 logic falling, death;

	 /*ball pos refers to the top left corner of the sprite*/
	 
	 
    parameter [9:0] Ball_X_reset = 150;  // start position if reset
    parameter [9:0] Ball_Y_reset = 230;  
    parameter [9:0] Ball_X_Min= 0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max= 610;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min= 0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max= 450;     // Bottommost point on the Y axis
	 
	 parameter [9:0] Ball_X_revive = 320;  //start position if death
	 parameter [9:0] Ball_Y_revive = 100;
    
	 parameter[9:0] big_platform_left = 78;
	 parameter [9:0] big_platform_right = 481;
	 parameter [9:0] big_platform_top = 294;
	 parameter [9:0] big_platform_bottom = 286;
	 
	 

    assign Ball_Width = 60;	 // assigns the value 4 as a 10-digit binary number, ie "0000000100"
	 assign Ball_Height = 60;	 // assigns the value 4 as a 10-digit binary number, ie "0000000100"
   
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Ball
        if (Reset)  // Asynchronous Reset
        begin
            Ball_Y_Motion <= 10'd0; 
				Ball_X_Motion <= 10'd0; 
				Ball_Y_Pos <= Ball_Y_reset;
				Ball_X_Pos <= Ball_X_reset;
        end
           
        else
        begin
 
			//keycodes
			if (keycode_1 == 8'h50 || keycode_2 == 8'h50 || keycode_3 == 8'h50 || keycode_4 == 8'h50)  //left arrow
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
				else if ( keycode_1 == 8'h4F || keycode_2 == 8'h4F || keycode_3 == 8'h4F || keycode_4 == 8'h4F ) //right arrow
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
				else if (keycode_1 == 8'h51 || keycode_2 == 8'h51 || keycode_3 == 8'h51 || keycode_4 == 8'h51 ) //down arrow
				begin
						if ((Ball_X_Pos > 126) & (Ball_X_Pos < 260) & (Ball_Y_Pos < 224 - Ball_Height) & (Ball_Y_Pos > 216 - Ball_Height)
							|| (Ball_X_Pos > 310) & (Ball_X_Pos < 432) & (Ball_Y_Pos < 224 - Ball_Height) & (Ball_Y_Pos > 216 - Ball_Height))
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
				else if (keycode_1 == 8'h52 || keycode_2 == 8'h52 || keycode_3 == 8'h52 || keycode_4 == 8'h52) //up arrow
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
			 
			//------final decisions --------- 
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
	
	
	//determine if the sprite is on the platform or not	
	always_comb
	begin
		if ((Ball_X_Pos > big_platform_left) & (Ball_X_Pos < big_platform_right) & (Ball_Y_Pos < big_platform_top - Ball_Height) & (Ball_Y_Pos > big_platform_bottom - Ball_Height))
				falling = 0;
			else if ((Ball_X_Pos > 126) & (Ball_X_Pos < 260) & (Ball_Y_Pos < 224 - Ball_Height) & (Ball_Y_Pos > 216 - Ball_Height)
				|| (Ball_X_Pos > 310) & (Ball_X_Pos < 432) & (Ball_Y_Pos < 224 - Ball_Height) & (Ball_Y_Pos > 216 - Ball_Height))
				falling = 0;
			else
				falling = 1;
	end
	
endmodule
