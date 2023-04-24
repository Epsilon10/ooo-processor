`timescale 1ps/1ps

module L1Cache
(input clk,
input [15:0] read_addr,
output [7:0] data_out);

    reg [7:0] data[0:16'hffff];

    initial begin
        $readmemh("mem.hex", data);
    end

    reg [7:0] m_data;
    reg [15:0] m_read_addr;

    assign data_out = m_data;

    always @(posedge clk) begin
        m_read_addr <= read_addr;
        m_data <= data[m_read_addr];
    end

endmodule
