`timescale 1ns/1ps
module tb();

reg clk1;
reg clk0;
reg rst_n;
reg sel;
wire clkout;

always #5 clk0 = ~clk0;

always #2 clk1 = ~clk1;

initial begin
    clk0 = 0;
    clk1 = 0;
    sel = 0;
    rst_n = 0;
    #10;
    rst_n = 1;
    sel = 0;

    #50;
    sel = 1;

    #100;
    sel = 0;

    #40;
    sel = 1;

    #100;
    $finish;
    

end







glitch_free_switch_clock u_glitch(
    .clk1   (clk1   ),
    .clk0   (clk0   ),
    .rst_n  (rst_n  ),
    .sel    (sel    ),
    .clkout (clkout )
);


endmodule