module register_file(input clk, 
    // READ PORT
    input [3:0]instr_buffer_read_addr [7:0], output [20:0]instr_buffer_read_data [7:0],

    // WRITE PORT
    input [20:0]retirement_write_data [2:0]
);

    reg [15:0] values[15:0];
    reg busy[15:0];
    reg [3:0] owner[15:0];

    reg [20:0]m_instr_buffer_read_data [7:0];

    assign instr_buffer_read_addr = m_instr_buffer_read_data;

    always @(posedge clk) begin
        // read
        integer i;
        integer j;

        for (i = 0; i < 8; i++) begin
            m_instr_buffer_read_data[i] <= {values[instr_buffer_read_addr[i]], busy[instr_buffer_read_addr[i]], owner[instr_buffer_read_addr[i]]};
        end

        for (j = 0; j < 3; j++) begin
            if (retirement_write_data[j][0]) begin
                values[retirement_write_data[j][4:1]] <= retirement_write_data[j][20:5];
            end 
        end
    end

endmodule


