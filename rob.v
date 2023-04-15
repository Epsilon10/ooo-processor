// Overflows and size calculations for m_head/m_tail just magically work.

// On cycle 0, we mark instructions as m_finished
// On cycle 1, we actually retire the instructions

module ROB
(input clk, 

// new instructions we're putting into ROB. Mark as invalid.
input instructions_valid[0:3],
input [3:0] new_targets[0:3],

// instructions that are m_finished executing
input cdb_valid[0:3],
input [3:0] indices[0:3],
input [15:0] new_values[0:3],

// output the returned values of m_finished instructions
output out_finished[0:15],
output [15:0] out_values[0:15],

// output used to write to registers
output register_write_enable[0:3],
output [3:0] register_targets[0:3],
output [15:0] register_write_data[0:3],
output [3:0] register_writers[0:3],

// always output the current size
output [3:0] size);

    reg [3:0] m_head = 0;
    reg [3:0] m_tail = 0;

    reg [3:0] m_target_registers[0:15];
    reg [15:0] m_return_values[0:15];
    reg m_finished[0:15];

    reg m_register_write_enable[0:3];
    reg [3:0] m_register_targets[0:3];
    reg [15:0] m_register_write_data[0:3];
    reg [3:0] m_register_writers[0:3];

    integer i;
    initial begin 
        for(i = 0; i < 16; i++) begin 
            m_finished[i] = 0;
        end

        for(i = 0; i < 3; i++) begin 
            m_register_write_enable[i] = 0;
        end
    end

    assign out_finished = m_finished;
    assign out_values = m_return_values;

    assign register_write_enable = m_register_write_enable;
    assign register_targets = m_register_targets;
    assign register_write_data = m_register_write_data;
    assign register_writers = m_register_writers;

    assign size = m_head - m_tail;

    always @(posedge clk) begin 
        // write to registers
        for(i = 0; i < 4; i++) begin 
            if (m_finished[m_tail + i]) begin 
                m_register_write_enable[i] <= 1;
                m_register_targets[i] <= m_tail + i;
                m_register_write_data[i] <= m_return_values[m_tail + i];
                m_register_writers[i] <= m_tail + i;
            end
        end

        m_tail <= m_tail +
        m_finished[m_tail] && m_finished[m_tail + 1] && m_finished[m_tail + 2] && m_finished[m_tail + 3] ? 4 : 
        m_finished[m_tail] && m_finished[m_tail + 1] && m_finished[m_tail + 2] ? 3 : 
        m_finished[m_tail] && m_finished[m_tail + 1] ? 2 : 
        m_finished[m_tail] ? 1 :
        0;        

        for (i = 0; i < 4; i++) begin 
            if(instructions_valid[i]) begin 
                m_finished[m_head + i] <= 0;
                m_target_registers[m_head + i] <= new_targets[i];
            end
        end
        m_head <= m_head + instructions_valid[0] + instructions_valid[1] + instructions_valid[2] + instructions_valid[3];

        for (i = 0; i < 4; i++) begin 
            if (cdb_valid[i]) begin 
                m_return_values[indices[i]] <= new_values[i];
                m_finished[indices[i]] <= 1;
            end
        end
    end

endmodule