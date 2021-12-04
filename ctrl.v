//控制单元controller
`timescale 1ns/1ns
/*
ALUOp
3'b000: Result=($signed(A)<$signed(B))?32'h0000_0001:32'h0000_0000;//若A<B，则result=1
3'b001: Result=A|B;//或
3'b010: Result=A+B;//加
3'b011: Result={B[15:0],16'h0000};//拓展到高16位
3'b101: Result=B<<sl;//逻辑左移
3'b110: Result=A-B;//减
3'b111: Result = 32'h0000_0000//default

EXTOp
2'b00:无符号16to32
2'b01:有符号16to32
2'b10:拓展到高16位
*/
module control(
				input [5:0] opcode,
				input zero,				//beq指令
				input [5:0] func,
				input overflow,			//溢出标志位 addi专用
				
				output reg [1:0]RegDst,	//写寄存器的目标寄存器号来源:0-rt 1-rd
				output reg ALUSrc,		//第二个ALU操作数的来源
				output reg [1:0] MemToReg,	//写入寄存器的数据来源
				output reg RegWrite,	//寄存器写使能有效
				output reg MemWrite,	//将数据写入到指定存储器单元中
				output reg PCSrc,		//判断是否执行分支(PC+4 or PC+4+offset)
				output reg [1:0]ExtOp,		//控制Extender的拓展方式
				output reg [2:0]ALUctr,	//3bit 控制ALU的运算
				output reg j_ctr,		//控制PC是否转移到J指令指示的地址
				output reg jr_ctr,		//jr指令
				output reg DMSrc
			);
	
	always@(opcode,zero,func)
		begin
			case(opcode)
				6'b000000://addu subu slt jr
					begin
					
						if(func==6'b100001)//addu
							begin
								RegDst 		= 2'b01;	//写寄存器的目标寄存器号来源:0-rt 1-rd
								ALUSrc 		= 0;		//第二个ALU操作数的来源
								MemToReg 	= 2'b0;		//写入寄存器的数据来源
								RegWrite 	= 1;		//寄存器写使能有效
								MemWrite 	= 0;		//将数据写入到指定存储器单元中
								PCSrc 		= 0;			//判断是否执行分支(PC+4 or PC+4+offset)
								ExtOp 		= 2'b0;			//控制Extender的拓展方式
								ALUctr		= 3'b010;	//3bit 控制ALU的运算
								j_ctr 		= 0;			//控制PC是否转移到J指令指示的地址
								jr_ctr 		= 0;		//jr指令
								DMSrc 		= 0;
								$display($time,,"(Control) ADDU");
								$display($time,,"(CTRL)RegDst=%b ALUSrc=%b MemToReg=%b RegWrite=%b MemWrite=%b PCSrc=%b ExtOp=%b ALUctr=%b j_ctr=%b jr_ctr=%b DMSrc=%b",RegDst,ALUSrc,MemToReg,RegWrite,MemWrite,PCSrc,ExtOp,ALUctr,j_ctr,jr_ctr,DMSrc);
							end
							
						else if(func==6'b100011)//subu
							begin
								RegDst		= 2'b01;	//写寄存器的目标寄存器号来源:0-rt 1-rd
								ALUSrc		= 0;		//第二个ALU操作数的来源
								MemToReg 	= 2'b0;	//写入寄存器的数据来源
								RegWrite 	= 1;		//寄存器写使能有效
								MemWrite	= 0;		//将数据写入到指定存储器单元中
								PCSrc 		= 0;		//判断是否执行分支(PC+4 or PC+4+offset)
								ExtOp 		= 2'b0;		//控制Extender的拓展方式
								ALUctr 		= 3'b110;	//3bit 控制ALU的运算
								j_ctr 		= 0;		//控制PC是否转移到J指令指示的地址
								jr_ctr 		= 0;		//jr指令
								DMSrc 		= 0;
								$display($time,,"(Control) SUBU");
								$display($time,,"(CTRL)RegDst=%b ALUSrc=%b MemToReg=%b RegWrite=%b MemWrite=%b PCSrc=%b ExtOp=%b ALUctr=%b j_ctr=%b jr_ctr=%b DMSrc=%b",RegDst,ALUSrc,MemToReg,RegWrite,MemWrite,PCSrc,ExtOp,ALUctr,j_ctr,jr_ctr,DMSrc);
							end
							
						else if(func==6'b101010)//slt
							begin
								RegDst 		= 2'b01;	//写寄存器的目标寄存器号来源:0-rt 1-rd
								ALUSrc 		= 0;		//第二个ALU操作数的来源:0-读寄存器2 1-指令低16位的符号拓展
								MemToReg 	= 2'b0;	//写入寄存器的数据来源:0-ALU计算结果 1-RAM
								RegWrite 	= 1;		//寄存器写使能有效
								MemWrite 	= 0;		//将数据写入到指定存储器单元中
								PCSrc 		= 0;		//判断是否执行分支(PC+4 or PC+4+offset) 0-不执行 1-执行
								ExtOp 		= 2'b0;		//控制Extender的拓展方式
								ALUctr 		= 3'b000;	//3bit 控制ALU的运算 见顶部注释
								j_ctr 		= 0;		//控制PC是否转移到J指令指示的地址
								jr_ctr 		= 0;		//jr指令
								DMSrc 		= 0;
								$display($time,,"(Control) SLT");
								$display($time,,"(CTRL)RegDst=%b ALUSrc=%b MemToReg=%b RegWrite=%b MemWrite=%b PCSrc=%b ExtOp=%b ALUctr=%b j_ctr=%b jr_ctr=%b DMSrc=%b",RegDst,ALUSrc,MemToReg,RegWrite,MemWrite,PCSrc,ExtOp,ALUctr,j_ctr,jr_ctr,DMSrc);
							end
						else if(func==6'b001000)//jr
							begin
								RegDst 		= 2'b00;	//写寄存器的目标寄存器号来源:0-rt 1-rd
								ALUSrc 		= 0;		//第二个ALU操作数的来源:0-读寄存器2 1-指令低16位的符号拓展
								MemToReg 	= 2'b0;	//写入寄存器的数据来源:0-ALU计算结果 1-RAM
								RegWrite 	= 0;		//寄存器写使能有效
								MemWrite 	= 0;		//将数据写入到指定存储器单元中
								PCSrc 		= 0;		//判断是否执行分支(PC+4 or PC+4+offset) 0-不执行 1-执行
								ExtOp 		= 2'b0;		//控制Extender的拓展方式
								ALUctr 		= 3'b111;	//3bit 控制ALU的运算 见顶部注释
								j_ctr 		= 0;		//控制PC是否转移到J指令指示的地址
								jr_ctr 		= 1;		//jr指令
								DMSrc 		= 0;
								$display($time,,"(Control) JR");
								$display($time,,"(CTRL)RegDst=%b ALUSrc=%b MemToReg=%b RegWrite=%b MemWrite=%b PCSrc=%b ExtOp=%b ALUctr=%b j_ctr=%b jr_ctr=%b DMSrc=%b",RegDst,ALUSrc,MemToReg,RegWrite,MemWrite,PCSrc,ExtOp,ALUctr,j_ctr,jr_ctr,DMSrc);
							end
						else//避免隐藏的锁存器
							begin
								RegDst 		= 2'b00;	//写寄存器的目标寄存器号来源:0-rt 1-rd
								ALUSrc 		= 0;		//第二个ALU操作数的来源:0-读寄存器2 1-指令低16位的符号拓展
								MemToReg 	= 2'b0;	//写入寄存器的数据来源:0-ALU计算结果 1-RAM
								RegWrite 	= 0;		//寄存器写使能有效
								MemWrite 	= 0;		//将数据写入到指定存储器单元中
								PCSrc 		= 0;		//判断是否执行分支(PC+4 or PC+4+offset) 0-不执行 1-执行
								ExtOp 		= 2'b0;		//控制Extender的拓展方式
								ALUctr 		= 3'b111;	//3bit 控制ALU的运算 见顶部注释
								j_ctr 		= 0;		//控制PC是否转移到J指令指示的地址
								jr_ctr 		= 0;		//jr指令
								DMSrc 		= 0;
								$display($time,,"(Control) DEFAULT");
								$display($time,,"(CTRL)RegDst=%b ALUSrc=%b MemToReg=%b RegWrite=%b MemWrite=%b PCSrc=%b ExtOp=%b ALUctr=%b j_ctr=%b jr_ctr=%b DMSrc=%b",RegDst,ALUSrc,MemToReg,RegWrite,MemWrite,PCSrc,ExtOp,ALUctr,j_ctr,jr_ctr,DMSrc);
							end
					end
					
				6'b001101://ori或立即数
					begin
						RegDst 		= 2'b00;	//写寄存器的目标寄存器号来源:0-rt 1-rd
						ALUSrc 		= 1;		//第二个ALU操作数的来源:0-读寄存器2 1-指令低16位的符号拓展
						MemToReg 	= 2'b0;	//写入寄存器的数据来源:0-ALU计算结果 1-RAM
						RegWrite 	= 1;		//寄存器写使能有效
						MemWrite 	= 0;		//将数据写入到指定存储器单元中
						PCSrc 		= 0;		//判断是否执行分支(PC+4 or PC+4+offset) 0-不执行 1-执行
						ExtOp 		= 2'b00;		//控制Extender的拓展方式 00ALU运算结果 01数据存储器的输出 10JAL跳转的目的地址 11没用
						ALUctr 		= 3'b001;	//3bit 控制ALU的运算 见顶部注释
						j_ctr 		= 0;		//控制PC是否转移到J指令指示的地址
						jr_ctr 		= 0;		//jr指令
						DMSrc 		= 0;
						$display($time,,"(Control) ORI");
						$display($time,,"(CTRL)RegDst=%b ALUSrc=%b MemToReg=%b RegWrite=%b MemWrite=%b PCSrc=%b ExtOp=%b ALUctr=%b j_ctr=%b jr_ctr=%b DMSrc=%b",RegDst,ALUSrc,MemToReg,RegWrite,MemWrite,PCSrc,ExtOp,ALUctr,j_ctr,jr_ctr,DMSrc);
					end
					
				6'b100011://lw 从基址+偏移处内存中读取数据，放入rt寄存器中
					begin
						RegDst 		= 2'b00;	//写寄存器的目标寄存器号来源:0-rt 1-rd
						ALUSrc 		= 1;		//第二个ALU操作数的来源:0-读寄存器2 1-指令低16位的符号拓展
						MemToReg 	= 2'b01;	//写入寄存器的数据来源:00-ALU计算结果 01-RAM
						RegWrite 	= 1;		//寄存器写使能有效
						MemWrite 	= 0;		//将数据写入到指定存储器单元中
						PCSrc 		= 0;		//判断是否执行分支(PC+4 or PC+4+offset) 0-不执行 1-执行
						ExtOp 		= 2'b01;	//控制Extender的拓展方式 00ALU运算结果 01数据存储器的输出 10JAL跳转的目的地址 11没用
						ALUctr 		= 3'b010;	//3bit 控制ALU的运算 见顶部注释
						j_ctr 		= 0;		//控制PC是否转移到J指令指示的地址
						jr_ctr 		= 0;		//jr指令
						DMSrc 		= 0;
						$display($time,,"(Control) LW");
						$display($time,,"(CTRL)RegDst=%b ALUSrc=%b MemToReg=%b RegWrite=%b MemWrite=%b PCSrc=%b ExtOp=%b ALUctr=%b j_ctr=%b jr_ctr=%b DMSrc=%b",RegDst,ALUSrc,MemToReg,RegWrite,MemWrite,PCSrc,ExtOp,ALUctr,j_ctr,jr_ctr,DMSrc);
					end
					
				6'b101011://sw 把寄存器中的数据写入基址+偏移的内存中 偏移的拓展是有符号还是无符号？
					begin
						RegDst 		= 2'b00;	//写寄存器的目标寄存器号来源:0-rt 1-rd
						ALUSrc 		= 1;		//第二个ALU操作数的来源:0-读寄存器2 1-指令低16位的符号拓展
						MemToReg 	= 2'b00;	//写入寄存器的数据来源:00-ALU计算结果 01-RAM
						RegWrite 	= 0;		//寄存器写使能有效
						MemWrite 	= 1;		//将数据写入到指定存储器单元中
						PCSrc 		= 0;		//判断是否执行分支(PC+4 or PC+4+offset) 0-不执行 1-执行
						ExtOp 		= 2'b01;	//控制Extender的拓展方式 不确定 与上面不同！！
						ALUctr 		= 3'b010;	//3bit 控制ALU的运算 见顶部注释
						j_ctr 		= 0;		//控制PC是否转移到J指令指示的地址
						jr_ctr 		= 0;		//jr指令
						DMSrc 		= 0;
						$display($time,,"(Control) SW");
						$display($time,,"(CTRL)RegDst=%b ALUSrc=%b MemToReg=%b RegWrite=%b MemWrite=%b PCSrc=%b ExtOp=%b ALUctr=%b j_ctr=%b jr_ctr=%b DMSrc=%b",RegDst,ALUSrc,MemToReg,RegWrite,MemWrite,PCSrc,ExtOp,ALUctr,j_ctr,jr_ctr,DMSrc);
					end
				
				6'b000100://beq 相等则(16bitaddress需要拓展并且左移两位)分支指令 注意需要ALU的0标志位
					begin
						RegDst 		= 2'b00;	//写寄存器的目标寄存器号来源:0-rt 1-rd
						ALUSrc 		= 0;		//第二个ALU操作数的来源:0-读寄存器2 1-指令低16位的符号拓展
						MemToReg 	= 2'b00;	//写入寄存器的数据来源:00-ALU计算结果 01-RAM
						RegWrite 	= 0;		//寄存器写使能有效
						MemWrite 	= 0;		//将数据写入到指定存储器单元中
						if(zero==1)	PCSrc = 1;	//判断是否执行分支(PC+4 or PC+4+offset) 0-不执行 1-执行 已经在NPC中实现左移两位
						else 		PCSrc = 0;
						ExtOp 		= 2'b01;	//控制Extender的拓展方式00无符号16to32 01:有符号16to32 10拓展到高16
						ALUctr 		= 3'b111;	//此处zero标志位单独判断 因此不需要ALUctr的控制
						j_ctr 		= 0;		//控制PC是否转移到J指令指示的地址
						jr_ctr 		= 0;		//jr指令
						DMSrc 		= 0;
						$display($time,,"(Control) BEQ");
						$display($time,,"(CTRL)RegDst=%b ALUSrc=%b MemToReg=%b RegWrite=%b MemWrite=%b PCSrc=%b ExtOp=%b ALUctr=%b j_ctr=%b jr_ctr=%b DMSrc=%b",RegDst,ALUSrc,MemToReg,RegWrite,MemWrite,PCSrc,ExtOp,ALUctr,j_ctr,jr_ctr,DMSrc);
					end
				
				6'b001111://lui 立即数加载至寄存器高16位
					begin
						RegDst 		= 2'b00;	//写寄存器的目标寄存器号来源:0-rt 1-rd
						ALUSrc 		= 1;		//(此标记并未直接控制ALU)第二ALU操作数的来源:0-读寄存器2 1-指令低16位的符号拓展
						MemToReg 	= 2'b00;	//写入寄存器的数据来源:00-ALU计算结果 01-RAM 02-JAL
						RegWrite 	= 1;		//寄存器写使能有效
						MemWrite 	= 0;		//将数据写入到指定存储器单元中
						PCSrc 		= 0;		//判断是否执行分支(PC+4 or PC+4+offset) 0-不执行 1-执行
						ExtOp 		= 2'b00;	//控制Extender的拓展方式00无符号16to32 01:有符号16to32 10拓展到高16
						ALUctr 		= 3'b011;	//3bit 控制ALU的运算 见顶部注释
						j_ctr 		= 0;		//控制PC是否转移到J指令指示的地址
						jr_ctr 		= 0;		//jr指令
						DMSrc 		= 0;
						$display($time,,"(Control) LUI");
						$display($time,,"(CTRL)RegDst=%b ALUSrc=%b MemToReg=%b RegWrite=%b MemWrite=%b PCSrc=%b ExtOp=%b ALUctr=%b j_ctr=%b jr_ctr=%b DMSrc=%b",RegDst,ALUSrc,MemToReg,RegWrite,MemWrite,PCSrc,ExtOp,ALUctr,j_ctr,jr_ctr,DMSrc);
					end
					
				6'b000010://j 无条件跳转
					begin
						RegDst 		= 2'b00;	//写寄存器的目标寄存器号来源:0-rt 1-rd
						ALUSrc 		= 0;		//(此标记并未直接控制ALU)第二ALU操作数的来源:0-读寄存器2 1-指令低16位的符号拓展
						MemToReg 	= 2'b00;	//写入寄存器的数据来源:00-ALU计算结果 01-RAM
						RegWrite 	= 0;		//寄存器写使能有效
						MemWrite 	= 0;		//将数据写入到指定存储器单元中
						PCSrc 		= 0;		//判断是否执行分支(PC+4 or PC+4+offset) 0-不执行 1-执行
						ExtOp 		= 2'b00;	//控制Extender的拓展方式00无符号16to32 01:有符号16to32 10拓展到高16
						ALUctr 		= 3'b111;	//3bit 控制ALU的运算 见顶部注释
						j_ctr 		= 1;		//在npc(用于计算下一条指令)中左移两位 并拼接剩余部分
						jr_ctr 		= 0;		//jr指令
						DMSrc 		= 0;
						$display($time,,"(Control) J");
						$display($time,,"(CTRL)RegDst=%b ALUSrc=%b MemToReg=%b RegWrite=%b MemWrite=%b PCSrc=%b ExtOp=%b ALUctr=%b j_ctr=%b jr_ctr=%b DMSrc=%b",RegDst,ALUSrc,MemToReg,RegWrite,MemWrite,PCSrc,ExtOp,ALUctr,j_ctr,jr_ctr,DMSrc);
					end
					
				6'b001000://addi 加立即数 支持溢出 如果溢出 则寄存器写使能无效
					begin
						RegDst 		= 2'b00;	//写寄存器的目标寄存器号来源:0-rt 1-rd
						ALUSrc 		= 1;		//(此标记并未直接控制ALU)第二ALU操作数的来源:0-读寄存器2 1-指令低16位的符号拓展
						MemToReg 	= 2'b00;	//写入寄存器的数据来源:00-ALU计算结果 01-RAM
						begin
							if(overflow==0)
							RegWrite= 1;		//无溢出 寄存器写使能有效
							else if(overflow==1)
							RegWrite= 0;		//有溢出 寄存器写使能无效
						end
						MemWrite 	= 0;		//将数据写入到指定存储器单元中
						PCSrc 		= 0;		//判断是否执行分支(PC+4 or PC+4+offset) 0-不执行 1-执行
						ExtOp 		= 2'b01;	//控制Extender的拓展方式00无符号16to32 01:有符号16to32 10拓展到高16
						ALUctr 		= 3'b010;	//3bit 控制ALU的运算 见顶部注释
						j_ctr 		= 0;		//在npc(用于计算下一条指令)中左移两位 并拼接剩余部分
						jr_ctr 		= 0;		//jr指令
						DMSrc 		= 0;
						$display($time,,"(Control) ADDI");
						$display($time,,"(CTRL)RegDst=%b ALUSrc=%b MemToReg=%b RegWrite=%b MemWrite=%b PCSrc=%b ExtOp=%b ALUctr=%b j_ctr=%b jr_ctr=%b DMSrc=%b overflow=%b",RegDst,ALUSrc,MemToReg,RegWrite,MemWrite,PCSrc,ExtOp,ALUctr,j_ctr,jr_ctr,DMSrc,overflow);
					end
				
				6'b001001://addiu
					begin
						RegDst 		= 2'b00;	//写寄存器的目标寄存器号来源:0-rt 1-rd
						ALUSrc 		= 1;		//(此标记并未直接控制ALU)第二ALU操作数的来源:0-读寄存器2 1-指令低16位的符号拓展
						MemToReg 	= 2'b00;	//写入寄存器的数据来源:00-ALU计算结果 01-RAM
						RegWrite 	= 1;		//寄存器写使能有效
						MemWrite 	= 0;		//将数据写入到指定存储器单元中
						PCSrc 		= 0;		//判断是否执行分支(PC+4 or PC+4+offset) 0-不执行 1-执行
						ExtOp 		= 2'b01;	//控制Extender的拓展方式00无符号16to32 01:有符号16to32 10拓展到高16
						ALUctr 		= 3'b010;	//3bit 控制ALU的运算 见顶部注释
						j_ctr 		= 0;		//在npc(用于计算下一条指令)中左移两位 并拼接剩余部分
						jr_ctr 		= 0;		//jr指令
						DMSrc 		= 0;
						$display($time,,"(Control) ADDIU");
						$display($time,,"(CTRL)RegDst=%b ALUSrc=%b MemToReg=%b RegWrite=%b MemWrite=%b PCSrc=%b ExtOp=%b ALUctr=%b j_ctr=%b jr_ctr=%b DMSrc=%b",RegDst,ALUSrc,MemToReg,RegWrite,MemWrite,PCSrc,ExtOp,ALUctr,j_ctr,jr_ctr,DMSrc);
					end
					
				
				6'b000011://jal
					begin
							RegDst 		= 2'b10;	//写寄存器的目标寄存器号来源:0-rt 1-rd
							ALUSrc 		= 0;		//(此标记并未直接控制ALU)第二ALU操作数的来源:0-读寄存器2 1-指令低16位的符号拓展
							MemToReg 	= 2'b10;	//写入寄存器的数据来源:00-ALU计算结果 01-RAM
							RegWrite 	= 1;		//寄存器写使能有效
							MemWrite 	= 0;		//将数据写入到指定存储器单元中
							PCSrc 		= 0;		//判断是否执行分支(PC+4 or PC+4+offset) 0-不执行 1-执行
							ExtOp 		= 2'b00;	//控制Extender的拓展方式00无符号16to32 01:有符号16to32 10拓展到高16
							ALUctr 		= 3'b111;	//3bit 控制ALU的运算 见顶部注释
							j_ctr 		= 1;		//在npc(用于计算下一条指令)中左移两位 并拼接剩余部分
							jr_ctr 		= 0;		//jr指令
							DMSrc 		= 0;
							$display($time,,"(Control) JAL");
							$display($time,,"(CTRL)RegDst=%b ALUSrc=%b MemToReg=%b RegWrite=%b MemWrite=%b PCSrc=%b ExtOp=%b ALUctr=%b j_ctr=%b jr_ctr=%b DMSrc=%b",RegDst,ALUSrc,MemToReg,RegWrite,MemWrite,PCSrc,ExtOp,ALUctr,j_ctr,jr_ctr,DMSrc);
					end
				
				default:
					begin
							RegDst 		= 2'b00;	//写寄存器的目标寄存器号来源:0-rt 1-rd
							ALUSrc 		= 0;		//(此标记并未直接控制ALU)第二ALU操作数的来源:0-读寄存器2 1-指令低16位的符号拓展
							MemToReg 	= 2'b00;	//写入寄存器的数据来源:00-ALU计算结果 01-RAM
							RegWrite 	= 0;		//寄存器写使能有效
							MemWrite 	= 0;		//将数据写入到指定存储器单元中
							PCSrc 		= 0;		//判断是否执行分支(PC+4 or PC+4+offset) 0-不执行 1-执行
							ExtOp 		= 2'b00;	//控制Extender的拓展方式00无符号16to32 01:有符号16to32 10拓展到高16
							ALUctr 		= 3'b111;	//3bit 控制ALU的运算 见顶部注释
							j_ctr 		= 0;		//在npc(用于计算下一条指令)中左移两位 并拼接剩余部分
							jr_ctr 		= 0;		//jr指令
							DMSrc 		= 0;
							$display($time,,"(Control) DEFAULT2");
							$display($time,,"(CTRL)RegDst=%b ALUSrc=%b MemToReg=%b RegWrite=%b MemWrite=%b PCSrc=%b ExtOp=%b ALUctr=%b j_ctr=%b jr_ctr=%b DMSrc=%b",RegDst,ALUSrc,MemToReg,RegWrite,MemWrite,PCSrc,ExtOp,ALUctr,j_ctr,jr_ctr,DMSrc);
					end
			endcase
		end
endmodule
				