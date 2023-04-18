`timescale 1ps/1ps

module Main;

    initial begin 
        $dumpfile("cpu.vcd");
        $dumpvars(0, main);
    end

    wire clk;
    Clock c0(clk);

    reg [15:0] pc_array[0:3] = {16'h0000, 16'h0000, 16'h0000, 16'h0000};
    wire [15:0] instructions[0:3];

    InstructionCache iCache
    (clk,
    pc_array, instructions);

    // go to rob
    wire rob_head;

    // comes from branch unit
    wire [15:0] branch_target, is_branch;

    // go to instruction buffer
    wire [3:0] opcode_out[0:3];
    wire op_a_local_dep_out[0:3];
    wire [3:0] op_a_owner_out[0:3];
    wire op_b_local_dep_out[0:3];
    wire [3:0] op_b_owner_out[0:3];
    wire [3:0] rt_out[0:3];

    // comes from instruction buffer
    wire [3:0] num_slots; // PROBLEM!!!!!!!

    // go to register file
    wire [3:0] ra_out[0:3],
    wire [3:0] rb_out[0:3],

    InstructionFetch iFetcher
    (clk,

    branch_target, is_branch,

    instructions,

    rob_head,

    num_slots,

    pc_array,

    opcode_out, 
    op_a_local_dep_out, op_a_owner_out,
    op_b_local_dep_out, op_b_owner_out,
    rt_out,

    ra_out, rb_out);

    // come from instruction fetcher
    wire instructions_valid; // PROBLEM!!!!!!!
    wire uses_rb; // PROBLEM!!!!!!!

    // come from register file
    wire [15:0] ra_value[0:3]; 
    wire ra_busy[0:3];
    wire [3:0] ra_owner[0:3];
    wire [15:0] rb_value[0:3];
    wire rb_busy[0:3];
    wire [3:0] rb_owner[0:3];

    // come from rob
    wire rob_output_valid[0:15];
    wire [15:0] rob_output_values[0:15];

    // come from functional units
    wire fxu_0_full; // PROBLEM!!!!!!!
    wire fxu_1_full; // PROBLEM!!!!!!!
    wire lsu_full; // PROBLEM!!!!!!!
    wire branch_full; // PROBLEM!!!!!!!

    // go to reservation stations
    wire out_a_valid [0:3];
    wire [15:0] out_a_value [0:3];
    wire [3:0] out_a_owner [0:3];
    
    wire out_b_valid [0:3];
    wire [15:0] out_b_value [0:3];
    wire [3:0] out_b_owner [0:3];
    
    wire [3:0] out_rt [0:3];
    wire [3:0] opcode [0:3];
    
    InstructionBuffer iBuffer
    (clk,

    instructions_valid,

    opcode_out, 
    op_a_local_dep_out, op_a_owner_out,
    op_b_local_dep_out, op_b_owner_out,
    rt_out,
    uses_rb,

    ra_value, ra_busy, ra_owner,
    rb_value, rb_busy, rb_owner,

    rob_output_valid, rob_output_values,

    fxu_0_full, fxu_1_full, lsu_full, branch_full,

    out_a_valid, out_a_value, out_a_owner, 
    out_b_valid, out_b_value, out_b_owner, 
    out_rt, opcode);

    // comes from instruction buffer
    wire always_valid[0:3] = {1, 1, 1, 1}; // PROBLEM!!!!!!!

    // come from functional units/common data bus
    wire cdb_valid[0:3];
    wire [3:0] indices[0:3];
    wire [15:0] new_values[0:3];

    // should go to instruction fetcher?
    wire out_finished[0:15]; // PROBLEM!!!!!!!
    wire [15:0] out_values[0:15]; // PROBLEM!!!!!!!

    // go to register file
    wire register_write_enable[0:3];
    wire [3:0] register_targets[0:3];
    wire [15:0] register_write_data[0:3];
    wire [3:0] register_writers[0:3];

    // should probably go to instruction buffer
    wire [3:0] size; // PROBLEM!!!!!!!

    ROB rob
    (clk,

    always_valid, 
    out_rt,

    cdb_valid,
    indices,
    new_values,

    out_finished,
    out_values,

    register_write_enable,
    register_targets,
    register_write_data,
    register_writers,

    size,
    head);

endmodule