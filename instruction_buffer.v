`timescale 1ps/1ps
`define NULL 10

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

output [3:0] out_rob_valid_flat, output [15:0] out_rob_rt_flat
);
    
    genvar n;

    wire [3:0] opcode[0:3];
    wire [7:0] immediate[0:3];

    wire op_a_local_dep[0:3]; 
    wire [3:0] op_a_owner[0:3];
    wire op_b_local_dep[0:3]; 
    wire [3:0] op_b_owner[0:3];

    wire [3:0] rt[0:3];
    wire uses_rb[0:3];
    wire is_ld_str[0:3];
    wire is_fxu[0:3];
    wire is_branch[0:3];

    wire [15:0]ra_value[0:3];
    wire ra_busy[0:3];
    wire [3:0] ra_owner[0:3];

    wire [15:0]rb_value[0:3];
    wire rb_busy[0:3];
    wire [3:0] rb_owner[0:3];

    wire rob_output_valid[0:15];
    wire [15:0]rob_output_values[0:15];

    // unflatten input wires
    generate
        for (n=0;n<4;n=n+1) assign opcode[3-n] = opcode_flat[4*n+3:4*n];
        for (n=0;n<4;n=n+1) assign immediate[3-n] = immediate_flat[8*n+7:8*n];

        for (n=0;n<4;n=n+1) assign op_a_local_dep[3-n] = op_a_local_dep_flat[1*n+0:1*n];
        for (n=0;n<4;n=n+1) assign op_a_owner[3-n] = op_a_owner_flat[4*n+3:4*n];
        for (n=0;n<4;n=n+1) assign op_b_local_dep[3-n] = op_b_local_dep_flat[1*n+0:1*n];
        for (n=0;n<4;n=n+1) assign op_b_owner[3-n] = op_b_owner_flat[4*n+3:4*n];

        for (n=0;n<4;n=n+1) assign rt[3-n] = rt_flat[4*n+3:4*n];
        for (n=0;n<4;n=n+1) assign uses_rb[3-n] = uses_rb_flat[1*n+0:1*n];
        for (n=0;n<4;n=n+1) assign is_ld_str[3-n] = is_ld_str_flat[1*n+0:1*n];
        for (n=0;n<4;n=n+1) assign is_fxu[3-n] = is_fxu_flat[1*n+0:1*n];
        for (n=0;n<4;n=n+1) assign is_branch[3-n] = is_branch_flat[1*n+0:1*n];

        for (n=0;n<4;n=n+1) assign ra_value[3-n] = ra_value_flat[16*n+15:16*n];
        for (n=0;n<4;n=n+1) assign ra_busy[3-n] = ra_busy_flat[1*n+0:1*n];
        for (n=0;n<4;n=n+1) assign ra_owner[3-n] = ra_owner_flat[4*n+3:4*n];
        
        for (n=0;n<4;n=n+1) assign rb_value[3-n] = rb_value_flat[16*n+15:16*n];
        for (n=0;n<4;n=n+1) assign rb_busy[3-n] = rb_busy_flat[1*n+0:1*n];
        for (n=0;n<4;n=n+1) assign rb_owner[3-n] = rb_owner_flat[4*n+3:4*n];
        
        for (n=0;n<16;n=n+1) assign rob_output_valid[15-n] = rob_output_valid_flat[1*n+0:1*n];
        for (n=0;n<16;n=n+1) assign rob_output_values[15-n] = rob_output_values_flat[16*n+15:16*n];
    endgenerate

    // flatten into output wires from all output regs
    generate
        for (n=0; n<4; n=n+1) assign out_rob_valid_flat [1*n+0:1*n] = rob_valid[3-n];
        for (n=0; n<4; n=n+1) assign out_rob_rt_flat [4*n+3:4*n] = rt[3-n];
    endgenerate







reg [3:0] ib_a_owner[0:3];
reg [3:0] ib_b_owner[0:3];

reg [3:0] ib_opcode[0:3];

wire [15:0] ib_a_value[0:3];
wire [15:0] ib_b_value[0:3];

wire ib_a_valid[0:3];
wire ib_b_valid[0:3];

reg [2:0] m_num_fetch = 0;

reg ib_valid;

always @(posedge clk) begin 
    integer i;
    for (i = 0; i < m_num_fetch; i++) begin
        ib_a_owner[i] <= op_a_local_dep[i] ? op_a_owner[i] : ra_owner[i];
        ib_b_owner[i] <= op_b_local_dep[i] ? op_b_owner[i] : rb_owner[i+1];
        ib_opcode[i] <= opcode[i];
    end
    ib_valid <= if_valid;
    m_num_fetch <= m_num_fetch_wire;
end

assign ib_a_valid[0] = ~op_a_local_dep[0] & (rob_output_valid[ib_a_owner[0]] | ~ra_busy[0]);
assign ib_a_valid[1] = ~op_a_local_dep[1] & (rob_output_valid[ib_a_owner[1]] | ~ra_busy[1]);
assign ib_b_valid[2] = ~op_a_local_dep[2] & (rob_output_valid[ib_a_owner[2]] | ~ra_busy[2]);
assign ib_a_valid[3] = ~op_a_local_dep[3] & (rob_output_valid[ib_a_owner[3]] | ~ra_busy[3]);

assign ib_a_value[0] = ra_busy[0] ? rob_output_values[ib_a_owner[0]] : ra_value[0];
assign ib_a_value[1] = ra_busy[1] ? rob_output_values[ib_a_owner[1]] : ra_value[1];
assign ib_b_value[2] = ra_busy[2] ? rob_output_values[ib_a_owner[2]] : ra_value[2];
assign ib_a_value[3] = ra_busy[3] ? rob_output_values[ib_a_owner[3]] : ra_value[3];

