//输入：NPC代表的下一条指令的地址
//输出："下一条指令" 即 "当前指令"。如果不reset，则根据clk输出当前指令PC的地址
`timescale 1ns / 1ns
module Pc(	
			input [31:0] NPC,		//NextPC计算单元
			input clk,				//时钟信号
			input reset,			//复位
			output reg [31:0] PC	//输出下一条指令的地址
		);
		
	initial
		begin
			PC <= 32'h0000_3000;		//PC复位后初值为0x0000_3000,目的是与MARS的Memory Configuration相配合
		end
		
	always@(posedge clk, posedge reset)//任何一个变动都可以触发
		begin
			if(reset) PC <= 32'h0000_3000;//PC复位后初值为0x0000_3000,目的是与MARS的Memory Configuration相配合
			else PC <= NPC;
			$display($time,,"(PC)NextPcAddr%b",PC);
		end
endmodule