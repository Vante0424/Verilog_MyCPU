//用于测试整个处理器
`timescale 1ns/1ns		//仿真时间单位/时间精度
`include "mips.v"

module mips_tb;
	reg clk;
	reg reset;
	
	mips mymips(clk, reset);
	
	always #10 clk = ~clk;
	
	initial clk = 0;
	
	initial
		begin
		$monitor($time,,"(mips_tb)clk = %b",clk);
		$display("display is Valid");
		#1000
		$finish;
		end
		
endmodule