module register_file
(input clk, 
    // READ PORT
input [3:0] instr_buffer_read_addr[0:7], input instru_buffer_read_enable[0:7], output [20:0] instr_buffer_read_data[0:7],

    // WRITE PORT
input [19:0] retirement_write_data[0:2], input retirement_write_data_enable[0:2]
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
            if (instru_buffer_read_enable[i])
                m_instr_buffer_read_data[i] <= {values[instr_buffer_read_addr[i]], busy[instr_buffer_read_addr[i]], owner[instr_buffer_read_addr[i]]};
        end

        for (j = 0; j < 3; j++) begin
            if (retirement_write_data_enable[j])
                values[retirement_write_data[j][3:0]] <= retirement_write_data[j][19:4];
        end
    end

endmodule


