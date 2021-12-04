//GPR寄存器堆
`timescale 1ns / 1ns
//注意组合逻辑(always敏感列表)用=赋值，时序逻辑(clk控制)用<=赋值
module GPR(
			input [31:0] WPC,//writePC 仅用于输出
			input clk,
			input reset,
			input RegWrite,//写使能
			
			input [4:0] ra1,//ReadAddress1
			input [4:0] ra2,//ReadAddress2
			input [4:0] wa,//WriteAddress
			
			input [31:0]wd,//WriteData
			
			output [31:0] rd1,//ReadData1
			output [31:0] rd2//ReadData2
		);
		
	reg[31:0] regfile[31:0];//定义32个 32-bit寄存器
	
	assign rd1 = regfile[ra1];//第一个读出的数据
	assign rd2 = regfile[ra2];//第二个读出的数据
	
	integer i;
	//integer flag = 0;
	
	initial
		begin
			for(i = 0; i < 32; i = i + 1) regfile[i] <= 0;
		end
		
	//时序逻辑
	always@(posedge clk, posedge reset)
		begin
			if(reset)
				begin
					for(i = 0; i < 32; i = i + 1) regfile[i] <= 0;
				end
			else if(RegWrite==1 && wa != 0)//wa=Write Address 不能写0号寄存器
				begin
					regfile[wa] <= wd;//写入数据
					$display($time,,"(Write GPR)PC%b: WriteAddress%b <= Data%b", WPC, wa, wd);
					#1
					begin
						$display($time,,"(Show GPR)");
						for(i = 0; i < 32; i = i + 1)
						begin
							$display($time,,"GPR%d = %h", i, regfile[i]);
						end
					end
				end
			else if(RegWrite==0)//写使能无效
				begin
					$display($time,,"(GPR)Write:false");
				end
			else//写使能有效但是寄存器地址为0
				begin
					$display($time,,"(GPR)DEFAULT:You CANNOT Write To GPR Address 0x00000000");
				end
		end		
endmodule