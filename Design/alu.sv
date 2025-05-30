`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design	: MIPS Processor
// Module	: ALU
//////////////////////////////////////////////////////////////////////////////////
`define AND 4'b0000
`define OR 4'b0001
`define ADD 4'b0010
`define SLL 4'b0011
`define SRL 4'b0100
`define SUB 4'b0110
`define SLT 4'b0111
`define ADDU 4'b1000
`define SUBU 4'b1001
`define XOR 4'b1010
`define SLTU 4'b1011
`define NOR 4'b1100
`define SRA 4'b1101
`define LUI 4'b1110


 module ALU(input logic [31:0]BusA,BusB,shift,	
			input logic [3:0]ALUCtrl, 
			input logic [4:0]shmt,     
			output logic [31:0]BusW, 
			output logic Zero);	
			
	logic less, sra, temp, less1;
	logic signed [31:0] signed_BusA, signed_BusB;
	
	assign signed_BusA = BusA;
	assign signed_BusB = BusB;
	
	assign less  = (signed_BusA < signed_BusB);
    assign less1 = ({1'b0, BusA} < {1'b0, BusB});
	
	 		
	always_comb 
	begin
		case(ALUCtrl)
			`AND : BusW <= BusA & BusB;
			`OR  : BusW <= BusA | BusB;
			`ADD : BusW <= BusA + BusB;
			`SLL : BusW <= BusB << shmt;
			`SUB : BusW <= BusA - BusB;
			`SRL : BusW <= shift;
			`SLT : BusW <= {31'd0, less};
			`ADDU: BusW <= BusA + BusB;
			`SUBU: BusW <= BusA - BusB;
			`XOR : BusW <= BusA ^ BusB;
			`SLTU: BusW <= {31'd0, less1};
			`NOR : BusW <= ~(BusA | BusB);
			`SRA : BusW <= ((BusB & 32'h80000000) == 0 ? shift : ( shift | (32'hffffffff << (32'd32 - shmt))));
			`LUI : BusW <= {BusB[15:0], 16'b0};
			default : BusW <= '0;
		endcase
	end
	
	assign Zero = (BusW == 32'd0);

endmodule
