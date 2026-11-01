`timescale 1ns/1ps

module main_control (
    input  logic [6:0] opcode,
    input  logic [2:0] fn3,
    output logic [1:0] memtoreg,
    output logic       branch,
    output logic       mux_inp,
    output logic       memread,
    output logic       memwrite,
    output logic       alusrc,
    output logic       reg_write,
    output logic [2:0] aluop,
    // Immediate format select: 0=I, 1=S, 2=B, 3=U, 4=J, 5=shift amount
    output logic [2:0] imm_sel
);
    always_comb begin
        branch=0; memread=0; memtoreg=2'b00; memwrite=0;
        alusrc=0; reg_write=0; aluop=3'b000; mux_inp=0; imm_sel=3'd0;

        case (opcode)
            7'b0110011: begin // R-type
                memtoreg=2'b00; reg_write=1; aluop=3'b000;
            end
            7'b0010011: begin // I-type ALU
                memtoreg=2'b00; alusrc=1; reg_write=1; aluop=3'b001;
                if (fn3==3'b001 || fn3==3'b101) imm_sel=3'd5;
            end
            7'b0000011: begin // Load
                memread=1; memtoreg=2'b01; alusrc=1; reg_write=1;
                aluop=3'b010; imm_sel=3'd0;
            end
            7'b0100011: begin // Store
                memwrite=1; alusrc=1; aluop=3'b011; imm_sel=3'd1;
            end
            7'b1100011: begin // Branch
                branch=1; aluop=3'b100; imm_sel=3'd2;
            end
            7'b1101111: begin // JAL
                memtoreg=2'b10; alusrc=1; reg_write=1; aluop=3'b110;
                imm_sel=3'd4;
            end
            7'b1100111: begin // JALR
                memtoreg=2'b10; alusrc=1; reg_write=1; aluop=3'b001;
                mux_inp=1; imm_sel=3'd0;
            end
            7'b0110111: begin // LUI
                memtoreg=2'b10; alusrc=1; reg_write=1; aluop=3'b110;
                imm_sel=3'd3;
            end
            7'b0010111: begin // AUIPC
                memtoreg=2'b10; alusrc=1; reg_write=1; aluop=3'b000;
                imm_sel=3'd3;
            end
            default: begin
                branch=0; memread=0; memwrite=0; alusrc=0;
                reg_write=0; aluop=3'b000; memtoreg=2'b00;
                mux_inp=0; imm_sel=3'd0;
            end
        endcase
    end
endmodule
