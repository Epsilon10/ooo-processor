module instruction_fetch
(input clk,
// output of branch unit
input [15:0] jump_target,
input is_jump,
// output of instruction cache
input [15:0] instr[0:3],
 
input [3:0]rob_head_idx,
// whats fed into icache
output [15:0] pc_to_icache[0:3],

// whats fed to instruction buffer
output [3:0] opcode_out[0:3], 
output op_a_local_dep_out[0:3], output [3:0] op_a_owner_out[0:3],
output op_b_local_dep_out[0:3], output [3:0] op_b_owner_out[0:3],
output [3:0] rt_out[0:3],

// for memory
output [3:0] ra_out[0:3],
output [3:0] rb_out[0:3]
);
    
    reg [15:0] m_pc_to_icache[3:0];
    assign pc_to_icache = m_pc_to_icache;

    initial begin 
        integer p;
        for(p = 1; p < 5; p++) begin 
            m_pc_to_icache[p] = 2*p;
        end
    end

    always @(posedge clk) begin 
        integer i;
        
        for (i = 1; i < 4; i++) begin
            m_pc_to_icache[i] <= is_jump ? jump_target + 2*i : m_pc_to_icache[i] + 2*(i+1);
        end
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

    wire d_is_add_sub_1 = d_opcode[1] == 0 | d_opcode[1] == 1;
    wire d_is_other_write_to_reg_1 = d_opcode[1] == 2 | d_opcode[1] == 4 | d_opcode[1] == 5 | d_opcode[1] == 6;

    assign op_a_owner[1] = (d_is_add_sub_3 | d_is_other_write_to_reg_3) & d_ra[1] == d_rt[0] ? 
                    rob_head_idx // ra_1 == rt_0
                    : rob_head_idx + 1;

    assign op_a_local_dep[1] = op_a_owner[1] == rob_head_idx + 1;

    wire d_is_add_sub_2 = d_opcode[2] == 0 | d_opcode[2] == 1;
    wire d_is_other_write_to_reg_2 = d_opcode[2] == 2 | d_opcode[2] == 4 | d_opcode[2] == 5 | d_opcode[2] == 6;

    assign op_a_owner[2] = (d_is_add_sub_2 | d_is_other_write_to_reg_2) 
                    ? (d_ra[2] == d_rt[1] ? (rob_head_idx + 1)  // ra_2 == rt_1
                    : d_ra[2] == d_rt[0] ? (rob_head_idx + 0) : rob_head_idx + 2) // ra_2 == rt_0
                    : rob_head_idx + 2;

    assign op_a_local_dep[2] = op_a_owner[2] == rob_head_idx + 2;

    wire d_is_add_sub_3 = d_opcode[3] == 0 | d_opcode[3] == 1;
    wire d_is_other_write_to_reg_3 = d_opcode[3] == 2 | d_opcode[3] == 4 | d_opcode[3] == 5 | d_opcode[3] == 6;

    assign op_a_owner[3] = (d_is_add_sub_3 | d_is_other_write_to_reg_3) 
                    ? (d_ra[3] == d_rt[2] ? (rob_head_idx + 2)  // ra_3 == rt_2
                    : d_ra[3] == d_rt[1] ? (rob_head_idx + 1) // ra_3 == rt_1
                    : d_ra[3] == d_rt[0] ? (rob_head_idx + 0) : rob_head_idx + 3) // ra_3 == rt_0
                    : rob_head_idx + 3;

    assign op_a_local_dep[3] = op_a_owner[3] == rob_head_idx + 3;

    // rb dependcy checking
    // only adds and subs have an rb
    assign op_b_owner[1] = d_is_add_sub_1 & d_rb[1] == d_rt[0] ? 
                    rob_head_idx // rb_1 == rt_0
                    : rob_head_idx + 1;

    assign op_b_local_dep[1] = op_b_owner[1] == rob_head_idx + 1;

    assign op_b_owner[2] = d_is_add_sub_2 
                    ? (d_rb[2] == d_rt[1] ? (rob_head_idx + 1)  // rb_2 == rt_1
                    : d_rb[2] == d_rt[0] ? (rob_head_idx + 0) : rob_head_idx + 2) // rb_2 == rt_0
                    : rob_head_idx + 2;

    assign op_b_local_dep[2] = op_b_owner[2] == rob_head_idx + 2;

    assign op_b_owner[3] = d_is_add_sub_3
                    ? (d_rb[3] == d_rt[2] ? (rob_head_idx + 2)  // rb_3 == rt_2
                    : d_rb[3] == d_rt[1] ? (rob_head_idx + 1) // rb_3 == rt_1
                    : d_rb[3] == d_rt[0] ? (rob_head_idx + 0) : rob_head_idx + 3) // rb_3 == rt_0
                    : rob_head_idx + 3;

    assign op_b_local_dep[3] = op_b_owner[3] == rob_head_idx + 3;

    assign op_a_local_dep_out = op_a_local_dep;
    assign op_a_owner_out = op_a_owner;

    assign op_b_local_dep_out = op_b_local_dep;
    assign op_b_owner_out = op_b_owner;

    assign d_ra = ra_out;
    assign d_rb = rb_out;
    assign d_rt = rt_out;

endmodule