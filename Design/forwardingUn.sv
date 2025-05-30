`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design 	: MIPS Processor
// Module	: Forwarding unit
//////////////////////////////////////////////////////////////////////////////////

module ForwardingUnit( 
    input  logic        UseImmed,
    input  logic        UseShamt,
    input  logic [4:0]  ID_Rs, ID_Rt,
    input  logic [4:0]  EX_Rw, MEM_Rw,
    input  logic        EX_RegWrite, MEM_RegWrite,
    output logic [1:0]  AluOpCtrlA,
    output logic [1:0]  AluOpCtrlB,
    output logic        DataMemForwardCtrl_EX,
    output logic        DataMemForwardCtrl_MEM
);

	// Forwarding control signals
    typedef enum logic [1:0] {
        FORWARD_NONE  = 2'b00,
        FORWARD_EX    = 2'b01,
        FORWARD_MEM   = 2'b10,
        FORWARD_CONST = 2'b11  // For shamt or immediate usage
    } forward_t;
	
	// ALU Input A forwarding logic
    always_comb begin
        if (!UseShamt && EX_Rw != 5'd0) begin
            if (ID_Rs == EX_Rw && EX_RegWrite)
                AluOpCtrlA = FORWARD_EX;
            else if (ID_Rs == MEM_Rw && (MEM_Rw != EX_Rw || !EX_RegWrite) && MEM_RegWrite)
                AluOpCtrlA = FORWARD_MEM;
            else
                AluOpCtrlA = FORWARD_NONE;
        end else if (UseShamt)
            AluOpCtrlA = FORWARD_CONST;
        else
            AluOpCtrlA = FORWARD_NONE;
    end

    // ALU Input B forwarding logic
    always_comb begin
        if (!UseImmed && EX_Rw != 5'd0) begin
            if (ID_Rt == EX_Rw && EX_RegWrite)
                AluOpCtrlB = FORWARD_EX;
            else if (ID_Rt == MEM_Rw && (MEM_Rw != EX_Rw || !EX_RegWrite) && MEM_RegWrite)
                AluOpCtrlB = FORWARD_MEM;
            else
                AluOpCtrlB = FORWARD_NONE;
        end else if (UseImmed)
            AluOpCtrlB = FORWARD_CONST;
        else
            AluOpCtrlB = FORWARD_NONE;
    end

    // Memory data forwarding logic
    always_comb begin
        if (MEM_RegWrite && ID_Rt == MEM_Rw) begin
            DataMemForwardCtrl_EX  = 1'b1;
            DataMemForwardCtrl_MEM = 1'b0;
        end else if (EX_RegWrite && ID_Rt == EX_Rw) begin
            DataMemForwardCtrl_EX  = 1'b0;
            DataMemForwardCtrl_MEM = 1'b1;
        end else begin
            DataMemForwardCtrl_EX  = 1'b0;
            DataMemForwardCtrl_MEM = 1'b0;
        end
    end
	
endmodule
