`timescale 1ps/1ps

// memory that is 100 cycles delayed
// same as pipeline memory but scaled up to 100 cycles

module DataMemory
(input clk,
input [15:0]raddr, output [7:0]rdata,
input wen, input [15:0]waddr, input [7:0]wdata);

    reg [7:0]data[0:16'hffff];

    /* Simulation -- read initial content from file */
    initial begin
        $readmemh("mem.hex",data);
    end

    reg [7:0] raddr0;
    reg [7:0] raddr1;
    reg [7:0] raddr2;
    reg [7:0] raddr3;
    reg [7:0] raddr4;
    reg [7:0] raddr5;
    reg [7:0] raddr6;
    reg [7:0] raddr7;
    reg [7:0] raddr8;
    reg [7:0] raddr9;
    reg [7:0] raddr10;
    reg [7:0] raddr11;
    reg [7:0] raddr12;
    reg [7:0] raddr13;
    reg [7:0] raddr14;
    reg [7:0] raddr15;
    reg [7:0] raddr16;
    reg [7:0] raddr17;
    reg [7:0] raddr18;
    reg [7:0] raddr19;
    reg [7:0] raddr20;
    reg [7:0] raddr21;
    reg [7:0] raddr22;
    reg [7:0] raddr23;
    reg [7:0] raddr24;
    reg [7:0] raddr25;
    reg [7:0] raddr26;
    reg [7:0] raddr27;
    reg [7:0] raddr28;
    reg [7:0] raddr29;
    reg [7:0] raddr30;
    reg [7:0] raddr31;
    reg [7:0] raddr32;
    reg [7:0] raddr33;
    reg [7:0] raddr34;
    reg [7:0] raddr35;
    reg [7:0] raddr36;
    reg [7:0] raddr37;
    reg [7:0] raddr38;
    reg [7:0] raddr39;
    reg [7:0] raddr40;
    reg [7:0] raddr41;
    reg [7:0] raddr42;
    reg [7:0] raddr43;
    reg [7:0] raddr44;
    reg [7:0] raddr45;
    reg [7:0] raddr46;
    reg [7:0] raddr47;
    reg [7:0] raddr48;
    reg [7:0] raddr49;
    reg [7:0] raddr50;
    reg [7:0] raddr51;
    reg [7:0] raddr52;
    reg [7:0] raddr53;
    reg [7:0] raddr54;
    reg [7:0] raddr55;
    reg [7:0] raddr56;
    reg [7:0] raddr57;
    reg [7:0] raddr58;
    reg [7:0] raddr59;
    reg [7:0] raddr60;
    reg [7:0] raddr61;
    reg [7:0] raddr62;
    reg [7:0] raddr63;
    reg [7:0] raddr64;
    reg [7:0] raddr65;
    reg [7:0] raddr66;
    reg [7:0] raddr67;
    reg [7:0] raddr68;
    reg [7:0] raddr69;
    reg [7:0] raddr70;
    reg [7:0] raddr71;
    reg [7:0] raddr72;
    reg [7:0] raddr73;
    reg [7:0] raddr74;
    reg [7:0] raddr75;
    reg [7:0] raddr76;
    reg [7:0] raddr77;
    reg [7:0] raddr78;
    reg [7:0] raddr79;
    reg [7:0] raddr80;
    reg [7:0] raddr81;
    reg [7:0] raddr82;
    reg [7:0] raddr83;
    reg [7:0] raddr84;
    reg [7:0] raddr85;
    reg [7:0] raddr86;
    reg [7:0] raddr87;
    reg [7:0] raddr88;
    reg [7:0] raddr89;
    reg [7:0] raddr90;
    reg [7:0] raddr91;
    reg [7:0] raddr92;
    reg [7:0] raddr93;
    reg [7:0] raddr94;
    reg [7:0] raddr95;
    reg [7:0] raddr96;
    reg [7:0] raddr97;
    reg [7:0] raddr98;

    reg [7:0] m_data;

    assign rdata = m_data;

    always @(posedge clk) begin
        // read
        raddr0 <= raddr;
        raddr1 <= raddr0;
        raddr2 <= raddr1;
        raddr3 <= raddr2;
        raddr4 <= raddr3;
        raddr5 <= raddr4;
        raddr6 <= raddr5;
        raddr7 <= raddr6;
        raddr8 <= raddr7;
        raddr9 <= raddr8;
        raddr10 <= raddr9;
        raddr11 <= raddr10;
        raddr12 <= raddr11;
        raddr13 <= raddr12;
        raddr14 <= raddr13;
        raddr15 <= raddr14;
        raddr16 <= raddr15;
        raddr17 <= raddr16;
        raddr18 <= raddr17;
        raddr19 <= raddr18;
        raddr20 <= raddr19;
        raddr21 <= raddr20;
        raddr22 <= raddr21;
        raddr23 <= raddr22;
        raddr24 <= raddr23;
        raddr25 <= raddr24;
        raddr26 <= raddr25;
        raddr27 <= raddr26;
        raddr28 <= raddr27;
        raddr29 <= raddr28;
        raddr30 <= raddr29;
        raddr31 <= raddr30;
        raddr32 <= raddr31;
        raddr33 <= raddr32;
        raddr34 <= raddr33;
        raddr35 <= raddr34;
        raddr36 <= raddr35;
        raddr37 <= raddr36;
        raddr38 <= raddr37;
        raddr39 <= raddr38;
        raddr40 <= raddr39;
        raddr41 <= raddr40;
        raddr42 <= raddr41;
        raddr43 <= raddr42;
        raddr44 <= raddr43;
        raddr45 <= raddr44;
        raddr46 <= raddr45;
        raddr47 <= raddr46;
        raddr48 <= raddr47;
        raddr49 <= raddr48;
        raddr50 <= raddr49;
        raddr51 <= raddr50;
        raddr52 <= raddr51;
        raddr53 <= raddr52;
        raddr54 <= raddr53;
        raddr55 <= raddr54;
        raddr56 <= raddr55;
        raddr57 <= raddr56;
        raddr58 <= raddr57;
        raddr59 <= raddr58;
        raddr60 <= raddr59;
        raddr61 <= raddr60;
        raddr62 <= raddr61;
        raddr63 <= raddr62;
        raddr64 <= raddr63;
        raddr65 <= raddr64;
        raddr66 <= raddr65;
        raddr67 <= raddr66;
        raddr68 <= raddr67;
        raddr69 <= raddr68;
        raddr70 <= raddr69;
        raddr71 <= raddr70;
        raddr72 <= raddr71;
        raddr73 <= raddr72;
        raddr74 <= raddr73;
        raddr75 <= raddr74;
        raddr76 <= raddr75;
        raddr77 <= raddr76;
        raddr78 <= raddr77;
        raddr79 <= raddr78;
        raddr80 <= raddr79;
        raddr81 <= raddr80;
        raddr82 <= raddr81;
        raddr83 <= raddr82;
        raddr84 <= raddr83;
        raddr85 <= raddr84;
        raddr86 <= raddr85;
        raddr87 <= raddr86;
        raddr88 <= raddr87;
        raddr89 <= raddr88;
        raddr90 <= raddr89;
        raddr91 <= raddr90;
        raddr92 <= raddr91;
        raddr93 <= raddr92;
        raddr94 <= raddr93;
        raddr95 <= raddr94;
        raddr96 <= raddr95;
        raddr97 <= raddr96;
        raddr98 <= raddr97;
        m_data <= data[raddr98];

        // write
        if (wen) begin
            data[waddr] <= wdata;
        end
    end

endmodule