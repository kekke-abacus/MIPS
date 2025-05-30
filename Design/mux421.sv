//////////////////////////////////////////////////////////////////////////////////
// Design 	: MIPS Processor
// module 	: Mux 4*1
//////////////////////////////////////////////////////////////////////////////////

module mux4_to_1_B (input logic [31:0]zero,one,two,three, input logic [1:0]select, output logic [31:0]out);

	always_comb 
	begin
		case(select)
			2'b00 : out <= zero;
			2'b01 : out <= one;
			2'b10 : out <= two;
			default : out <= three;
		endcase
	end
	
endmodule
