`timescale 1ps/1ps

module InstructionCache
(input clk,
input [15:1] pc_array[0:3],
output [15:0] instructions[0:3]);

    reg [15:0] data[0:16'h7fff];

    /* Simulation -- read initial content from file */
    initial begin
        $readmemh("instructions.hex",data);
    end

    reg [15:1] raddr_array[0:3];
    reg [15:0] rdata_array[0:3];

    assign instructions = rdata_array;

    always @(posedge clk) begin
        // you'd think there would be better syntax for this...
        raddr_array[0] <= pc_array[0];
        raddr_array[1] <= pc_array[1];
        raddr_array[2] <= pc_array[2];
        raddr_array[3] <= pc_array[3];

        rdata_array[0] <= data[raddr_array[0]];
        rdata_array[1] <= data[raddr_array[1]];
        rdata_array[2] <= data[raddr_array[2]];
        rdata_array[3] <= data[raddr_array[3]];
    end

endmodule
