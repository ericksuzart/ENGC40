// Copyright (C) 2018  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details.


// Generated by Quartus Prime Version 18.1 (Build Build 625 09/12/2018)
// Created on Thu Nov 28 01:26:25 2019

BlackJack BlackJack_inst
(
	.inclk0(inclk0_sig) ,	// input  inclk0_sig
	.i_Reset(i_Reset_sig) ,	// input  i_Reset_sig
	.i_Stay(i_Stay_sig) ,	// input  i_Stay_sig
	.i_Hit(i_Hit_sig) ,	// input  i_Hit_sig
	.o_Win(o_Win_sig) ,	// output  o_Win_sig
	.o_Lose(o_Lose_sig) ,	// output  o_Lose_sig
	.o_Tie(o_Tie_sig) ,	// output  o_Tie_sig
	.o_Hit_P(o_Hit_P_sig) ,	// output  o_Hit_P_sig
	.o_Hit_D(o_Hit_D_sig) ,	// output  o_Hit_D_sig
	.o_Stay_P(o_Stay_P_sig) ,	// output  o_Stay_P_sig
	.o_Stay_D(o_Stay_D_sig) ,	// output  o_Stay_D_sig
	.DealerHndDisplayU(DealerHndDisplayU_sig) ,	// output [0:6] DealerHndDisplayU_sig
	.DealerHndDisplayD(DealerHndDisplayD_sig) ,	// output [0:6] DealerHndDisplayD_sig
	.PlayerHndDisplayU(PlayerHndDisplayU_sig) ,	// output [0:6] PlayerHndDisplayU_sig
	.PlayerHndDisplayD(PlayerHndDisplayD_sig) ,	// output [0:6] PlayerHndDisplayD_sig
	.o_ResetState(o_ResetState_sig) ,	// output  o_ResetState_sig
	.o_StayState(o_StayState_sig) ,	// output  o_StayState_sig
	.o_StayDown(o_StayDown_sig) ,	// output  o_StayDown_sig
	.o_HitState(o_HitState_sig) ,	// output  o_HitState_sig
	.o_HitDown(o_HitDown_sig) 	// output  o_HitDown_sig
);

