module glitch_free_switch_clock
(
    input clk1,
    input clk0,
    input rst_n,
    input sel,
    output clkout
);

wire clk1_ff,clk0_ff;

reg clk0_r1,clk0_r2;
reg clk1_r1,clk1_r2;

assign clk1_ff = sel & (~clk1_r2);
assign clk0_ff = (~sel) & (~clk0_r2);


always @(posedge clk1,negedge rst_n) begin
    if(!rst_n)
        clk1_r1 <= 'b0;
    else
        clk1_r1 <= clk1_ff;
end

always @(negedge clk1,negedge rst_n) begin
    if(!rst_n)
        clk1_r2 <= 'b0;
    else
        clk1_r2 <= clk1_r1;  
end


always @(posedge clk0,negedge rst_n) begin
    if(!rst_n)
        clk0_r1 <= 'b0;
    else
        clk0_r1 <= clk0_ff;
end

always @(negedge clk0,negedge rst_n) begin
    if(!rst_n)
        clk0_r2 <= 'b0;
    else
        clk0_r2 <= clk0_r1;  
end

assign clkout = (clk1 & clk1_r2) | (clk0 & clk0_r2);

endmodule