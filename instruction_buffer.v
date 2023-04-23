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

output [3:0] out_rob_valid_flat, output [15:0] out_rob_rt_flat, output [3:0] rob_halt,

output [3:0] rt_update_enable_flat, output [15:0] rt_target_reg_flat, output [15:0] rt_owner_flat
);
    
    genvar n;

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

always @(posedge clk) begin 
    integer i;

    for (i = 0; i < 4; i++) begin
        ib_a_owner[i] <= op_a_local_dep[i] ? op_a_owner[i] : (ra_busy[i] ? ra_owner[i] : rob_head_idx + i);
        ib_b_owner[i] <= op_b_local_dep[i] ? op_b_owner[i] : (rb_busy[i] ? rb_owner[i] : rob_head_idx + i);
        ib_opcode[i] <= opcode[i];
        immediate[i] <= w_immediate[i];
        op_a_local_dep[i] <= w_op_a_local_dep[i];
        op_a_owner[i] <= w_op_a_owner[i];
        op_b_local_dep[i] <= w_op_b_local_dep[i];
        op_b_owner[i] <= w_op_b_owner[i];

        rt[i] <= w_rt[i];
        uses_rb[i] <= w_uses_rb[i];
        is_ld_str[i] <= w_is_ld_str[i];
        is_fxu[i] <= w_is_fxu[i];
        is_branch[i] <= w_is_branch[i];
    end

    for (i = 0; i < 15; i++) begin
        rob_output_valid[i] <= w_rob_output_valid[i];
        rob_output_values[i] <= w_rob_output_values[i];
    end
    ib_valid <= if_valid;
    m_num_fetch <= m_num_fetch_wire;
end

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

wire is_fxu_0_w = is_fxu[0];
wire i0_fxu_0 = is_fxu[0] & ~fxu_0_full;
wire i0_fxu_1 = is_fxu[0] & ~i0_fxu_0 & ~fxu_1_full;

wire is_fxu_0 = is_fxu[0];
wire is_fxu_1 = is_fxu[1];

wire i1_fxu_0 = is_fxu[1] & ~fxu_0_full & ~i0_fxu_0;
wire i1_fxu_1 = is_fxu[1] & ~i1_fxu_0 & ~fxu_1_full & ~i0_fxu_1;

wire i2_fxu_0 = is_fxu[2] & ~fxu_0_full & ~i0_fxu_0 & ~i1_fxu_0;
wire i2_fxu_1 = is_fxu[2] & ~i2_fxu_0 & ~fxu_1_full & ~i0_fxu_1 & ~i1_fxu_1;

wire i3_fxu_0 = is_fxu[3] & ~fxu_0_full & ~i0_fxu_0 & ~i1_fxu_0 & ~i2_fxu_0;
wire i3_fxu_1 = is_fxu[3] & ~i3_fxu_0 & ~fxu_1_full & ~i0_fxu_1 & ~i1_fxu_1 & ~i2_fxu_1;

wire i0_branch = is_branch[0] & ~branch_full;
wire i1_branch = is_branch[1] & ~branch_full & ~i0_branch;
wire i2_branch = is_branch[2] & ~branch_full & ~i0_branch & ~i1_branch;
wire i3_branch = is_branch[3] & ~branch_full & ~i0_branch & ~i1_branch & ~i2_branch;

// add load store later

wire stall_0 = (is_fxu[0] & (~i0_fxu_0 & ~i0_fxu_1)) | (is_branch[0] & ~i0_branch);
wire stall_1 = (is_fxu[1] & (~i1_fxu_0 & ~i1_fxu_1)) | (is_branch[1] & ~i1_branch);
wire stall_2 = (is_fxu[2] & (~i2_fxu_0 & ~i2_fxu_1)) | (is_branch[2] & ~i2_branch);
wire stall_3 = (is_fxu[3] & (~i3_fxu_0 & ~i3_fxu_1)) | (is_branch[3] & ~i3_branch);
wire stall_none = ~stall_0 & ~stall_1 & ~stall_2 & ~stall_3;

