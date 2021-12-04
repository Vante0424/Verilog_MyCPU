`timescale 1ns/1ns		//仿真时间单位/时间精度
`include "im.v"
module IM4k_tb;
	reg [31:0]addr;//要读取的指令的地址
			
	wire[5:0]op;//接收来自被测模块的输出 用导线连接
	wire[4:0]rs;
	wire[4:0]rt;
	wire[4:0]rd;
	wire[4:0]shamt;
	wire[5:0]func;
			
	wire[15:0]immediate16;//address
	wire[25:0]immediate26;//J指令 26位跳转地址
	
	IM_4k myim(addr,op,rs,rt,rd,shamt,func,immediate16,immediate26);
	
	always #5 addr<=addr+4;
	
	initial addr=0;//不能给wire型变量赋值
	
	initial
	begin
	$monitor($time,,"addr = %d, code = %b%b%b%b%b%b",addr,op,rs,rt,rd,shamt,func);
	#100
	$finish;
	end
endmodule