assign ib_b_valid[0] = ~uses_rb[0] | (~op_b_local_dep[0] & (rob_output_valid[ib_b_owner[0]] | ~rb_busy[0]));
assign ib_b_valid[1] = ~uses_rb[1] | (~op_b_local_dep[1] & (rob_output_valid[ib_b_owner[1]] | ~rb_busy[1]));
assign ib_b_valid[2] = ~uses_rb[2] | (~op_b_local_dep[2] & (rob_output_valid[ib_b_owner[2]] | ~rb_busy[2]));
assign ib_b_valid[3] = ~uses_rb[3] | (~op_b_local_dep[3] & (rob_output_valid[ib_b_owner[3]] | ~rb_busy[3]));

assign ib_b_value[0] = rb_busy[0] ? rob_output_values[ib_b_owner[0]] : rb_value[0];
assign ib_b_value[1] = rb_busy[1] ? rob_output_values[ib_b_owner[1]] : rb_value[1];
assign ib_b_value[2] = rb_busy[2] ? rob_output_values[ib_b_owner[2]] : rb_value[2];
assign ib_b_value[3] = rb_busy[3] ? rob_output_values[ib_b_owner[3]] : rb_value[3];

wire i0_fxu_0 = is_fxu[0] & ~fxu_0_full;
wire i0_fxu_1 = is_fxu[0] & fxu_0_full & ~fxu_1_full;

wire i1_fxu_0 = is_fxu[1] & ~fxu_0_full & ~i0_fxu_0;
wire i1_fxu_1 = is_fxu[1] & fxu_0_full & ~fxu_1_full & ~i0_fxu_1;

wire i2_fxu_0 = is_fxu[2] & ~fxu_0_full & ~i0_fxu_0 & ~i1_fxu_0;
wire i2_fxu_1 = is_fxu[2] & fxu_0_full & ~fxu_1_full & ~i0_fxu_1 & ~i1_fxu_1;

wire i3_fxu_0 = is_fxu[3] & ~fxu_0_full & ~i0_fxu_0 & ~i1_fxu_0 & ~i2_fxu_0;
wire i3_fxu_1 = is_fxu[3] & fxu_0_full & ~fxu_1_full & ~i0_fxu_1 & ~i1_fxu_1 & ~i2_fxu_1;

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

wire fxu_0_instr = i0_fxu_0 ? 0 : (i1_fxu_0 ? 1 : (i2_fxu_0 ? 2 : (i3_fxu_0 ? 3 : `NULL)));
wire fxu_1_instr = i0_fxu_1 ? 0 : (i1_fxu_1 ? 1 : (i2_fxu_1 ? 2 : (i3_fxu_1 ? 3 : `NULL)));
wire branch_instr = i0_branch ? 0 : (i1_branch ? 1 : (i2_branch ? 2 : (i3_branch ? 3 : `NULL)));

wire fxu_0_valid = fxu_0_instr != `NULL;
wire fxu_1_valid = fxu_1_instr != `NULL;
wire branch_valid = branch_instr != `NULL;

assign out_fxu_0_instr_valid = fxu_0_valid;
assign out_fxu_0_rob_idx = rob_head_idx + fxu_0_instr;
assign out_fxu_0_opcode = opcode[fxu_0_instr];
assign out_fxu_0_i = immediate[fxu_0_instr];

assign out_fxu_0_a_valid = ib_a_valid[fxu_0_instr];
assign out_fxu_0_a_owner = ib_a_owner[fxu_0_instr];
assign out_fxu_0_a_value = ib_a_value[fxu_0_instr];

assign out_fxu_0_b_valid = ib_b_valid[fxu_0_instr];
assign out_fxu_0_b_owner = ib_b_owner[fxu_0_instr];
assign out_fxu_0_b_value = ib_b_value[fxu_0_instr];

assign out_fxu_1_instr_valid = fxu_1_valid;
assign out_fxu_1_rob_idx = rob_head_idx + fxu_1_instr;
assign out_fxu_1_opcode = opcode[fxu_1_instr];
assign out_fxu_1_i = immediate[fxu_1_instr];

assign out_fxu_1_a_valid = ib_a_valid[fxu_1_instr];
assign out_fxu_1_a_owner = ib_a_owner[fxu_1_instr];
assign out_fxu_1_a_value = ib_a_value[fxu_1_instr];

assign out_fxu_1_b_valid = ib_b_valid[fxu_1_instr];
assign out_fxu_1_b_owner = ib_b_owner[fxu_1_instr];
assign out_fxu_1_b_value = ib_b_value[fxu_1_instr];

assign out_branch_instr_valid = branch_valid;
assign out_branch_rob_idx = rob_head_idx + branch_instr;
assign out_branch_opcode = opcode[branch_instr];

assign out_branch_a_valid = ib_a_valid[branch_instr];
assign out_branch_a_owner = ib_a_owner[branch_instr];
assign out_branch_a_value = ib_a_value[branch_instr];

assign out_branch_b_valid = ib_b_valid[branch_instr];
assign out_branch_b_owner = ib_b_owner[branch_instr];
assign out_branch_b_value = ib_b_value[branch_instr];

wire rob_valid [0:3];

assign rob_valid[0] = ~stall_0;
assign rob_valid[1] = ~stall_0 & ~stall_1;
assign rob_valid[2] = ~stall_0 & ~stall_1 & ~stall_2;
assign rob_valid[3] = ~stall_0 & ~stall_1 & ~stall_2 & ~stall_3;


endmodule