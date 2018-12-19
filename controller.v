`timescale 1ns / 1ps
`include"defines.h"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/03 18:55:02
// Design Name: 
// Module Name: controller
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


module controller(
	input wire clk,rst,
	//decode stage
	input wire [31:0]instrD,
	output wire pcsrcD,branchD,
	input wire equalD,
	output wire jumpD,jalD,jrD,balD,//jump
	output wire memenD,
	//execute stage
	input wire flushE,stallE,
	input wire overflow,///////-----------------new signal
	output wire memtoregE,alusrcE,
	output wire regdstE,regwriteE,	
	output wire[4:0] alucontrolE,

	//mem stage
	output wire memtoregM,memwriteM,
				regwriteM,memenM,
	//output wire [3:0] sel,
	//write back stage
	output wire memtoregW,regwriteW,
	output wire[1:0] hilo_we
 
    );
	
	//decode stage
	wire memtoregD,memwriteD,alusrcD,
		regdstD,regwriteD;
	wire jalD,jrD,balD;
	wire[4:0] alucontrolD;
	wire[5:0]opD,functD;
	assign opD=instrD[31:26];
	assign functD=instrD[5:0];
	//execute stage
	wire memwriteE;
	wire memenE;
//regwrite,regdst,alusrc,bracn,memen,memtoreg,jump,jal,jr,bal,memwrite;
	maindec md(
		.instr(instrD),
		.control({regwriteD,regdstD,alusrcD,branchD,memenD,memtoregD,jumpD,jalD,jrD,balD,memwriteD}),
		.hilo_we(hilo_we)
		);
	aludec ad(.op(opD),.funct(functD),.alucontrol(alucontrolD));


	assign pcsrcD = (branchD | balD) & equalD;
	//pipeline registers
	flopenrc #(11) regE(
		clk,
		rst,
		~stallE,
		flushE,
		{memtoregD,memwriteD,alusrcD,regdstD,regwriteD,memenD,alucontrolD},
		{memtoregE,memwriteE,alusrcE,regdstE,regwriteE,memenE,alucontrolE}
		);
	flopr #(4) regM(
		clk,rst,
		{memtoregE,memwriteE,regwriteE & (~overflow),memenE},//overflow cause error
		{memtoregM,memwriteM,regwriteM,memenM}
		);
	flopr #(2) regW(
		clk,rst,
		{memtoregM,regwriteM},
		{memtoregW,regwriteW}
		);
endmodule
