//多路选择器

`timescale 1ns / 1ns
 //注意组合逻辑(敏感列表)用=赋值，时序逻辑(clk控制)用<=赋值
 
//二选一 32bit
module mutiplexer32_1(
						input control,
							
						input [31:0] din0,
						input [31:0] din1,
							
						output reg [31:0] out32_1
					);
	always @(*)
		begin
			if(control==0) out32_1 = din0;
			else out32_1 = din1;
			$display($time,,"(MUX DataTo DM/ALU)control = %b, din0 = %b, din1 = %b, out = %b", control, din0, din1, out32_1);
		end
endmodule


//四选一 32bit  00ALU运算结果 01数据存储器的输出 10JAL跳转的目的地址 11没用
module mutiplexer32_2(
						input [1:0]control,
							
						input [31:0] din0,	//00ALU运算结果(包含高16拓展\普通运算)
						input [31:0] din1, 	//01数据存储器的输出
						input [31:0] din2,	//10JAL跳转的目的地址
						input [31:0] din3,	//没用到
							
						output reg [31:0] out32_2
					);
   always @(*)
		begin
			if(control==0) 			out32_2=din0;
			else if(control==2'b01) out32_2=din1;
			else if(control==2'b10) out32_2=din2;
			else if(control==2'b11) out32_2=din3;
			$display($time,,"(MUX RegWriteData)control = %b, din0 = %b, din1 = %b, din2 = %b, out = %b", control, din0, din1, din2, out32_2);
		end
endmodule


//3选1 5bit
module mutiplexer5	(
						input [1:0] control, //Regdst写寄存器的目标寄存器号来源 0-rt 1-rd
						
						input [4:0] din0,	//rt (lui)
						input [4:0] din1,	//rd
						input [4:0] din2,
						
						output reg [4:0] out5
					);
	 always @(*)
		begin
			if(control==0) 			out5=din0;
			else if(control==2'b01) out5=din1;
			else if(control==2'b10) out5=din2;
			$display($time,,"(MUX RegWriteAddr)control = %b, din0 = %b, din1 = %b, out = %b", control, din0, din1, out5);
		end
endmodule
