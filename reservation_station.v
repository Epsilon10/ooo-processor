`timescale 1ps/1ps

module ReservationStation(input clk, 
    input wen, 
    input [3:0]instr_index, input [3:0]instr_opcode, input [7:0]instr_i, input [3:0]in_op1, input [3:0]in_op2, input [15:0]in_val1, input [15:0]in_val2, input is_val_op1, input is_val_op2,
    output [3:0]out_instr_index, output [3:0]out_opcode, output [7:0]out_i, output out_valid,
    output [15:0]out_val1, output [15:0]out_val2, output is_full,
    // common data bus input
    input [3:0]cdb_valid_flat, input [15:0]cdb_rob_index_flat, input [63:0]cdb_result_flat
    );
    // if the instruction only has one operand, pass in a value for the second one and set is_val_op2 to true
    genvar n;
    wire cdb_valid[0:3];
    wire [3:0]cdb_rob_index[0:3];
    wire [15:0]cdb_result[0:3];
    generate
        for (n=0;n<4;n=n+1) assign cdb_valid[3-n] = cdb_valid_flat[1*n+0:1*n];
        for (n=0;n<4;n=n+1) assign cdb_rob_index[3-n] = cdb_rob_index_flat[4*n+3:4*n];
        for (n=0;n<4;n=n+1) assign cdb_result[3-n] = cdb_result_flat[16*n+15:16*n];
    endgenerate




    reg [15:0]instruction_indices[0:3]; // holds instruction address in ROB
    reg [3:0]instr_opcodes[0:3]; // holds 4-bit instruction opcodes
    reg [7:0]instr_i_values[0:3];     // holds immediate value for 
    reg instruction_valid[0:3];  // does this row actually represent an instruction or is it empty?
    initial begin
        instruction_valid[0] = 0;
        instruction_valid[1] = 0;
        instruction_valid[2] = 0;
        instruction_valid[3] = 0;
    end
    reg [3:0]op1[0:3];   // store owner of operand 1 register
    reg op1_valid[0:3];  // set to true once op1 resolves to a value
    reg [15:0]val1[0:3]; // store resolved value of operand 1
    reg [3:0]op2[0:3];   // store owner of operand 2 register
    reg op2_valid[0:3];  // set to true once op2 resolves to a value
    reg [15:0]val2[0:3]; // store resolved value of operand 2

    // output an instruction that is ready if stage 1 of the functional unit isn't busy (which it never is because it's pipelined)
    reg [3:0] out_instr_index_reg; // instruction address in ROB
    reg [3:0] out_opcode_reg; // the instruction itself
    reg [7:0] out_i_reg;      // immediate value if needed
    reg       out_valid_reg;            // is this an actual output
    reg [15:0]out_val1_reg;       // resolved value of operand 1
    reg [15:0]out_val2_reg;       // resolved value of operand 2

    // is reservation station full when trying to write versus in general
    reg is_full_reg = 0;

    assign out_instr_index = out_instr_index_reg;
    assign out_opcode = out_opcode_reg;
    assign out_i = out_i_reg;
    assign out_valid = out_valid_reg;
    assign out_val1 = out_val1_reg;
    assign out_val2 = out_val2_reg;
    
    assign is_full = is_full_reg;

    integer i;
    wire i0_valid = instruction_valid[2'b00];
    wire [3:0] i0_opcode = instr_opcodes[0];
    wire i0_op1_valid = op1_valid[0];
    wire i0_op2_valid = op2_valid[0];
    always @(posedge clk) begin
        // write an instruction to a free spot in the reservation station
        if (wen & ~instruction_valid[2'b00]) begin
            instruction_valid[2'b00] <= 1;
            instr_opcodes[2'b00] <= instr_opcode;
            instr_i_values[2'b00] <= instr_i;
            instruction_indices[2'b00] <= instr_index;

            op1[2'b00] <= in_op1;
            op2[2'b00] <= in_op2;

            val1[2'b00] <= in_val1;
            val2[2'b00] <= in_val2;

            op1_valid[2'b00] <= is_val_op1;
            op2_valid[2'b00] <= is_val_op2;
        end
        else if (wen & ~instruction_valid[2'b01]) begin
            instruction_valid[2'b01] <= 1;
            instr_opcodes[2'b01] <= instr_opcode;
            instr_i_values[2'b01] <= instr_i;
            instruction_indices[2'b01] <= instr_index;

            op1[2'b01] <= in_op1;
            op2[2'b01] <= in_op2;

            val1[2'b01] <= in_val1;
            val2[2'b01] <= in_val2;

            op1_valid[2'b01] <= is_val_op1;
            op2_valid[2'b01] <= is_val_op2;
        end
        else if (wen & ~instruction_valid[2'b10]) begin
            instruction_valid[2'b10] <= 1;
            instr_opcodes[2'b10] <= instr_opcode;
            instr_i_values[2'b10] <= instr_i;
            instruction_indices[2'b10] <= instr_index;

            op1[2'b10] <= in_op1;
            op2[2'b10] <= in_op2;

            val1[2'b10] <= in_val1;
            val2[2'b10] <= in_val2;

            op1_valid[2'b10] <= is_val_op1;
            op2_valid[2'b10] <= is_val_op2;
        end
        else if (wen & ~instruction_valid[2'b11]) begin
            instruction_valid[2'b11] <= 1;
            instr_opcodes[2'b11] <= instr_opcode;
            instr_i_values[2'b11] <= instr_i;
            instruction_indices[2'b11] <= instr_index;

            op1[2'b11] <= in_op1;
            op2[2'b11] <= in_op2;

            val1[2'b11] <= in_val1;
            val2[2'b11] <= in_val2;

            op1_valid[2'b11] <= is_val_op1;
            op2_valid[2'b11] <= is_val_op2;
        end

        is_full_reg <= instruction_valid[0] & instruction_valid[1] & instruction_valid[2] & instruction_valid[3];

        // update any operands which aren't ready if common data bus has value  
        for(i = 0; i < 4; i = i + 1) begin
            if (instruction_valid[i] & ~op1_valid[i] & cdb_valid[0] & (cdb_rob_index[0] == op1[i])) begin
                val1[i] <= cdb_result[0];
                op1_valid[i] <= 1;
            end
            else if (instruction_valid[i] & ~op1_valid[i] & cdb_valid[1] & (cdb_rob_index[1] == op1[i])) begin
                val1[i] <= cdb_result[1];
                op1_valid[i] <= 1;
            end
            else if (instruction_valid[i] & ~op1_valid[i] & cdb_valid[2] & (cdb_rob_index[2] == op1[i])) begin
                val1[i] <= cdb_result[2];
                op1_valid[i] <= 1;
            end
            else if (instruction_valid[i] & ~op1_valid[i] & cdb_valid[3] & (cdb_rob_index[3] == op1[i])) begin
                val1[i] <= cdb_result[3];
                op1_valid[i] <= 1;
            end


            if (instruction_valid[i] & ~op2_valid[i] & cdb_valid[0] & (cdb_rob_index[0] == op2[i])) begin
                val2[i] <= cdb_result[0];
                op2_valid[i] <= 1;
            end
            else if (instruction_valid[i] & ~op2_valid[i] & cdb_valid[1] & (cdb_rob_index[1] == op2[i])) begin
                val2[i] <= cdb_result[1];
                op2_valid[i] <= 1;
            end
            else if (instruction_valid[i] & ~op2_valid[i] & cdb_valid[2] & (cdb_rob_index[2] == op2[i])) begin
                val2[i] <= cdb_result[2];
                op2_valid[i] <= 1;
            end
            else if (instruction_valid[i] & ~op2_valid[i] & cdb_valid[3] & (cdb_rob_index[3] == op2[i])) begin
                val2[i] <= cdb_result[3];
                op2_valid[i] <= 1;
            end
        end
        

        // output next ready instruction
        if (instruction_valid[2'b00] & op1_valid[2'b00] & op2_valid[2'b00]) begin
            instruction_valid[2'b00] <= 0;
            out_instr_index_reg <= instruction_indices[2'b00];
            out_opcode_reg <= instr_opcodes[2'b00]; 
            out_i_reg <= instr_i_values[2'b00];
            out_valid_reg <= 1;      
            out_val1_reg <= val1[2'b00];       
            out_val2_reg <= val2[2'b00];
        end
        else if (instruction_valid[2'b01] & op1_valid[2'b01] & op2_valid[2'b01]) begin
            instruction_valid[2'b01] <= 0;
            out_instr_index_reg <= instruction_indices[2'b01];
            out_opcode_reg <= instr_opcodes[2'b01]; 
            out_i_reg <= instr_i_values[2'b01];
            out_valid_reg <= 1;      
            out_val1_reg <= val1[2'b01];       
            out_val2_reg <= val2[2'b01];
        end
        else if (instruction_valid[2'b10] & op1_valid[2'b10] & op2_valid[2'b10]) begin
            instruction_valid[2'b10] <= 0;
            out_instr_index_reg <= instruction_indices[2'b10];
            out_opcode_reg <= instr_opcodes[2'b10]; 
            out_i_reg <= instr_i_values[2'b10];
            out_valid_reg <= 1;      
            out_val1_reg <= val1[2'b10];       
            out_val2_reg <= val2[2'b10];
        end
        else if (instruction_valid[2'b11] & op1_valid[2'b11] & op2_valid[2'b11]) begin
            instruction_valid[2'b11] <= 0;
            out_instr_index_reg <= instruction_indices[2'b11];
            out_opcode_reg <= instr_opcodes[2'b11]; 
            out_i_reg <= instr_i_values[2'b11];
            out_valid_reg <= 1;      
            out_val1_reg <= val1[2'b11];       
            out_val2_reg <= val2[2'b11];
        end
        else begin
            out_valid_reg <= 0;
        end
    end

endmodule
