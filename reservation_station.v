`timescale 1ps/1ps

module ReservationStation(input clk, 
    input wen, input is_functional_unit_busy, 
    input [3:0]instr_index, input [15:0]instr_full, input [3:0]in_op1, input [3:0]in_op2, input [15:0]in_val1, input [15:0]in_val2, input is_val_op1, input is_val_op2,
    output [3:0]out_instr_index, output [15:0]out_instr_full, output out_valid,
    output [15:0]out_val1, output [15:0]out_val2, output write_failed, output is_full,
    // common data bus input
    input cdb_valid[0:3], input [3:0]cdb_rob_index [0:3], input [15:0] cdb_result [0:3]
    );
    // if the instruction only has one operand, pass in a value for the second one and set is_val_op2 to true

    reg [15:0]instruction_indices[3:0]; // holds instruction address in ROB
    reg [15:0]instructions[3:0]; // holds 16-bit full instruction
    reg instruction_valid[3:0];  // does this row actually represent an instruction or is it empty?
    reg [3:0]op1[3:0];   // store owner of operand 1 register
    reg op1_valid[3:0];  // set to true once op1 resolves to a value
    reg [15:0]val1[3:0]; // store resolved value of operand 1
    reg [3:0]op2[3:0];   // store owner of operand 2 register
    reg op2_valid[3:0];  // set to true once op2 resolves to a value
    reg [15:0]val2[3:0]; // store resolved value of operand 2

    // output an instruction that is ready if stage 1 of the functional unit isn't busy
    reg [3:0] out_instr_index_reg; // instruction address in ROB
    reg [15:0]out_instr_full_reg; // the instruction itself
    reg       out_valid_reg;            // is this an actual output
    reg [15:0]out_val1_reg;       // resolved value of operand 1
    reg [15:0]out_val2_reg;       // resolved value of operand 2

    // is reservation station full when trying to write versus in general
    reg write_failed_reg = 0;
    reg is_full_reg = 0;

    assign out_instr_index = out_instr_index_reg;
    assign out_instr_full = out_instr_full_reg;
    assign out_valid = out_valid_reg;
    assign out_val1 = out_val1_reg;
    assign out_val2 = out_val2_reg;
    
    assign write_failed = write_failed_reg;
    assign is_full = is_full_reg;

    always @(posedge clk) begin
        // write an instruction to a free spot in the reservation station
        if (wen & ~instruction_valid[2'b00]) begin
            instruction_valid[2'b00] <= 1;
            instructions[2'b00] <= instr_full;
            instruction_indices[2'b00] <= instr_index;

            op1[2'b00] <= in_op1;
            op2[2'b00] <= in_op2;

            val1[2'b00] <= in_val1;
            val2[2'b00] <= in_val2;

            op1_valid[2'b00] <= is_val_op1;
            op2_valid[2'b00] <= is_val_op2;

            write_failed_reg <= 0;
        end
        else if (wen & ~instruction_valid[2'b01]) begin
            instruction_valid[2'b01] <= 1;
            instructions[2'b01] <= instr_full;
            instruction_indices[2'b01] <= instr_index;

            op1[2'b01] <= in_op1;
            op2[2'b01] <= in_op2;

            val1[2'b01] <= in_val1;
            val2[2'b01] <= in_val2;

            op1_valid[2'b01] <= is_val_op1;
            op2_valid[2'b01] <= is_val_op2;

            write_failed_reg <= 0;
        end
        else if (wen & ~instruction_valid[2'b10]) begin
            instruction_valid[2'b10] <= 1;
            instructions[2'b10] <= instr_full;
            instruction_indices[2'b10] <= instr_index;

            op1[2'b10] <= in_op1;
            op2[2'b10] <= in_op2;

            val1[2'b10] <= in_val1;
            val2[2'b10] <= in_val2;

            op1_valid[2'b10] <= is_val_op1;
            op2_valid[2'b10] <= is_val_op2;

            write_failed_reg <= 0;
        end
        else if (wen & ~instruction_valid[2'b11]) begin
            instruction_valid[2'b11] <= 1;
            instructions[2'b11] <= instr_full;
            instruction_indices[2'b11] <= instr_index;

            op1[2'b11] <= in_op1;
            op2[2'b11] <= in_op2;

            val1[2'b11] <= in_val1;
            val2[2'b11] <= in_val2;

            op1_valid[2'b11] <= is_val_op1;
            op2_valid[2'b11] <= is_val_op2;

            write_failed_reg <= 0;
        end
        else if (wen) begin
            write_failed_reg <= 1;
        end

        is_full_reg <= instruction_valid[0] & instruction_valid[1] & instruction_valid[2] & instruction_valid[3];

        // update any operands which aren't ready if common data bus has value  
        for(integer i = 0; i < 4; i = i + 1) begin
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
        if (~is_functional_unit_busy & instruction_valid[2'b00] & op1_valid[2'b00] & op2_valid[2'b00]) begin
            instruction_valid[2'b00] <= 0;
            out_instr_index_reg <= instruction_indices[2'b00];
            out_instr_full_reg <= instructions[2'b00]; 
            out_valid_reg <= 1;      
            out_val1_reg <= val1[2'b00];       
            out_val2_reg <= val2[2'b00];
        end
        else if (~is_functional_unit_busy & instruction_valid[2'b01] & op1_valid[2'b01] & op2_valid[2'b01]) begin
            instruction_valid[2'b01] <= 0;
            out_instr_index_reg <= instruction_indices[2'b01];
            out_instr_full_reg <= instructions[2'b01]; 
            out_valid_reg <= 1;      
            out_val1_reg <= val1[2'b01];       
            out_val2_reg <= val2[2'b01];
        end
        else if (~is_functional_unit_busy & instruction_valid[2'b10] & op1_valid[2'b10] & op2_valid[2'b10]) begin
            instruction_valid[2'b10] <= 0;
            out_instr_index_reg <= instruction_indices[2'b10];
            out_instr_full_reg <= instructions[2'b10]; 
            out_valid_reg <= 1;      
            out_val1_reg <= val1[2'b10];       
            out_val2_reg <= val2[2'b10];
        end
        else if (~is_functional_unit_busy & instruction_valid[2'b11] & op1_valid[2'b11] & op2_valid[2'b11]) begin
            instruction_valid[2'b11] <= 0;
            out_instr_index_reg <= instruction_indices[2'b11];
            out_instr_full_reg <= instructions[2'b11]; 
            out_valid_reg <= 1;      
            out_val1_reg <= val1[2'b11];       
            out_val2_reg <= val2[2'b11];
        end
        else begin
            out_valid_reg <= 0;
        end
    end

endmodule
