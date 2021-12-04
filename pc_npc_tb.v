//用于测试pc和npc
`timescale 1ns/1ns		//仿真时间单位/时间精度
`include "pc.v"
`include "npc.v"

module pc_npc_tb;
	wire [31:0] NPC;	//下一条指令的地址,不明白为什么是wire类型而不是reg
	reg clk;
	reg reset;

	reg [31:0] imm16;	//beq
	reg [25:0] imm26;	//j,jal
	reg [31:0] rsd;	//jr跳转至寄存器的寄存器值
	reg branch_ctr;
	reg j_ctr;
	reg jr_ctr;
			
	wire [31:0] pc;
	wire [31:0] jalPC;		//jal跳转的地址
	
	Pc mypc(NPC, clk, reset, pc);
	NextPC mynextpc(pc, imm16, imm26, rsd, ranch_ctr, j_ctr, jr_ctr,NPC,jalPC);
	
	always #5 clk = ~clk;
	
	//initial NPC=0;
	initial clk=0;
	initial reset=0;
	initial imm16=0; 
	initial imm26=0; 
	initial rsd=0; 
	initial branch_ctr=0; 
	initial j_ctr=0; 
	initial jr_ctr=0;
	
	initial
	begin
	$monitor($time,,"NPC = %d, PC = %d",NPC, pc);
	#100
	$finish;
	end
endmodule