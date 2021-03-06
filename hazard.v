`timescale 1ns / 1ps
`include"defines.h"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/03 19:39:30
// Design Name: 
// Module Name: hazard
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


module hazard(
    input wire[4:0] rsD,rtD,rsE,rtE,writereg2E,writeregM,writeregW,
    input wire branchD,regwriteE,memtoregE,regwriteM,memtoregM,regwriteW,balD,jumpD,jrD,
    input wire [1:0]hilo_weM,hilo_weW,hilo_weE,
    input wire [4:0]alucontrolE,
    input wire div_ready,
    output wire div_start,
    output wire stallF,stallD,stallE,flushE,
    output reg  [1:0]forwardaE,forwardbE,
    output wire [1:0]forwardaD,forwardbD,
    output wire [1:0]forwardhiloE
    );
    wire lwstall;
    always@(*)begin
        if((rsE != 0) && (rsE == writeregM) && regwriteM)
            forwardaE <= 2'b10;
        else if((rsE != 0) && (rsE == writeregW) && regwriteW)
            forwardaE <= 2'b01;
        else
            forwardaE <= 2'b00;
        if((rtE != 0) && (rtE == writeregM) && regwriteM)
            forwardbE <= 2'b10;
        else if((rtE != 0) && (rtE == writeregW) && regwriteW)
            forwardbE <= 2'b01;
        else
            forwardbE <= 2'b00;
    end
    
    assign lwstall = ((rsD == rtE) || (rtD == rtE)) && memtoregE;
    //normal forward
    //assign forwardaD = ((rsD != 0) && (rsD == writeregM) && regwriteM);
    assign forwardaD = (rsD == 0) ? 2'b00:
                       (rsD == writereg2E & regwriteE) ? 2'b01:
                       (rsD == writeregM & regwriteM) ? 2'b10:
                       (rsD == writeregW & regwriteW) ?2'b11: 2'b00;
    assign forwardbD = (rtD == 0) ? 2'b00:
                       (rtD == writereg2E & regwriteE) ? 2'b01:
                       (rtD == writeregM & regwriteM) ? 2'b10:
                       (rtD == writeregW & regwriteW) ?2'b11: 2'b00;
    //hilp forward
    assign forwardhiloE =   (hilo_weE==2'b00 & (hilo_weM==2'b10 | hilo_weM==2'b01 | hilo_weM==2'b11))?2'b01:
                            (hilo_weE==2'b00 & (hilo_weW==2'b10 | hilo_weW==2'b01 | hilo_weW==2'b11))?2'b10:
                            2'b00;
    
    //assign branchstall = ((branchD | jrD | balD )&& regwriteE && (writeregE == rsD || writeregE == rtD)) || (branchD && memtoregM && (writeregM == rsD || writeregM == rtD));
    //div stall
    assign div_start = ((alucontrolE == `DIV_CONTROL) & (div_ready == `DivResultNotReady))  ? 1'b1 : 
                       ((alucontrolE == `DIVU_CONTROL) & (div_ready == `DivResultNotReady)) ? 1'b1 :
                       ((alucontrolE == `DIV_CONTROL) & (div_ready == `DivResultReady))     ? 1'b0 : 
                       ((alucontrolE == `DIVU_CONTROL) & (div_ready == `DivResultReady))    ? 1'b0 :  
                       1'b0;            

    assign stallF = (lwstall | div_start);
    assign stallD = stallF;
    //assign flushD = stallF;
    assign stallE = div_start;
   // assign flushE = lwstall;
   assign flushE = lwstall | jumpD | (branchD & (!balD));
endmodule
