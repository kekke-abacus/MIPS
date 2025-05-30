`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design	: MIPS Processor
// Module	: Hazard
//////////////////////////////////////////////////////////////////////////////////

module Hazard(
	input  logic       Jump, Branch, ALUZero,
    input  logic       memReadEX,
    input  logic       Clk, Rst,
    input  logic       UseImmed, UseShmt,
    input  logic [4:0] CurrRt, CurrRs, PrevRw,

    output logic       IF_Write, 
    output logic       PC_Write, 
    output logic       bubble,  
    output logic [1:0] addrSel
);
	
	// FSM states using typedef enum
    typedef enum logic [1:0] {
        NO_HAZARD = 2'b00,
        JUMP      = 2'b01,
        BRANCH_0  = 2'b10,
        BRANCH_1  = 2'b11
    } state_t;

    state_t FSM_state, FSM_nxt_state;

    logic LoadHazard;

	// RAW Hazard Detection Logic
    always_comb begin
        LoadHazard = 1'b0;
        if (PrevRw != 5'd0 && memReadEX) begin
            if (!UseImmed && !UseShmt) begin
                if (CurrRs == PrevRw || CurrRt == PrevRw)
                    LoadHazard = 1'b1;
            end
            else if (UseShmt && !UseImmed) begin
                if (CurrRs == PrevRw)
                    LoadHazard = 1'b1;
            end
            else if (!UseShmt && UseImmed) begin
                if (CurrRs == PrevRw)
                    LoadHazard = 1'b1;
            end
        end
    end
   
    //FSM for Hazard detection Unit  
    always_ff @(posedge Clk or negedge Rst) begin
		if (!Rst)
			FSM_state <= NO_HAZARD;
		else 
			FSM_state <= FSM_nxt_state;
	end
		
    //Combinational Logic for FSM        
    always_comb begin
        case (FSM_state)
			NO_HAZARD: begin
				if (Jump) begin
					FSM_nxt_state = JUMP;
					PC_Write 	  = 1'b1;
                    IF_Write 	  = 1'b1;
                    bubble 		  = 1'b0;
                    addrSel 	  = 2'b00;
				end
                else if (LoadHazard) begin
					FSM_nxt_state = NO_HAZARD; 
					PC_Write 	  = 1'b0;
                    IF_Write 	  = 1'b0;
                    bubble 		  = 1'b1;  //Stall for one cycle
                    addrSel 	  = 2'b00;
				end
                else if (Branch) begin 
					FSM_nxt_state = BRANCH_0;
					PC_Write 	  = 1'b1;
                    IF_Write 	  = 1'b1;
                    bubble 		  = 1'b0;
                    addrSel 	  = 2'b00;
				end
                else begin 
					FSM_nxt_state = NO_HAZARD;
                    PC_Write 	  = 1'b1;
                    IF_Write 	  = 1'b1;
                    bubble 		  = 1'b0;
                    addrSel 	  = 2'b00;
                end
            end
			
			JUMP: begin
                FSM_nxt_state = NO_HAZARD;
                PC_Write      = 1'b1;
                IF_Write      = 1'b0;
                bubble        = 1'b1;  //Stall for one cycle
                addrSel       = 2'b01;                                   
            end
			
			BRANCH_0: begin
                if (!ALUZero) begin
					FSM_nxt_state = NO_HAZARD;
                    PC_Write 	  =1'b0;
                    IF_Write 	  =1'b0;
                    bubble 		  = 1'b1; //Stall for one cycle
                    addrSel 	  = 2'b00;  
				end
                else begin
					FSM_nxt_state = BRANCH_1;
                    PC_Write 	  = 1'b0;
                    IF_Write 	  = 1'b0;
                    bubble 		  = 1'b1; //Stall for one cycle
                    addrSel 	  = 2'b00; 
                end
			end
			
			BRANCH_1: begin
                    FSM_nxt_state = NO_HAZARD;
                    PC_Write      = 1'b1;
                    IF_Write      = 1'b0;
                    bubble 		  = 1'b1; //Stall for one cycle
                    addrSel 	  = 2'b10;
            end
			
			default: begin
                    FSM_nxt_state = FSM_state;
                    PC_Write 	  = 1'b0;
                    IF_Write  	  = 1'b0;
                    bubble 		  = 1'b0;
                    addrSel 	  = 2'b00;
            end
        endcase
	end
	
endmodule
