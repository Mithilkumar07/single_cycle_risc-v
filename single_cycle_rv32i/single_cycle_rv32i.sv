`timescale 1ns/1ps

module single_cycle_riscv (
    input  logic        clk,
    input  logic        reset,
    //input  logic        stall,

    // ============================================================
    // Instruction memory interface
    // ============================================================
    input  logic [31:0] instruction,

    // ============================================================
    // Data memory interface
    // ============================================================
    input  logic [31:0] mem_out,

    output logic [31:0] rs2_data,
    output logic [31:0] alu_out,
    output logic        mem_write,
    output logic        mem_read,
    output logic [2:0]  fn3,
    output logic [6:0]  opcode,

    // ============================================================
    // Debug / monitoring
    // ============================================================
    output logic [31:0] address
);

    // ============================================================
    // Internal interconnect
    // ============================================================

    logic [31:0] rs1_data;
    logic [31:0] imm_out;

    logic [31:0] return_addr;
    logic [31:0] wb_data;
    logic [31:0] pc_signed_offset;

    logic and_out_ex;
    logic branch;
    logic alu_src;

    logic [1:0] memtoreg;
    logic [2:0] aluop;

    logic fn7_5;
    logic mux_inp;

    logic [6:0] imm11_5;


    // ============================================================
    // Memory control
    //
    // No trap gating is required because this design no longer
    // implements exceptions, interrupts, or privileged traps.
    // ============================================================

    // ID stage produces these directly
    // mem_write = mem_write_raw
    // mem_read  = mem_read_raw


    // ============================================================
    // 1. Instruction Fetch
    // ============================================================

    if_stage if_st (
        .clk              (clk),
        .reset            (reset),
      //  .stall            (stall),

        .and_out          (and_out_ex),
        .pc_signed_offset (pc_signed_offset),

        .address          (address),
        .pc_new           (return_addr)
    );


    // ============================================================
    // 2. Instruction Decode + Register File
    // ============================================================

    id_stage id_st (
        .clk              (clk),
        .reset            (reset),
       // .stall            (stall),

        .instruction      (instruction),
        .wb_data          (wb_data),

        .rs1_data         (rs1_data),
        .rs2_data         (rs2_data),
        .imm_out          (imm_out),

        .opcode_out_d     (opcode),
        .imm11_5          (imm11_5),
        .fn3_out_d        (fn3),
        .fn7_5            (fn7_5),

        .aluop            (aluop),
        .memtoreg         (memtoreg),

        .branch           (branch),
        .mem_write        (mem_write),
        .mem_read         (mem_read),
        .alu_src          (alu_src),
        .mux_inp          (mux_inp)
    );


    // ============================================================
    // 3. Execute
    //
    // ALU + branch/jump target calculation
    // ============================================================

    ex_stage ex_st (
        .rs1_data         (rs1_data),
        .rs2_data         (rs2_data),
        .imm_out          (imm_out),
        .address          (address),

        .branch           (branch),
        .alu_src          (alu_src),
        .fn7_5            (fn7_5),
        .mux_inp          (mux_inp),
        .fn3              (fn3),
        .imm11_5          (imm11_5),
        .aluop            (aluop),
        .opcode           (opcode),

        .and_out_ex       (and_out_ex),
        .alu_out          (alu_out),
        .pc_ex_out        (pc_signed_offset)
    );


    // ============================================================
    // 4. Write Back
    // ============================================================

    wb_stage wb_st (
        .mem_out          (mem_out),
        .alu_out          (alu_out),

        .return_addr      (return_addr),
        .imm_out          (imm_out),
        .pc_signed_offset (pc_signed_offset),

        .memtoreg         (memtoreg),
        .opcode_out_d     (opcode),

        .wb_data          (wb_data)
    );

endmodule