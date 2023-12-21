//-------------------------------------------------------------------------
//                                                                       --
//                                                                       --
//      For use with ECE 385 Lab 62                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module lab62 (

      ///////// Clocks /////////
      input     MAX10_CLK1_50, 

      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LEDR /////////
      output   [ 9: 0]   LEDR,

      ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// VGA /////////
      output             VGA_HS,
      output             VGA_VS,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,


      ///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N 

);




logic Reset_h, vssig, blank, sync, VGA_Clk;


//=======================================================
//  REG/WIRE declarations
//=======================================================
	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0; //4 bit input hex digits
	logic [1:0] signs, current_screen;
	logic [1:0] hundreds;
	logic [9:0] drawxsig, drawysig, ballxsig, ballysig, ballxsig2, ballysig2;
	logic [9:0] c1_width, c2_width, c1_height, c2_height;
	logic [3:0] BackgroundRed, BackgroundBlue, BackgroundGreen;
	logic [3:0] homescreenRed, homescreenBlue, homescreenGreen;
	logic [3:0] gameoverRed, gameoverBlue, gameoverGreen;
	logic [3:0] dkgameoverRed, dkgameoverBlue, dkgameoverGreen;
	logic [3:0] marioRed, marioBlue, marioGreen;
	logic [3:0] donkeyRed, donkeyBlue, donkeyGreen;
	logic [3:0] Red, Green, Blue;
	logic [7:0] keycode_1, keycode_2, keycode_3, keycode_4;
	
	logic death_c1, death_c2, hit_on_c1, hit_on_c2;
	logic life1_c1, life2_c1, life3_c1, life1_c2, life2_c2, life3_c2;
	logic [11:0] launch_distance_c1, launch_distance_c2;
	
	

