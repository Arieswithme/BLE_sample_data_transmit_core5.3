module my_ys(clk,rst,yy,y);
input clk,rst,yy;
output y;
reg y;

my_fpq2 u1(.clk(clk),.rst(rst),.clk_out(clk_out));

always @(posedge clk_out) 
   begin
	if (rst) 
	 begin
	  y <= 0;
	 end
	else 
	 begin
	  y <= 0;
    end
   end
endmodule