// issue: how do we actually modify register values in the table
// solution: maybe have the register table be an input?

// I assume size of ROB is 16

module ROB
(input clk, 
input [15:0] instruction, // puts new instruction in ROB
input finish_instruction, input [3:0] index, input [15:0] value, // update these when an instruction finishes executing
output [3:0] size); // always output our size

    reg [3:0] head = 0;
    reg [3:0] tail = 0;

    reg [15:0] instructions[0:15];
    reg [15:0] values[0:15];
    reg retired[0:15];

    always @(posedge clk) begin 
        instructions[tail] <= instruction;
        retired[tail] <= 0;
        tail <= tail + 1; // will overflow correctly

        if (finish_instruction) begin 
            retired[index] <= 1;
            values[index] <= value;

            if (index == head) begin
                head <= head + 1;
                // TODO: update register table
            end
        end
    end

endmodule 