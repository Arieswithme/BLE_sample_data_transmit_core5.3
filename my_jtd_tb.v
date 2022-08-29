`timescale 1ns/1ps

module my_jtd_tb;
reg clk,rst,sen1,sen2,ys;
wire R2,G2,Y2,R1,G1,Y1,a251,b251,c251,d251,e251,f251,g251,a250,b250,c250,d250,e250,f250,g250,a201,b201,c201,d201,e201,f201,g201,a200,b200,c200,d200,e200,f200,g200,a51,b51,c51,d51,e51,f51,g51,a50,b50,c50,d50,e50,f50,g50;

my_jtd u1(clk,rst,sen1,sen2,ys,R2,G2,Y2,R1,G1,Y1,a251,b251,c251,d251,e251,f251,g251,a250,b250,c250,d250,e250,f250,g250,a201,b201,c201,d201,e201,f201,g201,a200,b200,c200,d200,e200,f200,g200,a51,b51,c51,d51,e51,f51,g51,a50,b50,c50,d50,e50,f50,g50);
always
 begin
 #5
 clk=~clk;
 end
initial
 begin
 clk=1'b0;
 rst =1'b0;
 sen1=1'b1;
 sen2=1'b1;
 ys=0;
 
 #10
 rst =1'b1;
 sen1=1'b0;
 sen2=1'b1;
 ys=0;
 
 #10
 rst =1'b1;
 sen1=1'b1;
 sen2=1'b0;
 ys=0;
 
 //zc
  #10
 rst =1'b1;
 sen1=1'b1;
 sen2=1'b1;
 ys=0;
 
 #80
 rst=1'b1;
 sen1=1'b0;
 sen2=1'b0;
 ys=1;
 
 #80
 rst=1'b1;
 sen1=1'b1;
 sen2=1'b1;
 ys=0;
 
 #10
 rst=1'b1;
 sen1=1'b0;
 sen2=1'b0;
 ys=1;
 
 #30
 rst=1'b1;
 sen1=1'b1;
 sen2=1'b0;
 ys=0;
 
 #10
 rst=1'b1;
 sen1=1'b0;
 sen2=1'b1;
 ys=0;
 
 #10
 rst=1'b1;
 sen1=1'b0;
 sen2=1'b0;
 ys=0;

 end
 endmodule
 