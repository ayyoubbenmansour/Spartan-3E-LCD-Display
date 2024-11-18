`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ayyoub Benmansour
// 
// Create Date:    12:58:28 11/18/2024 
// Design Name: 
// Module Name:    LCD_Verilog 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module LCD_Verilog( clk, sf_e, e, rs, rw, db_4, db_3, db_2, db_1 );

	(* LOC = "C9" *) input clk; // pin C9 is the 50-MHz on-board clock
	(* LOC = "D16" *) output reg sf_e; // 1 LCD access (0 StrataFlash access)
	(* LOC = "M18" *) output reg e; // enable (1)
	(* LOC = "L18" *) output reg rs; // Register Select (1 data bits for R/W)
	(* LOC = "L17" *) output reg rw; // Read/Write, 1/0
	(* LOC = "M15" *) output reg db_4; // 4th data bits (to from a nibble)
	(* LOC = "P17" *) output reg db_3; // 3rd data bits (to from a nibble)
	(* LOC = "R16" *) output reg db_2; // 2nd data bits (to from a nibble)
	(* LOC = "R15" *) output reg db_1; // 1st data bits (to from a nibble)
	
	reg [ 26 : 0 ] count = 0;	// 27-bit count, 0-(128M-1), over 2 secs
	reg [ 5 : 0 ] code;			// 6-bit different signals to give out
	reg refresh;	
	always @ (posedge clk) begin
		count <= count +1;
		
		case ( count[ 26 : 21 ] )	// as top 6 bits change
			// Power-on initialization sequence
			0: code <= 6'h03;			// Power-on init sequence
			1: code <= 6'h03;			// Needed at least once
			2: code <= 6'h03;			// When LCD's powered on
			3: code <= 6'h02;			// Function Set
			4: code <= 6'h02;			// Function Set, upper nibble 0010
			5: code <= 6'h08;			// Lower nibble 1000 (10xx)
			6: code <= 6'h00; 			// Entry Mode, upper nibble 0000
			7: code <= 6'h06;			// Lower nibble 0110 (Incr, no shift)
			8: code <= 6'h00;			// Display On/Off, upper nibble 0000
			9: code <= 6'h0C;			// Lower nibble 1100 (Display ON, no cursor)
			10: code <= 6'h00;			// Clear Display
			11: code <= 6'h01;			// Clear Display, lower nibble 0001

			// First line: "SSE"
			12: code <= 6'h25;		// 'S' high nibble
			13: code <= 6'h23;		// 'S' low nibble
			14: code <= 6'h25;		// 'S' high nibble
			15: code <= 6'h23;		// 'S' low nibble
			16: code <= 6'h24;		// 'E' high nibble
			17: code <= 6'h25;		// 'E' low nibble

			// Set DDRAM address to start of the second line
			18: code <= 6'b001100;	// Set cursor to second line (upper nibble h40)
			19: code <= 6'b000000;	// Lower nibble: h0

			// Second line: "ENSIAS"
			20: code <= 6'h24;		// 'E' high nibble
			21: code <= 6'h25;		// 'E' low nibble
			22: code <= 6'h24;		// 'N' high nibble
			23: code <= 6'h2E;		// 'N' low nibble
			24: code <= 6'h25;		// 'S' high nibble
			25: code <= 6'h23;		// 'S' low nibble
			26: code <= 6'h24;		// 'I' high nibble
			27: code <= 6'h29;		// 'I' low nibble
			28: code <= 6'h24;		// 'A' high nibble
			29: code <= 6'h21;		// 'A' low nibble
			30: code <= 6'h25;		// 'S' high nibble
			31: code <= 6'h23;		// 'S' low nibble

			// Idle state
			default: code <= 6'h10;	// The rest un-used time
		endcase

		// Refresh (enable) the LCD
		refresh <= count[ 20 ]; // Flip rate ~25Hz (50MHz / 2^21)
		sf_e <= 1;
		{ e, rs, rw, db_4, db_3, db_2, db_1 } <= { refresh, code };
	end // always


endmodule
