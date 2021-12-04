`timescale 1ns/1ns

module mips(
			 input clk,
			 input reset
			);
	//以下是每个模块的输出
	//Control控制单元
	wire [1:0]RegDst;		//写寄存器的目标寄存器号来源:0-rt 1-rd
	wire ALUSrc;			//第二个ALU操作数的来源 ：0-读寄存器2 1-指令低16位的符号拓展
	wire [1:0] MemToReg;	//写入寄存器的数据来源
	wire RegWrite;			//寄存器写使能有效
	wire MemWrite;			//将数据写入到指定存储器单元中
	wire PCSrc;				//判断是否执行分支(PC+4 or PC+4+offset)
	wire [1:0]ExtOp;		//控制Extender的拓展方式
	wire [2:0]ALUctr;		//3bit 控制ALU的运算
	wire j_ctr;				//控制PC是否转移到J指令指示的地址
	wire jr_ctr;			//jr指令
	wire DMSrc;
	wire [15:0]immediate16;//address
	wire [25:0]immediate26;//J指令 26位跳转地址
	
	//IM指令存储器
	wire [5:0] opcode;
	wire [4:0] rs;
	wire [4:0] rt;
	wire [4:0] rd;
	wire [5:0] shamt;
	wire [5:0] func;
	
	//GPR寄存器堆
	wire [31:0] rd1;		//读出的数据1
	wire [31:0] rd2;		//读出的数据2
	
	//DM数据存储器
	wire [31:0] dout;		//读出的数据
	
	//ALU算数逻辑单元
	wire [31:0] Result;
	wire zero;
	wire overflow;
	
	//Ext拓展单元
	wire [31:0] EXTout;
	
	//MUX多路选择器
	wire [31:0] DataToDM;
	wire [31:0] DataToALU;
	wire [31:0] RegWriteData;
	wire [4:0] RegWriteAddress;
	
	//NPC
	wire [31:0] NPC;		//下一条指令的地址
	wire [31:0] jalPC;		//jal跳转的地址
	
	//PC
	wire [31:0] PC;			//PC输出下一条指令的地址
	
	//以下是各个模块的实例化 就是用导线把他们接在一起 注意函数参数要与上方的输出相同 否则会出现变量未定义的问题
	control Control(opcode[5:0],zero,func[5:0],overflow,RegDst[1:0],ALUSrc,MemToReg[1:0],RegWrite,MemWrite,PCSrc,ExtOp[1:0],ALUctr[2:0],j_ctr,jr_ctr,DMSrc);
						/*opcode[5:0],
						zero,				//beq指令
						func[5:0],
						overflow,
						
						RegDst[1:0],		//写寄存器的目标寄存器号来源:0-rt 1-rd
						ALUSrc,		//第二个ALU操作数的来源
						MemToReg[1:0],	//写入寄存器的数据来源
						RegWrite,	//寄存器写使能有效
						MemWrite,	//将数据写入到指定存储器单元中
						PCSrc,		//判断是否执行分支(PC+4 or PC+4+offset)
						ExtOp[1:0],		//控制Extender的拓展方式
						ALUctr[2:0],		//3bit 控制ALU的运算
						j_ctr,		//控制PC是否转移到J指令指示的地址
						jr_ctr,		//jr指令
						DMSrc
						*/
					
					
	IM_4k im		(PC,opcode[5:0],rs[4:0],rt[4:0],rd[4:0],shamt[4:0],func[5:0],immediate16[15:0],immediate26[25:0]);
						/*
						addr[31:0],		//输入 与上一个模块以导线相连 要取出的指令地址
					
						op[5:0],			//输出 6位操作码op
						rs[4:0],			//输出 源1
						rt[4:0],			//输出 源2
						rd[4:0],			//输出 目的
						shamt[4:0],		//只用于移位指令sll
						func[5:0],		//指出ALU的功能
						immediate16[15:0],	//address beq
						immediate26[25:0]	//J指令 26位跳转地址
						*/
					
			
	GPR gpr			(PC,clk,reset,RegWrite,rs[4:0],rt[4:0],RegWriteAddress,RegWriteData,rd1[31:0],rd2[31:0]);
						/*
						WPC[31:0],		//writePC
						clk,
						reset,
						RegWrite,		//寄存器写使能
						ra1[4:0],		//ReadAddress1
						ra2[4:0],		//ReadAddress2
						wa[4:0],			//RegWriteAddress
						wd[31:0],			//WriteData
						
						rd1[31:0],		//ReadData1
						rd2[31:0]			//ReadData2
						*/
					
					
	dm_4k dm		(PC[31:0],Result[31:0],DataToDM[31:0],MemWrite,clk,reset,dout[31:0]);
						/*
						pc[31:0],			//仅用于控制台输出看着方便
						addr[31:0],			//地址
						din[31:0],			//datain
						MemWrite,		//写使能
						clk,
						reset,
						
						dout[31:0]			//dataout
						*/
					
					
	ALU Alu			(rd1[31:0],DataToALU,5'b0,ALUctr[2:0],Result[31:0],zero,overflow);
						/*
						A[31:0],				//输入32位A
						B[31:0],				//输入32位B
						sl[4:0],				//左移的位数 sl是移位指令 没用
						ALUctr[2:0],			//3位ALU控制信号
						
						Result[31:0],			//因为要在always里面赋值，所以定义为reg
						zero			//零标志位
						*/
					
					
	EXT ext			(immediate16[15:0],ExtOp[1:0],EXTout[31:0]);
						/*
						EXTin[15:0],			//输入EXT的数据
						ExtOp[1:0],
						
						EXTout[31:0]			//拓展后输出的数据
						*/
					
	
	//计算写入DM的数据
	mutiplexer32_1 MuxDataToDM(DMSrc,rd2[31:0],32'b0,DataToDM);
	//计算参与运算的ALU数据2
	mutiplexer32_1 MuxDataToALU(ALUSrc,rd2[31:0],EXTout,DataToALU);
						/*
						control,//ALU数据2来源：0-读寄存器2 1-指令低16位的符号拓展
						din0 [31:0],	//读寄存器2
						din1 [31:0],	//指令低16位的符号拓展
						
						out32_1 [31:0]
						*/
					
	
	//RegWriteData的计算
	mutiplexer32_2 mux32_2(MemToReg,Result,dout,jalPC,32'b0,RegWriteData);//MUX RegWriteData
					/*
						control [1:0], //MemToReg: 00ALU运算结果(包含高16拓展\普通运算) 01数据存储器的输出 10JAL跳转的目的地址
						din0 [31:0],	//ALU结果
						din1 [31:0],	//DM输出
						din2 [31:0],	//JAL跳转目的地址
						din3 [31:0],//没用
							
						out32_2 [31:0]
					*/
	
	//RegWriteAddress的计算	
	mutiplexer5	mux5(RegDst,rt,rd,5'b11111,RegWriteAddress);
						/*
						control [1:0],//Regdst写寄存器的目标寄存器号来源 0-rt 1-rd
						din0 [4:0],	//rt lui应该写到rt
						din1 [4:0],	//rd
						din2 [4:0],
						
						out5 [4:0]
						*/
	
	NextPC npc		(PC[31:0],immediate16[15:0],immediate26[25:0],rd1[31:0],PCSrc,j_ctr,jr_ctr,NPC[31:0],jalPC[31:0]);
						/*
						PC[31:0],
						imm16[15:0],			//beq
						imm26[25:0],			//j,jal
						rsd[31:0],				//jr跳转至寄存器 对应接口是rd1[31:0] 是从寄存器读出的第一个数据
						branch_ctr,
						j_ctr,
						jr_ctr,
						
						NPC[31:0],			//下一条指令的地址
						jalPC[31:0]			//jal跳转的地址
						*/
					
				
	 Pc mypc		(NPC[31:0],clk,reset,PC[31:0]);
						/*
						NPC[31:0],			//NextPC计算单元
						clk,			//时钟信号
						reset,			//复位
						PC[31:0]				//输出下一条指令的地址
						*/
					
		
endmodule
	