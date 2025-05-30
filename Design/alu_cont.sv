`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design	: MIPS Processor
// module	: ALU control
//////////////////////////////////////////////////////////////////////////////////

//OPCODES
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

//R-type function codes
`define SLLFunc 6'b000000
`define SRLFunc 6'b000010
`define SRAFunc 6'b000011
`define ADDFunc 6'b100000
`define ADDUFunc 6'b100001
`define SUBFunc 6'b100010
`define SUBUFunc 6'b100011
`define ANDFunc 6'b100100
`define ORFunc 6'b100101
`define XORFunc 6'b100110
`define NORFunc 6'b100111
`define SLTFunc 6'b101010
`define SLTUFunc 6'b101011


module ALUControl(output logic [3:0]ALUCtrl, input logic [3:0]ALUop, input logic [5:0]FuncCode);

	always_comb begin
		if (ALUop == 4'b1111) begin
			case(FuncCode)
				`SLLFunc : ALUCtrl <= `SLL;
				`SRLFunc : ALUCtrl <= `SRL;
				`SRAFunc : ALUCtrl <= `SRA;
				`ADDFunc : ALUCtrl <= `ADD;
				`ADDUFunc: ALUCtrl <= `ADDU;
				`SUBFunc : ALUCtrl <= `SUB;
				`SUBUFunc: ALUCtrl <= `SUBU;
				`ANDFunc : ALUCtrl <= `AND;
				`ORFunc  : ALUCtrl <= `OR;
				`XORFunc : ALUCtrl <= `XOR;
				`NORFunc : ALUCtrl <= `NOR;
				`SLTFunc : ALUCtrl <= `SLT;
				`SLTUFunc: ALUCtrl <= `SLTU;
				 default : ALUCtrl <= 0;
			endcase
		end
		else ALUCtrl <= ALUop;
	end
	
endmodule
