`timescale 1ps/1ps
`define NULL 7

module InstructionBuffer
(input clk,
// from instruction fetch unit
input if_valid, // instruction fetch valid

input [15:0] opcode_flat, input [31:0] immediate_flat,
input [3:0]op_a_local_dep_flat, input [15:0] op_a_owner_flat,
input [3:0]op_b_local_dep_flat, input [15:0] op_b_owner_flat,

input [15:0] rt_flat,
input [3:0]uses_rb_flat,
input [3:0]is_ld_str_flat,
input [3:0]is_fxu_flat,
input [3:0]is_branch_flat,

// from regsiter file
input [63:0]ra_value_flat, input [3:0]ra_busy_flat, input [15:0] ra_owner_flat,
input [63:0]rb_value_flat, input [3:0]rb_busy_flat, input [15:0] rb_owner_flat,

// rob input
input [3:0]rob_head_idx, input [15:0]rob_output_valid_flat, input [255:0]rob_output_values_flat, 

// functional unit status'
input fxu_0_full, input fxu_1_full, input lsu_full, input branch_full,

// outputs
output [2:0] num_fetch,

// fxu 0
output out_fxu_0_instr_valid, output [3:0] out_fxu_0_rob_idx, output out_fxu_0_a_valid, output [15:0] out_fxu_0_a_value, output [3:0] out_fxu_0_a_owner, 
output out_fxu_0_b_valid, output [15:0] out_fxu_0_b_value, output [3:0] out_fxu_0_b_owner, output [3:0] out_fxu_0_opcode, output [7:0] out_fxu_0_i,

// fxu 1
output out_fxu_1_instr_valid, output [3:0] out_fxu_1_rob_idx, output out_fxu_1_a_valid, output [15:0] out_fxu_1_a_value, output [3:0] out_fxu_1_a_owner, 
output out_fxu_1_b_valid, output [15:0] out_fxu_1_b_value, output [3:0] out_fxu_1_b_owner, output [3:0] out_fxu_1_opcode, output [7:0] out_fxu_1_i,

// lsu
output out_lsu_instr_valid, output [3:0] out_lsu_rob_idx,output out_lsu_a_valid, output [15:0] out_lsu_a_value, output [3:0] out_lsu_a_owner, 
output out_lsu_b_valid, output [15:0] out_lsu_b_value, output [3:0] out_lsu_b_owner, output [3:0] out_lsu_opcode,

// branch unit
output out_branch_instr_valid, output [3:0] out_branch_rob_idx, output out_branch_a_valid, output [15:0] out_branch_a_value, output [3:0] out_branch_a_owner, 
output out_branch_b_valid, output [15:0] out_branch_b_value, output [3:0] out_branch_b_owner, output [3:0] out_branch_opcode,

output [3:0] out_rob_valid_flat, output [15:0] out_rob_rt_flat,

output [3:0] rt_update_enable_flat, output [15:0] rt_target_reg_flat, output [15:0] rt_owner_flat
);

    genvar n;

    reg first_time = 0;

    wire [3:0] opcode[0:3];
    wire [7:0] w_immediate[0:3];

    wire w_op_a_local_dep[0:3]; 
    wire [3:0] w_op_a_owner[0:3];
    wire w_op_b_local_dep[0:3]; 
    wire [3:0] w_op_b_owner[0:3];

    wire [3:0] w_rt[0:3];
    wire w_uses_rb[0:3];
    wire w_is_ld_str[0:3];
    wire w_is_fxu[0:3];
    wire w_is_branch[0:3];

    wire w_rob_output_valid[0:15];
    wire [15:0] w_rob_output_values[0:15];
    wire [7:0]imm_0 = w_immediate[0];
    wire [7:0]imm_1 = w_immediate[1];
    wire [7:0]imm_2 = w_immediate[2];
    wire [7:0]imm_3 = w_immediate[3];

    // unflatten input wires
    generate
        for (n=0;n<4;n=n+1) assign opcode[3-n] = opcode_flat[4*n+3:4*n];
        for (n=0;n<4;n=n+1) assign w_immediate[3-n] = immediate_flat[8*n+7:8*n];

        for (n=0;n<4;n=n+1) assign w_op_a_local_dep[3-n] = op_a_local_dep_flat[1*n+0:1*n];
        for (n=0;n<4;n=n+1) assign w_op_a_owner[3-n] = op_a_owner_flat[4*n+3:4*n];
        for (n=0;n<4;n=n+1) assign w_op_b_local_dep[3-n] = op_b_local_dep_flat[1*n+0:1*n];
        for (n=0;n<4;n=n+1) assign w_op_b_owner[3-n] = op_b_owner_flat[4*n+3:4*n];

        for (n=0;n<4;n=n+1) assign w_rt[3-n] = rt_flat[4*n+3:4*n];
        for (n=0;n<4;n=n+1) assign w_uses_rb[3-n] = uses_rb_flat[1*n+0:1*n];
        for (n=0;n<4;n=n+1) assign w_is_ld_str[3-n] = is_ld_str_flat[1*n+0:1*n];
        for (n=0;n<4;n=n+1) assign w_is_fxu[3-n] = is_fxu_flat[1*n+0:1*n];
        for (n=0;n<4;n=n+1) assign w_is_branch[3-n] = is_branch_flat[1*n+0:1*n];

        for (n=0;n<4;n=n+1) assign ra_value[3-n] = ra_value_flat[16*n+15:16*n];
        for (n=0;n<4;n=n+1) assign ra_busy[3-n] = ra_busy_flat[1*n+0:1*n];
        for (n=0;n<4;n=n+1) assign ra_owner[3-n] = ra_owner_flat[4*n+3:4*n];
        
        for (n=0;n<4;n=n+1) assign rb_value[3-n] = rb_value_flat[16*n+15:16*n];
        for (n=0;n<4;n=n+1) assign rb_busy[3-n] = rb_busy_flat[1*n+0:1*n];
        for (n=0;n<4;n=n+1) assign rb_owner[3-n] = rb_owner_flat[4*n+3:4*n];
        
        for (n=0;n<16;n=n+1) assign w_rob_output_valid[15-n] = rob_output_valid_flat[1*n+0:1*n];
        for (n=0;n<16;n=n+1) assign w_rob_output_values[15-n] = rob_output_values_flat[16*n+15:16*n];
    endgenerate

    // flatten into output wires from all output regs

    generate
        for (n=0; n<4; n=n+1) assign out_rob_valid_flat [1*n+0:1*n] = rob_valid[3-n];
        for (n=0; n<4; n=n+1) assign out_rob_rt_flat [4*n+3:4*n] = rt[3-n];

        for (n=0; n<4; n=n+1) assign rt_update_enable_flat[1*n+0:1*n] = rt_update_enable[3-n];
        for (n=0; n<4; n=n+1) assign rt_target_reg_flat[4*n+3:4*n] = rt_target_reg[3-n];
        for (n=0; n<4; n=n+1) assign rt_owner_flat[4*n+3:4*n] = rt_owner[3-n];

    endgenerate

    reg [7:0] immediate[0:3];

    reg op_a_local_dep[0:3]; 
    reg [3:0] op_a_owner[0:3];
    reg op_b_local_dep[0:3]; 
    reg [3:0] op_b_owner[0:3];

    reg [3:0] rt[0:3];
    reg uses_rb[0:3];
    reg is_ld_str[0:3];
    reg is_fxu[0:3];
    reg is_branch[0:3];

    reg [15:0]ra_value[0:3];
    reg ra_busy[0:3];
    reg [3:0] ra_owner[0:3];

    reg [15:0]rb_value[0:3];
    reg rb_busy[0:3];
    reg [3:0] rb_owner[0:3];

    reg rob_output_valid[0:15];
    reg [15:0]rob_output_values[0:15];

    reg [3:0] ib_a_owner[0:3];
    reg [3:0] ib_b_owner[0:3];

    reg [3:0] ib_opcode[0:3];

    wire [15:0] ib_a_value[0:3];
    wire [15:0] ib_b_value[0:3];

    wire ib_a_valid[0:3];
    wire ib_b_valid[0:3];

    reg [2:0] m_num_fetch = 0;

    reg ib_valid = 0;

    reg [1:0] head = 0;

    wire ib_opcode_0 = ib_opcode[0];
    wire ib_opcode_1 = ib_opcode[1];
    wire ib_opcode_2 = ib_opcode[2];
    wire ib_opcode_3 = ib_opcode[3];

    always @(posedge clk) begin 
        integer i;

        for (i = 0; i < 4; i++) begin
        // $write("cur itr %d\n", i);
            if (~(ib_valid & stall_array[head + i])) begin
                $write("THIS IS VALID: %d\n",i);
                ib_a_owner[head+i] <= op_a_local_dep[head+i] ? op_a_owner[head+i] : (ra_busy[head+i] ? ra_owner[head+i] : rob_head_idx + i);
                ib_b_owner[head+i] <= op_b_local_dep[head+i] ? op_b_owner[head+i] : (rb_busy[head+i] ? rb_owner[head+i] : rob_head_idx + i);
                ib_opcode[head+i] <= opcode[head+i];
                immediate[head+i] <= w_immediate[head+i];
                op_a_local_dep[head+i] <= w_op_a_local_dep[head+i];
                op_a_owner[head+i] <= w_op_a_owner[head+i];
                op_b_local_dep[head+i] <= w_op_b_local_dep[head+i];
                op_b_owner[head+i] <= w_op_b_owner[head+i];

                rt[head+i] <= w_rt[head+i];
                uses_rb[head+i] <= w_uses_rb[head+i];
                is_ld_str[head+i] <= w_is_ld_str[head+i];
                is_fxu[head+i] <= w_is_fxu[head+i];
                is_branch[head+i] <= w_is_branch[head+i];
            end
        end

        for (i = 0; i < 15; i++) begin
            rob_output_valid[i] <= w_rob_output_valid[i];
            rob_output_values[i] <= w_rob_output_values[i];
        end
        ib_valid <= if_valid;
        m_num_fetch <= m_num_fetch_wire;
        head <= ~ib_valid ? 0 : head + (m_num_fetch_wire - 1);
        first_time <= ib_valid;
    end

