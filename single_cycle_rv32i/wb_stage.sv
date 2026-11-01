`timescale 1ns/1ps

module wb_stage(
    input  logic [31:0] mem_out,          // Data from Data Memory
    input  logic [31:0] alu_out,          // Data from ALU
    input  logic [31:0] return_addr,      // PC + 4 (for JAL/JALR)
    input  logic [31:0] imm_out,          // Immediate for LUI
    input  logic [31:0] pc_signed_offset, // PC + upper immediate for AUIPC

    input  logic [1:0]  memtoreg,         // Selection from Main Control
    input  logic [6:0]  opcode_out_d,     // Instruction opcode

    output logic [31:0] wb_data           // Final data to Register File
);

    // ============================================================
    // Special writeback data
    //
    // JAL/JALR -> PC + 4
    // LUI      -> immediate
    // AUIPC    -> PC + upper immediate
    // ============================================================
    logic [31:0] pre_wb_data;

    always_comb begin
        case (opcode_out_d)

            // JAL / JALR
            7'b1101111,
            7'b1100111:
                pre_wb_data = return_addr;

            // LUI
            7'b0110111:
                pre_wb_data = imm_out;

            // AUIPC
            7'b0010111:
                pre_wb_data = pc_signed_offset;

            // Normal ALU result
            default:
                pre_wb_data = alu_out;

        endcase
    end


    // ============================================================
    // Final Writeback Multiplexer
    //
    // 00 -> ALU result
    // 01 -> Data memory result
    // 10 -> JAL/JALR/LUI/AUIPC result
    // ============================================================
    always_comb begin

        case (memtoreg)

            // R-type / I-type ALU operations
            2'b00:
                wb_data = alu_out;

            // Load instructions
            2'b01:
                wb_data = mem_out;

            // Jumps and U-type instructions
            2'b10:
                wb_data = pre_wb_data;

            // 11 is unused in the Zicsr-free design
            default:
                wb_data = alu_out;

        endcase

    end

endmodule