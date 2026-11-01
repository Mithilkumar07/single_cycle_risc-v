`timescale 1ns/1ps

module id_stage(
    input logic clk, reset, 
  //  input logic stall,
    input logic [31:0] instruction,
    input logic [31:0] wb_data,
    output logic [31:0] rs1_data, rs2_data, imm_out,
    output logic [6:0] opcode_out_d,
    output logic [6:0] imm11_5,
    output logic [2:0] fn3_out_d,
    output logic fn7_5,
    output logic [2:0] aluop,
    output logic [1:0] memtoreg,
    output logic branch, mem_write, mem_read, alu_src, mux_inp
);
    logic [4:0] rs1, rs2, rd;
    logic [6:0] fn7;
    logic [11:0] imm_i, imm_s;
    logic [12:0] imm_b;
    logic [19:0] imm_u;
    logic [20:0] imm_j;
    logic [2:0] imm_sel;
    logic reg_write_out, gated_reg_write;

    assign gated_reg_write = reg_write_out;     //&& !stall;
    assign imm11_5 = fn7;

    decoder decode(
        .instruction(instruction), .opcode(opcode_out_d),
        .rd(rd), .fn3(fn3_out_d), .rs1(rs1), .rs2(rs2),
        .fn7(fn7), .fn7_5(fn7_5),
        .imm_i(imm_i), .imm_s(imm_s), .imm_b(imm_b),
        .imm_u(imm_u), .imm_j(imm_j)
    );

    imm_generator imm_gen(
        .imm_i(imm_i), .imm_s(imm_s), .imm_b(imm_b),
        .imm_u(imm_u), .imm_j(imm_j), .shamt(imm_i[4:0]),
        .imm_sel(imm_sel), .imm_output(imm_out)
    );

    register_file reg_file(
        .clk(clk), .reset(reset), .rs1_sel(rs1), .rs2_sel(rs2),
        .rd_sel(rd), .reg_write(gated_reg_write), .wb_data(wb_data),
        .rs1_data(rs1_data), .rs2_data(rs2_data)
    );

    main_control mc(
        .opcode(opcode_out_d), .fn3(fn3_out_d),
        .branch(branch), .memtoreg(memtoreg), .aluop(aluop),
        .memwrite(mem_write), .alusrc(alu_src),
        .reg_write(reg_write_out), .memread(mem_read),
        .mux_inp(mux_inp), .imm_sel(imm_sel)
    );
endmodule
