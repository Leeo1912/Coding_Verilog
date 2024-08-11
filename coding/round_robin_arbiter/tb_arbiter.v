`timescale 1ns/1ps
module tb_arbiter (
    
);
reg clk;
reg rst_n;
reg [7:0] req;
wire [7:0] grant;

always #5 clk = ~clk;

initial begin
    clk = 0;
    rst_n = 0;
    #10;
    rst_n = 1;
    req = 8'b1101_1001;
    #10;
    req = 8'b1101_1100;
    #10;
    req = 8'b1110_0011;
    #10;
    req = 8'b0010_1010;

    #50;
    $finish;
    end





arbiter u_arbiter(
    .clk   (clk   ),
    .rst_n (rst_n ),
    .req   (req   ),
    .grant (grant )
);



endmodule