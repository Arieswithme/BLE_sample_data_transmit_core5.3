module my_fpq2(clk,rst,clk_out);
   parameter N = 10000000;
   input clk;
   input rst;
   output reg clk_out;
   reg[24:0] counter;

always @(posedge clk) 
   begin
	if (rst) 
	 begin
	  counter <= 0;
	 end
	else if(counter == N-1) 
	 begin
	  counter <= 0;
	 end
	else 
	 begin
	  counter <= counter + 1;
	 end
   end

always @(posedge clk) 
   begin
	if (rst) 
	 begin
	  clk_out <= 0;
	 end
	else if (counter == N-1) 
	 begin
	  clk_out <= ~clk_out;
	 end
   end

endmodule