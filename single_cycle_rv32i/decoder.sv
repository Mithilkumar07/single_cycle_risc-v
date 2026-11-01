`timescale 1ns/1ps

// Field extractor only: no opcode decoding or instruction classification.
module decoder(
    input  logic [31:0] instruction,
    output logic [6:0]  opcode,
    output logic [4:0]  rd,
    output logic [2:0]  fn3,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [6:0]  fn7,
    output logic       fn7_5,
    output logic [11:0] imm_i,
    output logic [11:0] imm_s,
    output logic [12:0] imm_b,
    output logic [19:0] imm_u,
    output logic [20:0] imm_j
);
    // Fixed-position field extraction. These assignments are independent
    // of opcode; instruction interpretation belongs in main_control.
    always_comb begin
        opcode = instruction[6:0];
        rd     = instruction[11:7];
        fn3    = instruction[14:12];
        rs1    = instruction[19:15];
        rs2    = instruction[24:20];
        fn7    = instruction[31:25];
        fn7_5  = instruction[30];

        imm_i = instruction[31:20];
        imm_s = {instruction[31:25], instruction[11:7]};
        imm_b = {instruction[31], instruction[7],
                 instruction[30:25], instruction[11:8], 1'b0};
        imm_u = instruction[31:12];
        imm_j = {instruction[31], instruction[19:12],
                 instruction[20], instruction[30:21], 1'b0};
    end
endmodule