//=======================================================
//  Structural coding
//=======================================================
		
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ; 
	assign USB_IRQ = ARDUINO_IO[9];
		
	//Assignments specific to Circuits At Home UHS_20
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[7] = USB_RST;//USB reset 
	assign ARDUINO_IO[8] = 1'bZ; //this is GPX (set to input)
	assign USB_GPX = 1'b0;//GPX is not needed for standard USB host - set to 0 to prevent interrupt
	
	//Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
	assign ARDUINO_IO[6] = 1'b1;
	
	//HEX drivers to convert numbers to HEX output
	HexDriver hex_driver5 (launch_distance_c1[11:8], HEX5[6:0]);
	
	HexDriver hex_driver4 (launch_distance_c1[7:4], HEX4[6:0]);
	
	HexDriver hex_driver3 (launch_distance_c1[3:0], HEX3[6:0]);
	
	HexDriver hex_driver2 (launch_distance_c2[11:8], HEX2[6:0]);
		
	HexDriver hex_driver1 (launch_distance_c2[7:4], HEX1[6:0]);
	
	HexDriver hex_driver0 (launch_distance_c2[3:0], HEX0[6:0]);

	
	assign LEDR[9] = life1_c1;
	assign LEDR[8] = life2_c1;
	assign LEDR[7] = life3_c1;
	assign LEDR[2] = life3_c2;
	assign LEDR[1] = life2_c2;
	assign LEDR[0] = life1_c2;
 	
	//fill in the hundreds digit as well as the negative sign
	//assign HEX5 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
	//assign HEX2 = {1'b1, ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};
	
	
	//Assign one button to reset
	assign {Reset_h}=~ (KEY[0]);

	//Our A/D converter is only 12 bit
	assign VGA_R = Red;
	assign VGA_B = Blue;
	assign VGA_G = Green;
	
	
	lab62_soc u0 (
		.clk_clk                           (MAX10_CLK1_50),  //clk.clk
		.reset_reset_n                     (1'b1),           //reset.reset_n
		.altpll_0_locked_conduit_export    (),               //altpll_0_locked_conduit.export
		.altpll_0_phasedone_conduit_export (),               //altpll_0_phasedone_conduit.export
		.altpll_0_areset_conduit_export    (),               //altpll_0_areset_conduit.export
		.key_external_connection_export    (KEY),            //key_external_connection.export

		//SDRAM
		.sdram_clk_clk(DRAM_CLK),                            //clk_sdram.clk
		.sdram_wire_addr(DRAM_ADDR),                         //sdram_wire.addr
		.sdram_wire_ba(DRAM_BA),                             //.ba
		.sdram_wire_cas_n(DRAM_CAS_N),                       //.cas_n
		.sdram_wire_cke(DRAM_CKE),                           //.cke
		.sdram_wire_cs_n(DRAM_CS_N),                         //.cs_n
		.sdram_wire_dq(DRAM_DQ),                             //.dq
		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),              //.dqm
		.sdram_wire_ras_n(DRAM_RAS_N),                       //.ras_n
		.sdram_wire_we_n(DRAM_WE_N),                         //.we_n

		//USB SPI	
		.spi0_SS_n(SPI0_CS_N),
		.spi0_MOSI(SPI0_MOSI),
		.spi0_MISO(SPI0_MISO),
		.spi0_SCLK(SPI0_SCLK),
		
		//USB GPIO
		.usb_rst_export(USB_RST),
		.usb_irq_export(USB_IRQ),
		.usb_gpx_export(USB_GPX),
		
		//LEDs and HEX
		.hex_digits_export({hex_num_4, hex_num_3, hex_num_1, hex_num_0}),
		.leds_export({hundreds, signs, LEDR[6:3]}),
		.keycode_1_export(keycode_1),
		.keycode_2_export(keycode_2),
		.keycode_3_export(keycode_3),
		.keycode_4_export(keycode_4)
		
	 );

	 
	 //instantiating the modules
	vga_controller vga(.Clk(MAX10_CLK1_50), .Reset(Reset_h), .hs(VGA_HS), .vs(VGA_VS), 
		.pixel_clk(VGA_Clk), .blank(blank), .sync(sync), .DrawX(drawxsig), .DrawY(drawysig) );

	ball char1( .Reset(Reset_h), .frame_clk(VGA_VS),.hit(hit_on_c1),
		.BallX(ballxsig), .BallY(ballysig), .BallW(c1_width), .BallH(c1_height),
		.death_status(death_c1), .launch_dist(launch_distance_c1),
		.keycode_1(keycode_1), .keycode_2(keycode_2), .keycode_3(keycode_3), .keycode_4(keycode_4));
	
	ball2 char2( .Reset(Reset_h), .frame_clk(VGA_VS), .hit(hit_on_c2),
		.BallX(ballxsig2), .BallY(ballysig2), .BallW(c2_width), .BallH(c2_height),
		.death_status(death_c2), .launch_dist(launch_distance_c2),
		.keycode_1(keycode_1), .keycode_2(keycode_2), .keycode_3(keycode_3), .keycode_4(keycode_4)	);

	
	color_mapper cm(.Clk(VGA_Clk), .blank(blank), .BallX(ballxsig), .BallY(ballysig), 
		.DrawX(drawxsig), .DrawY(drawysig), 
		.BallX2(ballxsig2), .BallY2(ballysig2),
		.C1W(c1_width), .C1H(c1_height), .C2H(c2_height), .C2W(c2_width),
		.Red(Red), .Green(Green), .Blue(Blue), 
		.c1r(marioRed), .c1g(marioGreen), .c1b(marioBlue),
		.c2r(donkeyRed), .c2g(donkeyGreen), .c2b(donkeyBlue), 
		.Backgroundred(BackgroundRed), .Backgroundblue(BackgroundBlue), .Backgroundgreen(BackgroundGreen),
		.hsr(homescreenRed), .hsg(homescreenGreen), .hsb(homescreenBlue),
		.gor(gameoverRed), .gog(gameoverGreen), .gob(gameoverBlue),
		.dgor(dkgameoverRed), .dgog(dkgameoverGreen), .dgob(dkgameoverBlue),
		.current_screen(current_screen) );
	
	battlefield_example battlefield ( .vga_clk(VGA_Clk), .DrawX(drawxsig), .DrawY(drawysig), .blank(blank), 
		.red(BackgroundRed), .green(BackgroundGreen), .blue(BackgroundBlue) );
		
	homescreen_example homescreen ( .vga_clk(VGA_Clk), .DrawX(drawxsig), .DrawY(drawysig), .blank(blank), 
		.red(homescreenRed), .green(homescreenGreen), .blue(homescreenBlue) );
		
	gameover_example gameover_screen ( .vga_clk(VGA_Clk), .DrawX(drawxsig), .DrawY(drawysig), .blank(blank), 
		.red(gameoverRed), .green(gameoverGreen), .blue(gameoverBlue) );
		
	dkgameover_example dkgameover_screen ( .vga_clk(VGA_Clk), .DrawX(drawxsig), .DrawY(drawysig), .blank(blank), 
		.red(dkgameoverRed), .green(dkgameoverGreen), .blue(dkgameoverBlue) );
	
//	run1_example mario(
//	.vga_clk(VGA_Clk),
//	.DrawX(drawxsig), .DrawY(drawysig), .BallX(ballxsig), .BallY(ballysig),
//	.blank(blank),
//	.red(marioRed), .green(marioGreen), .blue(marioBlue));

	mario_example mario (.vga_clk(VGA_Clk), 
	.DrawX(drawxsig), .DrawY(drawysig), .BallX(ballxsig), .BallY(ballysig),
	.blank(blank),
	.red(marioRed), .green(marioGreen), .blue(marioBlue));
	
	donkeykong_example donkeykong (.vga_clk(VGA_Clk), 
	.DrawX(drawxsig), .DrawY(drawysig), .BallX(ballxsig2), .BallY(ballysig2),
	.blank(blank),
	.red(donkeyRed), .green(donkeyGreen), .blue(donkeyBlue));


	controllogic control ( .clk(VGA_Clk), .reset(Reset_h),
		.c1x(ballxsig), .c1y(ballysig), .c2x(ballxsig2), .c2y(ballysig2),
		.death_c1(death_c1), .death_c2(death_c2),
		.hp_c1(launch_distance_c1), .hp_c2(launch_distance_c2),
		.life1_c1(life1_c1), .life2_c1(life2_c1), .life3_c1(life3_c1), 
		.life1_c2(life1_c2), .life2_c2(life2_c2), .life3_c2(life3_c2),
		.hit_on_c1(hit_on_c1), .hit_on_c2(hit_on_c2), .current_screen(current_screen),
	   .keycode_1(keycode_1), .keycode_2(keycode_2), .keycode_3(keycode_3), .keycode_4(keycode_4));

endmodule
