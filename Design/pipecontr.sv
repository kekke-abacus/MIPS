`timescale 1ns / 1ps

`define FUNC    4'b1111
`define ADD     4'b0000
`define SUB     4'b0001
`define AND     4'b0010
`define OR      4'b0011
`define SLT     4'b0100
`define SLL     4'b0101
`define SRL     4'b0110
`define NOR     4'b0111
`define XOR     4'b1000
`define LUI     4'b1001

`define RTYPEOPCODE 6'b000000
`define LW          6'b100011
`define SW          6'b101011
`define BEQ         6'b000100
`define BNE         6'b000101
`define ADDIU       6'b001001
`define ORI         6'b001101
`define ANDI        6'b001100
`define LUI_OP      6'b001111
`define SLTI        6'b001010
`define XORI        6'b001110
`define J           6'b000010
`define JAL         6'b000011

module control_unit (
    input  logic [5:0] Opcode,
    input  logic [5:0] Function,
    input  logic       bubble,
    output logic       RegDst,
    output logic       ALUSrc,
    output logic       MemToReg,
    output logic       RegWrite,
    output logic       MemRead,
    output logic       MemWrite,
    output logic       Branch,
    output logic       Jump,
    output logic       SignExtend,
    output logic [3:0] ALUOp,
    output logic       UseShamt
);

    always @(*) begin
        // Default values (NOP behavior)
        RegDst     = 0;
        ALUSrc     = 0;
        MemToReg   = 0;
        RegWrite   = 0;
        MemRead    = 0;
        MemWrite   = 0;
        Branch     = 0;
        Jump       = 0;
        SignExtend = 1;
        ALUOp      = `ADD;
        UseShamt   = 0;

        if (bubble) begin
            // Stall/Bubble: all control signals are NOP
            RegDst     = 0;
            ALUSrc     = 0;
            MemToReg   = 0;
            RegWrite   = 0;
            MemRead    = 0;
            MemWrite   = 0;
            Branch     = 0;
            Jump       = 0;
            SignExtend = 0;
            ALUOp      = `ADD;
            UseShamt   = 0;
        end else begin
            case (Opcode)
                `RTYPEOPCODE: begin
                    RegDst     = 1;
                    RegWrite   = 1;
                    ALUOp      = `FUNC;
                    SignExtend = 0;
                    if (Function == 6'b000000 || Function == 6'b000010 || Function == 6'b000011)
                        UseShamt = 1;
                end
                `LW: begin
                    ALUSrc     = 1;
                    MemToReg   = 1;
                    RegWrite   = 1;
                    MemRead    = 1;
                    ALUOp      = `ADD;
                end
                `SW: begin
                    ALUSrc     = 1;
                    MemWrite   = 1;
                    ALUOp      = `ADD;
                end
                `BEQ: begin
                    Branch     = 1;
                    ALUOp      = `SUB;
                end
                `BNE: begin
                    Branch     = 1;
                    ALUOp      = `SUB;
                end
                `ADDIU: begin
                    ALUSrc     = 1;
                    RegWrite   = 1;
                    ALUOp      = `ADD;
                end
                `ORI: begin
                    ALUSrc     = 1;
                    RegWrite   = 1;
                    ALUOp      = `OR;
                    SignExtend = 0;
                end
                `ANDI: begin
                    ALUSrc     = 1;
                    RegWrite   = 1;
                    ALUOp      = `AND;
                    SignExtend = 0;
                end
                `LUI_OP: begin
                    ALUSrc     = 1;
                    RegWrite   = 1;
                    ALUOp      = `LUI;
                    SignExtend = 0;
                end
                `SLTI: begin
                    ALUSrc     = 1;
                    RegWrite   = 1;
                    ALUOp      = `SLT;
                end
                `XORI: begin
                    ALUSrc     = 1;
                    RegWrite   = 1;
                    ALUOp      = `XOR;
                    SignExtend = 0;
                end
                `J: begin
                    Jump = 1;
                end
                `JAL: begin
                    Jump     = 1;
                    RegWrite = 1;
                end
                default: begin
                    // Safe NOP state
                    RegDst     = 0;
                    ALUSrc     = 0;
                    MemToReg   = 0;
                    RegWrite   = 0;
                    MemRead    = 0;
                    MemWrite   = 0;
                    Branch     = 0;
                    Jump       = 0;
                    SignExtend = 0;
                    ALUOp      = `ADD;
                    UseShamt   = 0;
                end
            endcase
        end
    end
endmodule
