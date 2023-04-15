// Overflows and size calculations for head/tail just magically work.

// On cycle 0, we mark instructions as finished
// On cycle 1, we actually retire the instructions

module ROB
(input clk, 

// new instructions we're putting into ROB. Mark as invalid.
input [2:0] num_instructions,
input [3:0] new_targets[0:4],

// instructions that are finished executing
input [2:0] num_finished, 
input [3:0] indices[0:3],
input [15:0] new_values[0:3],

// register table
input register_file,

// output the returned values of finished instructions
output out_finished[0:15],
output [15:0] out_values[0:15],

// output used to write to registers
output register_write_enable[0:3],
output [3:0] register_targets[0:3],
output [15:0] register_write_data[0:3],
output [3:0] register_writers[0:3],


// always output the current size
output [3:0] size);

    reg [3:0] head = 0;
    reg [3:0] tail = 0;

    reg [3:0] target_registers[0:15];
    reg [15:0] return_values[0:15];
    reg finished[0:15];
    integer i;
    initial begin 
        for(i = 0; i < 16; i++) begin 
            finished[i] = 0;
        end

        for(i = 0; i < 3; i++) begin 
            register_write_enable[i] = 0;
        end
    end

    assign out_finished = finished;
    assign out_values = return_values;

    assign size = head - tail;

    always @(posedge clk) begin 
        // write to registers
        for(i = 0; i < 4; i++) begin 
            if (finished[tail + i]) begin 
                register_write_enable[i] <= 1;
                register_targets[i] <= tail + i;
                register_write_data[i] <= return_values[tail + i];
                register_writers[i] <= tail + i;
            end
        end

        tail <= tail +
        finished[tail] && finished[tail + 1] && finished[tail + 2] && finished[tail + 3] ? 4 : 
        finished[tail] && finished[tail + 1] && finished[tail + 2] ? 3 : 
        finished[tail] && finished[tail + 1] ? 2 : 
        finished[tail] ? 1 :
        0;        

        for (i = 0; i < num_instructions; i++) begin 
            finished[head + i] <= 0;
            target_registers[head + i] <= new_targets[i];
        end
        head <= head + num_instructions;

        for (i = 0; i < num_finished; i++) begin 
            return_values[indices[i]] <= new_values[i];
            finished[indices[i]] <= 1;
        end
    end

endmodule