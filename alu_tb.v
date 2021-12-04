`timescale 1ns/1ns		//仿真时间单位/时间精度
`include "alu.v"
module ALU_tb;

	reg [31:0] A;
	reg [31:0] B;
	reg [4:0] sl;				//左移的位数
	reg [2:0] ALUctr;			//3位ALU控制信号
	wire [31:0] Result;			//
	wire zero;					//零标志位
	
	ALU myalu(A,B,sl,ALUctr,Result,zero);
	always #2 A<=A+1;			//A每1ns加一
	
	initial
	begin A=32'hffff_fff0;B=0;sl=0;ALUctr=3'b010;
	#0 B<=1;					//begin-end是串行
	end
	
	initial
	begin
	$monitor($time,,"(ALU)%d + %d = %d",A,B,Result);
	#100
	$finish;
	end
endmodule
