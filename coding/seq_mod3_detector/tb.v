`timescale 1ns/1ps

module seq_mod3_detector_tb();

reg clk;
reg rst_n;
reg data;
wire success;

reg [127:0] seq;
always #1 clk = ~clk;

initial begin
  clk = 1;
  rst_n = 1;
  data = 0;
  #2 rst_n <= 0;
  #2 rst_n <= 1;
  seq = 0;
  while(1) begin
    @(posedge clk) begin 
      data = $random%2;
      seq = (seq<<1) + data;
    end
  end

end


seq_mod3_detector U_SEQ_MOD3_DETECTOR_0(
    .clk          ( clk          ),
    .rst_n        ( rst_n        ),
    .data         ( data         ),
    .success      ( success      )
);

initial begin
    $fsdbDumpvars();
    $fsdbDumpMDA();
    $dumpvars();
    #200 $finish;
 end
endmodule