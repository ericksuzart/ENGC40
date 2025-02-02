`timescale 1ns/1ns

module TB_BlackJack;

// Clock
reg clk, clk_PLL;

// Botões
reg	ResetBtn;
wire StayBtn, HitBtn;

// Fios de saída de fim de jogo
wire o_Win, o_Lose, o_Tie;

// Fios de saída dos leds de Hit e Stay
wire o_Hit_P, o_Hit_D, o_Stay_P, o_Stay_D;

// Fios de saída para o display
wire [0:6] DealerHndDisplayD, DealerHndDisplayU;
wire [0:6] PlayerHndDisplayD, PlayerHndDisplayU;

// Saídas dos debouncers
wire w_HitPE, w_ResetDeb, w_ResetNE, w_ResetPE, w_StayPE;

wire w_HitDeb, w_HitNE, w_StayDeb, w_StayNE;

// Estados da máquina de estados global:
reg [8*15:0] StateStringGlobal;
wire [4:0] StateFSMGlobal;

// Estados da máquina de estados do embaralhador:
reg [8*15:0] StateStringShuffler;
wire [3:0] StateFSMShuffler;

// Estados da máquina de estados do adicionador de cartas
reg [8*15:0] StateStringCardAdder;
wire [3:0] StateFSMCardAdder;

// Arquivo
reg [31:0] OutputResetFile, OutputGameFile;

// Variáveis de acesso a memória pelo multiplexador para teste
reg MuxEnable;
reg [5:0] TestAddr;
reg TestClk;

reg ResetTester;

BlackJack DUV
(
    .inclk0(clk) ,	// input  inclk0_sig
    .i_Reset(ResetBtn) ,	// input  i_Reset_sig
    .i_Stay(StayBtn) ,	// input  i_Stay_sig
    .i_Hit(HitBtn) ,	// input  i_Hit_sig
    .o_Win(o_Win) ,	// output  o_Win_sig
    .o_Lose(o_Lose) ,	// output  o_Lose_sig
    .o_Tie(o_Tie) ,	// output  o_Tie
    .o_Hit_P(o_Hit_P) ,	// output  o_Hit_P
    .o_Hit_D(o_Hit_D) ,	// output  o_Hit_D
    .o_Stay_P(o_Stay_P) ,	// output  o_Stay_P
    .o_Stay_D(o_Stay_D) ,	// output  o_Stay_D
    .DealerHndDisplayU(DealerHndDisplayU) ,	// output [0:6] DealerHndDisplayU
    .DealerHndDisplayD(DealerHndDisplayD) ,	// output [0:6] DealerHndDisplayD
    .PlayerHndDisplayU(PlayerHndDisplayU) ,	// output [0:6] PlayerHndDisplayU
    .PlayerHndDisplayD(PlayerHndDisplayD), 	// output [0:6] PlayerHndDisplayD

    // saídas extra dos debouncers
    .o_HitDeb(w_HitDeb) ,
    .o_HitNE(w_HitNE) ,
    .o_StayDeb(w_StayDeb) ,
    .o_StayNE(w_StayNE)
);

// Saídas internas dos debouncers
assign DUV.w_ResetDeb = w_ResetDeb; // output  w_ResetDeb
assign DUV.w_ResetPE = w_ResetPE;   // reset posedge
assign DUV.w_ResetNE = w_ResetNE;   // Reset Negedge
assign DUV.w_HitPE = w_HitPE;       // Hit posedge
assign DUV.w_StayPE = w_StayPE;     // Stay posedge


// Tester

Tester Tester
(
    .StateFSM(DUV.b2v_FSM_Global.A_State),
    .TesterHand(DUV.w_PlayerHnd),
    .ResetTester(ResetTester), // DUV.w_ResetPE
    .clk(clk),
    .o_TesterHit(HitBtn),
    .o_TesterStay(StayBtn)
);


// Clocks always

// Clock de 50 MHz
always #5 clk = !clk;

/*50000 kHz - 5 ns
      2 kHz - x    (inversamente proporcional)
      
        x = 5 * 50000 / 2
        x = 125000 
        
        Utilizando 125 para diminuir o tempo de simulação
        125 = 2000 kHz */

// Clock de 2000 kHz
always #250 clk_PLL <= ~clk_PLL;	

assign DUV.clk_PLL = clk_PLL;

//======================================================
//               Monitorando estados
//======================================================

// Acessando os estados da FSM global:
assign StateFSMGlobal = DUV.b2v_FSM_Global.A_State;

always @(*)
begin
    case (StateFSMGlobal)
        5'b 00000 : StateStringGlobal = "Start";
        5'b 00001 : StateStringGlobal = "ShuffleDeck";
        5'b 00010 : StateStringGlobal = "PlayerWith1Card";
        5'b 00011 : StateStringGlobal = "D1_RstCardFSM";
        5'b 00100 : StateStringGlobal = "DealerWith1Card";
        5'b 00101 : StateStringGlobal = "P_RstCardFSM";
        5'b 00110 : StateStringGlobal = "PlayerWith2Card";
        5'b 00111 : StateStringGlobal = "D2_RstCardFSM";
        5'b 01000 : StateStringGlobal = "DealerWith2Card";
        5'b 01001 : StateStringGlobal = "PlayerTurn";
        5'b 01010 : StateStringGlobal = "DealerTurn";
        5'b 01011 : StateStringGlobal = "PlayerHit";
        5'b 01100 : StateStringGlobal = "DealerHit";
        5'b 01101 : StateStringGlobal = "PlayerStay";
        5'b 01110 : StateStringGlobal = "DealerStay";
        5'b 01111 : StateStringGlobal = "CardToPlayer";
        5'b 10000 : StateStringGlobal = "CardToDealer";
        5'b 10001 : StateStringGlobal = "WinState";
        5'b 10010 : StateStringGlobal = "TieState";
        5'b 10011 : StateStringGlobal = "LoseState";
        5'b 10100 : StateStringGlobal = "Measurement";
        5'b 10101 : StateStringGlobal = "DealerBlackJack";
    endcase
end

// Acessando os estados da FSM do embaralhador:
assign StateFSMShuffler = DUV.b2v_FSM_Embaralhador.A_State;

always @(*)
begin
    case (StateFSMShuffler)
        4'b 0000:  StateStringShuffler = "Start";
        4'b 0001:  StateStringShuffler = "InitOutputs";
        4'b 0010:  StateStringShuffler = "I_ReadMemOut";
        4'b 0011:  StateStringShuffler = "I_StoreMemOut";
        4'b 0100:  StateStringShuffler = "GetNxtAddr";
        4'b 0101:  StateStringShuffler = "J_ReadMemOut";
        4'b 0110:  StateStringShuffler = "J_StoreMemOut";
        4'b 0111:  StateStringShuffler = "J_WriteMemAddr";
        4'b 1000:  StateStringShuffler = "ChangeAddr";
        4'b 1001:  StateStringShuffler = "I_WriteMemAddr";
        4'b 1010:  StateStringShuffler = "IfState";
        4'b 1011:  StateStringShuffler = "IncreaseAddr";
        4'b 1100:  StateStringShuffler = "Shuffled";
    endcase
end

// Acessando os estados da FSM do adicionador de cartas
assign StateFSMCardAdder = DUV.b2v_FSM_CardAdder.A_State;

always @(*)
begin
    case (StateFSMCardAdder)
        4'b 0000 : StateStringCardAdder = "Start";
        4'b 0001 : StateStringCardAdder = "Wait_FSM";
        4'b 0010 : StateStringCardAdder = "ReadMem";
        4'b 0011 : StateStringCardAdder = "Value2Dealer";
        4'b 0100 : StateStringCardAdder = "Value2Player";
        4'b 0101 : StateStringCardAdder = "DealerWithAce";
        4'b 0110 : StateStringCardAdder = "DealerWithFace";
        4'b 0111 : StateStringCardAdder = "PlayerWithAce";
        4'b 1000 : StateStringCardAdder = "PlayerWithFace";
        4'b 1001 : StateStringCardAdder = "PlusTenDealer";
        4'b 1010 : StateStringCardAdder = "PlusTenPlayer";
        4'b 1011 : StateStringCardAdder = "CardOK";
    endcase
end

// Monitorar o estado do Shuffler

reg ShowStates; // variável para indicar se deve-se mostrar os estados

always @(StateFSMShuffler)
begin
    if(ShowStates)
    begin
        #1 ;
        // $display("[%t] - Shuffler State: %8s | %s |",$time ," ", StateStringShuffler);
        // $fdisplay(OutputResetFile, "[%t] - Shuffler State: %8s | %s |",$time ," ", StateStringShuffler);
        $fdisplay(OutputGameFile, "[%t] - Shuffler State: %8s | %s |",$time ," ", StateStringShuffler);
        
        case (StateFSMShuffler)
            4'b 0010 : // I_ReadMemOut
                $fdisplay(OutputGameFile, "\n[%t] -        Lido: %d do endereço %d \n",$time ,DUV.w_CardValue, DUV.w_S_Addr);

            4'b 0101 : // J_ReadMemOut
                $fdisplay(OutputGameFile, "\n[%t] -        Lido: %d do endereço %d \n",$time ,DUV.w_CardValue, DUV.w_S_Addr);

            4'b 1001 : // I_WriteMemAddr
                $fdisplay(OutputGameFile, "\n[%t] -        Trocado: %d com %d \n",$time ,DUV.w_S_Addr_J, DUV.w_S_Addr_I);
        endcase
    end
end

// Monitorar o estado do CardAdder
always @(StateFSMCardAdder)
begin
    if (ShowStates)
    begin
        #1 ;
        // $display("[%t] - CardAdder State:   | %s |",$time , StateStringCardAdder);
        // $fdisplay(OutputResetFile, "[%t] - CardAdder State:   | %s |",$time , StateStringCardAdder);
        $fdisplay(OutputGameFile, "[%t] - CardAdder State:         | %s |",$time , StateStringCardAdder);

        #1 ;
        if (StateFSMCardAdder == 4'b 1011)
        begin
            // $display("Player Hand: %d\nDealer Hand: %d", DUV.w_PlayerHnd, DUV.w_DealerHnd);
            // $fdisplay(OutputResetFile, "Player Hand: %d\nDealer Hand: %d", DUV.w_PlayerHnd, DUV.w_DealerHnd);
            $fdisplay(OutputGameFile, "\n       Player Hand: %d\n       Dealer Hand: %d\n", DUV.w_PlayerHnd, DUV.w_DealerHnd);
        end
    end
end

// Monitorar o estado do BlackJackController
always @(StateFSMGlobal)
begin
    if(ShowStates)
    begin
        // $display("||=================================================================||\n[%t] - BJController State: | %s |\n||=================================================================||",$time , StateStringGlobal);
        // $fdisplay(OutputResetFile, "||=================================================================||\n[%t] - BJController State: | %s |\n||=================================================================||",$time , StateStringGlobal);
        $fdisplay(OutputGameFile, "||=================================================================||\n[%t] - BJController State:      | %s |\n||=================================================================||",$time , StateStringGlobal);
    end
end

// Monitorar se o player deu hit ou stay
always @(o_Hit_P or o_Stay_P)
begin
    if (o_Hit_P)
        $fdisplay(OutputGameFile, "\n[%t] - O jogador deu Hit \n",$time);
    if (o_Stay_P)
        $fdisplay(OutputGameFile, "\n[%t] - O jogador deu Stay \n",$time);
end

// Monitorar se o dealer deu hit ou stay
always @(o_Hit_D or o_Stay_D)
begin
    if (o_Hit_D)
        $fdisplay(OutputGameFile, "\n[%t] - O dealer deu Hit \n",$time);
    if (o_Stay_D)
        $fdisplay(OutputGameFile, "\n[%t] - O dealer deu Stay \n",$time);
end

//======================================================
//                      Tasks
//======================================================

/* Task para simular um reset do player e verificar se o contador está
funcionando corretamente*/

reg [11:0] r_Contador;

task PlayerReset (input [31:0] clock_cicles, input Display);
    begin
        // Testar um input randomico de reset
        if (Display)
            // $display("||=================================================================||\n[%t] - O contador esta sendo testado com relacao ao reset", $time);
            $fdisplay(OutputResetFile, "||=================================================================||\n[%t] - O contador esta sendo testado com relacao ao reset", $time);
            $fdisplay(OutputGameFile, "||=================================================================||\n[%t] - O contador esta sendo testado com relacao ao reset", $time);

        // Inicizalizar o contador de checagem
        @(posedge clk_PLL) ResetBtn = 0;
        // @(posedge clk_PLL); // reseta o contador    

        if(clock_cicles)
        begin
            @(negedge clk_PLL) r_Contador = DUV.w_Count;
        end
        else
            @(posedge clk_PLL);

        // Repete un múmero de ciclos de clock dado pelo usuário
        repeat(clock_cicles)
        begin
            @(posedge clk_PLL) r_Contador = r_Contador + 1;
        end

        ResetBtn = 1;

        // Verifica se a saída está como o esperado
        if(clock_cicles)
            @(negedge clk_PLL);
        else
            r_Contador = 0;

        if(Display)
            if (r_Contador == DUV.w_Count)
            begin
                // $display("[%t] - O contador, quando ativo no reset, esta funcionando corretamente e contou ate %d\n||=================================================================||", $time, DUV.w_Count);

                $fdisplay(OutputResetFile, "[%t] - O contador, quando ativo no reset, esta funcionando corretamente:\nContador: %d", $time, DUV.w_Count);
                $fdisplay(OutputGameFile, "[%t] - O contador, quando ativo no reset, esta funcionando corretamente:\nContador: %d", $time, DUV.w_Count);
            end
            else
            begin
                // $display("[%t] - O contador, quando ativo no reset, nao esta funcionando corretamente:\n ContadorTB:%d\nContador:%d\n||===========================================||", $time,r_Contador, DUV.w_Count);
                $fdisplay(OutputResetFile, "[%t] - O contador, quando ativo no reset, nao esta funcionando corretamente:\n ContadorTB:%d\nContador:%d\n||=================================================================||", $time,r_Contador, DUV.w_Count);
                $fdisplay(OutputGameFile, "[%t] - O contador, quando ativo no reset, nao esta funcionando corretamente:\n ContadorTB:%d\nContador:%d\n||=================================================================||", $time,r_Contador, DUV.w_Count);
            end
    end
endtask

// Task to read from a memory module
// wire [5:0] w_Addr;

// reg [3:0] r_Ram [51:0];

// task read (input [5:0] address, output [3:0] data);
//     begin
//         TestEnable = 1;
//         TestAddr = address;
//         @(posedge clk);
//         TestClk = 1;
//         @(posedge clk);
//         data = DUV.w_MemData;
//         TestClk = 0;
//         TestEnable = 0;
//         $display("[%t] -> %d read from address %d", $time, data, address);
//         $display("_____________________________");
//     end
// endtask

// // Task para verificar se a memória foi embaralhada

// task CheckMem;
//     begin
        
//     end
// endtask

//======================================================
//                  Blocos iniital
//======================================================

/* Teste do reset e do contador, utilizar um clk_PLL de 125 pois o de 125000
demora de mais! 

Distintos tempos de botão pressionado fazem a mão do player e do dealer serem
diferentes assim, se essa condição se mostrar plausível no log do TestBench, o
Counter, o Shuffler, o CardAdder e o BJController estão funcionando corretamente
neste aspecto

Esse initial irá testar todas as possibilidades do contador e nos mostrar as
cartas iniciais do Player e do Dealer */

integer i;
reg ResetTestFinished;

initial
begin : ResetTest
    // Precisão do tempo
    $timeformat(-3, 2, " ms", 10);

    // Abrir o arquivo de saída
    OutputResetFile = $fopen("ResetTest2.txt","w");

    if (!OutputResetFile)
        $display("Nao foi possivel abrir o arquivo!");

    else
    begin
        $display("||########################################################################################||\n[%t] - Começando o testbench para verificar se o contador e o embaralhador estão funcionais\n||########################################################################################||\n", $time);
        
        $fdisplay(OutputResetFile, "||########################################################################################||\n[%t] - Começando o testbench para verificar se o contador e o embaralhador estão funcionais\n||########################################################################################||\n", $time);

        clk = 0;
        clk_PLL = 1'b0;
        ResetBtn = 1;
        // ShowStates = 0; // Tirar o comentário para testar todas as possibilidades
        ShowStates = 1; // Comentar para testar todas as possibilidades
        ResetTestFinished = 0;

        // for(i = 0; i < 4096; i= i +1)    // Tirar o comentário para testar todas as possibilidades
        // for(i = 0; i < 40; i= i +1)      // Player com BlackJack
        // for(i = 0; i < 41; i= i +1)      // Dealer com BlackJack
        // for(i = 0; i < 317; i= i +1)     // Teste de empate
        for(i = 0; i < 0; i= i +1) // Comentar para testar as demais possibilidades
        begin
            #5970 PlayerReset(i,1);

            wait (DUV.w_Count == i)
            begin
                // Tempo de embaralhar e adicionar as cartas
                #5960;
                // $display("Player Hand: %d\nDealer Hand: %d", DUV.w_PlayerHnd, DUV.w_DealerHnd);
                $fdisplay(OutputResetFile, "Player Hand: %d\nDealer Hand: %d\n||=================================================================||", DUV.w_PlayerHnd, DUV.w_DealerHnd);
            end
        end

        # 10000 ;
        ResetTestFinished = 1;
        $display("\n||=================================================================||\n[%t] - Terminado o teste do contador e do embaralhador\n||=================================================================||", $time);
        $fdisplay(OutputResetFile, "\n||=================================================================||\n[%t] - Terminado o teste do contador e do embaralhador\n||=================================================================||", $time);
        
        $fclose(OutputResetFile);
    end
    // $stop;
end

initial
begin : GameTest
    wait(ResetTestFinished)
    begin
        // Precisão do tempo
        // Está em milisegundos porém 
        $timeformat(-3, 5, " s", 10);

        // Abrir o arquivo de saída
        OutputGameFile = $fopen("GameTest.txt","w");

        if (!OutputGameFile)
            $display("Nao foi possivel abrir o arquivo!");

        else
        begin
            $display("||########################################################################################||\n[%t] - Começando o testbench para verificar o funcionamento do jogo\n||########################################################################################||\n", $time);
            
            $fdisplay(OutputGameFile, "||########################################################################################|\n[%t] - Começando o testbench para verificar o funcionamento do jogo\n||########################################################################################||\n", $time);

            clk = 0;
            clk_PLL = 1'b0;
            ResetBtn = 1;
            ShowStates = 1;
            
            
            // PlayerReset(40,0)    // Player com BlackJack (ativar em ResetTest o correspondente)
            // PlayerReset(41,0)    // Dealer com BlackJack (ativar em ResetTest o correspondente)
            // PlayerReset(317,0);  // Teste de empate com blackjack (ativar em ResetTest o correspondente)
            // PlayerReset(0,0);    // Player perde
            // PlayerReset(4,0);    // Jogador perde com Dealer com 21
            PlayerReset(3,0);    // Teste de empate sem blackjack

            wait (o_Win || o_Lose || o_Tie)
            begin
                if (o_Win)
                    $fdisplay(OutputGameFile, "\n[%t] - O jogador venceu essa jogada\n", $time);
                if (o_Lose)
                    $fdisplay(OutputGameFile, "\n[%t] - O jogador perdeu essa jogada\n", $time);
                if (o_Tie)
                    $fdisplay(OutputGameFile, "\n[%t] - O jogador empatou essa jogada\n", $time);
            end
            
            $display("\n||########################################################################################||\n[%t] - Terminado o teste para verificar o funcionamento do jogo\n||########################################################################################||", $time);
            $fdisplay(OutputGameFile, "\n||########################################################################################||\n[%t] - Terminado o teste para verificar o funcionamento do jogo\n||########################################################################################||", $time);
            
            $fclose(OutputGameFile);
        end

        $stop;
    end
end

always @(posedge clk)
begin
    if(ResetTestFinished)
        ResetTester <= DUV.w_ResetPE;
    else
        ResetTester <= 1;
end
endmodule // TB_BlackJack