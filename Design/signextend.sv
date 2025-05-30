//////////////////////////////////////////////////////////////////////////////////
// Design	: MIPS Processor
// Module 	: Sign Extender
//////////////////////////////////////////////////////////////////////////////////

module SignExtender(
	input logic [15:0]in, 
	input logic signExtend, 
	output logic [31:0]out
);

	always_comb begin
		if (signExtend == 0) 
	       out <= 32'h0 + in;
		else 
	       out <= (in[15] ? (32'hffff0000 + in) : (32'h0 + in));
	end
	
endmodule


