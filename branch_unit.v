`timescale 1ps/1ps

module BranchUnit
(input [3:0] opcode, input [3:0] in_index, input in_valid,
input [3:0] vt, input [3:0] va, input [3:0] vb, input [8:0] i, // we receive decoded values
output out_valid, output [3:0] rob_index, output [15:0] branch_target, output branch_taken);

    reg m_valid;

    always @(posedge clk) begin 
        m_valid <= in_valid;
    end

    assign rob_index = in_index;
    assign branch_target = vt;

    wire isJz = opcode == 4'b1000;
    wire isJnz = opcode == 4'b1001;
    wire isJs = opcode == 4'b1010;
    wire isJns = opcode == 4'b1011;

    assign out_valid = m_valid;

    assign branch_taken = 
    isJz ? va == 0 : 
    isJnz ? va != 0 :
    isJs ? va[0] == 1 :
    isJns ? va[0] != 1 : 
    0;

endmodule