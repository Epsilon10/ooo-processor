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


    reg [15:0] data[0:16'h7fff];

    /* Simulation -- read initial content from file */
    initial begin
        $readmemh("instructions.hex",data);
    end

    reg [15:0] rdata_array[0:3];


    always @(posedge clk) begin
        rdata_array[0] <= data[pc_array[0]];
        rdata_array[1] <= data[pc_array[1]];
        rdata_array[2] <= data[pc_array[2]];
        rdata_array[3] <= data[pc_array[3]];
    end

endmodule
