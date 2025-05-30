////////////////////////////////////////////////////////////////////////////////
// Design	: MIPS Processor
// Module 	: mux 4*1
//////////////////////////////////////////////////////////////////////////////////

module mux4_to_1_A (input logic [31:0]zero,one,two, input logic [1:0]select, output logic [31:0]out);

	always_comb 
	begin
		case(select)
			2'b00 : out <= zero;
			2'b01 : out <= one;
			2'b10 : out <= two;
			default : out <= zero;
		endcase
	end
	
endmodule

