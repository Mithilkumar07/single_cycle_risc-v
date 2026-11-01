`timescale 1ns/1ps

module imm_generator(
    input logic [11:0] imm_i,
    input logic [11:0] imm_s,
    input logic [12:0] imm_b,
    input logic [19:0] imm_u,
    input logic [20:0] imm_j,
    input logic [4:0]  shamt,
    input logic [2:0]  imm_sel,
    output logic [31:0] imm_output
);
    always_comb begin
        case (imm_sel)
            3'd0: imm_output = {{20{imm_i[11]}}, imm_i}; // I
            3'd1: imm_output = {{20{imm_s[11]}}, imm_s}; // S
            3'd2: imm_output = {{19{imm_b[12]}}, imm_b}; // B (bit 0 included)
            3'd3: imm_output = {imm_u, 12'b0};           // U
            3'd4: imm_output = {{11{imm_j[20]}}, imm_j}; // J (bit 0 included)
            3'd5: imm_output = {27'b0, shamt};           // shift immediate
            default: imm_output = 32'b0;
        endcase
    end
endmodule
