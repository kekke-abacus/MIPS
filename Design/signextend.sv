module SignExtender (
    input  logic [15:0] in,
    input  logic        signExtend,
    output logic [31:0] out
);

    always_comb begin
        if (signExtend) 
            out = {{16{in[15]}}, in};  // Sign-extend
        else 
            out = {16'b0, in};         // Zero-extend
    end

endmodule
