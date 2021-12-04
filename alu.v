`timescale 1ns / 1ns
/*
 *	Module Name:	ALU
 *	File Created:	2019-4-4 16:11:12
 *	Notes: overflow是溢出标志位
 *  
 */
 
 //注意组合逻辑(敏感列表)用=赋值，时序逻辑(clk控制)用<=赋值
 
 module ALU(	input [31:0] A,				//输入32位A
				input [31:0] B,				//输入32位B
				input [4:0]	sl,				//左移的位数
				input [2:0] ALUctr,			//3位ALU控制信号
				output reg[31:0] Result,	//因为要在always里面赋值，所以定义为reg
				output reg zero,			//零标志位
				
				output reg overflow			//溢出标志位
			);
			
	initial overflow = 0;
	
	always@(*)						//(*)表示自动添加敏感列表
		begin
			case(ALUctr)				//决定ALU操作
				3'b000: 
					begin
						Result=($signed(A)<$signed(B))?32'h0000_0001:32'h0000_0000;//若A<B，则result=1
						$display($time,,"(ALU)(if a<b,res=1)A = %b, B = %b, Result = %b", A, B, Result);
					end
				
				3'b001:
					begin
						Result=A|B;//或
						$display($time,,"(ALU)(or)A = %b, B = %b, Result = %b", A, B, Result);
					end
				
				3'b010:
					begin
						Result=A+B;//加
						if((A[31]==1'h0&&B[31]==1'h0&&Result[31]==1'h1) || (A[31]==1'h1&&B[31]==1'h1&&Result[31]==1'h0))
							begin
								overflow=1'h1;//正溢/负溢
								$write("OVERFLOW！\n");
							end
						else overflow=1'h0;//如果没有这一句 会产生锁存器？反正会有明明不溢出却被判断溢出的bug
						$display($time,,"(ALU)(add)A = %b, B = %b, Result = %b A[31]=%b B[31]=%b overflow=%b", A, B, Result,A[31],B[31],overflow);
					end
				
				3'b011:
					begin
						Result={B[15:0],16'h0000};//拓展到高16位
						$display($time,,"(ALU)(16toUp32)A = %b, B = %b, Result = %b", A, B, Result);
					end
				
				3'b101: 
					begin
						Result=B<<sl;//逻辑左移
						$display($time,,"(ALU)(<<)A = %b, B = %b, Result = %b", A, B, Result);
					end
				
				3'b110:
					begin
						Result=A-B;//减
						$display($time,,"(ALU)(sub)A = %b, B = %b, Result = %b", A, B, Result);
					end
				
				default:
					begin
						Result<=32'h0000_0000;
						$display($time,,"(ALU)(DEFAULT)");
					end
				
			endcase
			
			if(A==B) zero=1;//计算零标志位
			else zero=0;
			
		end
	
endmodule
			