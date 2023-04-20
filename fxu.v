`timescale 1ps/1ps

module FXU
(input clk,
input [3:0] opcode, input [3:0] in_index, input in_valid,
input [15:0] va, input [15:0] vb, input [7:0] i, // we receive decoded values
output out_valid, output [3:0] rob_index, output [15:0] return_value);

    reg m_valid;

    always @(posedge clk) begin 
        m_valid <= in_valid;
    end

    assign rob_index = in_index;
    assign out_valid = m_valid;

    wire isAdd = opcode == 4'b0000;
    wire isSub = opcode == 4'b0001;
    wire isMov = opcode == 4'b0100;
    wire isMovl = opcode == 4'b0101;
    wire isMovh = opcode == 4'b0110;

    assign return_value = 
    isAdd ? va + vb : 
    isSub ? va - vb :
    isMov ? va :
    isMovl ? {va[15:8], i} : 
    isMovh ? {i, va[7:0]} : 
    0;

endmodule