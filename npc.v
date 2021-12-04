`timescale 1ns / 1ns
//计算下一条指令的地址
//输入的PC是当前指令的地址
//输出的NPC是下一条指令的地址
module NextPC
		(
			input [31:0] PC,
			input [15:0] imm16,	//beq
			input [25:0] imm26,	//j,jal
			input [31:0] rsd,	//jr跳转至寄存器
			input branch_ctr,
			input j_ctr,
			input jr_ctr,
			
			output reg [31:0] NPC,	//下一条指令的地址
			output [31:0] jalPC		//jal跳转的地址
		);

	assign jalPC = PC + 4;
	
	reg [31:0]imm16ex;
	
	always @(*)
		begin
			if(j_ctr) NPC <= {PC[31:28], imm26, 2'b0};	//j指令 自带左移两位
			else if(jr_ctr) NPC <= rsd;					//jr指令
			else if(branch_ctr)							//beq指令，branch判断是否执行分支 自带左移两位
				begin
					if(imm16[15]==0)		imm16ex={14'b00000000000000,imm16[15:0],2'b0};  
					else if(imm16[15]==1)	imm16ex={14'b11111111111111,imm16[15:0],2'b0};
					NPC <= PC + 4 + imm16ex;
					$display($time,,"(NPC beq)imm16:%b imm16ex:%b PC+4:%b",imm16,imm16ex,PC + 4);
				end
			else NPC = PC  + 4;
			$display($time,,"(NPC)CurPCAddr:%b NextPcAddr:%b",PC,NPC);
		end
endmodule