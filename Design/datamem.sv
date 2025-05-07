module DataMemory (
    input  logic         Clock,
    input  logic         MemoryRead,
    input  logic         MemoryWrite,
    input  logic [5:0]   Address,
    input  logic [31:0]  WriteData,
    output logic [31:0]  ReadData
);

    logic [31:0] datamem [0:63];

    always_ff @(posedge Clock) begin
        if (MemoryWrite)
            datamem[Address] <= WriteData;
        if (MemoryRead)
            ReadData <= datamem[Address];
    end

endmodule
