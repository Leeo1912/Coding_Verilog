module rr_arbiter_tb();
reg clk,rstn;
reg [7:0] req;
 
wire [7:0] grant;
 
initial begin
    forever #5 clk = ~clk;
end
 
initial begin
    clk = 0;
    rstn = 0;
    req = 8'd0;
    #10
    rstn = 1;
    #5
    req = #1 8'b1011_1110;
    #10
    req = #1 8'b0101_0010;
    #10
    req = #1 8'b1010_1000;
    #10
    req = #1 8'b1100_1000;
    #10
    req = #1 8'd0;
    #50
    $finish();
end
 
rr_arbiter u_rr_arbiter(
    .clk    (clk)  ,
    .rstn   (rstn) ,
    .req    (req)  ,
    .grant  (grant)
);
 
// initial begin
//     $fsdbDumpfile("rr_arbiter.fsdb");
//     $fsdbDumpvars(0);
// end
 
endmodule