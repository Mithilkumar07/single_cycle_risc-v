`timescale 1ns/1ps

module ex_stage (
    // ============================================================
    // Data inputs
    // ============================================================
    input  logic [31:0] rs1_data,       // Register file rs1
    input  logic [31:0] rs2_data,       // Register file rs2
    input  logic [31:0] imm_out,        // Immediate
    input  logic [31:0] address,        // Current PC


    // ============================================================
    // Control inputs
    // ============================================================
    input  logic        branch,         // Conditional branch
    input  logic        alu_src,        // 0=rs2_data, 1=imm_out
    input  logic        fn7_5,          // instruction[30]
    input  logic        mux_inp,        // 1=JALR, 0=branch/JAL
    input  logic [2:0]  fn3,            // funct3
    input  logic [6:0]  imm11_5,        // instruction[31:25]
    input  logic [2:0]  aluop,          // ALU operation class
    input  logic [6:0]  opcode,         // Instruction opcode


    // ============================================================
    // Outputs
    // ============================================================
    output logic        and_out_ex,     // Branch/jump taken
    output logic [31:0] alu_out,        // ALU result
    output logic [31:0] pc_ex_out       // Branch/jump target
);


    // ============================================================
    // Internal signals
    // ============================================================
    logic [31:0] alu_operand_b;
    logic        branch_taken;
    logic [4:0]  alu_operation;
    logic [31:0] pc_signed_offset;


    // ============================================================
    // ALU Operand-B Mux
    //
    // alu_src = 0 → rs2_data
    // alu_src = 1 → immediate
    //
    // Used by:
    //   R-type       → rs2
    //   I-type       → immediate
    //   Load         → immediate
    //   Store        → immediate
    //   JALR         → immediate
    // ============================================================
    assign alu_operand_b = alu_src ? imm_out : rs2_data;


    // ============================================================
    // Branch / Jump Target
    //
    // Branch/JAL:
    //     PC + immediate
    //
    // JALR:
    //     rs1 + immediate
    //     (computed by ALU)
    // ============================================================
    always_comb begin
        pc_signed_offset = address + imm_out;
    end


    // ============================================================
    // PC Target Mux
    //
    // mux_inp = 1 → JALR target from ALU
    // mux_inp = 0 → branch/JAL target
    //
    // JALR requires bit[0] to be zero.
    // ============================================================
    assign pc_ex_out =
            mux_inp
            ? {alu_out[31:1], 1'b0}
            : pc_signed_offset;


    // ============================================================
    // Branch / Jump Taken
    //
    // Conditional branch:
    //     branch & branch_taken
    //
    // JAL:
    //     opcode = 7'b1101111
    //
    // JALR:
    //     opcode = 7'b1100111
    // ============================================================
    assign and_out_ex =
            (branch && branch_taken)
            | (opcode == 7'h6F)
            | (opcode == 7'h67);


    // ============================================================
    // ALU
    // ============================================================
    alu alu_unit (
        .alu_control (alu_operation),
        .rs1_data    (rs1_data),
        .rs2_data    (alu_operand_b),
        .alu_out     (alu_out),
        .zero        (branch_taken)
    );


    // ============================================================
    // ALU Control
    // ============================================================
    alu_control ac (
        .alu_op      (aluop),
        .fn3         (fn3),
        .imm11_5     (imm11_5),
        .fn7_5       (fn7_5),
        .control_out (alu_operation)
    );

endmodule