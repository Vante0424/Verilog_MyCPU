`timescale 1ns / 1ns
//DM数据寄存器
module dm_4k(
				input [31:0] pc,//仅用于控制台输出看着方便
				input [31:0] addr,//地址
				input [31:0] din,//datain
				input MemWrite,//写使能
				input clk,
				input reset,
				
				output [31:0] dout//dataout
			);
			
	wire [11:2] address;			//以字为单位的地址,因为寄存器是1024"字"
	assign address = addr[11:2];
	
	reg[31:0] dm[1023:0];	//32bit*1024字的数据存储器
	
	assign dout = dm[address];//始终输出
	
	integer i;
	initial
		begin
			for(i = 0; i < 1024; i = i + 1) dm[i] <= 0;//初始化数据存储器为0
		end
	
	always@(posedge clk, posedge reset)
		begin
			if(reset)
				begin
					for(i = 1; i < 1024; i = i + 1) dm[i] <= 0;
				end
			else
				begin
					if(MemWrite)
						begin
							$display($time,,"(DM)Before MemWrite:");
							begin
								for(i=0;i<128;i=i+1)$write("%h ", dm[i]);
								$write("\n");//换行专用
							end
							
							dm[address] <= din;
							
							#1
							begin
								$display($time,,"(DM MemWrite)dmAddr%b <= Data%b", addr, din);
								$display($time,,"(DM)Finish MemWrite:");
								begin
									for(i=0;i<128;i=i+1)$write("%h ", dm[i]);
									$write("\n");//换行专用
								end
							end
						end
				end
		end
endmodule