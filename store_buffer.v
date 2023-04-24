module StoreBuffer
(input clk,
input in_valid, input [15:0] in_address, input [7:0] in_value,
output wen, output [15:0] out_addr, output [7:0] out_data,
output [256:0] out_addresses_flat, output [128:0] out_values_flat, output [16:0] out_retired_flat); 
    
    reg [3:0] head = 0;
    reg [3:0] tail = 0;

    reg [15:0] m_addresses[0:15];
    reg [7:0] m_values[0:15];
    reg m_retired[0:15];

    reg m_wen;
    reg [15:0] m_out_addr;
    reg [7:0] m_out_data;

    assign wen = m_wen;
    assign out_addr = m_out_addr;
    assign out_data = m_out_data;
    
    // siddh pls flatten the outputs lol

    always @(posedge clk) begin 
        if (in_valid) begin 
            m_addresses[head] <= in_address;
            m_values[head] <= in_value;
            m_retired[head] <= 0;
            head <= head + 1;
        end

        if(m_retired[tail]) begin 
            m_wen <= 1;
            m_out_addr <= m_addresses[tail];
            m_out_data <= m_out_data[tail];
            tail <= tail + 1;
        end
        else begin 
            m_wen <= 0;
        end
    end

endmodule