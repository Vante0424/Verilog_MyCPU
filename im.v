`timescale 1ns/1ns
//IM 指令存储器 与上一个模块以导线相连wire输入 将本模块数据输出到下一个模块reg输出
module IM_4k(
			input [31:0]addr,//与上一个模块以导线相连 32bit 要取出额的指令地址
			
			output reg[5:0]op,//输出 6位操作码op
			output reg[4:0]rs,//输出 源1
			output reg[4:0]rt,//输出 源2
			output reg[4:0]rd,//输出 目的
			output reg[4:0]shamt,//只用于移位指令sll
			output reg[5:0]func,//指出ALU的功能
			
			output reg[15:0]immediate16,//address
			output reg[25:0]immediate26//J指令 26位跳转地址
		);

	reg [31:0]im[1023:0];//im存储读取的所有指令 2^10
	
	wire [11:2]address;//因为im一共只有2^10,所以address的位宽为10
	
	//wire[31:0]realaddress;
	//assign realaddress=addr-32'h00003000;//为了和mars匹配31号寄存器的值，减去32'h00003000偏移。因为在这里代码段从0开始存的，每次读的时候以0地址为起始地址。但是实际上就算31号寄存器的值不匹配，即使用下面这一行注释掉的代码，也可以正常运行。
	//assign address=realaddress[11:2];//按字节寻址，address自动取addr的左移两位
	assign address=addr[11:2];//按字节寻址，address自动取addr的左移两位 实际超出去没关系 im一共只有2^10，地址只取[11:2]这段 
	
	integer i;
	
	initial begin
		$readmemh("p2-test.txt",im);//从文件中读取指令 格式：$readmemb("<数据文件名>",<存贮器名>,<起始地址>);
		begin
			$display("(IM)Finish Read File",im);
			for(i=0;i<128;i=i+1)$write("%h ", im[i]);
			$write("\n");//换行专用
		end
		
	end
	
	always @(*)//分离输出指令的各个部分
		begin
			op=im[address][31:26];
			rs=im[address][25:21];
			rt=im[address][20:16];
			rd=im[address][15:11];
			shamt=im[address][10:6];
			func=im[address][5:0];
			
			immediate16=im[address][15:0];
			immediate26=im[address][25:0];
			
			$display($time,,"(IM)Current Code:%b %b %b %b %b %b ; TheAddrOfCurCode = %b ",op,rs,rt,rd,shamt,func,addr);
		end
	
endmodule	

			