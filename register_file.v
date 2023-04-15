module register_file
(input clk, 
    // READ PORT for instruction buffer
input [3:0] instr_buffer_read_addr[0:7], input instru_buffer_read_enable[0:7], output [15:0] read_data_value[0:7], output read_data_busy[0:7], output [3:0] read_data_owner[0:7],

    // WRITE PORT
input retirement_write_data_enable[0:2], input [15:0] retirement_write_data[0:2], input [3:0] retirement_target_reg[0:2]
);

    reg [15:0] values[0:15];
    reg busy[0:15];
    reg [3:0] owner[0:15];

    reg [15:0] m_read_data_value[0:7];
    reg m_read_data_busy[0:7];
    reg [3:0] m_read_data_owner[0:7];


    assign read_data_value = m_read_data_value;
    assign read_data_busy = m_read_data_busy;
    assign read_data_owner = m_read_data_owner;

    always @(posedge clk) begin
        // read
        integer i;
        integer j;

        for (i = 0; i < 8; i++) begin
            if (instru_buffer_read_enable[i]) begin
                m_read_data_value[i] <= values[instr_buffer_read_addr[i]];
                m_read_data_busy[i] <= busy[instr_buffer_read_addr[i]];
                m_read_data_owner[i] <= owner[instr_buffer_read_addr[i]];
            end
        end

        for (j = 0; j < 3; j++) begin
            if (retirement_write_data_enable[j])
                values[retirement_target_reg[j]] <= retirement_write_data[j];
        end
    end

endmodule


