//Extender位拓展
/*
EXTOp
2'b00:无符号16to32
2'b01:有符号16to32
2'b10:拓展到高16位
*/
 //注意组合逻辑(always敏感列表)用=赋值，时序逻辑(clk控制)用<=赋值
`timescale 1ns / 1ns
module EXT(
			input [15:0] EXTin,//输入EXT的数据
			input [1:0]ExtOp,
			output reg [31:0] EXTout//拓展后输出的数据
			);
			
	always@(*)
		begin
			case(ExtOp)
				2'b00://无符号16to32
					begin
						EXTout = {16'b0,EXTin[15:0]};
						$display($time,,"(EXT)EXTOp = 00; EXTin = %b EXTout = %b",EXTin, EXTout);
					end
					
				2'b01://有符号16to32
					begin
						if(EXTin[15]==1)
							EXTout = {16'b1111_1111_1111_1111,EXTin[15:0]};
						else EXTout = {16'b0000_0000_0000_0000,EXTin[15:0]};
						$display($time,,"(EXT)EXTOp = 01; EXTin = %b EXTout = %b",EXTin, EXTout);
					end
					
				2'b10://拓展至高16
					begin
						EXTout = {EXTin[15:0],16'b0000_0000_0000_0000};
						$display($time,,"(EXT)EXTOp = 10; EXTin = %b EXTout = %b",EXTin, EXTout);
					end
				
				default: 
					begin
						$display($time,,"(EXT)EXTOp = default");
						EXTout = 32'b0;
					end
			endcase
		end
endmodule