`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design	:MIPS Processor
// Module 	: Data Memory
//////////////////////////////////////////////////////////////////////////////////

module DataMemory (input logic Clock, 
				input logic MemoryRead,  
				input logic MemoryWrite, 
				input logic [5:0]Address,
				output logic [31:0]ReadData,
				input logic [31:0]WriteData ); 
				
		logic [31:0]datamem[63:0];
		
		
	always @(posedge Clock)   //memory read operation
        begin
             if (MemoryRead == 1)  
                     ReadData <= datamem[Address];
        end
      
     always @(negedge Clock)  //memory write operation
         begin
              if(MemoryWrite == 1) 
                      datamem[Address] <= WriteData;
         end
        				
endmodule
