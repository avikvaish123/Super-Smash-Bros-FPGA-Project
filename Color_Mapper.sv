//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//                                                                       --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 7                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  color_mapper (input Clk, blank,
							input  [9:0] BallX, BallY, DrawX, DrawY, BallX2, BallY2, C1W, C2W, C1H, C2H,
							input logic [3:0] c1r, c2r, c1g, c2g, c1b, c2b, Backgroundred, Backgroundblue, Backgroundgreen,
							input logic [3:0] hsr, hsg, hsb, gor, gog, gob, dgor, dgog, dgob,
							input logic [1:0] current_screen,
                     output logic [3:0]  Red, Green, Blue );
    
    logic ball_on;
	 logic ball_on2;
	 
 /* Old Ball: Generated square box by checking if the current pixel is within a square of length
    2*Ball_Size, centered at (BallX, BallY).  Note that this requires unsigned comparisons.
	 
    if ((DrawX >= BallX - Ball_size) &&
       (DrawX <= BallX + Ball_size) &&
       (DrawY >= BallY - Ball_size) &&
       (DrawY <= BallY + Ball_size))

     New Ball: Generates (pixelated) circle by using the standard circle formula.  Note that while 
     this single line is quite powerful descriptively, it causes the synthesis tool to use up three
     of the 12 available multipliers on the chip!  Since the multiplicants are required to be signed,
	  we have to first cast them from logic to int (signed by default) before they are multiplied). */
	  
    int DistX, DistY, Width1, Height1;
	 assign DistX = DrawX - BallX;
    assign DistY = DrawY - BallY;
    assign Width1 = C1W;
	 assign Height1 = C1H;
	 
	 int DistX2, DistY2, Width2, Height2;
	 assign DistX2 = DrawX - BallX2;
    assign DistY2 = DrawY - BallY2;
    assign Width2 = C2W;
	 assign Height2 = C2H;
	  
    always_comb
    begin:Ball_on_proc
        if ( (DistX >=0) & (DistX < Width1) & (DistY >=0) & (DistY < Height1) ) 
            ball_on = 1'b1;
        else 
            ball_on = 1'b0;
     end 
	  
	   always_comb
    begin//:Ball_on_proc
        if ( (DistX2 >=0) & (DistX2 < Width2) & (DistY2 >=0) & (DistY2 < Height2) ) 
            ball_on2 = 1'b1;
        else 
            ball_on2 = 1'b0;
     end 
       
//    always_ff @ (posedge Clk)
//    begin:RGB_Display
//        
//        if(blank) 
//        begin 
//		  
//           if ((ball_on == 1'b1)) 
//        begin 
//            Red <= marioRed;
//            Green <= marioGreen;
//            Blue <= marioBlue;
//        end   
//		  else if ((ball_on2 == 1'b1)) 
//        begin 
//            Red <= marioRed;
//            Green <= marioGreen;
//            Blue <= marioBlue;
//        end 
//			else
//			begin
//				Red <= Backgroundred;
//				Blue <= Backgroundblue;
//				Green <= Backgroundgreen;
//			end
//			
//        end
		  
		   always_comb
    begin:RGB_Display
//        if ((marioRed == 10'd255 && marioBlue == 10'd255 && marioGreen == 10'd255) || (marioRed == 10'd235 && marioBlue == 10'd235 && marioGreen == 10'd235))
//		  begin
//				Red = Backgroundred;
//				Blue = Backgroundblue;
//				Green = Backgroundgreen;
//		  
//		  end
        
		  if (current_screen == 2'b00)
		  begin
				Red = hsr;
				Blue = hsb;
				Green = hsg;
		  end
		  else if (current_screen == 2'b10)
		  begin
				Red = gor;
				Blue = gob;
				Green = gog;
		  end
		  else if (current_screen == 2'b11)
		  begin
				Red = dgor;
				Blue = dgob;
				Green = dgog;
		  end
		  else
		  begin
			  if ((ball_on == 1'b1) && !(c1r == 4'hF && c1b == 4'hF && c1g == 4'hF) && !(c1r == 4'hE && c1b == 4'hE && c1g == 4'hE)) 
			  begin 
					Red = c1r;
					Green = c1g;
					Blue = c1b;
			  end   
			  else if ((ball_on2 == 1'b1) && !(c2r == 4'hF && c2b == 4'hF && c2g == 4'hF)) 
			  begin 
					Red = c2r;
					Green = c2g;
					Blue = c2b;
			  end 
			  else
			  begin
					Red = Backgroundred;
					Blue = Backgroundblue;
					Green = Backgroundgreen;
			  end
		  end
		  
    end 
    
endmodule
