`timescale 1ps/1ps

module Main;

    initial begin 
        $dumpfile("cpu.vcd");
        $dumpvars(0, Main);
    end

    wire clk;
    Clock c0(clk);
    reg halt = 0;
    counter counter(halt, clk);

    wire [63:0] pc_array;
    wire [59:0] pc_array_truncated = {pc_array[63:49], pc_array[47:33], pc_array[31:17], pc_array[15:1]};


    /*


    wire [63:0] pc_array_input;
    */
    // wire [63:0] pc_array_input;

    wire [63:0] instructions;

    InstructionCache iCache
    (clk,
    pc_array_truncated, instructions);

    // go to rob
    wire [3:0] rob_head;

    // comes from branch unit
    wire [15:0] branch_target = 0;
    wire is_branch = 0;

    // go to instruction buffer
    wire [15:0] opcode_out;
    wire [31:0] immediate_out;

    wire [3:0]  op_a_local_dep_out;
    wire [15:0] op_a_owner_out;
    wire [3:0]  op_b_local_dep_out;
    wire [15:0] op_b_owner_out;
    wire [15:0] rt_out;

    wire [3:0]uses_rb_out;
    wire [3:0]is_ld_str_out;
    wire [3:0]is_fxu_out;
    wire [3:0]is_branch_out;
    wire [3:0]is_halt_out;

    // comes from instruction buffer
    wire [2:0] num_slots; 

    // go to register file
    wire [15:0] ra_out;
    wire [15:0] rb_out;
    wire if_valid_out;

    InstructionFetch iFetcher
    (clk,

    branch_target, is_branch,

    instructions,

    rob_head,

    num_slots,

    pc_array,

    opcode_out, immediate_out,
    op_a_local_dep_out, op_a_owner_out,
    op_b_local_dep_out, op_b_owner_out,
    rt_out,

    uses_rb_out,
    is_ld_str_out,
    is_fxu_out,
    is_branch_out,
    is_halt_out,

    ra_out, rb_out,
    if_valid_out);

    // come from register file
    wire [63:0] ra_value; 
    wire [3:0]  ra_busy;
    wire [15:0] ra_owner;
    wire [63:0] rb_value;
    wire [3:0]  rb_busy;
    wire [15:0] rb_owner;

    // come from rob
    wire [15:0]rob_output_valid;
    wire [255:0] rob_output_values;

    // come from functional units
    wire fxu_0_full;
    wire fxu_1_full;
    wire lsu_full;
    wire branch_full;

    // go to reservation stations
    wire out_fxu_0_instr_valid;
    wire [3:0] out_fxu_0_rob_idx;
    wire out_fxu_0_a_valid;
    wire [15:0] out_fxu_0_a_value;
    wire [3:0] out_fxu_0_a_owner;
    
    wire out_fxu_0_b_valid;
    wire [15:0] out_fxu_0_b_value;
    wire [3:0] out_fxu_0_b_owner;
    
    wire [3:0] out_fxu_0_opcode;
    wire [7:0] out_fxu_0_i;
    
    // fxu 1
    wire out_fxu_1_instr_valid;
    wire [3:0] out_fxu_1_rob_idx;
    wire out_fxu_1_a_valid;
    wire [15:0] out_fxu_1_a_value;
    wire [3:0] out_fxu_1_a_owner;
    
    wire out_fxu_1_b_valid;
    wire [3:0] out_branch_rob_idx;
    wire [15:0] out_fxu_1_b_value;
    wire [3:0] out_fxu_1_b_owner;

    wire [3:0] out_fxu_1_opcode;
    wire [7:0] out_fxu_1_i;

    
    // lsu
    wire out_lsu_instr_valid;
    wire [3:0] out_lsu_rob_idx;

    wire out_lsu_a_valid;
    wire [15:0] out_lsu_a_value;
    wire [3:0] out_lsu_a_owner;
    
    wire out_lsu_b_valid;
    wire [15:0] out_lsu_b_value;
    wire [3:0] out_lsu_b_owner;

    wire [3:0] out_lsu_opcode;
    
    // branch unit
    wire out_branch_instr_valid;
    wire out_branch_a_valid;
    wire [15:0] out_branch_a_value;
    wire [3:0] out_branch_a_owner;
    
    wire out_branch_b_valid;
    wire [15:0] out_branch_b_value;
    wire [3:0] out_branch_b_owner;

    wire [3:0] out_branch_opcode;
    
    wire [3:0]out_rob_valid;
    wire [15:0]out_rob_rt;

    wire [3:0] rt_update_enable_flat;
    output [15:0] rt_target_reg_flat;
    output [15:0] rt_owner_flat;

    wire [3:0] rob_halt;

    wire flush = 0;
    
    InstructionBuffer iBuffer
    (clk,

    if_valid_out,
    flush,

    opcode_out, immediate_out,
    op_a_local_dep_out, op_a_owner_out,
    op_b_local_dep_out, op_b_owner_out,
    
    rt_out,
    uses_rb_out,
    is_ld_str_out,
    is_fxu_out,
    is_branch_out,
    is_halt_out,

    ra_value, ra_busy, ra_owner,
    rb_value, rb_busy, rb_owner,

    rob_head, rob_output_valid, rob_output_values,

    fxu_0_full, fxu_1_full, lsu_full, branch_full,

    num_slots,

    out_fxu_0_instr_valid, out_fxu_0_rob_idx, out_fxu_0_a_valid, out_fxu_0_a_value, out_fxu_0_a_owner, 
    out_fxu_0_b_valid, out_fxu_0_b_value, out_fxu_0_b_owner, out_fxu_0_opcode, out_fxu_0_i,

    // fxu 1
    out_fxu_1_instr_valid,out_fxu_1_rob_idx, out_fxu_1_a_valid, out_fxu_1_a_value, out_fxu_1_a_owner, 
    out_fxu_1_b_valid, out_fxu_1_b_value, out_fxu_1_b_owner, out_fxu_1_opcode, out_fxu_1_i,

    // lsu
    out_lsu_instr_valid,out_lsu_rob_idx, out_lsu_a_valid, out_lsu_a_value, out_lsu_a_owner, 
    out_lsu_b_valid, out_lsu_b_value, out_lsu_b_owner, out_lsu_opcode,

    // branch unit
    out_branch_instr_valid, out_branch_rob_idx, out_branch_a_valid, out_branch_a_value, out_branch_a_owner, 
    out_branch_b_valid, out_branch_b_value, out_branch_b_owner,out_branch_opcode,

    out_rob_valid, out_rob_rt, rob_halt,
    rt_update_enable_flat, rt_target_reg_flat, rt_owner_flat
    );

    // come from functional units/common data bus
    wire cdb_valid_0;
    wire cdb_valid_1;
    wire cdb_valid_2;
    wire cdb_valid_3;

    wire [3:0]cdb_valid = {cdb_valid_3, cdb_valid_2, cdb_valid_1, cdb_valid_0};

    assign cdb_valid[0] = 0; // TODO remove once branch unit added
    assign cdb_valid[1] = 0; // TODO remove once LSU added
    wire [15:0] indices;
    wire [63:0] new_values;

    // go to register file
    wire [3:0]register_write_enable;
    wire [15:0] register_targets;
    wire [63:0] register_write_data;
    wire [15:0] register_writers;

    // should probably go to instruction buffer
    wire [3:0] size; // PROBLEM!!!!!!!
    wire [3:0] flush_cdb = 0;

    ROB rob
    (clk,

    out_rob_valid,
    out_rob_rt,
    rob_halt,

    cdb_valid,
    indices,
    new_values,
    flush_cdb,

    rob_output_valid,
    rob_output_values,

    register_write_enable,
    register_targets,
    register_write_data,
    register_writers,

    is_branch,
    branch_target,

    size,
    rob_head);

    wire [3:0]res_fxu0_out_instr_index;
    wire [3:0]res_fxu0_out_opcode;
    wire [7:0]res_fxu0_out_i;
    wire res_fxu0_out_valid;
    wire [15:0]res_fxu0_op1_value;
    wire [15:0]res_fxu0_op2_value;

    // last 3 inputs to fxu reservation station
    // concatenate the CDB outputs from all functional units
    // input cdb_valid[0:3], input [3:0]cdb_rob_index[0:3], input [15:0]cdb_result[0:3]

    ReservationStation fxu0_reservationstation 
    (clk, 
    out_fxu_0_instr_valid, 
    out_fxu_0_rob_idx, out_fxu_0_opcode, out_fxu_0_i, out_fxu_0_a_owner, out_fxu_0_b_owner, out_fxu_0_a_value, out_fxu_0_b_value, out_fxu_0_a_valid, out_fxu_0_b_valid,
    res_fxu0_out_instr_index, res_fxu0_out_opcode, res_fxu0_out_i, res_fxu0_out_valid,
    res_fxu0_op1_value, res_fxu0_op2_value, fxu_0_full,
    // common data bus input
    cdb_valid, indices, new_values);


    FXU fxu0
    (clk,
    res_fxu0_out_opcode, res_fxu0_out_instr_index, res_fxu0_out_valid,
    res_fxu0_op1_value, res_fxu0_op2_value, res_fxu0_out_i, 
    cdb_valid_3, indices[15:12], new_values[63:48]
    );


    wire [3:0]res_fxu1_out_instr_index;
    wire [3:0]res_fxu1_out_opcode;
    wire [7:0]res_fxu1_out_i;
    wire res_fxu1_out_valid;
    wire [15:0]res_fxu1_op1_value;
    wire [15:0]res_fxu1_op2_value;

    ReservationStation fxu1_reservationstation 
    (clk, 
    out_fxu_1_instr_valid, 
    out_fxu_1_rob_idx, out_fxu_1_opcode, out_fxu_1_i, out_fxu_1_a_owner, out_fxu_1_b_owner, out_fxu_1_a_value, out_fxu_1_b_value, out_fxu_1_a_valid, out_fxu_1_b_valid,
    res_fxu1_out_instr_index, res_fxu1_out_opcode, res_fxu1_out_i, res_fxu1_out_valid,
    res_fxu1_op1_value, res_fxu1_op2_value, fxu_1_full,
    // common data bus input
    cdb_valid, indices, new_values);


    FXU fxu1
    (clk,
    res_fxu1_out_opcode, res_fxu1_out_instr_index, res_fxu1_out_valid,
    res_fxu1_op1_value, res_fxu1_op2_value, res_fxu1_out_i, 
    cdb_valid_2, indices[11:8], new_values[47:32]
    );


    RegisterFile register_file
    (clk, 
    ra_out, 
    ra_value, 
    ra_busy, 
    ra_owner,

    // READ PORT 2 for instruciton fetcher
    rb_out,
    rb_value, 
    rb_busy, 
    rb_owner,

    // WRITE PORT
    register_write_enable,
    register_targets,
    register_write_data,
    register_writers,
    rt_update_enable_flat,
    rt_target_reg_flat,
    rt_owner_flat
    );

endmodule