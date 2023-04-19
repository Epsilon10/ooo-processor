`timescale 1ps/1ps

module Main;

    initial begin 
        $dumpfile("cpu.vcd");
        $dumpvars(0, main);
    end

    wire clk;
    Clock c0(clk);

    

endmodule