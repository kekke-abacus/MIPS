module PipelineProcessor (
    input logic CLK,
    input logic Reset_L,
    input logic [31:0] startPC,
    output logic [31:0] dMemOut
);

// Pipeline Registers
logic [31:0] PC, instruction1;
logic [31:0] instruction2;
logic [4:0] rs1_2, rs2_2, rw2;
logic [31:0] A, B;
logic [31:0] imm2;
logic [2:0] ALUOp2;
logic [1:0] ALUSrcA2, ALUSrcB2;
logic [1:0] ForwardA, ForwardB;
logic [31:0] operandA, operandB;
logic [3:0] ALUCtl;
logic [31:0] aluOut3, aluOut4, aluOut5;
logic [31:0] memOut, memOut5;
logic [4:0] rw3, rw4, rw5;
logic [31:0] DataIn3, DataIn4;
logic [31:0] regWriteData;
logic [1:0] Data_Mem_Fwrd_Ctrl_MEM3, DataMemForwardCtrl_MEM4;
logic [31:0] MemData_MuxOut;
logic PCWrite, IF_ID_Write, ID_Flush, EX_Flush, branch2, zero, PCSrc;
logic memRead2, memWrite2, regWrite2, memToReg2;
logic memRead3, memWrite3, regWrite3, memToReg3;
logic memRead4, memWrite4, regWrite4, memToReg4;
logic regWrite5, memToReg5;

// Instruction Fetch Stage
InstructionMemory iMem (
    .Address(PC),
    .Instruction(instruction1)
);

always_ff @(posedge CLK or negedge Reset_L) begin
    if (!Reset_L)
        PC <= startPC;
    else if (PCWrite)
        PC <= PCSrc ? (PC + imm2) : (PC + 4);
end

// Pipeline Register: IF/ID
always_ff @(posedge CLK or negedge Reset_L) begin
    if (!Reset_L || ID_Flush)
        instruction2 <= 0;
    else if (IF_ID_Write)
        instruction2 <= instruction1;
end

// Instruction Decode Stage
assign rs1_2 = instruction2[19:15];
assign rs2_2 = instruction2[24:20];
assign rw2 = instruction2[11:7];

PipelinedControl control (
    .Instruction(instruction2),
    .ALUOp(ALUOp2),
    .ALUSrcA(ALUSrcA2),
    .ALUSrcB(ALUSrcB2),
    .Branch(branch2),
    .MemRead(memRead2),
    .MemWrite(memWrite2),
    .RegWrite(regWrite2),
    .MemToReg(memToReg2)
);

Hazard hazard (
    .ID_EX_Rs1(rs1_2),
    .ID_EX_Rs2(rs2_2),
    .EX_MEM_RegWrite(regWrite3),
    .EX_MEM_Rd(rw3),
    .MEM_WB_RegWrite(regWrite4),
    .MEM_WB_Rd(rw4),
    .PCWrite(PCWrite),
    .IF_ID_Write(IF_ID_Write),
    .ID_Flush(ID_Flush)
);

RegisterFile rf (
    .clk(CLK),
    .we3(regWrite5),
    .ra1(rs1_2),
    .ra2(rs2_2),
    .wa3(rw5),
    .wd3(regWriteData),
    .rd1(A),
    .rd2(B)
);

SignExtender ext (
    .Instruction(instruction2),
    .Immediate(imm2)
);

// Pipeline Register: ID/EX
logic [4:0] rs1_3, rs2_3, rw3_next;
logic [31:0] A3, B3, imm3;
logic [2:0] ALUOp3;
logic [1:0] ALUSrcA3, ALUSrcB3;
logic branch3;
always_ff @(posedge CLK or negedge Reset_L) begin
    if (!Reset_L || EX_Flush) begin
        rs1_3 <= 0; rs2_3 <= 0; rw3_next <= 0;
        A3 <= 0; B3 <= 0; imm3 <= 0;
        ALUOp3 <= 0; ALUSrcA3 <= 0; ALUSrcB3 <= 0;
        branch3 <= 0;
        memRead3 <= 0; memWrite3 <= 0; regWrite3 <= 0; memToReg3 <= 0;
    end else begin
        rs1_3 <= rs1_2; rs2_3 <= rs2_2; rw3_next <= rw2;
        A3 <= A; B3 <= B; imm3 <= imm2;
        ALUOp3 <= ALUOp2; ALUSrcA3 <= ALUSrcA2; ALUSrcB3 <= ALUSrcB2;
        branch3 <= branch2;
        memRead3 <= memRead2; memWrite3 <= memWrite2;
        regWrite3 <= regWrite2; memToReg3 <= memToReg2;
    end
end

ForwardingUnit fwd (
    .EX_MEM_RegWrite(regWrite4),
    .MEM_WB_RegWrite(regWrite5),
    .EX_MEM_Rd(rw4),
    .MEM_WB_Rd(rw5),
    .ID_EX_Rs1(rs1_3),
    .ID_EX_Rs2(rs2_3),
    .ForwardA(ForwardA),
    .ForwardB(ForwardB),
    .Data_Mem_Fwrd_Ctrl(Data_Mem_Fwrd_Ctrl_MEM3)
);

mux4_to_1_A mA (
    .in0(A3), .in1(regWriteData), .in2(aluOut4), .in3(0),
    .sel(ForwardA), .out(operandA)
);

mux4_to_1_B mB (
    .in0(B3), .in1(regWriteData), .in2(aluOut4), .in3(0),
    .sel(ForwardB), .out(operandB)
);

ALUControl aluCtl (
    .ALUOp(ALUOp3),
    .Funct7(imm3[10:5]),
    .Funct3(instruction2[14:12]),
    .ALUCtl(ALUCtl)
);

ALU alu (
    .A(operandA),
    .B(ALUSrcB3 == 2'b00 ? operandB : imm3),
    .ALUControl(ALUCtl),
    .Zero(zero),
    .Result(aluOut3)
);

// Pipeline Register: EX/MEM
always_ff @(posedge CLK or negedge Reset_L) begin
    if (!Reset_L) begin
        rw3 <= 0; DataIn3 <= 0; aluOut4 <= 0;
        DataMemForwardCtrl_MEM4 <= 0;
        memRead4 <= 0; memWrite4 <= 0;
        regWrite4 <= 0; memToReg4 <= 0;
    end else begin
        rw3 <= rw3_next;
        DataIn3 <= operandB;
        aluOut4 <= aluOut3;
        DataMemForwardCtrl_MEM4 <= Data_Mem_Fwrd_Ctrl_MEM3;
        memRead4 <= memRead3;
        memWrite4 <= memWrite3;
        regWrite4 <= regWrite3;
        memToReg4 <= memToReg3;
    end
end

assign MemData_MuxOut = (DataMemForwardCtrl_MEM4) ? regWriteData : DataIn4;

DataMemory dMem (
    .ReadData(memOut),
    .Address(aluOut4),
    .WriteData(MemData_MuxOut),
    .MemRead(memRead4),
    .MemWrite(memWrite4),
    .CLK(CLK)
);

// Pipeline Register: MEM/WB
always_ff @(negedge CLK or negedge Reset_L) begin
    if (!Reset_L) begin
        memOut5 <= 0; aluOut5 <= 0; rw5 <= 0;
        memToReg5 <= 0; regWrite5 <= 0;
    end else begin
        memOut5 <= memOut;
        aluOut5 <= aluOut4;
        rw5 <= rw4;
        memToReg5 <= memToReg4;
        regWrite5 <= regWrite4;
    end
end

assign regWriteData = (memToReg5) ? memOut5 : aluOut5;
assign dMemOut = memOut;

endmodule
