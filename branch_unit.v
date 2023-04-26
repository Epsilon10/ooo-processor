`timescale 1ps/1ps

module BranchUnit
(input clk, 
input [3:0] opcode, input [3:0] in_index, input in_valid,
input [15:0] vt, input [15:0] va,  // we receive decoded values
output out_valid, output [3:0] rob_index, output [15:0] branch_target);

    reg m_valid;
    reg [3:0] m_opcode;
    reg [3:0] m_in_index;
    reg [15:0] m_vt;
    reg [15:0] m_va;

    always @(posedge clk) begin 
        m_valid <= in_valid;
        m_opcode <= opcode;
        m_in_index <= in_index;
        m_vt <= vt;
        m_va <= va;
    end

    wire isJz = opcode == 4'b1000;
    wire isJnz = opcode == 4'b1001;
    wire isJs = opcode == 4'b1010;
    wire isJns = opcode == 4'b1011;

    wire branch_taken = 
    isJz ? va == 0 : 
    isJnz ? va != 0 :
    isJs ? va[0] == 1 :
    isJns ? va[0] != 1 : 
    0;

    assign out_valid = m_valid & branch_taken; // if branch isn't taken, do nothing
    assign rob_index = m_in_index;
    assign branch_target = m_vt;

endmodule