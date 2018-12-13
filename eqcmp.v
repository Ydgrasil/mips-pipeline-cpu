`timescale 1ns / 1ps
`include"defines.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/08 14:40:02
// Design Name: 
// Module Name: eqcmp
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



module eqcmp(
    input wire[31:0] a,b,
    input wire[5:0]  op,
    input wire[4:0]  rt,
    output wire c
    );
    assign c = (op == `BEQ)  ? (a == b):
               (op == `BNE)  ? (a != b):
               (op == `BGTZ) ? ((a[31] == 1'b0) && (a != `ZeroWord)):
               (op == `BLEZ) ? ((a[31] == 1'b1) || (a == `ZeroWord)):
               (op == `BLTZ || op == `BLTZAL) ? (a[31] == 1'b1):  
               (op == `BGEZ || op == `BGEZAL) ? ((a[31] == 1'b0) || (a == `ZeroWord)):
               1'b0;
               ////BLTZAL  rs的值小于 0则转移
               /// BGEZAL rs的值大于等于 0则转移 


endmodule

