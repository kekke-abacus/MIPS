//////////////////////////////////////////////////////////////////////////////////
// Design	:MIPS Processor
// Module	: Register File
//////////////////////////////////////////////////////////////////////////////////

module RegisterFile(
	input  logic        CLK,     
	input  logic        Reset_L,
	input  logic [4:0]  rs, 
	input  logic [4:0]  rt, 
	input  logic [4:0]  rw5, 
	input  logic        regWrite5,
	input  logic [31:0] Busw,  
	output logic [31:0] BusA,
	output logic [31:0] BusB
);

	logic [31:0] registerfile [0:31];  
  
  	integer i;
	
   	always_ff @(posedge CLK) begin 
        if (!Reset_L) begin
		    for (i=0; i<32; i=i+1) begin
			    registerfile[i] <= 32'h0;
			end
        end else if(regWrite5 && rw5 != 0) begin  
				registerfile[rw5] <= Busw;
		end
		else registerfile <=registerfile;
    end 

    always_comb begin
        BusA <= registerfile[rs];
        BusB <= registerfile[rt];
    end 
	
endmodule

