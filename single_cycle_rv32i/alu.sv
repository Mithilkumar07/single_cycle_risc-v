`timescale 1ns/1ps

// =============================================================================
// Operation encoding (alu_control → 5 bits):
//
//   00000  ADD
//   00001  SUB
//   00010  XOR
//   00011  OR
//   00100  AND
//   00101  SLL
//   00110  SRL
//   00111  SRA
//   01000  SLT
//   01001  SLTU
//   01010  BEQ
//   01011  BNE
//   01100  BLT
//   01101  BGE
//   01110  BLTU
//   01111  BGEU
//
//   10000 - 11111  Unused
// =============================================================================

module alu #(
    parameter int DATA_WIDTH = 32
)(
    input  logic [4:0]            alu_control,

    input  logic [DATA_WIDTH-1:0] rs1_data,
    input  logic [DATA_WIDTH-1:0] rs2_data,

    output logic [DATA_WIDTH-1:0] alu_out,
    output logic                  zero
);

    // ============================================================
    // Signed views of operands
    // ============================================================
    logic signed [DATA_WIDTH-1:0] rs1_signed;
    logic signed [DATA_WIDTH-1:0] rs2_signed;

    assign rs1_signed = $signed(rs1_data);
    assign rs2_signed = $signed(rs2_data);


    // ============================================================
    // ALU Operations
    // ============================================================
    always_comb begin

        // Safe defaults
        alu_out = {DATA_WIDTH{1'b0}};
        zero    = 1'b0;

        unique case (alu_control)

            // ----------------------------------------------------
            // Arithmetic
            // ----------------------------------------------------
            5'b00000:
                alu_out = rs1_data + rs2_data;       // ADD / ADDI

            5'b00001:
                alu_out = rs1_data - rs2_data;       // SUB


            // ----------------------------------------------------
            // Logical
            // ----------------------------------------------------
            5'b00010:
                alu_out = rs1_data ^ rs2_data;       // XOR / XORI

            5'b00011:
                alu_out = rs1_data | rs2_data;       // OR / ORI

            5'b00100:
                alu_out = rs1_data & rs2_data;       // AND / ANDI


            // ----------------------------------------------------
            // Shift operations
            // ----------------------------------------------------
            5'b00101:
                alu_out = rs1_data << rs2_data[4:0]; // SLL / SLLI

            5'b00110:
                alu_out = rs1_data >> rs2_data[4:0]; // SRL / SRLI

            5'b00111:
                alu_out = rs1_signed >>> rs2_data[4:0]; // SRA / SRAI


            // ----------------------------------------------------
            // Set Less Than
            // ----------------------------------------------------
            5'b01000:
                alu_out = (rs1_signed < rs2_signed)
                          ? 32'd1 : 32'd0;            // SLT / SLTI

            5'b01001:
                alu_out = (rs1_data < rs2_data)
                          ? 32'd1 : 32'd0;            // SLTU / SLTIU


            // ----------------------------------------------------
            // Branch comparisons
            //
            // Only 'zero' is used for branches.
            // alu_out remains 0.
            // ----------------------------------------------------
            5'b01010:
                zero = (rs1_data == rs2_data);       // BEQ

            5'b01011:
                zero = (rs1_data != rs2_data);       // BNE

            5'b01100:
                zero = (rs1_signed < rs2_signed);    // BLT

            5'b01101:
                zero = (rs1_signed >= rs2_signed);   // BGE

            5'b01110:
                zero = (rs1_data < rs2_data);        // BLTU

            5'b01111:
                zero = (rs1_data >= rs2_data);       // BGEU


            // ----------------------------------------------------
            // Undefined control codes
            // ----------------------------------------------------
            default:
            begin
                alu_out = {DATA_WIDTH{1'b0}};
                zero    = 1'b0;
            end

        endcase
    end

endmodule
