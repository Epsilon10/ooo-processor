`timescale 1ps/1ps

module InstructionFetch
(input clk,
// output of branch unit
input [15:0] jump_target, input is_jump,

// output of instruction cache
input [63:0]instr_flat,
 
input [3:0]rob_head_idx,

// num available slots in instruction buffer
input [2:0]num_fetch,

// whats fed into icache
output [63:0]pc_to_icache_flat,

// whats fed to instruction buffer
output [15:0] opcode_out_flat, output [31:0] immediate_out_flat,
output [3:0]op_a_local_dep_out_flat, output [15:0] op_a_owner_out_flat,
output [3:0]op_b_local_dep_out_flat, output [15:0] op_b_owner_out_flat,
output [15:0] rt_out_flat,

output [3:0]uses_rb_out_flat,
output [3:0]is_ld_str_out_flat,
output [3:0]is_fxu_out_flat,
output [3:0]is_branch_out_flat,

// for register file
output [15:0]ra_out_flat, output [15:0]rb_out_flat,
output if_valid_out
);

    genvar n;
    wire [15:0]instr[0:3];

    // unflatten input wires
    generate
        for (n=0;n<4;n=n+1) assign instr[3-n] = instr_flat[16*n+15:16*n];
    endgenerate

    // flatten into output wires from all output regs
    generate
        for (n=0; n<4; n=n+1) assign pc_to_icache_flat [16*n+15:16*n] = m_pc_to_icache[3-n];
        for (n=0; n<4; n=n+1) assign opcode_out_flat [4*n+3:4*n] = d_opcode[3-n];
        for (n=0; n<4; n=n+1) assign immediate_out_flat [8*n+7:8*n] = d_immediate[3-n];

        for (n=0; n<4; n=n+1) assign op_a_local_dep_out_flat [1*n+0:1*n] = op_a_local_dep[3-n];
        for (n=0; n<4; n=n+1) assign op_a_owner_out_flat [4*n+3:4*n] = op_a_owner[3-n];
        for (n=0; n<4; n=n+1) assign op_b_local_dep_out_flat [1*n+0:1*n] = op_b_local_dep[3-n];
        for (n=0; n<4; n=n+1) assign op_b_owner_out_flat [4*n+3:4*n] = op_b_owner[3-n];

        for (n=0; n<4; n=n+1) assign ra_out_flat [4*n+3:4*n] = d_ra[3-n];
        for (n=0; n<4; n=n+1) assign rb_out_flat [4*n+3:4*n] = d_rb[3-n];
        for (n=0; n<4; n=n+1) assign rt_out_flat [4*n+3:4*n] = d_rt[3-n];

        for (n=0; n<4; n=n+1) assign uses_rb_out_flat [1*n+0:1*n] = uses_rb[3-n];
        for (n=0; n<4; n=n+1) assign is_ld_str_out_flat [1*n+0:1*n] = is_ld_str[3-n];
        for (n=0; n<4; n=n+1) assign is_fxu_out_flat [1*n+0:1*n] = is_fxu[3-n];
        for (n=0; n<4; n=n+1) assign is_branch_out_flat [1*n+0:1*n] = is_branch[3-n];
    endgenerate







    reg started = 0;
    reg if_valid = 1;
    assign if_valid_out = if_valid;

    reg [15:0] m_pc_to_icache[0:3];

    reg [15:0] last_pc;

    initial begin 
        integer p;
        for(p = 0; p < num_fetch; p++) begin 
            m_pc_to_icache[p] = 0;
        end

        last_pc = 0;
    end

    always @(posedge clk) begin 
        integer i;
        
        for (i = 0; i < num_fetch; i++) begin
            m_pc_to_icache[i] <= is_jump ? jump_target + 2*i : (~started ? last_pc + 2*i : last_pc + 2*(i+1));
        end
    end

    always @(negedge clk) begin
        started <= 1;
        if (num_fetch > 0)
            last_pc <= m_pc_to_icache[num_fetch - 1];
    end

    reg d_valid = 0;

    reg [15:0] d_instr[0:3];

    always @(posedge clk) begin
        d_instr[0] <= instr[0];
        d_instr[1] <= instr[1];
        d_instr[2] <= instr[2];
        d_instr[3] <= instr[3];
    end

    wire [3:0] d_opcode[0:3];

    assign d_opcode[0] = d_instr[0][15:12];
    assign d_opcode[1] = d_instr[1][15:12];
    assign d_opcode[2] = d_instr[2][15:12];
    assign d_opcode[3] = d_instr[3][15:12];

    wire [3:0] d_immediate[0:3];

    assign d_immediate[0] = d_instr[0][11:4];
    assign d_immediate[1] = d_instr[1][11:4];
    assign d_immediate[2] = d_instr[2][11:4];
    assign d_immediate[3] = d_instr[3][11:4];

    wire [3:0] d_rt[3:0];

    assign d_rt[0] = d_instr[0][11:8];
    assign d_rt[1] = d_instr[1][11:8];
    assign d_rt[2] = d_instr[2][11:8];
    assign d_rt[3] = d_instr[3][11:8];

    wire [3:0] d_ra[3:0];

    assign d_ra[0] = d_instr[0][7:4];
    assign d_ra[1] = d_instr[1][7:4];
    assign d_ra[2] = d_instr[2][7:4];
    assign d_ra[3] = d_instr[3][7:4];

    wire [3:0] d_rb[3:0];

    assign d_rb[0] = d_instr[0][3:0];
    assign d_rb[1] = d_instr[1][3:0];
    assign d_rb[2] = d_instr[2][3:0];
    assign d_rb[3] = d_instr[3][3:0];

    wire op_a_local_dep[0:3];
    wire [3:0] op_a_owner[0:3];

    wire op_b_local_dep[0:3];
    wire [3:0] op_b_owner[0:3];

    // ra dependcy checking
    assign op_a_local_dep[0] = 0;

    wire d_uses_ra_1 = d_opcode[1] == 0 | d_opcode[1] == 1 | d_opcode[1] == 2 | d_opcode[1] == 3 
        | d_opcode[1] == 4 | d_opcode[1] == 8 | d_opcode[1] == 9 | d_opcode[1] == 10 | d_opcode[1] == 11;

    assign op_a_owner[1] = d_uses_ra_1 & d_ra[1] == d_rt[0] ? 
                    rob_head_idx // ra_1 == rt_0
                    : rob_head_idx + 1;

    assign op_a_local_dep[1] = op_a_owner[1] != rob_head_idx + 1;

    wire d_uses_ra_2 = d_opcode[2] == 0 | d_opcode[2] == 1 | d_opcode[2] == 2 | d_opcode[2] == 3 
        | d_opcode[2] == 4 | d_opcode[2] == 8 | d_opcode[2] == 9 | d_opcode[2] == 10 | d_opcode[2] == 11;

    assign op_a_owner[2] = d_uses_ra_2 
                    ? (d_ra[2] == d_rt[1] ? (rob_head_idx + 1)  // ra_2 == rt_1
                    : d_ra[2] == d_rt[0] ? (rob_head_idx + 0) : rob_head_idx + 2) // ra_2 == rt_0
                    : rob_head_idx + 2;

    assign op_a_local_dep[2] = op_a_owner[2] != rob_head_idx + 2;

    wire d_uses_ra_3 = d_opcode[3] == 0 | d_opcode[3] == 1 | d_opcode[3] == 2 | d_opcode[3] == 3 
        | d_opcode[3] == 4 | d_opcode[3] == 8 | d_opcode[3] == 9 | d_opcode[3] == 10 | d_opcode[3] == 11;

    assign op_a_owner[3] = d_uses_ra_3 
                    ? (d_ra[3] == d_rt[2] ? (rob_head_idx + 2)  // ra_3 == rt_2
                    : d_ra[3] == d_rt[1] ? (rob_head_idx + 1) // ra_3 == rt_1
                    : d_ra[3] == d_rt[0] ? (rob_head_idx + 0) : rob_head_idx + 3) // ra_3 == rt_0
                    : rob_head_idx + 3;

    assign op_a_local_dep[3] = op_a_owner[3] != rob_head_idx + 3;

    assign op_b_local_dep[0] = 0;

    wire d_uses_rb_1 = d_opcode[1] == 0 | d_opcode[1] == 1 | d_opcode[1] == 10 | d_opcode[1] == 11 | d_opcode[1] == 4;

    // rb dependcy checking
    assign op_b_owner[1] = d_uses_rb_1 & d_rb[1] == d_rt[0] ? 
                    rob_head_idx // rb_1 == rt_0
                    : rob_head_idx + 1;

    assign op_b_local_dep[1] = op_b_owner[1] != rob_head_idx + 1;

    wire d_uses_rb_2 = d_opcode[2] == 0 | d_opcode[2] == 1 | d_opcode[2] == 10 | d_opcode[2] == 11 | d_opcode[2] == 4;


    assign op_b_owner[2] = d_uses_rb_2
                    ? (d_rb[2] == d_rt[1] ? (rob_head_idx + 1)  // rb_2 == rt_1
                    : d_rb[2] == d_rt[0] ? (rob_head_idx + 0) : rob_head_idx + 2) // rb_2 == rt_0
                    : rob_head_idx + 2;

    assign op_b_local_dep[2] = op_b_owner[2] != rob_head_idx + 2;

    wire d_uses_rb_3 = d_opcode[3] == 0 | d_opcode[3] == 1 | d_opcode[3] == 10 | d_opcode[3] == 11 | d_opcode[3] == 4;

    assign op_b_owner[3] = d_uses_rb_3
                    ? (d_rb[3] == d_rt[2] ? (rob_head_idx + 2)  // rb_3 == rt_2
                    : d_rb[3] == d_rt[1] ? (rob_head_idx + 1) // rb_3 == rt_1
                    : d_rb[3] == d_rt[0] ? (rob_head_idx + 0) : rob_head_idx + 3) // rb_3 == rt_0
                    : rob_head_idx + 3;

    assign op_b_local_dep[3] = op_b_owner[3] != rob_head_idx + 3;

    wire is_ld_str[0:3];
    wire is_fxu[0:3];
    wire is_branch[0:3];

    assign is_ld_str[0] = d_opcode[0] == 2 | d_opcode[0] == 3;
    assign is_ld_str[1] = d_opcode[1] == 2 | d_opcode[1] == 3;
    assign is_ld_str[2] = d_opcode[2] == 2 | d_opcode[2] == 3;
    assign is_ld_str[3] = d_opcode[3] == 2 | d_opcode[3] == 3;

    assign is_fxu[0] = d_opcode[0] == 0 | d_opcode[0] == 1 | d_opcode[0] == 4 | d_opcode[0] == 5 | d_opcode[0] == 6;
    assign is_fxu[1] = d_opcode[1] == 0 | d_opcode[1] == 1 | d_opcode[1] == 4 | d_opcode[1] == 5 | d_opcode[1] == 6;
    assign is_fxu[2] = d_opcode[2] == 0 | d_opcode[2] == 1 | d_opcode[2] == 4 | d_opcode[2] == 5 | d_opcode[2] == 6;
    assign is_fxu[3] = d_opcode[3] == 0 | d_opcode[3] == 1 | d_opcode[3] == 4 | d_opcode[3] == 5 | d_opcode[3] == 6;

    assign is_branch[0] = d_opcode[0] == 8 | d_opcode[0] == 9 | d_opcode[0] == 10 | d_opcode[0] == 11;
    assign is_branch[1] = d_opcode[1] == 2 | d_opcode[1] == 3 | d_opcode[1] == 10 | d_opcode[1] == 11;
    assign is_branch[2] = d_opcode[2] == 2 | d_opcode[2] == 3 | d_opcode[2] == 10 | d_opcode[2] == 11;
    assign is_branch[3] = d_opcode[3] == 2 | d_opcode[3] == 3 | d_opcode[3] == 10 | d_opcode[3] == 11;

    wire uses_rb[0:3];
    assign uses_rb[0] = d_opcode[0] == 0 | d_opcode[0] == 1 | d_opcode[0] == 8 | d_opcode[0] == 9 | d_opcode[0] == 10  |  d_opcode[0] == 11;
    assign uses_rb[1] = d_opcode[1] == 0 | d_opcode[1] == 1 | d_opcode[1] == 8 | d_opcode[1] == 9 | d_opcode[1] == 10  |  d_opcode[1] == 11;
    assign uses_rb[2] = d_opcode[2] == 0 | d_opcode[2] == 1 | d_opcode[2] == 8 | d_opcode[2] == 9 | d_opcode[2] == 10  |  d_opcode[2] == 11;
    assign uses_rb[3] = d_opcode[3] == 0 | d_opcode[3] == 1 | d_opcode[3] == 8 | d_opcode[3] == 9 | d_opcode[3] == 10  |  d_opcode[3] == 11;
endmodule