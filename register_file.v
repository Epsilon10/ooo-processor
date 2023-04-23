`timescale 1ps/1ps

module RegisterFile
(input clk, 

// READ PORT 1 for instruction fetcher
input [15:0]instr_buffer_read_addr_flat, 
output [63:0] read_data_value_flat, 
output [3:0]  read_data_busy_flat, 
output [15:0] read_data_owner_flat,

// READ PORT 2 for instruciton fetcher
input  [15:0] instr_buffer_read_addr_2_flat, 
output [63:0] read_data_value_2_flat, 
output [3:0]  read_data_busy_2_flat , 
output [15:0] read_data_owner_2_flat,

// WRITE PORT 1
input [3:0]retirement_write_data_enable_flat, 
input [15:0]retirement_target_reg_flat, 
input [63:0]retirement_write_data_flat, 
input [15:0]instruction_writer_flat,

// WRITE PORT 2 (for instruction buffer)
input [3:0] rt_update_enable_flat,
input [15:0] rt_target_reg_flat,
input [15:0] rt_owner_flat
);


    genvar n;
    wire [3:0]instr_buffer_read_addr[0:3];
    wire [3:0]instr_buffer_read_addr_2[0:3];
    wire retirement_write_data_enable[0:3];
    wire [3:0]retirement_target_reg[0:3];
    wire [15:0]retirement_write_data[0:3];
    wire [3:0]instruction_writer[0:3];

    wire rt_update_enable[0:3];
    wire [3:0] rt_target_reg[0:3];
    wire [3:0] rt_owner[0:3];

    // unflatten input wires
    generate
        for (n=0;n<4;n=n+1) assign instr_buffer_read_addr[3-n] = instr_buffer_read_addr_flat[4*n+3:4*n];
        for (n=0;n<4;n=n+1) assign instr_buffer_read_addr_2[3-n] = instr_buffer_read_addr_2_flat[4*n+3:4*n];
        for (n=0;n<4;n=n+1) assign retirement_write_data_enable[3-n] = retirement_write_data_enable_flat[1*n+0:1*n];
        for (n=0;n<4;n=n+1) assign retirement_target_reg[3-n] = retirement_target_reg_flat[4*n+3:4*n];
        for (n=0;n<4;n=n+1) assign retirement_write_data[3-n] = retirement_write_data_flat[16*n+15:16*n];
        for (n=0;n<4;n=n+1) assign instruction_writer[3-n] = instruction_writer_flat[4*n+3:4*n];

        for (n=0;n<4;n=n+1) assign rt_update_enable[3-n] = rt_update_enable_flat[1*n+0:1*n];
        for (n=0;n<4;n=n+1) assign rt_target_reg[3-n] = rt_target_reg_flat[4*n+3:4*n];
        for (n=0;n<4;n=n+1) assign rt_owner[3-n] = rt_owner_flat[4*n+3:4*n];

    endgenerate

    // flatten into output wires from all output regs
    generate
        for (n=0; n<4; n=n+1) assign read_data_value_flat [16*n+15:16*n] = m_read_data_value[3-n];
        for (n=0; n<4; n=n+1) assign read_data_busy_flat  [1*n+0:1*n]    = m_read_data_busy[3-n];
        for (n=0; n<4; n=n+1) assign read_data_owner_flat [4*n+3:4*n]    = m_read_data_owner[3-n];

        for (n=0; n<4; n=n+1) assign read_data_value_2_flat[16*n+15:16*n] = m_read_data_value_2[3-n];
        for (n=0; n<4; n=n+1) assign read_data_busy_2_flat [1*n+0:1*n]    = m_read_data_busy_2[3-n];
        for (n=0; n<4; n=n+1) assign read_data_owner_2_flat[4*n+3:4*n]    = m_read_data_owner_2[3-n];
    endgenerate

    reg [15:0] values[0:15];
    reg busy[0:15];
    reg [3:0] owner[0:15];

    reg [15:0] m_read_data_value[0:3];
    reg m_read_data_busy[0:3];
    reg [3:0] m_read_data_owner[0:3];

    reg [15:0] m_read_data_value_2[0:3];
    reg m_read_data_busy_2[0:3];
    reg [3:0] m_read_data_owner_2[0:3];

    initial begin
        integer i;
        for (i = 0; i < 16; i++) begin
            busy[i] = 0;
        end

        values[5] = 70;
        values[2] = 0;
    end

    always @(posedge clk) begin
        integer i;

        // read 1
        for (i = 0; i < 4; i++) begin
            m_read_data_value[i] <= instr_buffer_read_addr[i] == 0 ? 0 : values[instr_buffer_read_addr[i]];
            m_read_data_busy[i] <= busy[instr_buffer_read_addr[i]];
            m_read_data_owner[i] <= owner[instr_buffer_read_addr[i]];
        end

        // read 2
        for (i = 0; i < 4; i++) begin
            m_read_data_value_2[i] <= instr_buffer_read_addr_2[i] == 0 ? 0 : values[instr_buffer_read_addr_2[i]];
            m_read_data_busy_2[i] <= busy[instr_buffer_read_addr_2[i]];
            m_read_data_owner_2[i] <= owner[instr_buffer_read_addr_2[i]];
        end

        // write
        for (i = 0; i < 4; i++) begin
            if (retirement_write_data_enable[i]) begin
                values[retirement_target_reg[i]] <= retirement_write_data[i];

                // TODO: make sure commit does not overwrite register file busy!!!!
                if (m_read_data_owner[retirement_target_reg[i]] == instruction_writer[i]) begin 
                    m_read_data_busy[retirement_target_reg[i]] <= 0;
                end
            end
        end
    end

endmodule