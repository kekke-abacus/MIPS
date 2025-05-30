`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design	: MIPS Processor
// Module 	: Pipelined Controller
//////////////////////////////////////////////////////////////////////////////////

`define RTYPEOPCODE 6'b000000
`define LWOPCODE  	6'b100011
`define SWOPCODE 	6'b101011
`define BEQOPCODE 	6'b000100
`define JOPCODE 	6'b000010
`define ORIOPCODE 	6'b001101
`define ADDIOPCODE 	6'b001000
`define ADDIUOPCODE 6'b001001
`define ANDIOPCODE 	6'b001100
`define LUIOPCODE 	6'b001111
`define SLTIOPCODE 	6'b001010
`define SLTIUOPCODE 6'b001011
`define XORIOPCODE 	6'b001110

`define AND 	4'b0000
`define OR 	    4'b0001
`define ADD 	4'b0010
`define SLL 	4'b0011
`define SRL 	4'b0100
`define SUB 	4'b0110
`define SLT 	4'b0111
`define ADDU 	4'b1000
`define SUBU 	4'b1001
`define XOR 	4'b1010
`define SLTU 	4'b1011
`define NOR 	4'b1100
`define SRA 	4'b1101
`define LUI 	4'b1110
`define FUNC 	4'b1111

module PipelinedControl(
   output logic 	  Jump,
   output logic 	  Branch,
   output logic 	  ALUSrc,
   output logic 	  UseShamt,
   output logic 	  MemToReg,
   output logic 	  RegWrite,
   output logic 	  MemRead,
   output logic 	  MemWrite,
   output logic 	  SignExtend,
   output logic [3:0] ALUOp,
   output logic 	  RegDst,
   input  logic 	  bubble,
   input  logic [5:0] Opcode,
   input  logic [5:0] Function
);
 
	always @(Opcode,Function,bubble) begin
		if(bubble) begin    //When stall is introduced
			MemToReg   = #2 0;
			RegWrite   = #2 0;
			MemRead    = #2 0;
			MemWrite   = #2 0;
			Branch 	   = #2 0;
			Jump 	   = #2 0;
			SignExtend = #2 1'b0;
			ALUOp 	   = #2 4'b00;
			UseShamt   = #2 0;
			RegDst 	   = #2 0;
			ALUSrc 	   = #2 0;				
		end else begin
			case(Opcode)
				`RTYPEOPCODE: begin
					RegDst 		= #2 1;
					ALUSrc 		= #2 0;
					MemToReg 	= #2 0;
					RegWrite 	= #2 1;
					MemRead 	= #2 0;
					MemWrite 	= #2 0;
					Branch 		= #2 0;
					Jump 		= #2 0;
					SignExtend 	= #2 1'b0;
					ALUOp	 	= #2 `FUNC;
					if (Function == 6'b000010 || Function == 6'b000011 || Function == 6'b000000) 
						 UseShamt = #2 1'b1; //6'b000000=SLL, 6'b000011=SRA, 6'b000010=SRL
					else UseShamt = #2  1'b0;
				end   
				
				`BEQOPCODE: begin
					UseShamt 	= #2 1'b0;
					RegDst 		= #2  1'b0;
					ALUSrc 		= #2  0;
					MemToReg 	= #2  0;
					RegWrite 	= #2  0;
					MemRead 	= #2  0;
					MemWrite 	= #2  0;
					Branch 		= #2  1;
					Jump 		= #2  0;
					SignExtend 	= #2  1'b1;
					ALUOp 		= #2 `SUB;
				end
				
				`JOPCODE: begin
					UseShamt 	= #2 1'b0;
					RegDst 		= #2  0;
					ALUSrc 		= #2  0;
					MemToReg 	= #2  0;
					RegWrite 	= #2  0;
					MemRead		= #2  0;
					MemWrite 	= #2  0;
					Branch 		= #2  0;
					Jump 		= #2  1;
					SignExtend 	= #2  1'b1;
					ALUOp 		= #2  4'b0000;
				end
				
				`LWOPCODE: begin
					UseShamt 	= #2 1'b0;
					RegDst 		= #2 0;
					ALUSrc 		= #2 1;
					MemToReg 	= #2 1;
					RegWrite 	= #2 1;
					MemRead 	= #2 1;
					MemWrite 	= #2 0;
					Branch 		= #2 0;
					Jump 		= #2 0;
					SignExtend 	= #2 1'b1;
					ALUOp 		= #2 `ADD;
				end
				
				`SWOPCODE: begin
					UseShamt 	= #2 1'b0;
					RegDst 		= #2  0;
					ALUSrc 		= #2  1;
					MemToReg 	= #2  0;
					RegWrite 	= #2  0;
					MemRead 	= #2  0;
					MemWrite 	= #2  1;
					Branch 		= #2  0;
					Jump 		= #2  0;
					SignExtend 	= #2  1'b1;
					ALUOp 		= #2  `ADD;
				end
				
				`ORIOPCODE: begin
					UseShamt 	= #2 1'b0;
					RegDst 		= #2 0;
					ALUSrc 		= #2 1;
					MemToReg 	= #2 0;
					RegWrite 	= #2 1;
					MemRead 	= #2 0;
					MemWrite 	= #2 0;
					Branch 		= #2 0;
					Jump 		= #2 0;
					SignExtend 	= #2 1'b0;
					ALUOp 		= #2 `OR;
				end
				
				`ADDIOPCODE: begin
					UseShamt 	= #2 1'b0;
					RegDst 		= #2 0;
					ALUSrc 		= #2 1;
					MemToReg 	= #2 0;
					RegWrite 	= #2 1;
					MemRead 	= #2 0;
					MemWrite 	= #2 0;
					Branch 		= #2 0;
					Jump 		= #2 0;
					SignExtend 	= #2 1'b1;
					ALUOp 		= #2 `ADD;
				end
				
				`ADDIUOPCODE: begin
					UseShamt 	= #2 1'b0;
					RegDst 		= #2 0;
					ALUSrc 		= #2 1;
					MemToReg 	= #2 0;
					RegWrite 	= #2 1;
					MemRead 	= #2 0;
					MemWrite 	= #2 0;
					Branch 		= #2 0;
					Jump 		= #2 0;
					SignExtend 	= #2 1'b0;
					ALUOp 		= #2 `ADD;
				end
				
				`ANDIOPCODE: 
				begin
					UseShamt 	= #2 1'b0;
					RegDst 		= #2 0;
					ALUSrc 		= #2 1;
					MemToReg 	= #2 0;
					RegWrite 	= #2 1;
					MemRead 	= #2 0;
					MemWrite 	= #2 0;
					Branch 		= #2 0;
					Jump 		= #2 0;
					SignExtend 	= #2 1'b0;
					ALUOp 		= #2 `AND;
				end
				
				`LUIOPCODE: 
				begin
					RegDst 		= #2 0;
					ALUSrc 		= #2 1;
					MemToReg 	= #2 0;
					RegWrite 	= #2 1;
					MemRead 	= #2 0;
					MemWrite 	= #2 0;
					Branch 		= #2 0;
					Jump 		= #2 0;
					SignExtend 	= #2 1'b0;
					ALUOp 		= #2 `LUI;
				end
				
				`SLTIOPCODE: 
				begin
					UseShamt 	= #2 1'b0;
					RegDst 		= #2 0;
					ALUSrc 		= #2 1;
					MemToReg 	= #2 0;
					RegWrite 	= #2 1;
					MemRead 	= #2 0;
					MemWrite 	= #2 0;
					Branch	 	= #2 0;
					Jump 		= #2 0;
					SignExtend 	= #2 1'b1;
					ALUOp 		= #2 `SLT;
				end
				
				`SLTIUOPCODE: 
				begin
					RegDst 		= #2 0;
					UseShamt 	= #2 1'b0;
					ALUSrc 		= #2 1;
					MemToReg	= #2 0;
					RegWrite 	= #2 1;
					MemRead 	= #2 0;
					MemWrite 	= #2 0;
					Branch 		= #2 0;
					Jump 		= #2 0;
					SignExtend 	= #2 1'b1;
					ALUOp 		= #2 `SLTU;
				end
				`XORIOPCODE: 
				begin
					UseShamt 	= #2 1'b0;
					RegDst 		= #2 0;
					ALUSrc 		= #2 1;
					MemToReg 	= #2 0;
					RegWrite 	= #2 1;
					MemRead 	= #2 0;
					MemWrite 	= #2 0;
					Branch 		= #2 0;
					Jump 		= #2 0;
					SignExtend 	= #2 1'b0;
					ALUOp 		= #2 `XOR;
				end
				
				default: 
				begin
					UseShamt 	= #2 1'b0;
					RegDst 		= #2 1'bx;
					ALUSrc 		= #2 1'bx;
					MemToReg 	= #2 1'bx;
					RegWrite 	= #2 1'bx;
					MemRead 	= #2 1'bx;
					MemWrite 	= #2 1'bx;
					Branch		= #2 1'bx;
					Jump 		= #2 1'bx;
					SignExtend 	= #2 1'bx;
					ALUOp 		= #2 4'bxxxx;
				end
			endcase
		end
	end
	
endmodule
