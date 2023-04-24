module LSU
(input clk,
input in_valid, 
input [14:0] pc, input [15:0] va, input [3:0] in_rob_index,
input [7:0] l1_out, input [7:0] memory_out,
output [15:0] l1_read_port, input [15:0] memory_read_port,
output out_valid, output [3:0] out_rob_index, output [15:0] out_return_value);

    reg [5:0] count_target = 100;
    reg [5:0] count = 0;
    reg m_valid = 0;

    assign l1_read_port = va;
    assign memory_read_port = va;

    assign out_return_value = count_target == 100 ? memory_read_port : l1_read_port;
    assign out_rob_index = in_rob_index;
    assign out_valid = m_valid;

    always @(posedge clk) begin 
        // new load
        if (in_valid) begin 
            // cheat hash function where we just look at the lower 2 bits of the pc
            // every 4th instruction, they should be 00 - 25% chance
            count_target <= pc[2] == 0 && pc[1] == 0 ? 100 : 2;
            count <= 0;
        end
        count <= count + 1;

        if(count == count_target) begin 
            m_valid <= 1;
        end
    end

endmodule