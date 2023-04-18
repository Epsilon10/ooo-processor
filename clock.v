`timescale 1ps/1ps
module Clock(output clk);

    reg theClock = 1;
    assign clk = theClock;
    
    always begin
        #500;
        theClock = !theClock;
    end
endmodule