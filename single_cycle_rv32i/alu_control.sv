`timescale 1ns/1ps

module alu_control (
    input  logic [2:0] alu_op,          // Operation class from main_control
    input  logic [2:0] fn3,             // funct3 field from instruction
    input  logic [6:0] imm11_5,         // instruction[31:25]: shift qualifier
    input  logic       fn7_5,           // instruction[30]: SUB/SRA distinguish bit

    output logic [4:0] control_out      // 5-bit ALU operation select
);

    always_comb begin

        // Default: ADD
        control_out = 5'b00000;

        case (alu_op)

            // ============================================================
            // R-Type
            //
            // fn3 selects operation.
            // fn7_5 distinguishes:
            //   ADD / SUB
            //   SRL / SRA
            // ============================================================
            3'b000:
            begin
                case (fn3)

                    3'b000:
                        control_out = fn7_5
                                      ? 5'b00001     // SUB
                                      : 5'b00000;    // ADD

                    3'b001:
                        control_out = 5'b00101;     // SLL

                    3'b010:
                        control_out = 5'b01000;     // SLT

                    3'b011:
                        control_out = 5'b01001;     // SLTU

                    3'b100:
                        control_out = 5'b00010;     // XOR

                    3'b101:
                        control_out = fn7_5
                                      ? 5'b00111     // SRA
                                      : 5'b00110;    // SRL

                    3'b110:
                        control_out = 5'b00011;     // OR

                    3'b111:
                        control_out = 5'b00100;     // AND

                    default:
                        control_out = 5'b00000;

                endcase
            end


            // ============================================================
            // I-Type ALU
            //
            // Same operation mapping as R-Type except there is no SUBI.
            //
            // For fn3 = 101:
            //   imm11_5 = 7'b0000000 -> SRLI
            //   imm11_5 = 7'b0100000 -> SRAI
            // ============================================================
            3'b001:
            begin
                case (fn3)

                    3'b000:
                        control_out = 5'b00000;     // ADDI

                    3'b001:
                        control_out = 5'b00101;     // SLLI

                    3'b010:
                        control_out = 5'b01000;     // SLTI

                    3'b011:
                        control_out = 5'b01001;     // SLTIU

                    3'b100:
                        control_out = 5'b00010;     // XORI

                    3'b101:
                        control_out = (imm11_5 == 7'h20)
                                      ? 5'b00111     // SRAI
                                      : 5'b00110;    // SRLI

                    3'b110:
                        control_out = 5'b00011;     // ORI

                    3'b111:
                        control_out = 5'b00100;     // ANDI

                    default:
                        control_out = 5'b00000;

                endcase
            end


            // ============================================================
            // Load
            //
            // Effective address:
            //     rs1 + sign-extended immediate
            // ============================================================
            3'b010:
                control_out = 5'b00000;             // ADD


            // ============================================================
            // Store
            //
            // Effective address:
            //     rs1 + sign-extended immediate
            // ============================================================
            3'b011:
                control_out = 5'b00000;             // ADD


            // ============================================================
            // Branch
            //
            // fn3 determines branch comparison.
            // ============================================================
            3'b100:
            begin
                case (fn3)

                    3'b000:
                        control_out = 5'b01010;     // BEQ

                    3'b001:
                        control_out = 5'b01011;     // BNE

                    3'b100:
                        control_out = 5'b01100;     // BLT

                    3'b101:
                        control_out = 5'b01101;     // BGE

                    3'b110:
                        control_out = 5'b01110;     // BLTU

                    3'b111:
                        control_out = 5'b01111;     // BGEU

                    default:
                        control_out = 5'b00000;

                endcase
            end


            // ============================================================
            // JAL / LUI / AUIPC path
            //
            // Current datapath uses ADD as the defined ALU operation.
            // The appropriate writeback source is selected elsewhere.
            // ============================================================
            3'b110:
                control_out = 5'b00000;             // ADD


            // ============================================================
            // Unused / reserved ALU operation codes
            // ============================================================
            default:
                control_out = 5'b00000;

        endcase
    end

endmodule