wire m_num_fetch_wire = stall_none ? 4 : (stall_0 ? 0 : (stall_1 ? 1 : (stall_2 ? 2 : (stall_3 ? 3 : `NULL))));

wire [2:0]fxu_0_instr = i0_fxu_0 ? 0 : (i1_fxu_0 ? 1 : (i2_fxu_0 ? 2 : (i3_fxu_0 ? 3 : `NULL)));
wire [2:0]fxu_1_instr = i0_fxu_1 ? 0 : (i1_fxu_1 ? 1 : (i2_fxu_1 ? 2 : (i3_fxu_1 ? 3 : `NULL)));
wire [2:0]branch_instr = i0_branch ? 0 : (i1_branch ? 1 : (i2_branch ? 2 : (i3_branch ? 3 : `NULL)));

wire fxu_0_valid = fxu_0_instr != `NULL;
wire fxu_1_valid = fxu_1_instr != `NULL;
wire branch_valid = branch_instr != `NULL;

assign out_fxu_0_instr_valid = fxu_0_valid;
assign out_fxu_0_rob_idx = rob_head_idx + fxu_0_instr;
assign out_fxu_0_opcode = ib_opcode[fxu_0_instr];
assign out_fxu_0_i = immediate[fxu_0_instr];

assign out_fxu_0_a_valid = ib_a_valid[fxu_0_instr];
assign out_fxu_0_a_owner = ib_a_owner[fxu_0_instr];
assign out_fxu_0_a_value = ib_a_value[fxu_0_instr];

assign out_fxu_0_b_valid = ib_b_valid[fxu_0_instr];
assign out_fxu_0_b_owner = ib_b_owner[fxu_0_instr];
assign out_fxu_0_b_value = ib_b_value[fxu_0_instr];

assign out_fxu_1_instr_valid = fxu_1_valid;
assign out_fxu_1_rob_idx = rob_head_idx + fxu_1_instr;
assign out_fxu_1_opcode = ib_opcode[fxu_1_instr];
assign out_fxu_1_i = immediate[fxu_1_instr];

assign out_fxu_1_a_valid = ib_a_valid[fxu_1_instr];
assign out_fxu_1_a_owner = ib_a_owner[fxu_1_instr];
assign out_fxu_1_a_value = ib_a_value[fxu_1_instr];

assign out_fxu_1_b_valid = ib_b_valid[fxu_1_instr];
assign out_fxu_1_b_owner = ib_b_owner[fxu_1_instr];
assign out_fxu_1_b_value = ib_b_value[fxu_1_instr];

assign out_branch_instr_valid = branch_valid;
assign out_branch_rob_idx = rob_head_idx + branch_instr;
assign out_branch_opcode = ib_opcode[branch_instr];

assign out_branch_a_valid = ib_a_valid[branch_instr];
assign out_branch_a_owner = ib_a_owner[branch_instr];
assign out_branch_a_value = ib_a_value[branch_instr];

assign out_branch_b_valid = ib_b_valid[branch_instr];
assign out_branch_b_owner = ib_b_owner[branch_instr];
assign out_branch_b_value = ib_b_value[branch_instr];

wire rob_valid [0:3];

assign rob_valid[0] = ib_valid & ~stall_0;
assign rob_valid[1] = ib_valid & ~stall_0 & ~stall_1;
assign rob_valid[2] = ib_valid & ~stall_0 & ~stall_1 & ~stall_2;
assign rob_valid[3] = ib_valid & ~stall_0 & ~stall_1 & ~stall_2 & ~stall_3;

assign rob_halt[0] = !is_fxu[0] & !is_branch[0] & !is_ld_str[0];
assign rob_halt[1] = !is_fxu[1] & !is_branch[1] & !is_ld_str[1];
assign rob_halt[2] = !is_fxu[2] & !is_branch[2] & !is_ld_str[2];
assign rob_halt[3] = !is_fxu[3] & !is_branch[3] & !is_ld_str[3];

wire i3_writes_to_reg = ib_opcode[3] == 0 | ib_opcode[3] == 1 | ib_opcode[3] == 2 | ib_opcode[3] == 4 | ib_opcode[3] == 5 | ib_opcode[3] == 6;
wire i2_writes_to_reg = ib_opcode[2] == 0 | ib_opcode[2] == 1 | ib_opcode[2] == 2 | ib_opcode[2] == 4 | ib_opcode[2] == 5 | ib_opcode[2] == 6;
wire i1_writes_to_reg = ib_opcode[1] == 0 | ib_opcode[1] == 1 | ib_opcode[1] == 2 | ib_opcode[1] == 4 | ib_opcode[1] == 5 | ib_opcode[1] == 6;
wire i0_writes_to_reg = ib_opcode[0] == 0 | ib_opcode[0] == 1 | ib_opcode[0] == 2 | ib_opcode[0] == 4 | ib_opcode[0] == 5 | ib_opcode[0] == 6;

wire rt_update_enable [0:3];
wire [3:0] rt_target_reg[0:3];
wire [3:0] rt_owner[0:3];

// TODO: unflatten

assign rt_update_enable[3] = 1 & i3_writes_to_reg;
assign rt_update_enable[2] = rt[3] != rt[2] & i2_writes_to_reg;
assign rt_update_enable[1] = rt[1] != rt[2] & rt[1] != rt[3] & i1_writes_to_reg; 
assign rt_update_enable[0] = rt[0] != rt[1] & rt[0] != rt[2] & rt[0] != rt[3] & i0_writes_to_reg;

assign rt_target_reg[0] = rt[0];
assign rt_target_reg[1] = rt[1];
assign rt_target_reg[2] = rt[2];
assign rt_target_reg[3] = rt[3];

assign rt_owner[0] = rob_head_idx;
assign rt_owner[1] = rob_head_idx + 1;
assign rt_owner[2] = rob_head_idx + 2;
assign rt_owner[3] = rob_head_idx + 3;

endmodule