wire [1:0] head_overflow_1 = head + 1;
wire [1:0] head_overflow_2 = head + 2;
wire [1:0] head_overflow_3 = head + 3;


wire is_mov_imm_0 = ib_opcode[0] == 5 | ib_opcode[0] == 5;
wire is_mov_imm_1 = ib_opcode[1] == 5 | ib_opcode[1] == 6;
wire is_mov_imm_2 = ib_opcode[2] == 5 | ib_opcode[2] == 6;
wire is_mov_imm_3 = ib_opcode[3] == 5 | ib_opcode[3] == 6; 

assign ib_a_valid[0] = (~op_a_local_dep[0] & (rob_output_valid[ib_a_owner[0]] | ~ra_busy[0]))  | is_mov_imm_0;
assign ib_a_valid[1] = (~op_a_local_dep[1] & (rob_output_valid[ib_a_owner[1]] | ~ra_busy[1])) | is_mov_imm_1;
assign ib_a_valid[2] = (~op_a_local_dep[2] & (rob_output_valid[ib_a_owner[2]] | ~ra_busy[2])) | is_mov_imm_2;
assign ib_a_valid[3] = (~op_a_local_dep[3] & (rob_output_valid[ib_a_owner[3]] | ~ra_busy[3])) | is_mov_imm_3;

