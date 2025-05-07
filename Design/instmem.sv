module InstructionMemory (
    output logic [31:0] Data,
    input  logic [31:0] Address
);

    always_comb begin
        unique case (Address)
            // Program 1
            32'h00000000: Data = 32'h34080032; // ori $t0, $zero, 50
            32'h00000004: Data = 32'hac080000; // sw $t0, 0($zero)
            32'h00000008: Data = 32'h8c090000; // lw $t1, 0($zero)
            32'h0000000C: Data = 32'h01284820; // add $t1, $t1, $t0
            32'h00000010: Data = 32'hac090004; // sw $t1, 4($zero)

            // Program 2
            32'h00000014: Data = 32'h34080032; // ori $t0, $zero, 50
            32'h00000018: Data = 32'h3409000a; // ori $t1, $zero, 10
            32'h0000001C: Data = 32'h01095022; // sub $t2, $t0, $t1
            32'h00000020: Data = 32'hac0a0000; // sw $t2, 0($zero)

            // Program 3
            32'h00000024: Data = 32'h3408000a; // ori $t0, $zero, 10
            32'h00000028: Data = 32'h34090014; // ori $t1, $zero, 20
            32'h0000002C: Data = 32'h01098024; // and $s0, $t0, $t1
            32'h00000030: Data = 32'hac100000; // sw $s0, 0($zero)

            // Program 4
            32'h00000034: Data = 32'h3408000a; // ori $t0, $zero, 10
            32'h00000038: Data = 32'h34090014; // ori $t1, $zero, 20
            32'h0000003C: Data = 32'h01098825; // or $s1, $t0, $t1
            32'h00000040: Data = 32'hac110000; // sw $s1, 0($zero)

            // Program 5
            32'h00000044: Data = 32'h3408000a; // ori $t0, $zero, 10
            32'h00000048: Data = 32'h34090014; // ori $t1, $zero, 20
            32'h0000004C: Data = 32'h01099026; // xor $s2, $t0, $t1
            32'h00000050: Data = 32'hac120000; // sw $s2, 0($zero)

            // Program 6 (slt)
            32'h00000054: Data = 32'h3408000a; // ori $t0, $zero, 10
            32'h00000058: Data = 32'h34090014; // ori $t1, $zero, 20
            32'h0000005C: Data = 32'h0109982a; // slt $s3, $t0, $t1
            32'h00000060: Data = 32'hac130000; // sw $s3, 0($zero)

            // Program 7 (slt with reverse values)
            32'h00000064: Data = 32'h34080014; // ori $t0, $zero, 20
            32'h00000068: Data = 32'h3409000a; // ori $t1, $zero, 10
            32'h0000006C: Data = 32'h0109982a; // slt $s3, $t0, $t1
            32'h00000070: Data = 32'hac130000; // sw $s3, 0($zero)

            // Program 8 (sll and srl)
            32'h00000074: Data = 32'h34080001; // ori $t0, $zero, 1
            32'h00000078: Data = 32'h00084100; // sll $t0, $t0, 4
            32'h0000007C: Data = 32'hac080000; // sw $t0, 0($zero)
            32'h00000080: Data = 32'h00084902; // srl $t1, $t0, 4
            32'h00000084: Data = 32'hac090004; // sw $t1, 4($zero)

            // Program 9 (beq)
            32'h00000088: Data = 32'h3408000a; // ori $t0, $zero, 10
            32'h0000008C: Data = 32'h3409000a; // ori $t1, $zero, 10
            32'h00000090: Data = 32'h11090002; // beq $t0, $t1, skip
            32'h00000094: Data = 32'h34080014; // ori $t0, $zero, 20 (should skip)
            32'h00000098: Data = 32'hac080000; // sw $t0, 0($zero)

            // Program 10 (bne)
            32'h0000009C: Data = 32'h3408000a; // ori $t0, $zero, 10
            32'h000000A0: Data = 32'h3409000a; // ori $t1, $zero, 10
            32'h000000A4: Data = 32'h15090002; // bne $t0, $t1, skip
            32'h000000A8: Data = 32'h34080014; // ori $t0, $zero, 20 (should not execute)
            32'h000000AC: Data = 32'hac080000; // sw $t0, 0($zero)

            // Program 11 (jumps and jal)
            32'h000000B0: Data = 32'h08000002; // j 0x00000008
            32'h000000B4: Data = 32'h3408000a; // ori $t0, $zero, 10
            32'h000000B8: Data = 32'h34090014; // ori $t1, $zero, 20
            32'h000000BC: Data = 32'hac080000; // sw $t0, 0($zero)
            32'h000000C0: Data = 32'hac090004; // sw $t1, 4($zero)

            // Program 12 (jal and jr)
            32'h000000C4: Data = 32'h0c000035; // jal 0x000000D4
            32'h000000C8: Data = 32'hac0a0000; // sw $t2, 0($zero)
            32'h000000CC: Data = 32'hac0b0004; // sw $t3, 4($zero)
            32'h000000D0: Data = 32'h0800003A; // j 0x000000E8 (end)
            32'h000000D4: Data = 32'h340a00aa; // ori $t2, $zero, 0xaa
            32'h000000D8: Data = 32'h340b0055; // ori $t3, $zero, 0x55
            32'h000000DC: Data = 32'h03e00008; // jr $ra
            32'h000000E0: Data = 32'h00000000; // nop
            32'h000000E4: Data = 32'h00000000; // nop
            32'h000000E8: Data = 32'h00000000; // nop (end of program)

            default: Data = 32'h00000000; // Default: nop
        endcase
    end

endmodule
