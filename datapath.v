`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/03 18:53:51
// Design Name: 
// Module Name: datapath
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module datapath(
	input wire clk,rst,
	//fetch stage
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	//decode stage
	input wire pcsrcD,branchD,
	input wire jumpD,
	output wire equalD,
	output wire[5:0] opD,functD,
	input wire [1:0] hilo_weD,
	//execute stage
	input wire memtoregE,
	input wire alusrcE,regdstE,
	input wire regwriteE,
	input wire[4:0] alucontrolE,
	output wire flushE,
	//mem stage
	input wire memtoregM,
	input wire regwriteM,
	output wire[31:0] aluoutM,writedataM,
	input wire[31:0] readdataM,
	//writeback stage
	input wire memtoregW,
	input wire regwriteW,
	output wire [31:0]instrD
    );
	
	//fetch stage
	wire stallF;
	//FD
	wire [31:0] pcnextFD,pcnextbrFD,pcplus4F,pcbranchD;
	//decode stage
	wire [31:0] pcplus4D;
	wire forwardaD,forwardbD;
	wire [4:0] rsD,rtD,rdD;
	wire flushD,stallD; 
	wire [31:0] signimmD,signimmshD;
	wire [31:0] srcaD,srca2D,srcbD,srcb2D;
	//execute stage
	wire [1:0] forwardaE,forwardbE;
	wire [1:0] forwardhiloE;
	wire [4:0] rsE,rtE,rdE;
	wire [4:0] writeregE;
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
	wire [31:0] aluoutE;
	//mem stage
	wire [4:0] writeregM;
	//writeback stage
	wire [4:0] writeregW;
	wire [31:0] aluoutW,readdataW,resultW;
	wire [4:0] saD,saE;
	wire [1:0]hilo_weW,hilo_weM,hilo_weE;
	wire [31:0]hi_alu_outM,hi_alu_outW,hi_alu_outE,hiE,hi2E;
	wire [31:0]lo_alu_outM,lo_alu_outW,lo_alu_outE,loE,lo2E;

	//hazard detection
	hazard h(
		//fetch stage
		.stallF(stallF),
		//decode stage
		.rsD(rsD),.rtD(rtD),
		.branchD(branchD),
		.forwardaD(forwardaD),.forwardbD(forwardbD),
		.stallD(stallD),
		//execute stage
		.rsE(rsE),.rtE(rtE),
		.writeregE(writeregE),
		.regwriteE(regwriteE),
		.memtoregE(memtoregE),
		.forwardaE(forwardaE),.forwardbE(forwardbE),
		.flushE(flushE),
		//mem stage
		.writeregM(writeregM),
		.regwriteM(regwriteM),
		.memtoregM(memtoregM),
		//write back stage
		.writeregW(writeregW),
		.regwriteW(regwriteW),
		//hilo 
		.hilo_weM(hilo_weM),
		.hilo_weE(hilo_weE),
		.hilo_weW(hilo_weW),
		.forwardhiloE(forwardhiloE)
		);

	//next PC logic (operates in fetch an decode)
	mux2 #(32) pcbrmux(.a(pcplus4F),.b(pcbranchD),.op(pcsrcD),.out(pcnextbrFD));
	mux2 #(32) pcmux(.a(pcnextbrFD),
		.b({pcplus4D[31:28],instrD[25:0],2'b00}),
		.op(jumpD),.out(pcnextFD));

	//regfile (operates in decode and writeback)
	regfile rf(.clk(~clk),.we3(regwriteW),.ra1(rsD),.ra2(rtD),.wa3(writeregW),.wd3(resultW),.rd1(srcaD),.rd2(srcbD));///

	//fetch stage logic
	flopenr #(32) pcreg(clk,rst,~stallF,pcnextFD,pcF);
	adder pcadd1(pcF,32'b100,pcplus4F);
	//decode stage
	flopenr #(32) r1D(clk,rst,~stallD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
	signext se(instrD[15:0],instrD[29:28],signimmD);
	sl2 immsh(signimmD,signimmshD);
	adder pcadd2(pcplus4D,signimmshD,pcbranchD);
	mux2 #(32) forwardamux(srcaD,aluoutM,forwardaD,srca2D);
	mux2 #(32) forwardbmux(srcbD,aluoutM,forwardbD,srcb2D);
	eqcmp comp(srca2D,srcb2D,opD,rtD,equalD);

	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
	assign saD = instrD[10:6];
	//execute stage
	floprc #(32) r1E(clk,rst,flushE,srcaD,srcaE);
	floprc #(32) r2E(clk,rst,flushE,srcbD,srcbE);
	floprc #(32) r3E(clk,rst,flushE,signimmD,signimmE);
	floprc #(5) r4E(clk,rst,flushE,rsD,rsE);
	floprc #(5) r5E(clk,rst,flushE,rtD,rtE);
	floprc #(5) r6E(clk,rst,flushE,rdD,rdE);
	floprc #(5) r7E(clk,rst,flushE,saD,saE);
	floprc #(2) r8E(clk,rst,flushE,hilo_weD,hilo_weE);

	mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);
	mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
	//hiE hiE,hi_alu_outM hilo_oM[63:32],hi_alu_outW hilo_oW[63:32];
	mux3 #(32) forwardhimux(hiE,hi_alu_outM,hi_alu_outW,forwardhiloE,hi2E);
	mux3 #(32) forwardlomux(loE,lo_alu_outM,lo_alu_outW,forwardhiloE,lo2E);

	mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);

	alu alu(.a(srca2E),.b(srcb3E),.op(alucontrolE),.sa(saE),.hilo_we(hilo_weE),.hi(hi2E),
		.lo(lo2E),.res(aluoutE),.hi_alu_out(hi_alu_outE),.lo_alu_out(lo_alu_outE));
	mux2 #(5) wrmux(rtE,rdE,regdstE,writeregE);

	//mem stage
	flopr #(32) r1M(clk,rst,srcb2E,writedataM);
	flopr #(32) r2M(clk,rst,aluoutE,aluoutM);
	flopr #(5) r3M(clk,rst,writeregE,writeregM);
	flopr #(32) r4M(clk,rst,hi_alu_outE,hi_alu_outM);
	flopr #(32) r5M(clk,rst,lo_alu_outE,lo_alu_outM);
	flopr #(2) r6M(clk,rst,hilo_weE,hilo_weM);
	//writeback stage
	flopr #(32) r1W(clk,rst,aluoutM,aluoutW);
	flopr #(32) r2W(clk,rst,readdataM,readdataW);
	flopr #(5) r3W(clk,rst,writeregM,writeregW);
	flopr #(2) r4W(clk,rst,hilo_weM,hilo_weW);

	flopr #(32) r5W(clk,rst,hi_alu_outM,hi_alu_outW);
	flopr #(32) r6W(clk,rst,lo_alu_outM,lo_alu_outW);
	mux2 #(32) resmux(aluoutW,readdataW,memtoregW,resultW);
	hilo_reg hilo(clk,rst,hilo_weW,hi_alu_outW[31:0],lo_alu_outW[31:0],hiE[31:0],loE[31:0]);

endmodule