assign ib_a_value[0] = ra_busy[0] ? rob_output_values[ib_a_owner[0]] : ra_value[0];
assign ib_a_value[1] = ra_busy[1] ? rob_output_values[ib_a_owner[1]] : ra_value[1];
assign ib_a_value[2] = ra_busy[2] ? rob_output_values[ib_a_owner[2]] : ra_value[2];
assign ib_a_value[3] = ra_busy[3] ? rob_output_values[ib_a_owner[3]] : ra_value[3];

assign ib_b_valid[0] = (~uses_rb[0] | (~op_b_local_dep[0] & (rob_output_valid[ib_b_owner[0]] | ~rb_busy[0]))) | is_mov_imm_0;
assign ib_b_valid[1] = (~uses_rb[1] | (~op_b_local_dep[1] & (rob_output_valid[ib_b_owner[1]] | ~rb_busy[1]))) | is_mov_imm_1;
assign ib_b_valid[2] = (~uses_rb[2] | (~op_b_local_dep[2] & (rob_output_valid[ib_b_owner[2]] | ~rb_busy[2]))) | is_mov_imm_2;
assign ib_b_valid[3] = (~uses_rb[3] | (~op_b_local_dep[3] & (rob_output_valid[ib_b_owner[3]] | ~rb_busy[3]))) | is_mov_imm_3;

assign ib_b_value[0] = rb_busy[0] ? rob_output_values[ib_b_owner[0]] : rb_value[0];
assign ib_b_value[1] = rb_busy[1] ? rob_output_values[ib_b_owner[1]] : rb_value[1];
assign ib_b_value[2] = rb_busy[2] ? rob_output_values[ib_b_owner[2]] : rb_value[2];
assign ib_b_value[3] = rb_busy[3] ? rob_output_values[ib_b_owner[3]] : rb_value[3];

wire i0_fxu_0 = is_fxu[head] & ~fxu_0_full;
wire i0_fxu_1 = is_fxu[head] & ~i0_fxu_0 & ~fxu_1_full;

wire i1_fxu_0 = is_fxu[head_overflow_1] & ~fxu_0_full & ~i0_fxu_0;
wire i1_fxu_1 = is_fxu[head_overflow_1] & ~i1_fxu_0 & ~fxu_1_full & ~i0_fxu_1;

wire i2_fxu_0 = is_fxu[head_overflow_2] & ~fxu_0_full & ~i0_fxu_0 & ~i1_fxu_0;
wire i2_fxu_1 = is_fxu[head_overflow_2] & ~i2_fxu_0 & ~fxu_1_full & ~i0_fxu_1 & ~i1_fxu_1;

wire i3_fxu_0 = is_fxu[head_overflow_3] & ~fxu_0_full & ~i0_fxu_0 & ~i1_fxu_0 & ~i2_fxu_0;
wire i3_fxu_1 = is_fxu[head_overflow_3] & ~i3_fxu_0 & ~fxu_1_full & ~i0_fxu_1 & ~i1_fxu_1 & ~i2_fxu_1;

wire i0_branch = is_branch[head] & ~branch_full;
wire i1_branch = is_branch[head+1] & ~branch_full & ~i0_branch;
wire i2_branch = is_branch[head+2] & ~branch_full & ~i0_branch & ~i1_branch;
wire i3_branch = is_branch[head+3] & ~branch_full & ~i0_branch & ~i1_branch & ~i2_branch;



endmodule