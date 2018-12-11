`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/03 18:48:17
// Design Name: 
// Module Name: top
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


module top(
	input wire clk,rst,
	output wire[31:0] writedata,dataadr,
	output wire memwrite
    );

	wire[31:0] pc,instr,readdata;
       
	mips mips(clk,rst,pc,instr,memwrite,dataadr,writedata,readdata);
	blk_mem_gen_0 imem(.clka(~clk),.addra(pc[9:2]),.douta(instr));
	blk_mem_gen_1 dmem(.clka(~clk),.wea({3'b000,memwrite}),.addra(dataadr),.dina(writedata),.douta(readdata));
endmodule

