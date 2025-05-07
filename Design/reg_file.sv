module RegisterFile (
    input  logic        clk,
    input  logic        reset_n,       // active-low reset
    input  logic [4:0]  rs,            // Read address 1
    input  logic [4:0]  rt,            // Read address 2
    input  logic [4:0]  rd,            // Write address
    input  logic        regWrite,      // Write enable
    input  logic [31:0] writeData,     // Data to write
    output logic [31:0] readData1,     // Output 1
    output logic [31:0] readData2      // Output 2
);

    // 32 registers, each 32 bits wide
    logic [31:0] regfile [31:0];

    integer i;

    // Synchronous Write and Reset
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            for (i = 0; i < 32; i++) begin
                regfile[i] <= 32'h0;
            end
        end else if (regWrite && rd != 5'd0) begin
            regfile[rd] <= writeData; // Register 0 is hardwired to 0
        end
    end

    // Asynchronous Read
    always_comb begin
        readData1 = regfile[rs];
        readData2 = regfile[rt];
    end

endmodule
