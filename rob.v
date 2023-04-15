// Overflows and size calculations for head/tail just magically work.

// On cycle 0, we mark instructions as finished
// On cycle 1, we figure out which instructions to retire
// On cycle 2, we actually retire the instructions

module ROB
(input clk, 

// new instructions we're putting into ROB. Mark as invalid.
input [2:0] num_instructions,
input [3:0] new_targets[0:4],

// instructions that are finished executing
input [2:0] num_finished, 
input [3:0] indices[0:3],
input [15:0] new_values[0:3],

// output the returned values of finished instructions
output out_finished[0:15],
output [15:0] out_values[0:15],

// always output the current size
output [3:0] size);

    reg [3:0] head = 0;
    reg [3:0] tail = 0;

    reg [2:0] num_retire = 0;

    reg [3:0] target_registers[0:15];
    reg [15:0] return_values[0:15];
    reg finished[0:15];
    integer i;
    initial begin 
        for(i = 0; i < 16; i++) begin 
            finished[i] = 0;
        end
    end

    assign out_finished = finished;
    assign out_values = return_values;

    assign size = head - tail;

    always @(posedge clk) begin 
        for(i = 0; i < num_retire; i++) begin 
            // write to registers
        end

        tail <= tail + num_retire;

        // can probably make this more efficient with a tree thing
        // retire max of 3 instructions per cycle
        num_retire <=
        //finished[tail] && finished[tail + 1] && finished[tail + 2] && finished[tail + 3] && finished[tail = 4] ? 5 : 
        //finished[tail] && finished[tail + 1] && finished[tail + 2] && finished[tail + 3] ? 4 : 
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