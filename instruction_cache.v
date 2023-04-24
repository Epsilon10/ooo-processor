`timescale 1ps/1ps

module InstructionCache
(input clk,
input [59:0] pc_array_flat,
output [63:0] instructions_flat);

    genvar i;
    wire [15:1]pc_array[0:3];

    // unflatten input wires
    generate
        for(i=0; i<4; i=i+1) assign pc_array[3-i] = pc_array_flat[15*i+14:15*i];
    endgenerate

    // flatten into output wires from all output regs
    generate
        for (i=0; i<4; i=i+1) assign instructions_flat [16*i+15:16*i] = rdata_array[3-i];
    endgenerate

    wire [15:0]pc_array_0 = {pc_array_flat[59:45], 1'b0};
    wire [15:0]pc_array_1 = {pc_array_flat[44:30], 1'b0};
    wire [15:0]pc_array_2 = {pc_array_flat[29:15], 1'b0};
    wire [15:0]pc_array_3 = {pc_array_flat[14:0 ], 1'b0};


    reg [15:0] data[0:16'h7fff];

    /* Simulation -- read initial content from file */
    initial begin
        $readmemh("instructions.hex",data);
    end

    wire [15:0] rdata_array[0:3];

    assign rdata_array[0] = data[pc_array[0]];
    assign rdata_array[1] = data[pc_array[1]];
    assign rdata_array[2] = data[pc_array[2]];
    assign rdata_array[3] = data[pc_array[3]];


endmodule
