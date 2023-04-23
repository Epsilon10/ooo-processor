`timescale 1ps/1ps

module FXU
(input clk,
input [3:0] in_opcode, input [3:0] in_index, input in_valid,
input [15:0] in_va, input [15:0] in_vb, input [7:0] in_i, // we receive decoded values
output out_valid, output [3:0] out_rob_index, output [15:0] out_return_value);

    reg m_valid = 0;
    reg [3:0] opcode;
    reg [3:0] rob_index;
    reg [15:0] va;
    reg [15:0] vb;
    reg [15:0] i;

    always @(posedge clk) begin 
        m_valid <= in_valid;
        opcode <= in_opcode;
        rob_index <= in_index;
        va <= in_va;
        vb <= in_vb;
        i <= in_i;
    end

    wire isAdd = opcode == 4'b0000;
    wire isSub = opcode == 4'b0001;
    wire isMov = opcode == 4'b0100;
    wire isMovl = opcode == 4'b0101;
    wire isMovh = opcode == 4'b0110;

    assign out_return_value = 
    isAdd ? va + vb : 
    isSub ? va - vb :
    isMov ? va :
    isMovl ? {{8{i[7]}}, i} : 
    isMovh ? {i, va[7:0]} : 
    0;

    assign out_valid = m_valid;
    assign out_rob_index = rob_index;

endmodule