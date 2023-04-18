`include "reservation_station.v"

module instruction_buffer
(input clk,
// from instruction fetch unit
input if_valid, // instruction fetch valid

input [3:0] opcode[0:3], 
input op_a_local_dep[0:3], output [3:0] op_a_owner[0:3],
input op_b_local_dep[0:3], output [3:0] op_b_owner[0:3],
input [3:0] rt[0:3],
input uses_rb[0:3]

// from regsiter file
input [15:0] ra_value[0:3], 
input ra_busy[0:3], 
input [3:0] ra_owner[0:3],

input [15:0] rb_value[0:3], 
input rb_busy[0:3], 
input [3:0] rb_owner[0:3],

// rob input
input rob_output_valid[0:15], input [15:0] rob_output_values[0:15],

// functional unit status'
input fxu_0_full, input fxu_1_full, input lsu_full, input branch_full,

// outputs
output out_a_valid [0:3], output [15:0] out_a_value [0:3], output [3:0] out_a_owner [0:3], 
output out_b_valid [0:3], output [15:0] out_b_value [0:3], output [3:0] out_b_owner [0:3], 
output [3:0] out_rt [0:3]
);

reg [3:0] ib_a_owner[0:3];
reg [3:0] ib_b_owner[0:3];

reg [3:0] ib_opcode[0:3];

wire [15:0] ib_a_value[0:3];
wire [15:0] ib_b_value[0:3];

wire ib_a_valid[0:3];
wire ib_b_valid[0:3];

always @(posedge clk) begin 
    integer i;
    for (i = 0; i < 4; i++) begin
        ib_a_owner[i] <= op_a_local_dep[i] ? op_a_owner[i] : ra_owner[i];
        ib_b_owner[i] <= op_b_local_dep[i] ? op_b_owner[i] : rb_owner[i+1];
    end

    ib_opcode <= opcode;
end

assign ib_a_valid[0] = ~op_a_local_dep[0] & (rob_output_valid[ib_a_owner[0]] | ~ra_busy[0]);
assign ib_a_valid[1] = ~op_a_local_dep[1] & (rob_output_valid[ib_a_owner[1]] | ~ra_busy[1]);
assign ib_b_valid[2] = ~op_a_local_dep[2] & (rob_output_valid[ib_a_owner[2]] | ~ra_busy[2]);
assign ib_a_valid[3] = ~op_a_local_dep[3] & (rob_output_valid[ib_a_owner[3]] | ~ra_busy[3]);

assign ib_a_value[0] = ra_busy[0] ? rob_output_value[ib_a_owner[0]] : ra_value[0];
assign ib_a_value[1] = ra_busy[1] ? rob_output_value[ib_a_owner[1]] : ra_value[1];
assign ib_b_value[2] = ra_busy[2] ? rob_output_value[ib_a_owner[2]] : ra_value[2];
assign ib_a_value[3] = ra_busy[3] ? rob_output_value[ib_a_owner[3]] : ra_value[3];

assign ib_b_valid[0] = ~uses_rb[0] | (~op_b_local_dep[0] & (rob_output_valid[ib_b_owner[0]] | ~rb_busy[0]));
assign ib_b_valid[1] = ~uses_rb[1] | (~op_b_local_dep[1] & (rob_output_valid[ib_b_owner[1]] | ~rb_busy[1]));
assign ib_b_valid[2] = ~uses_rb[2] | (~op_b_local_dep[2] & (rob_output_valid[ib_b_owner[2]] | ~rb_busy[2]));
assign ib_b_valid[3] = ~uses_rb[3] | (~op_b_local_dep[3] & (rob_output_valid[ib_b_owner[3]] | ~rb_busy[3]));

assign ib_b_value[0] = rb_busy[0] ? rob_output_value[ib_b_owner[0]] : rb_value[0];
assign ib_b_value[1] = rb_busy[1] ? rob_output_value[ib_b_owner[1]] : rb_value[1];
assign ib_b_value[2] = rb_busy[2] ? rob_output_value[ib_b_owner[2]] : rb_value[2];
assign ib_b_value[3] = rb_busy[3] ? rob_output_value[ib_b_owner[3]] : rb_value[3];




endmodule