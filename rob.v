`timescale 1ps/1ps

// Overflows and size calculations for head/tail just magically work.

// On cycle 0, we mark instructions as finished
// On cycle 1, we actually retire the instructions

module ROB
(input clk, 

// new instructions we're putting into ROB. Mark as invalid.
input [3:0] instructions_valid_flat,
input [15:0] new_targets_flat,
input [3:0] halt_flat,

// instructions that are finished executing
input [3:0] cdb_valid_flat,
input [15:0] indices_flat,
input [63:0] new_values_flat,
input [3:0] flush_flat,

// output the returned values of finished instructions
output [15:0]out_finished_flat,
output [255:0]out_values_flat,

// output used to write to registers
output [3:0]register_write_enable_flat,
output [15:0]register_targets_flat,
output [63:0]register_write_data_flat,
output [15:0]register_writers_flat,

// flushing ouput
output flush_pipeline,
output [15:0] pc_target, 

// always output the current size and head
output [3:0] size,
output [3:0] head);

    genvar n;
    wire instructions_valid[0:3];
    wire halt [0:3];
    wire [3:0]new_targets[0:3];
    wire cdb_valid[0:3];
    wire flush[0:3];
    wire [3:0]indices[0:3];
    wire [15:0]new_values[0:3];
    wire cdb_val_3 = cdb_valid[3];
    // unflatten input wires
    generate
        for (n=0;n<4;n=n+1) assign instructions_valid[3-n] = instructions_valid_flat[1*n+0:1*n];
        for (n=0;n<4;n=n+1) assign halt[3-n] = halt_flat[1*n+0:1*n];
        for (n=0;n<4;n=n+1) assign new_targets[3-n] = new_targets_flat[4*n+3:4*n];
        for (n=0;n<4;n=n+1) assign cdb_valid[3-n] = cdb_valid_flat[1*n+0:1*n];
        for (n=0;n<4;n=n+1) assign flush[3-n] = flush_flat[1*n+0:1*n];
        for (n=0;n<4;n=n+1) assign indices[3-n] = indices_flat[4*n+3:4*n];
        for (n=0;n<4;n=n+1) assign new_values[3-n] = new_values_flat[16*n+15:16*n];
    endgenerate

    // flatten into output wires from all output regs
    generate
        for (n=0; n<16; n=n+1) assign out_finished_flat[1*n+0:1*n] = m_finished[15-n];
        for (n=0; n<16; n=n+1) assign out_values_flat[16*n+15:16*n] = m_return_values[15-n];

        for (n=0; n<4; n=n+1) assign register_write_enable_flat[1*n+0:1*n] = m_register_write_enable[3-n];
        for (n=0; n<4; n=n+1) assign register_targets_flat[4*n+3:4*n] = m_register_targets[3-n];
        for (n=0; n<4; n=n+1) assign register_write_data_flat[16*n+15:16*n] = m_register_write_data[3-n];
        for (n=0; n<4; n=n+1) assign register_writers_flat[4*n+3:4*n] = m_register_writers[3-n];
    endgenerate

    reg [3:0] m_head = 0;
    reg [3:0] m_tail = 0;

    reg [3:0] m_target_registers[0:15];
    reg [15:0] m_return_values[0:15];
    reg m_finished[0:15];
    reg m_halt[0:15];
    reg m_flush[0:15];

    reg m_register_write_enable[0:3];
    reg [3:0] m_register_targets[0:3];
    reg [15:0] m_register_write_data[0:3];
    reg [3:0] m_register_writers[0:3];

    reg m_flush_pipeline = 0;
    reg [15:0] m_pc_target = 0;

    integer i;
    initial begin 
        for(i = 0; i < 16; i++) begin 
            m_finished[i] = 0;
            m_flush[i] = 0;
        end

        for(i = 0; i < 3; i++) begin 
            m_register_write_enable[i] = 0;
        end
    end

    assign size = m_head - m_tail;
    assign head = m_head;

    assign flush_pipeline = m_flush_pipeline;
    assign pc_target = m_pc_target;

    always @(posedge clk) begin 
        // write to registers
        for(i = 0; i < 4; i++) begin 
            if (commit[i]) begin 
                if (m_flush[m_tail + i]) begin 
                    m_flush_pipeline <= 1;
                    m_pc_target <= m_return_values[m_tail + i];
                end
                else begin 
                    m_register_write_enable[i] <= 1;
                    m_register_targets[i] <= m_target_registers[m_tail + i];
                    m_register_write_data[i] <= m_return_values[m_tail + i];
                    m_register_writers[i] <= m_tail + i;

                    m_finished[m_tail + i] <= 0;

                    if (m_target_registers[m_tail + i] == 0) begin 
                        $write("%c", m_return_values[m_tail + i]);
                    end

                    if (m_halt[m_tail + i]) begin 
                        $write("\n");
                        $finish;
                    end

                    m_flush_pipeline <= 0;
                end
            end
        end

        m_tail <= ((last_commit != 15) & m_flush[m_tail + last_commit]) ? m_head : m_tail + commit[0] + commit[1] + commit[2] + commit[3];     

        for (i = 0; i < 4; i++) begin 
            if(instructions_valid[i]) begin 
                m_finished[m_head + i] <= halt[i]; // if it's a halt, then it's finished
                m_target_registers[m_head + i] <= new_targets[i];
                m_halt[m_head + i] <= halt[i];
            end
        end
        m_head <= m_head + instructions_valid[0] + instructions_valid[1] + instructions_valid[2] + instructions_valid[3];

       // $write("%b\n", cdb_valid[0]);
        for (i = 0; i < 4; i++) begin 
           //$write("%d\n", cdb_valid[i]);

            if (cdb_valid[i]) begin 
              //$write("hello");
                //("%d\n", indices[i]);
                m_return_values[indices[i]] <= new_values[i];
                m_finished[indices[i]] <= 1;
                m_flush[i] <= flush[i];
            end
        end
    end

    wire [3:0] commit;
    assign commit[0] = m_finished[m_tail];
    assign commit[1] = commit[0] & m_finished[m_tail + 1] & ~flush[0];
    assign commit[2] = commit[0] & commit[1] & m_finished[m_tail + 2] & ~flush[1];
    assign commit[3] = commit[0] & commit[1] & commit[2] & m_finished[m_tail + 3] & ~flush[2];

    wire c0 = commit[0];
    wire c1 = commit[1];
    wire c2 = commit[2];
    wire c3 = commit[3];

    // if we're flushing, the flush instruction will always be the last commit
    wire last_commit = 
    commit[3] ? 3 : 
    commit[2] ? 2 : 
    commit[1] ? 1 : 
    commit[0] ? 0 : 15;

    wire [15:0]ret_0 = m_return_values[0];
    wire [15:0]n_0 = new_values[0];
    wire fin_0 = m_finished[0];
    wire [3:0] targ_reg_0 = m_target_registers[0];

    wire [15:0]ret_1 = m_return_values[1];
    wire [15:0]n_1 = new_values[1];
    wire fin_1 = m_finished[1];
    wire [3:0] targ_reg_1 = m_target_registers[1];

    wire [15:0]ret_2 = m_return_values[2];
    wire [15:0]n_2 = new_values[2];
    wire fin_2 = m_finished[2];
    wire [3:0] targ_reg_2 = m_target_registers[2];

    wire [15:0]ret_3 = m_return_values[3];
    wire [15:0]n_3 = new_values[3];
    wire fin_3 = m_finished[3];
    wire [3:0] targ_reg_3 = m_target_registers[3];


endmodule