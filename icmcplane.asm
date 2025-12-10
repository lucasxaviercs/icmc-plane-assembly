; =**** ICMC PLANE ****=


jmp main

; Declaração de Variáveis Globais


AviaoPos:   var #1      ; Armazena a posição do avião na tela
AviaoChar:  var #1      ; Armazena o caracter que é o avião (NO NOSSO CASO É A CRASE)
ObsLista:   var #15     ; Armazena em um vetor os obstáculos ativos na tela
ObsType:    var #15     ; Esse é o tipo de obstáculos, temos dois tipos ('$' e '%')
RandSeed:   var #1      ; É um índice para geração aleatória no RandTable
LoopCount:  var #1      ; Contados usado para controlar a frequencia de spawn dos obstáculos
Entropy:    var #1      ; Variável gerada para adicionar imprevisibilidade e não ter um padrão de obstáculos, além de auxiliar para que não haja coluna que não caia obstáculos


ScoreCount: var #1      ; Contador do tempo que define quando o jogador ganhará ponto (*)
ScorePos:   var #1      ; Armazena na tela a posição do score
StarCount:  var #1      ; Armazena a quantidade de estrelas até o momento (OBS: quando chega em 5 estrelas, você zerou o jogo)

; Mensagens utilizadas durante o código
MsgGO:      string "GAME OVER"
MsgWin:     string "PARABENS! VOCE ZEROU O JOGO!" 
MsgRest:    string "SPACE: Jogar Novamente" 
MsgMenu:    string "E: Sair do jogo"     
MsgScore:   string "SCORE:"

; Tabela aleatória que auxilia na geração de obstáculos por meio de números randomicos [VETOR RANDOM]
RandTable:  var #60
static RandTable + #0, #13
static RandTable + #1, #03
static RandTable + #2, #37
static RandTable + #3, #05
static RandTable + #4, #09
static RandTable + #5, #39
static RandTable + #6, #08
static RandTable + #7, #01
static RandTable + #8, #18
static RandTable + #9, #02
static RandTable + #10, #29
static RandTable + #11, #11
static RandTable + #12, #25
static RandTable + #13, #04
static RandTable + #14, #33
static RandTable + #15, #15
static RandTable + #16, #28
static RandTable + #17, #07
static RandTable + #18, #36
static RandTable + #19, #06
static RandTable + #20, #19
static RandTable + #21, #26
static RandTable + #22, #10
static RandTable + #23, #34
static RandTable + #24, #12
static RandTable + #25, #00
static RandTable + #26, #38
static RandTable + #27, #21
static RandTable + #28, #14
static RandTable + #29, #30
static RandTable + #30, #22
static RandTable + #31, #27
static RandTable + #32, #17
static RandTable + #33, #35
static RandTable + #34, #31
static RandTable + #35, #24
static RandTable + #36, #16
static RandTable + #37, #32
static RandTable + #38, #23
static RandTable + #39, #20
static RandTable + #40, #11
static RandTable + #41, #25
static RandTable + #42, #02
static RandTable + #43, #38
static RandTable + #44, #14
static RandTable + #45, #05
static RandTable + #46, #30
static RandTable + #47, #19
static RandTable + #48, #01
static RandTable + #49, #39
static RandTable + #50, #00
static RandTable + #51, #22
static RandTable + #52, #18
static RandTable + #53, #36
static RandTable + #54, #08
static RandTable + #55, #29
static RandTable + #56, #13
static RandTable + #57, #33
static RandTable + #58, #07
static RandTable + #59, #20

; =*** MAIN ***=
main:
    call ImprimeTelaIncial   
    call ClearScreen    

Game_Init:
    call ClearScreen

    ; Coloca o avião na sua posição inicial
    loadn r0, #1140     
    store AviaoPos, r0  
    loadn r0, #'`'      
    store AviaoChar, r0 
    
    ; Zera os contadores 
    loadn r0, #0
    store RandSeed, r0
    store LoopCount, r0
    store Entropy, r0    
    store ScoreCount, r0 
    store StarCount, r0  

    ; Limpa o vetor de obstáculos 
    loadn r0, #ObsLista
    loadn r1, #15
    loadn r2, #0
    call LimparBuffer
    
    loadn r0, #ObsType
    loadn r1, #15
    loadn r2, #0
    call LimparBuffer
    
    call LimpaScore
    
    ; Posiciona o layout (LINHA 0) para imprimir o score
    loadn r0, #0           
    loadn r1, #MsgScore    
    loadn r2, #2304        
    call ImprimirStrings 
    
    ; Antes de contabilizar as  estrelas (*), escrevemos a string "SCORE:" utilizando 6 caracteres, por isso
    ;colocamos a posição das * a partir do 7
    loadn r0, #7           
    store ScorePos, r0     

; Loop que executa as principais funções do jogo
Game_Loop:
    ; OBS: Utilizamos essa parte, com a variável Entropy, para que ela mude constantemente a cada ciclo
    ; Como ela é somada ao RandSeed na função Random para que os obstáculos
    ; não tenha um padrão repetitivo
    load r0, Entropy 
    inc r0
    loadn r1, #100
    mod r0, r0, r1 ; r0 = (ENTROPY + 1) % 100
    store Entropy, r0 ; 
    
    
    call Desenhar_TelaJogo ; Chama a função que faz a tela de fundo do jogo
    
    call InputTeclado ; verifica se a pessoa está teclando 'A' ou 'D'
    call MovimentoObstaculos ; movimenta obstáculos
    call SpawnObstaculos  ; gera obstáculos   
    call DesenhaAviao        ; Desenha o caracter do avião na nova posição
    call AtualizaScore    ; Verifica se o jogador ganhou ponto
    call Delay      ; Funçao auxiliar que melhora a jogabilidade   
    jmp Game_Loop

; Função para gerar os números randomicos
FuncRandom:
    push r1
    push r2
    push r3
    push r4
    
    ; Pega um número da tabela declarada lá no ínicio do código
    load r1, RandSeed ; carrega o índice atual
    loadn r2, #RandTable ; carrega o end. onde a tabela começa na memória
    add r2, r2, r1
    loadi r0, r2        
    
    ; Adiciona imprevisibilidade
    load r4, Entropy  
    add r0, r0, r4      
    
    ; Limita ao tamanho da tela do simulador
    loadn r3, #40
    mod r0, r0, r3      
    
    ; Já faz uma preparação para gerar o próximo número randomico
    inc r1
    loadn r3, #60       
    mod r1, r1, r3
    store RandSeed, r1
    
    pop r4
    pop r3
    pop r2
    pop r1
    rts


; Gera obstáculos
SpawnObstaculos:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    
    ; controle de tempo para não gerar muitos obstáculos
    load r0, LoopCount
    inc r0
    loadn r1, #4        
    cmp r0, r1
    jle SpawnObsPular ;se não deu um tempo mínimo, da um jump
    
    ; Zera para gerar o próximo
    loadn r0, #0
    store LoopCount, r0
    
    ; Busca espaços não ocupados no vetor de Obstáculos
    loadn r1, #ObsLista
    loadn r4, #ObsType
    loadn r2, #15
ObstaculosEspacoVetor:
    loadi r0, r1 ; le o slot/índice atual
    loadn r3, #0
    cmp r0, r3
    jeq ObstaculosEspacoAchei ; se for 0, é pq tem espaço
    inc r1
    inc r4
    dec r2
    jnz ObstaculosEspacoVetor
    jmp SairSpawnObstaculos 
    
; Achei espaço no vetor de obstáculos? SIM
; Gera o obstáculos, podendo ser $ o %, em uma posição aleatória
ObstaculosEspacoAchei:
    call FuncRandom   ;sorteia um número       
    
    loadn r3, #40       
    add r0, r0, r3    ; posição final = random + 40
    
    storei r1, r0  ; salva posição calculada dentro do vetor    
    
    ; essa parte é uma forma de escolher o tipo do obstaculo
    loadn r3, #2
    mod r3, r0, r3
    loadn r5, #0
    cmp r3, r5
    jeq ehPar ; se for par obstaculo = %
    loadn r5, #'$' ; se for impar obstaculo = $
    jmp SalvarTipoObstaculo
ehPar:
    loadn r5, #'%'
SalvarTipoObstaculo:
    storei r4, r5    ; salva o caractere do obstaculo no vetor ObsType   
    
SpawnObsPular:
    store LoopCount, r0
SairSpawnObstaculos:
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts

AtualizaScore:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    
    ; CRONÔMETRO
    load r0, ScoreCount
    inc r0
    
    loadn r1, #150   ; "tempo" necessário para ganhar ponto   
    
    cmp r0, r1
    jne SalvaScore ; se não chegou nos 1800 pula pra esse label
    
    
    loadn r0, #0 ; reseta o cronômetro
         
    ;atualiza o contador de estrelas
    load r4, StarCount
    inc r4
    store StarCount, r4
    
    load r2, ScorePos
    loadn r1, #39        
    cmp r2, r1
    jeg Score_IsFull  ; usado apenas para um salto condicional com um ponto para ir
    ; para um local "seguro" sem executar nada quando chegar     
    
    loadn r3, #'*'       
    loadn r1, #2304      
    add r3, r3, r1   ; adiciona a cor ao caractere    
    outchar r3, r2  ; imprime o * na cor selecionada   
    inc r2 ; avança posição
    store ScorePos, r2   
    
    loadn r5, #5
    cmp r4, r5
    jeq Game_Win          

    jmp SalvaScore

Score_IsFull:
    nop

SalvaScore:
    store ScoreCount, r0 
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts

Game_Win:
    call ClearScreen
    loadn r0, #530
    loadn r1, #MsgWin
    loadn r2, #2304      
    call ImprimirStrings
    
    loadn r0, #610
    loadn r1, #MsgRest
    call ImprimirStrings
    
    loadn r0, #650
    loadn r1, #MsgMenu
    call ImprimirStrings
    
    jmp InputGAMEOVERLOOP    

MovimentoObstaculos:
    push r0 
    push r1 
    push r2 
    push r3 
    push r4 
    push r5 
    push r6 
    push r7 
    
    loadn r0, #ObsLista ; "ponteiro" para o vetor de posicoes da lista
    loadn r6, #ObsType ; ponteiro para o vetor de tipos de obstaculos
    loadn r2, #15 ; contador para assegurar os 15 slots possiveis de obstaculos
    loadn r3, #40 
    loadn r4, #1200 ;limite inferior da tela
    
MoverObstaculosLoop:
    loadi r1, r0  ; carrega a posição do obstaculo atual em r1 MEM(R1) <- R0      
    loadn r5, #0
    cmp r1, r5
    jeq ObsMovimentaProximo  ; se a posição for 0, slot está vazio, então pulamos para o próximo  
    
    loadi r7, r6  ; carrega o obstaculo de um dos tipos para r7      
    
    ; Lógica para pintar cada um dos obstáculos de uma cor
    loadn r5, #'$'      
    cmp r7, r5
    jeq PintarVermelhoObs   ; pintar de vermelho    

    ; Pintar Cinza
    loadn r5, #2304   
    jmp AplicarCorObstaculo     

PintarVermelhoObs:
    loadn r5, #2304     

AplicarCorObstaculo:
    add r7, r7, r5 ; r7 agora possui o caractere + a cor 

    loadn r5, #' ' ; apaga sua posição antiga (apagar o rastro)
    outchar r5, r1      
    
    add r1, r1, r3  ; move para baixo   
    cmp r1, r4 ; compara a nova posição com o limite inferior da tela
    jeg ApagarObstaculo  ; apaga obstaculo se estiver no limite inferior da tela  
    
    load r5, AviaoPos   ; carrega a posicao do jogador
    cmp r1, r5          ; compara posicao do jogador com a dos obstáculos
    jeq Game_Over       ; se estiver na mesma posição => Gameover
    
    outchar r7, r1 ; desenha o caractere colorido na nova posição     
    storei r0, r1  ; atualiza a memória (ObsLista) com a nova posição
    jmp ObsMovimentaProximo

ApagarObstaculo:
    loadn r5, #0 
    storei r0, r5 ; gravo 0 na posição da memória atual, sinalizando que aquele espaço está
    ; livre, liberando o espaço para novos obstáculos

ObsMovimentaProximo:
    inc r0 ; avanço ponteiro de posição
    inc r6 ; avanço o ponteiro do tipo de obstáculo
    dec r2 ; decremento o contador da cap do vetor
    jnz MoverObstaculosLoop
    
    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts

;Le a entrada do teclado (stdin) do usuário
InputTeclado:
    push r0
    push r1
    push r2
    push r3
    
    inchar r0 ;leitura do teclado e salva em r0
    
    loadn r1, #255 ; verificação de ociosidade
    cmp r0, r1
    jeq Input_Exit ;sair
    
    load r2, AviaoPos   ; salva em r2 o endereço do AviaoPos
    
    loadn r3, #' ' ; carrega r3 com space
    
    loadn r1, #'a'
    cmp r0, r1
    jeq Input_Esquerda ; anda para esquerda
    
    loadn r1, #'d'
    cmp r0, r1
    jeq Input_Direita
    jmp Input_Exit ;sair

; anda para esquerda
Input_Esquerda:
    outchar r3, r2 ; Desenha um SPACE ' ' (R3) na posição atual R2
    
    loadn r1, #40 ; Cálculo para ver se não passamos nos limites laterais da tela
    mod r1, r2, r1
    
    loadn r3, #0 ; carrega 0, indíce do limite da esquerda
    
    cmp r1, r3
    jeq Input_Update ; colisão com os limites laterais da tela
    
    dec r2 ; Verificou que não é "PAREDE" e passou
    ; então subtrai 1 da posição atual, andando para esquerda
    
    jmp Input_Update ; Atualizo a posição na memória (SALVANDO ELA NA MEMÓRIA)

Input_Direita:
    outchar r3, r2 ; Desenha um SPACE ' ' (R3) na posição atual R2
    
    loadn r1, #40 ; Cálculo para ver se não passamos nos limites laterais da tela
    mod r1, r2, r1
    
    loadn r3, #39 ; carrega 39, índice do limite da direita
    
    cmp r1, r3
    jeq Input_Update ; colisão com o limite da direita da tela
    
    inc r2 ; Verificou que não é "PAREDE" e passou
    ; então adiciona 1 da posição atual, andando para direita

Input_Update:
    store AviaoPos, r2  ; atualiza a nova posição na memória

Input_Exit:
    pop r3
    pop r2
    pop r1
    pop r0
    rts

DesenhaAviao:             
    push r0
    push r1
    push r2           

    load r0, AviaoChar  ; carrega o caractere do aviao em r0
    loadn r2, #2816   ; coloca a cor
    add r0, r0, r2    

    load r1, AviaoPos   ; carrega a posição atual do jogador
    outchar r0, r1 ; imprime
    
    pop r2            
    pop r1
    pop r0
    rts

;Reservamos a linha 0 pro SCORE, essa função nos assegura que essa linha não terá
;nada que mantenha a limpeza/clareza do score
LimpaScore:
    push r0
    push r1
    push r2
    loadn r0, #0        
    loadn r1, #40       
    loadn r2, #' '
LimpaScoreLoop:
    outchar r2, r0
    inc r0
    dec r1
    jnz LimpaScoreLoop
    pop r2
    pop r1
    pop r0
    rts

ImprimeTelaIncial:
    ; serve para desenhar a tela inicial
    push r0
    push r1
    push r2
    push r3
    call Desenhar_TelaInicial 
    loadn r0, #532    ; posição na tela     
    loadn r1, #0      ; enedereço da string         
    loadn r2, #2304   ; cor     
    call ImprimirStrings
AguardaComecar: ; espera apertar espaço pra começar o jogo
    inchar r0               
    loadn r1, #' '          
    cmp r0, r1              
    jne AguardaComecar     
    pop r3
    pop r2
    pop r1
    pop r0
    rts

Game_Over:
    call ClearScreen
    loadn r0, #535
    loadn r1, #MsgGO
    loadn r2, #2304     
    call ImprimirStrings
    
    loadn r0, #610      
    loadn r1, #MsgRest
    call ImprimirStrings
    
    loadn r0, #650      
    loadn r1, #MsgMenu
    call ImprimirStrings
    
; LOOP DO GAMEOVER
InputGAMEOVERLOOP:
    inchar r0
    loadn r1, #255
    cmp r0, r1
    jeq InputGAMEOVERLOOP   
    loadn r1, #' '
    cmp r0, r1
    jeq Game_Init    
    loadn r1, #'e'
    cmp r0, r1
    jeq Game_Exit           
    jmp InputGAMEOVERLOOP
    
Game_Exit:
    halt

;No nosso jogo essa função será útil para limpar o vetor de obstáculos, preenchendo com 0
;assegurando que o jogo comece limpo, sem lixo na memória
LimparBuffer:
    push r0 ;coloca r0 e r1 na pilha
    push r1
LimparBuffer_Loop:
    storei r0, r2 ; MEM(R0) <- R2
    inc r0 ; passa para o próximo endereço de memória do vetor
    dec r1 ; controlador para não passar do tamanho do vetor
    jnz LimparBuffer_Loop
    pop r1
    pop r0 ;desempilha r0 e r1
    rts

; Apagar os 1200 caracteres possíveis de ser exibido na tela do simulador
ClearScreen:
    push r0
    push r1
    loadn r0, #1200
    loadn r1, #' '
ClearScreen_Loop:
    dec r0
    outchar r1, r0
    jnz ClearScreen_Loop
    pop r1
    pop r0
    rts

Delay:
    push r0
    push r1
    loadn r1, #5       
DelayLOOP1:          
    loadn r0, #4000    
DelayLOOP2:           
    dec r0             
    jnz DelayLOOP2    
    dec r1             
    jnz DelayLOOP1   
    pop r1
    pop r0
    rts

; Imprimir as strings necessárias
ImprimirStrings:
    push r0
    push r1
    push r2
    push r3
    push r4
    loadn r3, #'\0'
ImprimirStringsLoop:
    loadi r4, r1
    cmp r4, r3
    jeq ImprimirStringFimLOOP
    add r4, r2, r4      
    outchar r4, r0
    inc r0
    inc r1
    jmp ImprimirStringsLoop
ImprimirStringFimLOOP:
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts
    
        ; == DESENHOS ==
TelaInicial : var #1200
  ;Linha 0
  static TelaInicial + #0, #3967
  static TelaInicial + #1, #3967
  static TelaInicial + #2, #3967
  static TelaInicial + #3, #3967
  static TelaInicial + #4, #3967
  static TelaInicial + #5, #3967
  static TelaInicial + #6, #3967
  static TelaInicial + #7, #3967
  static TelaInicial + #8, #3967
  static TelaInicial + #9, #3967
  static TelaInicial + #10, #3967
  static TelaInicial + #11, #3967
  static TelaInicial + #12, #3967
  static TelaInicial + #13, #3967
  static TelaInicial + #14, #3967
  static TelaInicial + #15, #3967
  static TelaInicial + #16, #3967
  static TelaInicial + #17, #3967
  static TelaInicial + #18, #3967
  static TelaInicial + #19, #3967
  static TelaInicial + #20, #3967
  static TelaInicial + #21, #3967
  static TelaInicial + #22, #3967
  static TelaInicial + #23, #3967
  static TelaInicial + #24, #3967
  static TelaInicial + #25, #3967
  static TelaInicial + #26, #3967
  static TelaInicial + #27, #3967
  static TelaInicial + #28, #3967
  static TelaInicial + #29, #3967
  static TelaInicial + #30, #3967
  static TelaInicial + #31, #3967
  static TelaInicial + #32, #3967
  static TelaInicial + #33, #3967
  static TelaInicial + #34, #2844
  static TelaInicial + #35, #3967
  static TelaInicial + #36, #3967
  static TelaInicial + #37, #3967
  static TelaInicial + #38, #3967
  static TelaInicial + #39, #3967

  ;Linha 1
  static TelaInicial + #40, #3967
  static TelaInicial + #41, #3967
  static TelaInicial + #42, #3967
  static TelaInicial + #43, #3967
  static TelaInicial + #44, #3967
  static TelaInicial + #45, #3967
  static TelaInicial + #46, #3967
  static TelaInicial + #47, #2838
  static TelaInicial + #48, #3967
  static TelaInicial + #49, #3967
  static TelaInicial + #50, #3967
  static TelaInicial + #51, #3967
  static TelaInicial + #52, #3967
  static TelaInicial + #53, #3967
  static TelaInicial + #54, #3967
  static TelaInicial + #55, #3967
  static TelaInicial + #56, #3967
  static TelaInicial + #57, #3967
  static TelaInicial + #58, #3967
  static TelaInicial + #59, #3967
  static TelaInicial + #60, #3967
  static TelaInicial + #61, #3967
  static TelaInicial + #62, #3967
  static TelaInicial + #63, #3967
  static TelaInicial + #64, #3967
  static TelaInicial + #65, #3967
  static TelaInicial + #66, #3967
  static TelaInicial + #67, #3967
  static TelaInicial + #68, #3967
  static TelaInicial + #69, #3967
  static TelaInicial + #70, #3967
  static TelaInicial + #71, #3967
  static TelaInicial + #72, #3967
  static TelaInicial + #73, #3967
  static TelaInicial + #74, #2912
  static TelaInicial + #75, #3967
  static TelaInicial + #76, #3967
  static TelaInicial + #77, #3967
  static TelaInicial + #78, #3967
  static TelaInicial + #79, #3967

  ;Linha 2
  static TelaInicial + #80, #3967
  static TelaInicial + #81, #3967
  static TelaInicial + #82, #3967
  static TelaInicial + #83, #3967
  static TelaInicial + #84, #3967
  static TelaInicial + #85, #3967
  static TelaInicial + #86, #2838
  static TelaInicial + #87, #3967
  static TelaInicial + #88, #3967
  static TelaInicial + #89, #3967
  static TelaInicial + #90, #3967
  static TelaInicial + #91, #3967
  static TelaInicial + #92, #3967
  static TelaInicial + #93, #3967
  static TelaInicial + #94, #3967
  static TelaInicial + #95, #3967
  static TelaInicial + #96, #3967
  static TelaInicial + #97, #3967
  static TelaInicial + #98, #3967
  static TelaInicial + #99, #3967
  static TelaInicial + #100, #3967
  static TelaInicial + #101, #3967
  static TelaInicial + #102, #3967
  static TelaInicial + #103, #3967
  static TelaInicial + #104, #3967
  static TelaInicial + #105, #3967
  static TelaInicial + #106, #3967
  static TelaInicial + #107, #3967
  static TelaInicial + #108, #3967
  static TelaInicial + #109, #3967
  static TelaInicial + #110, #3967
  static TelaInicial + #111, #3967
  static TelaInicial + #112, #2834
  static TelaInicial + #113, #2912
  static TelaInicial + #114, #2912
  static TelaInicial + #115, #2912
  static TelaInicial + #116, #3967
  static TelaInicial + #117, #3967
  static TelaInicial + #118, #3967
  static TelaInicial + #119, #3967

  ;Linha 3
  static TelaInicial + #120, #3967
  static TelaInicial + #121, #3967
  static TelaInicial + #122, #3967
  static TelaInicial + #123, #3967
  static TelaInicial + #124, #2911
  static TelaInicial + #125, #2911
  static TelaInicial + #126, #2911
  static TelaInicial + #127, #2911
  static TelaInicial + #128, #2911
  static TelaInicial + #129, #3967
  static TelaInicial + #130, #2911
  static TelaInicial + #131, #2911
  static TelaInicial + #132, #2911
  static TelaInicial + #133, #2911
  static TelaInicial + #134, #2911
  static TelaInicial + #135, #3967
  static TelaInicial + #136, #2911
  static TelaInicial + #137, #2911
  static TelaInicial + #138, #2835
  static TelaInicial + #139, #2832
  static TelaInicial + #140, #2911
  static TelaInicial + #141, #2911
  static TelaInicial + #142, #3967
  static TelaInicial + #143, #3967
  static TelaInicial + #144, #2911
  static TelaInicial + #145, #2911
  static TelaInicial + #146, #2911
  static TelaInicial + #147, #2911
  static TelaInicial + #148, #2911
  static TelaInicial + #149, #3967
  static TelaInicial + #150, #3967
  static TelaInicial + #151, #3967
  static TelaInicial + #152, #2912
  static TelaInicial + #153, #2912
  static TelaInicial + #154, #2912
  static TelaInicial + #155, #2912
  static TelaInicial + #156, #2912
  static TelaInicial + #157, #3967
  static TelaInicial + #158, #3967
  static TelaInicial + #159, #3967

  ;Linha 4
  static TelaInicial + #160, #3967
  static TelaInicial + #161, #3967
  static TelaInicial + #162, #3967
  static TelaInicial + #163, #2940
  static TelaInicial + #164, #2911
  static TelaInicial + #165, #2838
  static TelaInicial + #166, #2844
  static TelaInicial + #167, #2838
  static TelaInicial + #168, #2911
  static TelaInicial + #169, #2863
  static TelaInicial + #170, #3967
  static TelaInicial + #171, #2911
  static TelaInicial + #172, #2911
  static TelaInicial + #173, #2911
  static TelaInicial + #174, #2911
  static TelaInicial + #175, #2940
  static TelaInicial + #176, #3967
  static TelaInicial + #177, #3967
  static TelaInicial + #178, #2908
  static TelaInicial + #179, #2863
  static TelaInicial + #180, #3967
  static TelaInicial + #181, #2836
  static TelaInicial + #182, #2940
  static TelaInicial + #183, #2863
  static TelaInicial + #184, #3967
  static TelaInicial + #185, #2911
  static TelaInicial + #186, #2911
  static TelaInicial + #187, #2911
  static TelaInicial + #188, #2911
  static TelaInicial + #189, #2940
  static TelaInicial + #190, #3967
  static TelaInicial + #191, #2912
  static TelaInicial + #192, #2912
  static TelaInicial + #193, #2834
  static TelaInicial + #194, #2912
  static TelaInicial + #195, #2834
  static TelaInicial + #196, #2912
  static TelaInicial + #197, #2912
  static TelaInicial + #198, #3967
  static TelaInicial + #199, #3967

  ;Linha 5
  static TelaInicial + #200, #3967
  static TelaInicial + #201, #3967
  static TelaInicial + #202, #3967
  static TelaInicial + #203, #2838
  static TelaInicial + #204, #2845
  static TelaInicial + #205, #2940
  static TelaInicial + #206, #2844
  static TelaInicial + #207, #2940
  static TelaInicial + #208, #2940
  static TelaInicial + #209, #3967
  static TelaInicial + #210, #2940
  static TelaInicial + #211, #2842
  static TelaInicial + #212, #2842
  static TelaInicial + #213, #2842
  static TelaInicial + #214, #3967
  static TelaInicial + #215, #2940
  static TelaInicial + #216, #3967
  static TelaInicial + #217, #2908
  static TelaInicial + #218, #3967
  static TelaInicial + #219, #3967
  static TelaInicial + #220, #2863
  static TelaInicial + #221, #3967
  static TelaInicial + #222, #2940
  static TelaInicial + #223, #3967
  static TelaInicial + #224, #2940
  static TelaInicial + #225, #3967
  static TelaInicial + #226, #3967
  static TelaInicial + #227, #3967
  static TelaInicial + #228, #3967
  static TelaInicial + #229, #3967
  static TelaInicial + #230, #3967
  static TelaInicial + #231, #2912
  static TelaInicial + #232, #2834
  static TelaInicial + #233, #2834
  static TelaInicial + #234, #2912
  static TelaInicial + #235, #2834
  static TelaInicial + #236, #2834
  static TelaInicial + #237, #2912
  static TelaInicial + #238, #3967
  static TelaInicial + #239, #3967

  ;Linha 6
  static TelaInicial + #240, #3967
  static TelaInicial + #241, #3967
  static TelaInicial + #242, #3967
  static TelaInicial + #243, #2838
  static TelaInicial + #244, #2838
  static TelaInicial + #245, #2940
  static TelaInicial + #246, #2844
  static TelaInicial + #247, #2940
  static TelaInicial + #248, #2940
  static TelaInicial + #249, #3967
  static TelaInicial + #250, #2940
  static TelaInicial + #251, #2842
  static TelaInicial + #252, #2842
  static TelaInicial + #253, #3967
  static TelaInicial + #254, #3967
  static TelaInicial + #255, #2940
  static TelaInicial + #256, #3967
  static TelaInicial + #257, #2940
  static TelaInicial + #258, #2908
  static TelaInicial + #259, #2863
  static TelaInicial + #260, #2940
  static TelaInicial + #261, #3967
  static TelaInicial + #262, #2940
  static TelaInicial + #263, #3967
  static TelaInicial + #264, #2940
  static TelaInicial + #265, #3967
  static TelaInicial + #266, #3967
  static TelaInicial + #267, #3967
  static TelaInicial + #268, #3967
  static TelaInicial + #269, #3967
  static TelaInicial + #270, #3967
  static TelaInicial + #271, #3967
  static TelaInicial + #272, #2834
  static TelaInicial + #273, #2912
  static TelaInicial + #274, #2912
  static TelaInicial + #275, #2912
  static TelaInicial + #276, #2834
  static TelaInicial + #277, #2834
  static TelaInicial + #278, #3967
  static TelaInicial + #279, #3967

  ;Linha 7
  static TelaInicial + #280, #3967
  static TelaInicial + #281, #3967
  static TelaInicial + #282, #3967
  static TelaInicial + #283, #3967
  static TelaInicial + #284, #2911
  static TelaInicial + #285, #2940
  static TelaInicial + #286, #2844
  static TelaInicial + #287, #2940
  static TelaInicial + #288, #2940
  static TelaInicial + #289, #2823
  static TelaInicial + #290, #2940
  static TelaInicial + #291, #2911
  static TelaInicial + #292, #2911
  static TelaInicial + #293, #2911
  static TelaInicial + #294, #2911
  static TelaInicial + #295, #2940
  static TelaInicial + #296, #3967
  static TelaInicial + #297, #2940
  static TelaInicial + #298, #3967
  static TelaInicial + #299, #3967
  static TelaInicial + #300, #2940
  static TelaInicial + #301, #3967
  static TelaInicial + #302, #2940
  static TelaInicial + #303, #3967
  static TelaInicial + #304, #2940
  static TelaInicial + #305, #2911
  static TelaInicial + #306, #2911
  static TelaInicial + #307, #2911
  static TelaInicial + #308, #2911
  static TelaInicial + #309, #3967
  static TelaInicial + #310, #3967
  static TelaInicial + #311, #3967
  static TelaInicial + #312, #2912
  static TelaInicial + #313, #2834
  static TelaInicial + #314, #2912
  static TelaInicial + #315, #2834
  static TelaInicial + #316, #2912
  static TelaInicial + #317, #2834
  static TelaInicial + #318, #3967
  static TelaInicial + #319, #3967

  ;Linha 8
  static TelaInicial + #320, #3967
  static TelaInicial + #321, #3967
  static TelaInicial + #322, #3967
  static TelaInicial + #323, #2940
  static TelaInicial + #324, #2911
  static TelaInicial + #325, #2911
  static TelaInicial + #326, #2911
  static TelaInicial + #327, #2911
  static TelaInicial + #328, #2911
  static TelaInicial + #329, #2908
  static TelaInicial + #330, #2911
  static TelaInicial + #331, #2911
  static TelaInicial + #332, #2911
  static TelaInicial + #333, #2911
  static TelaInicial + #334, #2911
  static TelaInicial + #335, #2940
  static TelaInicial + #336, #2911
  static TelaInicial + #337, #2940
  static TelaInicial + #338, #3967
  static TelaInicial + #339, #3967
  static TelaInicial + #340, #2940
  static TelaInicial + #341, #2911
  static TelaInicial + #342, #2940
  static TelaInicial + #343, #2908
  static TelaInicial + #344, #2911
  static TelaInicial + #345, #2911
  static TelaInicial + #346, #2911
  static TelaInicial + #347, #2911
  static TelaInicial + #348, #2911
  static TelaInicial + #349, #2940
  static TelaInicial + #350, #2911
  static TelaInicial + #351, #2842
  static TelaInicial + #352, #2911
  static TelaInicial + #353, #2911
  static TelaInicial + #354, #2911
  static TelaInicial + #355, #2911
  static TelaInicial + #356, #2911
  static TelaInicial + #357, #3967
  static TelaInicial + #358, #3967
  static TelaInicial + #359, #3967

  ;Linha 9
  static TelaInicial + #360, #3967
  static TelaInicial + #361, #3967
  static TelaInicial + #362, #3967
  static TelaInicial + #363, #2940
  static TelaInicial + #364, #3967
  static TelaInicial + #365, #3967
  static TelaInicial + #366, #2911
  static TelaInicial + #367, #2911
  static TelaInicial + #368, #3967
  static TelaInicial + #369, #2908
  static TelaInicial + #370, #2940
  static TelaInicial + #371, #2834
  static TelaInicial + #372, #2940
  static TelaInicial + #373, #3967
  static TelaInicial + #374, #3967
  static TelaInicial + #375, #3967
  static TelaInicial + #376, #3967
  static TelaInicial + #377, #3967
  static TelaInicial + #378, #2838
  static TelaInicial + #379, #2863
  static TelaInicial + #380, #2908
  static TelaInicial + #381, #3967
  static TelaInicial + #382, #3967
  static TelaInicial + #383, #3967
  static TelaInicial + #384, #2940
  static TelaInicial + #385, #2843
  static TelaInicial + #386, #2908
  static TelaInicial + #387, #2839
  static TelaInicial + #388, #2842
  static TelaInicial + #389, #2940
  static TelaInicial + #390, #2845
  static TelaInicial + #391, #2940
  static TelaInicial + #392, #2842
  static TelaInicial + #393, #2911
  static TelaInicial + #394, #2911
  static TelaInicial + #395, #2911
  static TelaInicial + #396, #2911
  static TelaInicial + #397, #2940
  static TelaInicial + #398, #3967
  static TelaInicial + #399, #3967

  ;Linha 10
  static TelaInicial + #400, #3967
  static TelaInicial + #401, #3967
  static TelaInicial + #402, #3967
  static TelaInicial + #403, #2940
  static TelaInicial + #404, #3967
  static TelaInicial + #405, #2940
  static TelaInicial + #406, #2911
  static TelaInicial + #407, #2911
  static TelaInicial + #408, #2857
  static TelaInicial + #409, #2836
  static TelaInicial + #410, #2940
  static TelaInicial + #411, #3967
  static TelaInicial + #412, #2940
  static TelaInicial + #413, #3967
  static TelaInicial + #414, #3967
  static TelaInicial + #415, #3967
  static TelaInicial + #416, #3967
  static TelaInicial + #417, #3967
  static TelaInicial + #418, #2863
  static TelaInicial + #419, #2838
  static TelaInicial + #420, #2838
  static TelaInicial + #421, #2908
  static TelaInicial + #422, #3967
  static TelaInicial + #423, #3967
  static TelaInicial + #424, #2940
  static TelaInicial + #425, #2843
  static TelaInicial + #426, #2843
  static TelaInicial + #427, #2908
  static TelaInicial + #428, #2841
  static TelaInicial + #429, #2940
  static TelaInicial + #430, #2845
  static TelaInicial + #431, #2940
  static TelaInicial + #432, #2940
  static TelaInicial + #433, #2911
  static TelaInicial + #434, #2911
  static TelaInicial + #435, #2842
  static TelaInicial + #436, #3967
  static TelaInicial + #437, #3967
  static TelaInicial + #438, #3967
  static TelaInicial + #439, #3967

  ;Linha 11
  static TelaInicial + #440, #3967
  static TelaInicial + #441, #3967
  static TelaInicial + #442, #3967
  static TelaInicial + #443, #2940
  static TelaInicial + #444, #3967
  static TelaInicial + #445, #2832
  static TelaInicial + #446, #2911
  static TelaInicial + #447, #2911
  static TelaInicial + #448, #2911
  static TelaInicial + #449, #2863
  static TelaInicial + #450, #2940
  static TelaInicial + #451, #2843
  static TelaInicial + #452, #2940
  static TelaInicial + #453, #3967
  static TelaInicial + #454, #3967
  static TelaInicial + #455, #3967
  static TelaInicial + #456, #3967
  static TelaInicial + #457, #2863
  static TelaInicial + #458, #2838
  static TelaInicial + #459, #2863
  static TelaInicial + #460, #2908
  static TelaInicial + #461, #3967
  static TelaInicial + #462, #2908
  static TelaInicial + #463, #3967
  static TelaInicial + #464, #2940
  static TelaInicial + #465, #2843
  static TelaInicial + #466, #2908
  static TelaInicial + #467, #2843
  static TelaInicial + #468, #2908
  static TelaInicial + #469, #2940
  static TelaInicial + #470, #2845
  static TelaInicial + #471, #2940
  static TelaInicial + #472, #2842
  static TelaInicial + #473, #2911
  static TelaInicial + #474, #2911
  static TelaInicial + #475, #2940
  static TelaInicial + #476, #3967
  static TelaInicial + #477, #3967
  static TelaInicial + #478, #3967
  static TelaInicial + #479, #3967

  ;Linha 12
  static TelaInicial + #480, #3967
  static TelaInicial + #481, #3967
  static TelaInicial + #482, #3967
  static TelaInicial + #483, #2940
  static TelaInicial + #484, #3967
  static TelaInicial + #485, #2940
  static TelaInicial + #486, #2828
  static TelaInicial + #487, #2828
  static TelaInicial + #488, #2828
  static TelaInicial + #489, #2826
  static TelaInicial + #490, #2940
  static TelaInicial + #491, #2843
  static TelaInicial + #492, #2940
  static TelaInicial + #493, #2911
  static TelaInicial + #494, #2911
  static TelaInicial + #495, #2843
  static TelaInicial + #496, #2863
  static TelaInicial + #497, #2838
  static TelaInicial + #498, #2911
  static TelaInicial + #499, #2911
  static TelaInicial + #500, #2911
  static TelaInicial + #501, #2911
  static TelaInicial + #502, #3967
  static TelaInicial + #503, #2908
  static TelaInicial + #504, #2940
  static TelaInicial + #505, #2845
  static TelaInicial + #506, #2940
  static TelaInicial + #507, #2908
  static TelaInicial + #508, #2842
  static TelaInicial + #509, #2846
  static TelaInicial + #510, #2845
  static TelaInicial + #511, #2940
  static TelaInicial + #512, #2940
  static TelaInicial + #513, #2911
  static TelaInicial + #514, #2911
  static TelaInicial + #515, #2911
  static TelaInicial + #516, #2911
  static TelaInicial + #517, #3967
  static TelaInicial + #518, #3967
  static TelaInicial + #519, #3967

  ;Linha 13
  static TelaInicial + #520, #3967
  static TelaInicial + #521, #3967
  static TelaInicial + #522, #3967
  static TelaInicial + #523, #2940
  static TelaInicial + #524, #2911
  static TelaInicial + #525, #2940
  static TelaInicial + #526, #3967
  static TelaInicial + #527, #3967
  static TelaInicial + #528, #3967
  static TelaInicial + #529, #2826
  static TelaInicial + #530, #2940
  static TelaInicial + #531, #2911
  static TelaInicial + #532, #2911
  static TelaInicial + #533, #2911
  static TelaInicial + #534, #2911
  static TelaInicial + #535, #2863
  static TelaInicial + #536, #2911
  static TelaInicial + #537, #2863
  static TelaInicial + #538, #2836
  static TelaInicial + #539, #2833
  static TelaInicial + #540, #3967
  static TelaInicial + #541, #3967
  static TelaInicial + #542, #2908
  static TelaInicial + #543, #2911
  static TelaInicial + #544, #2940
  static TelaInicial + #545, #2911
  static TelaInicial + #546, #2940
  static TelaInicial + #547, #2843
  static TelaInicial + #548, #2908
  static TelaInicial + #549, #2911
  static TelaInicial + #550, #2911
  static TelaInicial + #551, #2940
  static TelaInicial + #552, #2911
  static TelaInicial + #553, #2911
  static TelaInicial + #554, #2911
  static TelaInicial + #555, #2911
  static TelaInicial + #556, #2911
  static TelaInicial + #557, #2940
  static TelaInicial + #558, #3967
  static TelaInicial + #559, #3967

  ;Linha 14
  static TelaInicial + #560, #3967
  static TelaInicial + #561, #3967
  static TelaInicial + #562, #3967
  static TelaInicial + #563, #3967
  static TelaInicial + #564, #3967
  static TelaInicial + #565, #3967
  static TelaInicial + #566, #3967
  static TelaInicial + #567, #3967
  static TelaInicial + #568, #3967
  static TelaInicial + #569, #3967
  static TelaInicial + #570, #3967
  static TelaInicial + #571, #3967
  static TelaInicial + #572, #3967
  static TelaInicial + #573, #3967
  static TelaInicial + #574, #3967
  static TelaInicial + #575, #3967
  static TelaInicial + #576, #3967
  static TelaInicial + #577, #3967
  static TelaInicial + #578, #3967
  static TelaInicial + #579, #3967
  static TelaInicial + #580, #3967
  static TelaInicial + #581, #3967
  static TelaInicial + #582, #3967
  static TelaInicial + #583, #3967
  static TelaInicial + #584, #3967
  static TelaInicial + #585, #2842
  static TelaInicial + #586, #2839
  static TelaInicial + #587, #3967
  static TelaInicial + #588, #3967
  static TelaInicial + #589, #3967
  static TelaInicial + #590, #3967
  static TelaInicial + #591, #3967
  static TelaInicial + #592, #2842
  static TelaInicial + #593, #3967
  static TelaInicial + #594, #3967
  static TelaInicial + #595, #2842
  static TelaInicial + #596, #3967
  static TelaInicial + #597, #3967
  static TelaInicial + #598, #3967
  static TelaInicial + #599, #3967

  ;Linha 15
  static TelaInicial + #600, #3967
  static TelaInicial + #601, #3967
  static TelaInicial + #602, #3967
  static TelaInicial + #603, #3967
  static TelaInicial + #604, #3967
  static TelaInicial + #605, #3967
  static TelaInicial + #606, #3967
  static TelaInicial + #607, #3967
  static TelaInicial + #608, #3967
  static TelaInicial + #609, #3967
  static TelaInicial + #610, #3967
  static TelaInicial + #611, #3967
  static TelaInicial + #612, #3967
  static TelaInicial + #613, #3967
  static TelaInicial + #614, #3967
  static TelaInicial + #615, #3967
  static TelaInicial + #616, #3967
  static TelaInicial + #617, #3967
  static TelaInicial + #618, #3967
  static TelaInicial + #619, #3967
  static TelaInicial + #620, #3967
  static TelaInicial + #621, #3967
  static TelaInicial + #622, #3967
  static TelaInicial + #623, #3967
  static TelaInicial + #624, #3967
  static TelaInicial + #625, #3967
  static TelaInicial + #626, #3967
  static TelaInicial + #627, #3967
  static TelaInicial + #628, #3967
  static TelaInicial + #629, #3967
  static TelaInicial + #630, #3967
  static TelaInicial + #631, #3967
  static TelaInicial + #632, #3967
  static TelaInicial + #633, #3967
  static TelaInicial + #634, #3967
  static TelaInicial + #635, #2842
  static TelaInicial + #636, #3967
  static TelaInicial + #637, #3967
  static TelaInicial + #638, #3967
  static TelaInicial + #639, #3967

  ;Linha 16
  static TelaInicial + #640, #3967
  static TelaInicial + #641, #3967
  static TelaInicial + #642, #3967
  static TelaInicial + #643, #3967
  static TelaInicial + #644, #3967
  static TelaInicial + #645, #3967
  static TelaInicial + #646, #3967
  static TelaInicial + #647, #3967
  static TelaInicial + #648, #3967
  static TelaInicial + #649, #3967
  static TelaInicial + #650, #3967
  static TelaInicial + #651, #3967
  static TelaInicial + #652, #3967
  static TelaInicial + #653, #3967
  static TelaInicial + #654, #3967
  static TelaInicial + #655, #3967
  static TelaInicial + #656, #3967
  static TelaInicial + #657, #3967
  static TelaInicial + #658, #3967
  static TelaInicial + #659, #3967
  static TelaInicial + #660, #3967
  static TelaInicial + #661, #3967
  static TelaInicial + #662, #3967
  static TelaInicial + #663, #3967
  static TelaInicial + #664, #3967
  static TelaInicial + #665, #3967
  static TelaInicial + #666, #3967
  static TelaInicial + #667, #3967
  static TelaInicial + #668, #3967
  static TelaInicial + #669, #3967
  static TelaInicial + #670, #3967
  static TelaInicial + #671, #3967
  static TelaInicial + #672, #3967
  static TelaInicial + #673, #3967
  static TelaInicial + #674, #3967
  static TelaInicial + #675, #3967
  static TelaInicial + #676, #3967
  static TelaInicial + #677, #3967
  static TelaInicial + #678, #3967
  static TelaInicial + #679, #3967

  ;Linha 17
  static TelaInicial + #680, #3967
  static TelaInicial + #681, #3967
  static TelaInicial + #682, #3967
  static TelaInicial + #683, #3967
  static TelaInicial + #684, #3967
  static TelaInicial + #685, #3967
  static TelaInicial + #686, #3967
  static TelaInicial + #687, #3967
  static TelaInicial + #688, #3967
  static TelaInicial + #689, #3967
  static TelaInicial + #690, #3967
  static TelaInicial + #691, #3967
  static TelaInicial + #692, #3967
  static TelaInicial + #693, #3967
  static TelaInicial + #694, #3967
  static TelaInicial + #695, #3967
  static TelaInicial + #696, #3967
  static TelaInicial + #697, #3967
  static TelaInicial + #698, #3967
  static TelaInicial + #699, #3967
  static TelaInicial + #700, #3967
  static TelaInicial + #701, #3967
  static TelaInicial + #702, #3967
  static TelaInicial + #703, #3967
  static TelaInicial + #704, #3967
  static TelaInicial + #705, #3967
  static TelaInicial + #706, #3967
  static TelaInicial + #707, #3967
  static TelaInicial + #708, #3967
  static TelaInicial + #709, #3967
  static TelaInicial + #710, #3967
  static TelaInicial + #711, #3967
  static TelaInicial + #712, #3967
  static TelaInicial + #713, #3967
  static TelaInicial + #714, #3967
  static TelaInicial + #715, #3967
  static TelaInicial + #716, #3967
  static TelaInicial + #717, #3967
  static TelaInicial + #718, #3967
  static TelaInicial + #719, #3967

  ;Linha 18
  static TelaInicial + #720, #3967
  static TelaInicial + #721, #3967
  static TelaInicial + #722, #3967
  static TelaInicial + #723, #3967
  static TelaInicial + #724, #3967
  static TelaInicial + #725, #3967
  static TelaInicial + #726, #3967
  static TelaInicial + #727, #3967
  static TelaInicial + #728, #3967
  static TelaInicial + #729, #3967
  static TelaInicial + #730, #3967
  static TelaInicial + #731, #3967
  static TelaInicial + #732, #3967
  static TelaInicial + #733, #3967
  static TelaInicial + #734, #3967
  static TelaInicial + #735, #3967
  static TelaInicial + #736, #3967
  static TelaInicial + #737, #3967
  static TelaInicial + #738, #3967
  static TelaInicial + #739, #3967
  static TelaInicial + #740, #3967
  static TelaInicial + #741, #3967
  static TelaInicial + #742, #3967
  static TelaInicial + #743, #3967
  static TelaInicial + #744, #3967
  static TelaInicial + #745, #3967
  static TelaInicial + #746, #3967
  static TelaInicial + #747, #3967
  static TelaInicial + #748, #3967
  static TelaInicial + #749, #3967
  static TelaInicial + #750, #3967
  static TelaInicial + #751, #3967
  static TelaInicial + #752, #3967
  static TelaInicial + #753, #3967
  static TelaInicial + #754, #3967
  static TelaInicial + #755, #3967
  static TelaInicial + #756, #3967
  static TelaInicial + #757, #3967
  static TelaInicial + #758, #3967
  static TelaInicial + #759, #3967

  ;Linha 19
  static TelaInicial + #760, #3967
  static TelaInicial + #761, #3967
  static TelaInicial + #762, #3967
  static TelaInicial + #763, #3967
  static TelaInicial + #764, #3967
  static TelaInicial + #765, #3967
  static TelaInicial + #766, #3967
  static TelaInicial + #767, #3967
  static TelaInicial + #768, #3967
  static TelaInicial + #769, #3967
  static TelaInicial + #770, #3967
  static TelaInicial + #771, #3967
  static TelaInicial + #772, #3967
  static TelaInicial + #773, #3967
  static TelaInicial + #774, #3967
  static TelaInicial + #775, #3967
  static TelaInicial + #776, #3967
  static TelaInicial + #777, #3967
  static TelaInicial + #778, #3967
  static TelaInicial + #779, #3967
  static TelaInicial + #780, #3967
  static TelaInicial + #781, #3967
  static TelaInicial + #782, #3967
  static TelaInicial + #783, #3967
  static TelaInicial + #784, #3967
  static TelaInicial + #785, #3967
  static TelaInicial + #786, #3967
  static TelaInicial + #787, #3967
  static TelaInicial + #788, #3967
  static TelaInicial + #789, #3967
  static TelaInicial + #790, #3967
  static TelaInicial + #791, #3967
  static TelaInicial + #792, #3967
  static TelaInicial + #793, #3967
  static TelaInicial + #794, #3967
  static TelaInicial + #795, #3967
  static TelaInicial + #796, #3967
  static TelaInicial + #797, #3967
  static TelaInicial + #798, #3967
  static TelaInicial + #799, #3967

  ;Linha 20
  static TelaInicial + #800, #3967
  static TelaInicial + #801, #3967
  static TelaInicial + #802, #3967
  static TelaInicial + #803, #3967
  static TelaInicial + #804, #3967
  static TelaInicial + #805, #3967
  static TelaInicial + #806, #3967
  static TelaInicial + #807, #3967
  static TelaInicial + #808, #3967
  static TelaInicial + #809, #3967
  static TelaInicial + #810, #3967
  static TelaInicial + #811, #3967
  static TelaInicial + #812, #3967
  static TelaInicial + #813, #3967
  static TelaInicial + #814, #3967
  static TelaInicial + #815, #3967
  static TelaInicial + #816, #3967
  static TelaInicial + #817, #3967
  static TelaInicial + #818, #3967
  static TelaInicial + #819, #3967
  static TelaInicial + #820, #3967
  static TelaInicial + #821, #3967
  static TelaInicial + #822, #3967
  static TelaInicial + #823, #3967
  static TelaInicial + #824, #3967
  static TelaInicial + #825, #3967
  static TelaInicial + #826, #3967
  static TelaInicial + #827, #3967
  static TelaInicial + #828, #3967
  static TelaInicial + #829, #3967
  static TelaInicial + #830, #3967
  static TelaInicial + #831, #3967
  static TelaInicial + #832, #3967
  static TelaInicial + #833, #3967
  static TelaInicial + #834, #3967
  static TelaInicial + #835, #3967
  static TelaInicial + #836, #3967
  static TelaInicial + #837, #3967
  static TelaInicial + #838, #3967
  static TelaInicial + #839, #3967

  ;Linha 21
  static TelaInicial + #840, #3967
  static TelaInicial + #841, #3967
  static TelaInicial + #842, #3967
  static TelaInicial + #843, #3967
  static TelaInicial + #844, #3967
  static TelaInicial + #845, #2896
  static TelaInicial + #846, #2930
  static TelaInicial + #847, #2917
  static TelaInicial + #848, #2931
  static TelaInicial + #849, #2931
  static TelaInicial + #850, #2921
  static TelaInicial + #851, #2927
  static TelaInicial + #852, #2926
  static TelaInicial + #853, #2917
  static TelaInicial + #854, #3967
  static TelaInicial + #855, #2899
  static TelaInicial + #856, #2896
  static TelaInicial + #857, #2881
  static TelaInicial + #858, #2883
  static TelaInicial + #859, #2885
  static TelaInicial + #860, #3967
  static TelaInicial + #861, #2928
  static TelaInicial + #862, #2913
  static TelaInicial + #863, #2930
  static TelaInicial + #864, #2913
  static TelaInicial + #865, #3967
  static TelaInicial + #866, #2922
  static TelaInicial + #867, #2927
  static TelaInicial + #868, #2919
  static TelaInicial + #869, #2913
  static TelaInicial + #870, #2930
  static TelaInicial + #871, #3967
  static TelaInicial + #872, #3967
  static TelaInicial + #873, #3967
  static TelaInicial + #874, #3967
  static TelaInicial + #875, #3967
  static TelaInicial + #876, #3967
  static TelaInicial + #877, #3967
  static TelaInicial + #878, #3967
  static TelaInicial + #879, #3967

  ;Linha 22
  static TelaInicial + #880, #3967
  static TelaInicial + #881, #3967
  static TelaInicial + #882, #3967
  static TelaInicial + #883, #3967
  static TelaInicial + #884, #3967
  static TelaInicial + #885, #3967
  static TelaInicial + #886, #3967
  static TelaInicial + #887, #3967
  static TelaInicial + #888, #3967
  static TelaInicial + #889, #3967
  static TelaInicial + #890, #3967
  static TelaInicial + #891, #3967
  static TelaInicial + #892, #3967
  static TelaInicial + #893, #3967
  static TelaInicial + #894, #3967
  static TelaInicial + #895, #3967
  static TelaInicial + #896, #3967
  static TelaInicial + #897, #3967
  static TelaInicial + #898, #3967
  static TelaInicial + #899, #3967
  static TelaInicial + #900, #3967
  static TelaInicial + #901, #3967
  static TelaInicial + #902, #3967
  static TelaInicial + #903, #3967
  static TelaInicial + #904, #3967
  static TelaInicial + #905, #3967
  static TelaInicial + #906, #3967
  static TelaInicial + #907, #3967
  static TelaInicial + #908, #3967
  static TelaInicial + #909, #3967
  static TelaInicial + #910, #3967
  static TelaInicial + #911, #3967
  static TelaInicial + #912, #3967
  static TelaInicial + #913, #3967
  static TelaInicial + #914, #3967
  static TelaInicial + #915, #3967
  static TelaInicial + #916, #3967
  static TelaInicial + #917, #3967
  static TelaInicial + #918, #3967
  static TelaInicial + #919, #3967

  ;Linha 23
  static TelaInicial + #920, #3967
  static TelaInicial + #921, #3967
  static TelaInicial + #922, #3967
  static TelaInicial + #923, #3967
  static TelaInicial + #924, #3967
  static TelaInicial + #925, #3967
  static TelaInicial + #926, #3967
  static TelaInicial + #927, #3967
  static TelaInicial + #928, #3967
  static TelaInicial + #929, #3967
  static TelaInicial + #930, #3967
  static TelaInicial + #931, #3967
  static TelaInicial + #932, #3967
  static TelaInicial + #933, #3967
  static TelaInicial + #934, #3967
  static TelaInicial + #935, #3967
  static TelaInicial + #936, #3967
  static TelaInicial + #937, #3967
  static TelaInicial + #938, #3967
  static TelaInicial + #939, #3967
  static TelaInicial + #940, #3967
  static TelaInicial + #941, #3967
  static TelaInicial + #942, #3967
  static TelaInicial + #943, #3967
  static TelaInicial + #944, #3967
  static TelaInicial + #945, #3967
  static TelaInicial + #946, #3967
  static TelaInicial + #947, #3967
  static TelaInicial + #948, #3967
  static TelaInicial + #949, #3967
  static TelaInicial + #950, #3967
  static TelaInicial + #951, #3967
  static TelaInicial + #952, #3967
  static TelaInicial + #953, #3967
  static TelaInicial + #954, #3967
  static TelaInicial + #955, #3967
  static TelaInicial + #956, #3967
  static TelaInicial + #957, #3967
  static TelaInicial + #958, #3967
  static TelaInicial + #959, #3967

  ;Linha 24
  static TelaInicial + #960, #3967
  static TelaInicial + #961, #3967
  static TelaInicial + #962, #3967
  static TelaInicial + #963, #3967
  static TelaInicial + #964, #3967
  static TelaInicial + #965, #3967
  static TelaInicial + #966, #3967
  static TelaInicial + #967, #3967
  static TelaInicial + #968, #3967
  static TelaInicial + #969, #3967
  static TelaInicial + #970, #3967
  static TelaInicial + #971, #3967
  static TelaInicial + #972, #3967
  static TelaInicial + #973, #3967
  static TelaInicial + #974, #3967
  static TelaInicial + #975, #3967
  static TelaInicial + #976, #3967
  static TelaInicial + #977, #3967
  static TelaInicial + #978, #3967
  static TelaInicial + #979, #3967
  static TelaInicial + #980, #3967
  static TelaInicial + #981, #3967
  static TelaInicial + #982, #3967
  static TelaInicial + #983, #3967
  static TelaInicial + #984, #3967
  static TelaInicial + #985, #3967
  static TelaInicial + #986, #3967
  static TelaInicial + #987, #3967
  static TelaInicial + #988, #3967
  static TelaInicial + #989, #3967
  static TelaInicial + #990, #3967
  static TelaInicial + #991, #3967
  static TelaInicial + #992, #3967
  static TelaInicial + #993, #3967
  static TelaInicial + #994, #3967
  static TelaInicial + #995, #3967
  static TelaInicial + #996, #3967
  static TelaInicial + #997, #3967
  static TelaInicial + #998, #3967
  static TelaInicial + #999, #3967

  ;Linha 25
  static TelaInicial + #1000, #3967
  static TelaInicial + #1001, #3967
  static TelaInicial + #1002, #3967
  static TelaInicial + #1003, #3967
  static TelaInicial + #1004, #3967
  static TelaInicial + #1005, #3967
  static TelaInicial + #1006, #3967
  static TelaInicial + #1007, #3967
  static TelaInicial + #1008, #3967
  static TelaInicial + #1009, #3967
  static TelaInicial + #1010, #3967
  static TelaInicial + #1011, #3967
  static TelaInicial + #1012, #3967
  static TelaInicial + #1013, #3967
  static TelaInicial + #1014, #3967
  static TelaInicial + #1015, #3967
  static TelaInicial + #1016, #3967
  static TelaInicial + #1017, #3967
  static TelaInicial + #1018, #3967
  static TelaInicial + #1019, #3967
  static TelaInicial + #1020, #3967
  static TelaInicial + #1021, #3967
  static TelaInicial + #1022, #3967
  static TelaInicial + #1023, #3967
  static TelaInicial + #1024, #3967
  static TelaInicial + #1025, #3967
  static TelaInicial + #1026, #3967
  static TelaInicial + #1027, #3967
  static TelaInicial + #1028, #3967
  static TelaInicial + #1029, #3967
  static TelaInicial + #1030, #3967
  static TelaInicial + #1031, #3967
  static TelaInicial + #1032, #3967
  static TelaInicial + #1033, #3967
  static TelaInicial + #1034, #3967
  static TelaInicial + #1035, #3967
  static TelaInicial + #1036, #3967
  static TelaInicial + #1037, #3967
  static TelaInicial + #1038, #3967
  static TelaInicial + #1039, #3967

  ;Linha 26
  static TelaInicial + #1040, #3967
  static TelaInicial + #1041, #3967
  static TelaInicial + #1042, #3967
  static TelaInicial + #1043, #3967
  static TelaInicial + #1044, #3967
  static TelaInicial + #1045, #3967
  static TelaInicial + #1046, #3967
  static TelaInicial + #1047, #3967
  static TelaInicial + #1048, #3967
  static TelaInicial + #1049, #3967
  static TelaInicial + #1050, #3967
  static TelaInicial + #1051, #3967
  static TelaInicial + #1052, #3967
  static TelaInicial + #1053, #3967
  static TelaInicial + #1054, #3967
  static TelaInicial + #1055, #3967
  static TelaInicial + #1056, #3967
  static TelaInicial + #1057, #3967
  static TelaInicial + #1058, #3967
  static TelaInicial + #1059, #3967
  static TelaInicial + #1060, #3967
  static TelaInicial + #1061, #3967
  static TelaInicial + #1062, #3967
  static TelaInicial + #1063, #3967
  static TelaInicial + #1064, #3967
  static TelaInicial + #1065, #3967
  static TelaInicial + #1066, #3967
  static TelaInicial + #1067, #3967
  static TelaInicial + #1068, #3967
  static TelaInicial + #1069, #3967
  static TelaInicial + #1070, #3967
  static TelaInicial + #1071, #3967
  static TelaInicial + #1072, #3967
  static TelaInicial + #1073, #3967
  static TelaInicial + #1074, #3967
  static TelaInicial + #1075, #3967
  static TelaInicial + #1076, #3967
  static TelaInicial + #1077, #3967
  static TelaInicial + #1078, #3967
  static TelaInicial + #1079, #3967

  ;Linha 27
  static TelaInicial + #1080, #3967
  static TelaInicial + #1081, #3967
  static TelaInicial + #1082, #3967
  static TelaInicial + #1083, #3967
  static TelaInicial + #1084, #3967
  static TelaInicial + #1085, #3967
  static TelaInicial + #1086, #3967
  static TelaInicial + #1087, #3967
  static TelaInicial + #1088, #3967
  static TelaInicial + #1089, #3967
  static TelaInicial + #1090, #3967
  static TelaInicial + #1091, #3967
  static TelaInicial + #1092, #3967
  static TelaInicial + #1093, #3967
  static TelaInicial + #1094, #3967
  static TelaInicial + #1095, #3967
  static TelaInicial + #1096, #3967
  static TelaInicial + #1097, #3967
  static TelaInicial + #1098, #3967
  static TelaInicial + #1099, #3967
  static TelaInicial + #1100, #3967
  static TelaInicial + #1101, #3967
  static TelaInicial + #1102, #3967
  static TelaInicial + #1103, #3967
  static TelaInicial + #1104, #3967
  static TelaInicial + #1105, #3967
  static TelaInicial + #1106, #3967
  static TelaInicial + #1107, #3967
  static TelaInicial + #1108, #3967
  static TelaInicial + #1109, #3967
  static TelaInicial + #1110, #3967
  static TelaInicial + #1111, #3967
  static TelaInicial + #1112, #3967
  static TelaInicial + #1113, #3967
  static TelaInicial + #1114, #3967
  static TelaInicial + #1115, #3967
  static TelaInicial + #1116, #3967
  static TelaInicial + #1117, #3967
  static TelaInicial + #1118, #3967
  static TelaInicial + #1119, #3967

  ;Linha 28
  static TelaInicial + #1120, #3967
  static TelaInicial + #1121, #3967
  static TelaInicial + #1122, #3967
  static TelaInicial + #1123, #3967
  static TelaInicial + #1124, #3967
  static TelaInicial + #1125, #3967
  static TelaInicial + #1126, #3967
  static TelaInicial + #1127, #3967
  static TelaInicial + #1128, #3967
  static TelaInicial + #1129, #3967
  static TelaInicial + #1130, #3967
  static TelaInicial + #1131, #3967
  static TelaInicial + #1132, #3967
  static TelaInicial + #1133, #3967
  static TelaInicial + #1134, #3967
  static TelaInicial + #1135, #3967
  static TelaInicial + #1136, #3967
  static TelaInicial + #1137, #3967
  static TelaInicial + #1138, #3967
  static TelaInicial + #1139, #3967
  static TelaInicial + #1140, #3967
  static TelaInicial + #1141, #3967
  static TelaInicial + #1142, #3967
  static TelaInicial + #1143, #3967
  static TelaInicial + #1144, #3967
  static TelaInicial + #1145, #3967
  static TelaInicial + #1146, #3967
  static TelaInicial + #1147, #3967
  static TelaInicial + #1148, #3967
  static TelaInicial + #1149, #3967
  static TelaInicial + #1150, #3967
  static TelaInicial + #1151, #3967
  static TelaInicial + #1152, #3967
  static TelaInicial + #1153, #3967
  static TelaInicial + #1154, #3967
  static TelaInicial + #1155, #3967
  static TelaInicial + #1156, #3967
  static TelaInicial + #1157, #3967
  static TelaInicial + #1158, #3967
  static TelaInicial + #1159, #3967

  ;Linha 29
  static TelaInicial + #1160, #3967
  static TelaInicial + #1161, #3967
  static TelaInicial + #1162, #3967
  static TelaInicial + #1163, #3967
  static TelaInicial + #1164, #3967
  static TelaInicial + #1165, #3967
  static TelaInicial + #1166, #3967
  static TelaInicial + #1167, #3967
  static TelaInicial + #1168, #3967
  static TelaInicial + #1169, #3967
  static TelaInicial + #1170, #3967
  static TelaInicial + #1171, #3967
  static TelaInicial + #1172, #3967
  static TelaInicial + #1173, #3967
  static TelaInicial + #1174, #3967
  static TelaInicial + #1175, #3967
  static TelaInicial + #1176, #3967
  static TelaInicial + #1177, #3967
  static TelaInicial + #1178, #3967
  static TelaInicial + #1179, #3967
  static TelaInicial + #1180, #3967
  static TelaInicial + #1181, #3967
  static TelaInicial + #1182, #3967
  static TelaInicial + #1183, #3967
  static TelaInicial + #1184, #3967
  static TelaInicial + #1185, #3967
  static TelaInicial + #1186, #3967
  static TelaInicial + #1187, #3967
  static TelaInicial + #1188, #3967
  static TelaInicial + #1189, #3967
  static TelaInicial + #1190, #3967
  static TelaInicial + #1191, #3967
  static TelaInicial + #1192, #3967
  static TelaInicial + #1193, #3967
  static TelaInicial + #1194, #3967
  static TelaInicial + #1195, #3967
  static TelaInicial + #1196, #3967
  static TelaInicial + #1197, #3967
  static TelaInicial + #1198, #3967
  static TelaInicial + #1199, #3967

Desenhar_TelaInicial:
  push R0
  push R1
  push R2
  push R3

  loadn R0, #TelaInicial
  loadn R1, #0
  loadn R2, #1200

  DesenharTelaInicialLoop:

    add R3,R0,R1
    loadi R3, R3
    outchar R3, R1
    inc R1
    cmp R1, R2

    jne DesenharTelaInicialLoop

  pop R3
  pop R2
  pop R1
  pop R0
  rts
  
  TelaJogo : var #1200
  ;Linha 0
  static TelaJogo + #0, #3967
  static TelaJogo + #1, #3967
  static TelaJogo + #2, #3967
  static TelaJogo + #3, #3967
  static TelaJogo + #4, #3967
  static TelaJogo + #5, #3967
  static TelaJogo + #6, #3967
  static TelaJogo + #7, #3967
  static TelaJogo + #8, #3967
  static TelaJogo + #9, #3967
  static TelaJogo + #10, #3967
  static TelaJogo + #11, #3967
  static TelaJogo + #12, #3967
  static TelaJogo + #13, #3967
  static TelaJogo + #14, #3967
  static TelaJogo + #15, #3967
  static TelaJogo + #16, #3967
  static TelaJogo + #17, #3967
  static TelaJogo + #18, #3967
  static TelaJogo + #19, #3967
  static TelaJogo + #20, #3967
  static TelaJogo + #21, #3967
  static TelaJogo + #22, #3967
  static TelaJogo + #23, #3967
  static TelaJogo + #24, #95
  static TelaJogo + #25, #95
  static TelaJogo + #26, #95
  static TelaJogo + #27, #95
  static TelaJogo + #28, #95
  static TelaJogo + #29, #3967
  static TelaJogo + #30, #3967
  static TelaJogo + #31, #3967
  static TelaJogo + #32, #3967
  static TelaJogo + #33, #3967
  static TelaJogo + #34, #3967
  static TelaJogo + #35, #3967
  static TelaJogo + #36, #3967
  static TelaJogo + #37, #3967
  static TelaJogo + #38, #3967
  static TelaJogo + #39, #3967

  ;Linha 1
  static TelaJogo + #40, #3967
  static TelaJogo + #41, #3967
  static TelaJogo + #42, #3967
  static TelaJogo + #43, #3967
  static TelaJogo + #44, #3967
  static TelaJogo + #45, #3967
  static TelaJogo + #46, #3967
  static TelaJogo + #47, #3967
  static TelaJogo + #48, #3967
  static TelaJogo + #49, #3967
  static TelaJogo + #50, #3967
  static TelaJogo + #51, #3967
  static TelaJogo + #52, #3967
  static TelaJogo + #53, #3967
  static TelaJogo + #54, #3967
  static TelaJogo + #55, #3967
  static TelaJogo + #56, #3967
  static TelaJogo + #57, #3967
  static TelaJogo + #58, #3967
  static TelaJogo + #59, #3967
  static TelaJogo + #60, #3967
  static TelaJogo + #61, #3967
  static TelaJogo + #62, #3967
  static TelaJogo + #63, #47
  static TelaJogo + #64, #3967
  static TelaJogo + #65, #3967
  static TelaJogo + #66, #3967
  static TelaJogo + #67, #3967
  static TelaJogo + #68, #3967
  static TelaJogo + #69, #92
  static TelaJogo + #70, #95
  static TelaJogo + #71, #95
  static TelaJogo + #72, #95
  static TelaJogo + #73, #95
  static TelaJogo + #74, #95
  static TelaJogo + #75, #95
  static TelaJogo + #76, #3967
  static TelaJogo + #77, #3967
  static TelaJogo + #78, #3967
  static TelaJogo + #79, #3967

  ;Linha 2
  static TelaJogo + #80, #3967
  static TelaJogo + #81, #3967
  static TelaJogo + #82, #3967
  static TelaJogo + #83, #3967
  static TelaJogo + #84, #3967
  static TelaJogo + #85, #3967
  static TelaJogo + #86, #3967
  static TelaJogo + #87, #3967
  static TelaJogo + #88, #3967
  static TelaJogo + #89, #3967
  static TelaJogo + #90, #3967
  static TelaJogo + #91, #3967
  static TelaJogo + #92, #3967
  static TelaJogo + #93, #3967
  static TelaJogo + #94, #3967
  static TelaJogo + #95, #3967
  static TelaJogo + #96, #3967
  static TelaJogo + #97, #3967
  static TelaJogo + #98, #3967
  static TelaJogo + #99, #3967
  static TelaJogo + #100, #3967
  static TelaJogo + #101, #3967
  static TelaJogo + #102, #30
  static TelaJogo + #103, #124
  static TelaJogo + #104, #3967
  static TelaJogo + #105, #3967
  static TelaJogo + #106, #3967
  static TelaJogo + #107, #3967
  static TelaJogo + #108, #3967
  static TelaJogo + #109, #3967
  static TelaJogo + #110, #3967
  static TelaJogo + #111, #3967
  static TelaJogo + #112, #3967
  static TelaJogo + #113, #3967
  static TelaJogo + #114, #3967
  static TelaJogo + #115, #3967
  static TelaJogo + #116, #92
  static TelaJogo + #117, #25
  static TelaJogo + #118, #3967
  static TelaJogo + #119, #3967

  ;Linha 3
  static TelaJogo + #120, #3967
  static TelaJogo + #121, #3967
  static TelaJogo + #122, #3967
  static TelaJogo + #123, #3967
  static TelaJogo + #124, #3967
  static TelaJogo + #125, #3967
  static TelaJogo + #126, #3967
  static TelaJogo + #127, #3967
  static TelaJogo + #128, #3967
  static TelaJogo + #129, #3967
  static TelaJogo + #130, #3967
  static TelaJogo + #131, #3967
  static TelaJogo + #132, #3967
  static TelaJogo + #133, #3967
  static TelaJogo + #134, #3967
  static TelaJogo + #135, #3967
  static TelaJogo + #136, #3967
  static TelaJogo + #137, #3967
  static TelaJogo + #138, #3967
  static TelaJogo + #139, #3967
  static TelaJogo + #140, #3967
  static TelaJogo + #141, #3967
  static TelaJogo + #142, #30
  static TelaJogo + #143, #124
  static TelaJogo + #144, #3967
  static TelaJogo + #145, #3967
  static TelaJogo + #146, #3967
  static TelaJogo + #147, #3967
  static TelaJogo + #148, #3967
  static TelaJogo + #149, #3967
  static TelaJogo + #150, #3967
  static TelaJogo + #151, #3967
  static TelaJogo + #152, #3967
  static TelaJogo + #153, #3967
  static TelaJogo + #154, #3967
  static TelaJogo + #155, #3967
  static TelaJogo + #156, #3967
  static TelaJogo + #157, #124
  static TelaJogo + #158, #3967
  static TelaJogo + #159, #3967

  ;Linha 4
  static TelaJogo + #160, #3967
  static TelaJogo + #161, #3967
  static TelaJogo + #162, #3967
  static TelaJogo + #163, #3967
  static TelaJogo + #164, #3967
  static TelaJogo + #165, #3967
  static TelaJogo + #166, #3967
  static TelaJogo + #167, #3967
  static TelaJogo + #168, #3967
  static TelaJogo + #169, #3967
  static TelaJogo + #170, #3967
  static TelaJogo + #171, #3967
  static TelaJogo + #172, #3967
  static TelaJogo + #173, #3967
  static TelaJogo + #174, #3967
  static TelaJogo + #175, #3967
  static TelaJogo + #176, #3967
  static TelaJogo + #177, #3967
  static TelaJogo + #178, #3967
  static TelaJogo + #179, #3967
  static TelaJogo + #180, #3967
  static TelaJogo + #181, #3967
  static TelaJogo + #182, #47
  static TelaJogo + #183, #3967
  static TelaJogo + #184, #3967
  static TelaJogo + #185, #3967
  static TelaJogo + #186, #3967
  static TelaJogo + #187, #3967
  static TelaJogo + #188, #3967
  static TelaJogo + #189, #3967
  static TelaJogo + #190, #3967
  static TelaJogo + #191, #3967
  static TelaJogo + #192, #3967
  static TelaJogo + #193, #3967
  static TelaJogo + #194, #3967
  static TelaJogo + #195, #3967
  static TelaJogo + #196, #3967
  static TelaJogo + #197, #124
  static TelaJogo + #198, #3967
  static TelaJogo + #199, #3967

  ;Linha 5
  static TelaJogo + #200, #3967
  static TelaJogo + #201, #3967
  static TelaJogo + #202, #3967
  static TelaJogo + #203, #3967
  static TelaJogo + #204, #3967
  static TelaJogo + #205, #95
  static TelaJogo + #206, #95
  static TelaJogo + #207, #95
  static TelaJogo + #208, #95
  static TelaJogo + #209, #95
  static TelaJogo + #210, #3967
  static TelaJogo + #211, #3967
  static TelaJogo + #212, #24
  static TelaJogo + #213, #24
  static TelaJogo + #214, #24
  static TelaJogo + #215, #24
  static TelaJogo + #216, #3967
  static TelaJogo + #217, #3967
  static TelaJogo + #218, #3967
  static TelaJogo + #219, #3967
  static TelaJogo + #220, #3967
  static TelaJogo + #221, #3967
  static TelaJogo + #222, #124
  static TelaJogo + #223, #3967
  static TelaJogo + #224, #3967
  static TelaJogo + #225, #3967
  static TelaJogo + #226, #3967
  static TelaJogo + #227, #3967
  static TelaJogo + #228, #3967
  static TelaJogo + #229, #3967
  static TelaJogo + #230, #3967
  static TelaJogo + #231, #3967
  static TelaJogo + #232, #29
  static TelaJogo + #233, #29
  static TelaJogo + #234, #3967
  static TelaJogo + #235, #3967
  static TelaJogo + #236, #47
  static TelaJogo + #237, #3967
  static TelaJogo + #238, #3967
  static TelaJogo + #239, #3967

  ;Linha 6
  static TelaJogo + #240, #3967
  static TelaJogo + #241, #3967
  static TelaJogo + #242, #3967
  static TelaJogo + #243, #3967
  static TelaJogo + #244, #47
  static TelaJogo + #245, #3967
  static TelaJogo + #246, #3967
  static TelaJogo + #247, #3967
  static TelaJogo + #248, #3967
  static TelaJogo + #249, #3967
  static TelaJogo + #250, #92
  static TelaJogo + #251, #95
  static TelaJogo + #252, #95
  static TelaJogo + #253, #95
  static TelaJogo + #254, #95
  static TelaJogo + #255, #95
  static TelaJogo + #256, #3967
  static TelaJogo + #257, #3967
  static TelaJogo + #258, #3967
  static TelaJogo + #259, #3967
  static TelaJogo + #260, #3967
  static TelaJogo + #261, #3967
  static TelaJogo + #262, #124
  static TelaJogo + #263, #3967
  static TelaJogo + #264, #3967
  static TelaJogo + #265, #3967
  static TelaJogo + #266, #3967
  static TelaJogo + #267, #3967
  static TelaJogo + #268, #3967
  static TelaJogo + #269, #3967
  static TelaJogo + #270, #3967
  static TelaJogo + #271, #29
  static TelaJogo + #272, #95
  static TelaJogo + #273, #95
  static TelaJogo + #274, #95
  static TelaJogo + #275, #47
  static TelaJogo + #276, #3967
  static TelaJogo + #277, #3967
  static TelaJogo + #278, #3967
  static TelaJogo + #279, #3967

  ;Linha 7
  static TelaJogo + #280, #3967
  static TelaJogo + #281, #3967
  static TelaJogo + #282, #3967
  static TelaJogo + #283, #124
  static TelaJogo + #284, #9
  static TelaJogo + #285, #3967
  static TelaJogo + #286, #3967
  static TelaJogo + #287, #3967
  static TelaJogo + #288, #3967
  static TelaJogo + #289, #3967
  static TelaJogo + #290, #3967
  static TelaJogo + #291, #3967
  static TelaJogo + #292, #3967
  static TelaJogo + #293, #24
  static TelaJogo + #294, #24
  static TelaJogo + #295, #24
  static TelaJogo + #296, #92
  static TelaJogo + #297, #3967
  static TelaJogo + #298, #3967
  static TelaJogo + #299, #3967
  static TelaJogo + #300, #3967
  static TelaJogo + #301, #3967
  static TelaJogo + #302, #92
  static TelaJogo + #303, #3967
  static TelaJogo + #304, #3967
  static TelaJogo + #305, #3967
  static TelaJogo + #306, #3967
  static TelaJogo + #307, #3967
  static TelaJogo + #308, #3967
  static TelaJogo + #309, #3967
  static TelaJogo + #310, #3967
  static TelaJogo + #311, #47
  static TelaJogo + #312, #29
  static TelaJogo + #313, #29
  static TelaJogo + #314, #3967
  static TelaJogo + #315, #3967
  static TelaJogo + #316, #3967
  static TelaJogo + #317, #3967
  static TelaJogo + #318, #3967
  static TelaJogo + #319, #3967

  ;Linha 8
  static TelaJogo + #320, #3967
  static TelaJogo + #321, #3967
  static TelaJogo + #322, #3967
  static TelaJogo + #323, #3967
  static TelaJogo + #324, #92
  static TelaJogo + #325, #11
  static TelaJogo + #326, #3967
  static TelaJogo + #327, #3967
  static TelaJogo + #328, #3967
  static TelaJogo + #329, #3967
  static TelaJogo + #330, #3967
  static TelaJogo + #331, #3967
  static TelaJogo + #332, #3967
  static TelaJogo + #333, #3967
  static TelaJogo + #334, #24
  static TelaJogo + #335, #24
  static TelaJogo + #336, #3967
  static TelaJogo + #337, #45
  static TelaJogo + #338, #95
  static TelaJogo + #339, #3967
  static TelaJogo + #340, #3967
  static TelaJogo + #341, #3967
  static TelaJogo + #342, #3967
  static TelaJogo + #343, #92
  static TelaJogo + #344, #3967
  static TelaJogo + #345, #3967
  static TelaJogo + #346, #3967
  static TelaJogo + #347, #3967
  static TelaJogo + #348, #3967
  static TelaJogo + #349, #3967
  static TelaJogo + #350, #3967
  static TelaJogo + #351, #124
  static TelaJogo + #352, #3967
  static TelaJogo + #353, #3967
  static TelaJogo + #354, #3967
  static TelaJogo + #355, #3967
  static TelaJogo + #356, #3967
  static TelaJogo + #357, #3967
  static TelaJogo + #358, #3967
  static TelaJogo + #359, #3967

  ;Linha 9
  static TelaJogo + #360, #3967
  static TelaJogo + #361, #3967
  static TelaJogo + #362, #3967
  static TelaJogo + #363, #3967
  static TelaJogo + #364, #3967
  static TelaJogo + #365, #124
  static TelaJogo + #366, #3967
  static TelaJogo + #367, #3967
  static TelaJogo + #368, #3967
  static TelaJogo + #369, #3967
  static TelaJogo + #370, #3967
  static TelaJogo + #371, #3967
  static TelaJogo + #372, #3967
  static TelaJogo + #373, #3967
  static TelaJogo + #374, #3967
  static TelaJogo + #375, #3967
  static TelaJogo + #376, #3967
  static TelaJogo + #377, #15
  static TelaJogo + #378, #21
  static TelaJogo + #379, #124
  static TelaJogo + #380, #3967
  static TelaJogo + #381, #3967
  static TelaJogo + #382, #3967
  static TelaJogo + #383, #3967
  static TelaJogo + #384, #92
  static TelaJogo + #385, #95
  static TelaJogo + #386, #95
  static TelaJogo + #387, #95
  static TelaJogo + #388, #95
  static TelaJogo + #389, #95
  static TelaJogo + #390, #47
  static TelaJogo + #391, #3967
  static TelaJogo + #392, #3967
  static TelaJogo + #393, #3967
  static TelaJogo + #394, #3967
  static TelaJogo + #395, #3967
  static TelaJogo + #396, #3967
  static TelaJogo + #397, #3967
  static TelaJogo + #398, #3967
  static TelaJogo + #399, #3967

  ;Linha 10
  static TelaJogo + #400, #3967
  static TelaJogo + #401, #3967
  static TelaJogo + #402, #3967
  static TelaJogo + #403, #3967
  static TelaJogo + #404, #3967
  static TelaJogo + #405, #124
  static TelaJogo + #406, #3967
  static TelaJogo + #407, #3967
  static TelaJogo + #408, #3967
  static TelaJogo + #409, #3967
  static TelaJogo + #410, #3967
  static TelaJogo + #411, #3967
  static TelaJogo + #412, #3967
  static TelaJogo + #413, #3967
  static TelaJogo + #414, #3967
  static TelaJogo + #415, #3967
  static TelaJogo + #416, #3967
  static TelaJogo + #417, #3967
  static TelaJogo + #418, #3967
  static TelaJogo + #419, #124
  static TelaJogo + #420, #3967
  static TelaJogo + #421, #3967
  static TelaJogo + #422, #3967
  static TelaJogo + #423, #3967
  static TelaJogo + #424, #3967
  static TelaJogo + #425, #3967
  static TelaJogo + #426, #3967
  static TelaJogo + #427, #3967
  static TelaJogo + #428, #3967
  static TelaJogo + #429, #3967
  static TelaJogo + #430, #3967
  static TelaJogo + #431, #3967
  static TelaJogo + #432, #3967
  static TelaJogo + #433, #3967
  static TelaJogo + #434, #3967
  static TelaJogo + #435, #3967
  static TelaJogo + #436, #3967
  static TelaJogo + #437, #3967
  static TelaJogo + #438, #3967
  static TelaJogo + #439, #3967

  ;Linha 11
  static TelaJogo + #440, #3967
  static TelaJogo + #441, #3967
  static TelaJogo + #442, #3967
  static TelaJogo + #443, #3967
  static TelaJogo + #444, #3967
  static TelaJogo + #445, #3967
  static TelaJogo + #446, #92
  static TelaJogo + #447, #3967
  static TelaJogo + #448, #3967
  static TelaJogo + #449, #3967
  static TelaJogo + #450, #3967
  static TelaJogo + #451, #16
  static TelaJogo + #452, #3967
  static TelaJogo + #453, #3967
  static TelaJogo + #454, #3967
  static TelaJogo + #455, #3967
  static TelaJogo + #456, #3967
  static TelaJogo + #457, #3967
  static TelaJogo + #458, #3967
  static TelaJogo + #459, #124
  static TelaJogo + #460, #3967
  static TelaJogo + #461, #3967
  static TelaJogo + #462, #3967
  static TelaJogo + #463, #3967
  static TelaJogo + #464, #3967
  static TelaJogo + #465, #3967
  static TelaJogo + #466, #3967
  static TelaJogo + #467, #3967
  static TelaJogo + #468, #3967
  static TelaJogo + #469, #3967
  static TelaJogo + #470, #3967
  static TelaJogo + #471, #3967
  static TelaJogo + #472, #3967
  static TelaJogo + #473, #3967
  static TelaJogo + #474, #3967
  static TelaJogo + #475, #3967
  static TelaJogo + #476, #3967
  static TelaJogo + #477, #3967
  static TelaJogo + #478, #3967
  static TelaJogo + #479, #3967

  ;Linha 12
  static TelaJogo + #480, #3967
  static TelaJogo + #481, #3967
  static TelaJogo + #482, #3967
  static TelaJogo + #483, #3967
  static TelaJogo + #484, #3967
  static TelaJogo + #485, #3967
  static TelaJogo + #486, #3967
  static TelaJogo + #487, #92
  static TelaJogo + #488, #95
  static TelaJogo + #489, #95
  static TelaJogo + #490, #95
  static TelaJogo + #491, #16
  static TelaJogo + #492, #3967
  static TelaJogo + #493, #3967
  static TelaJogo + #494, #3967
  static TelaJogo + #495, #3967
  static TelaJogo + #496, #3967
  static TelaJogo + #497, #3967
  static TelaJogo + #498, #47
  static TelaJogo + #499, #3967
  static TelaJogo + #500, #3967
  static TelaJogo + #501, #3967
  static TelaJogo + #502, #3967
  static TelaJogo + #503, #3967
  static TelaJogo + #504, #3967
  static TelaJogo + #505, #3967
  static TelaJogo + #506, #3967
  static TelaJogo + #507, #3967
  static TelaJogo + #508, #3967
  static TelaJogo + #509, #3967
  static TelaJogo + #510, #3967
  static TelaJogo + #511, #3967
  static TelaJogo + #512, #3967
  static TelaJogo + #513, #3967
  static TelaJogo + #514, #3967
  static TelaJogo + #515, #3967
  static TelaJogo + #516, #3967
  static TelaJogo + #517, #3967
  static TelaJogo + #518, #3967
  static TelaJogo + #519, #3967

  ;Linha 13
  static TelaJogo + #520, #3967
  static TelaJogo + #521, #3967
  static TelaJogo + #522, #3967
  static TelaJogo + #523, #3967
  static TelaJogo + #524, #3967
  static TelaJogo + #525, #3967
  static TelaJogo + #526, #3967
  static TelaJogo + #527, #3967
  static TelaJogo + #528, #3967
  static TelaJogo + #529, #3967
  static TelaJogo + #530, #3967
  static TelaJogo + #531, #92
  static TelaJogo + #532, #95
  static TelaJogo + #533, #95
  static TelaJogo + #534, #95
  static TelaJogo + #535, #95
  static TelaJogo + #536, #95
  static TelaJogo + #537, #47
  static TelaJogo + #538, #3967
  static TelaJogo + #539, #3967
  static TelaJogo + #540, #3967
  static TelaJogo + #541, #3967
  static TelaJogo + #542, #3967
  static TelaJogo + #543, #3967
  static TelaJogo + #544, #3967
  static TelaJogo + #545, #3967
  static TelaJogo + #546, #3967
  static TelaJogo + #547, #3967
  static TelaJogo + #548, #3967
  static TelaJogo + #549, #3967
  static TelaJogo + #550, #3967
  static TelaJogo + #551, #3967
  static TelaJogo + #552, #3967
  static TelaJogo + #553, #3967
  static TelaJogo + #554, #3967
  static TelaJogo + #555, #3967
  static TelaJogo + #556, #3967
  static TelaJogo + #557, #3967
  static TelaJogo + #558, #3967
  static TelaJogo + #559, #3967

  ;Linha 14
  static TelaJogo + #560, #3967
  static TelaJogo + #561, #3967
  static TelaJogo + #562, #3967
  static TelaJogo + #563, #3967
  static TelaJogo + #564, #3967
  static TelaJogo + #565, #3967
  static TelaJogo + #566, #3967
  static TelaJogo + #567, #3967
  static TelaJogo + #568, #3967
  static TelaJogo + #569, #3967
  static TelaJogo + #570, #3967
  static TelaJogo + #571, #3967
  static TelaJogo + #572, #3967
  static TelaJogo + #573, #3967
  static TelaJogo + #574, #3967
  static TelaJogo + #575, #3967
  static TelaJogo + #576, #3967
  static TelaJogo + #577, #3967
  static TelaJogo + #578, #3967
  static TelaJogo + #579, #3967
  static TelaJogo + #580, #3967
  static TelaJogo + #581, #3967
  static TelaJogo + #582, #3967
  static TelaJogo + #583, #3967
  static TelaJogo + #584, #3967
  static TelaJogo + #585, #3967
  static TelaJogo + #586, #3967
  static TelaJogo + #587, #3967
  static TelaJogo + #588, #3967
  static TelaJogo + #589, #3967
  static TelaJogo + #590, #3967
  static TelaJogo + #591, #3967
  static TelaJogo + #592, #3967
  static TelaJogo + #593, #3967
  static TelaJogo + #594, #3967
  static TelaJogo + #595, #3967
  static TelaJogo + #596, #3967
  static TelaJogo + #597, #3967
  static TelaJogo + #598, #3967
  static TelaJogo + #599, #3967

  ;Linha 15
  static TelaJogo + #600, #3967
  static TelaJogo + #601, #3967
  static TelaJogo + #602, #3967
  static TelaJogo + #603, #3967
  static TelaJogo + #604, #3967
  static TelaJogo + #605, #3967
  static TelaJogo + #606, #3967
  static TelaJogo + #607, #3967
  static TelaJogo + #608, #3967
  static TelaJogo + #609, #3967
  static TelaJogo + #610, #3967
  static TelaJogo + #611, #3967
  static TelaJogo + #612, #3967
  static TelaJogo + #613, #3967
  static TelaJogo + #614, #3967
  static TelaJogo + #615, #3967
  static TelaJogo + #616, #3967
  static TelaJogo + #617, #3967
  static TelaJogo + #618, #3967
  static TelaJogo + #619, #3967
  static TelaJogo + #620, #3967
  static TelaJogo + #621, #3967
  static TelaJogo + #622, #3967
  static TelaJogo + #623, #3967
  static TelaJogo + #624, #3967
  static TelaJogo + #625, #3967
  static TelaJogo + #626, #3967
  static TelaJogo + #627, #3967
  static TelaJogo + #628, #3967
  static TelaJogo + #629, #3967
  static TelaJogo + #630, #3967
  static TelaJogo + #631, #3967
  static TelaJogo + #632, #3967
  static TelaJogo + #633, #3967
  static TelaJogo + #634, #3967
  static TelaJogo + #635, #3967
  static TelaJogo + #636, #3967
  static TelaJogo + #637, #3967
  static TelaJogo + #638, #3967
  static TelaJogo + #639, #3967

  ;Linha 16
  static TelaJogo + #640, #3967
  static TelaJogo + #641, #3967
  static TelaJogo + #642, #3967
  static TelaJogo + #643, #3967
  static TelaJogo + #644, #3967
  static TelaJogo + #645, #3967
  static TelaJogo + #646, #3967
  static TelaJogo + #647, #3967
  static TelaJogo + #648, #3967
  static TelaJogo + #649, #3967
  static TelaJogo + #650, #3967
  static TelaJogo + #651, #3967
  static TelaJogo + #652, #3967
  static TelaJogo + #653, #3967
  static TelaJogo + #654, #3967
  static TelaJogo + #655, #3967
  static TelaJogo + #656, #3967
  static TelaJogo + #657, #3967
  static TelaJogo + #658, #3967
  static TelaJogo + #659, #3967
  static TelaJogo + #660, #3967
  static TelaJogo + #661, #3967
  static TelaJogo + #662, #3967
  static TelaJogo + #663, #3967
  static TelaJogo + #664, #3967
  static TelaJogo + #665, #3967
  static TelaJogo + #666, #95
  static TelaJogo + #667, #95
  static TelaJogo + #668, #95
  static TelaJogo + #669, #95
  static TelaJogo + #670, #3967
  static TelaJogo + #671, #3967
  static TelaJogo + #672, #3967
  static TelaJogo + #673, #3967
  static TelaJogo + #674, #3967
  static TelaJogo + #675, #3967
  static TelaJogo + #676, #3967
  static TelaJogo + #677, #3967
  static TelaJogo + #678, #3967
  static TelaJogo + #679, #3967

  ;Linha 17
  static TelaJogo + #680, #3967
  static TelaJogo + #681, #3967
  static TelaJogo + #682, #3967
  static TelaJogo + #683, #3967
  static TelaJogo + #684, #3967
  static TelaJogo + #685, #3967
  static TelaJogo + #686, #3967
  static TelaJogo + #687, #3967
  static TelaJogo + #688, #3967
  static TelaJogo + #689, #3967
  static TelaJogo + #690, #3967
  static TelaJogo + #691, #3967
  static TelaJogo + #692, #3967
  static TelaJogo + #693, #3967
  static TelaJogo + #694, #3967
  static TelaJogo + #695, #3967
  static TelaJogo + #696, #3967
  static TelaJogo + #697, #3967
  static TelaJogo + #698, #3967
  static TelaJogo + #699, #95
  static TelaJogo + #700, #95
  static TelaJogo + #701, #95
  static TelaJogo + #702, #95
  static TelaJogo + #703, #95
  static TelaJogo + #704, #95
  static TelaJogo + #705, #47
  static TelaJogo + #706, #3967
  static TelaJogo + #707, #3967
  static TelaJogo + #708, #3967
  static TelaJogo + #709, #3967
  static TelaJogo + #710, #92
  static TelaJogo + #711, #3967
  static TelaJogo + #712, #3967
  static TelaJogo + #713, #3967
  static TelaJogo + #714, #3967
  static TelaJogo + #715, #3967
  static TelaJogo + #716, #3967
  static TelaJogo + #717, #3967
  static TelaJogo + #718, #3967
  static TelaJogo + #719, #3967

  ;Linha 18
  static TelaJogo + #720, #3967
  static TelaJogo + #721, #3967
  static TelaJogo + #722, #3967
  static TelaJogo + #723, #3967
  static TelaJogo + #724, #3967
  static TelaJogo + #725, #3967
  static TelaJogo + #726, #3967
  static TelaJogo + #727, #3967
  static TelaJogo + #728, #3967
  static TelaJogo + #729, #3967
  static TelaJogo + #730, #3967
  static TelaJogo + #731, #3967
  static TelaJogo + #732, #3967
  static TelaJogo + #733, #3967
  static TelaJogo + #734, #3967
  static TelaJogo + #735, #3967
  static TelaJogo + #736, #3967
  static TelaJogo + #737, #3967
  static TelaJogo + #738, #47
  static TelaJogo + #739, #3967
  static TelaJogo + #740, #3967
  static TelaJogo + #741, #3967
  static TelaJogo + #742, #3967
  static TelaJogo + #743, #3967
  static TelaJogo + #744, #3967
  static TelaJogo + #745, #3967
  static TelaJogo + #746, #3967
  static TelaJogo + #747, #3967
  static TelaJogo + #748, #3967
  static TelaJogo + #749, #3967
  static TelaJogo + #750, #3967
  static TelaJogo + #751, #124
  static TelaJogo + #752, #3967
  static TelaJogo + #753, #3967
  static TelaJogo + #754, #3967
  static TelaJogo + #755, #3967
  static TelaJogo + #756, #3967
  static TelaJogo + #757, #3967
  static TelaJogo + #758, #3967
  static TelaJogo + #759, #3967

  ;Linha 19
  static TelaJogo + #760, #3967
  static TelaJogo + #761, #3967
  static TelaJogo + #762, #3967
  static TelaJogo + #763, #3967
  static TelaJogo + #764, #3967
  static TelaJogo + #765, #3967
  static TelaJogo + #766, #3967
  static TelaJogo + #767, #3967
  static TelaJogo + #768, #3967
  static TelaJogo + #769, #3967
  static TelaJogo + #770, #3967
  static TelaJogo + #771, #3967
  static TelaJogo + #772, #3967
  static TelaJogo + #773, #3967
  static TelaJogo + #774, #3967
  static TelaJogo + #775, #3967
  static TelaJogo + #776, #3967
  static TelaJogo + #777, #47
  static TelaJogo + #778, #3967
  static TelaJogo + #779, #3967
  static TelaJogo + #780, #3967
  static TelaJogo + #781, #3967
  static TelaJogo + #782, #3967
  static TelaJogo + #783, #3967
  static TelaJogo + #784, #3967
  static TelaJogo + #785, #3967
  static TelaJogo + #786, #3967
  static TelaJogo + #787, #3967
  static TelaJogo + #788, #3967
  static TelaJogo + #789, #3967
  static TelaJogo + #790, #3967
  static TelaJogo + #791, #92
  static TelaJogo + #792, #95
  static TelaJogo + #793, #95
  static TelaJogo + #794, #3967
  static TelaJogo + #795, #3967
  static TelaJogo + #796, #3967
  static TelaJogo + #797, #3967
  static TelaJogo + #798, #3967
  static TelaJogo + #799, #3967

  ;Linha 20
  static TelaJogo + #800, #3967
  static TelaJogo + #801, #3967
  static TelaJogo + #802, #3967
  static TelaJogo + #803, #3967
  static TelaJogo + #804, #3967
  static TelaJogo + #805, #3967
  static TelaJogo + #806, #3967
  static TelaJogo + #807, #3967
  static TelaJogo + #808, #3967
  static TelaJogo + #809, #3967
  static TelaJogo + #810, #3967
  static TelaJogo + #811, #3967
  static TelaJogo + #812, #3967
  static TelaJogo + #813, #3967
  static TelaJogo + #814, #3967
  static TelaJogo + #815, #3967
  static TelaJogo + #816, #3967
  static TelaJogo + #817, #124
  static TelaJogo + #818, #3967
  static TelaJogo + #819, #3967
  static TelaJogo + #820, #3967
  static TelaJogo + #821, #3967
  static TelaJogo + #822, #3967
  static TelaJogo + #823, #3967
  static TelaJogo + #824, #3967
  static TelaJogo + #825, #3967
  static TelaJogo + #826, #3967
  static TelaJogo + #827, #3967
  static TelaJogo + #828, #3967
  static TelaJogo + #829, #3967
  static TelaJogo + #830, #3967
  static TelaJogo + #831, #3967
  static TelaJogo + #832, #3967
  static TelaJogo + #833, #3967
  static TelaJogo + #834, #92
  static TelaJogo + #835, #3967
  static TelaJogo + #836, #3967
  static TelaJogo + #837, #3967
  static TelaJogo + #838, #3967
  static TelaJogo + #839, #3967

  ;Linha 21
  static TelaJogo + #840, #3967
  static TelaJogo + #841, #3967
  static TelaJogo + #842, #3967
  static TelaJogo + #843, #3967
  static TelaJogo + #844, #3967
  static TelaJogo + #845, #3967
  static TelaJogo + #846, #3967
  static TelaJogo + #847, #3967
  static TelaJogo + #848, #3967
  static TelaJogo + #849, #3967
  static TelaJogo + #850, #3967
  static TelaJogo + #851, #3967
  static TelaJogo + #852, #3967
  static TelaJogo + #853, #3967
  static TelaJogo + #854, #3967
  static TelaJogo + #855, #3967
  static TelaJogo + #856, #3967
  static TelaJogo + #857, #124
  static TelaJogo + #858, #19
  static TelaJogo + #859, #3967
  static TelaJogo + #860, #3967
  static TelaJogo + #861, #3967
  static TelaJogo + #862, #3967
  static TelaJogo + #863, #3967
  static TelaJogo + #864, #3967
  static TelaJogo + #865, #3967
  static TelaJogo + #866, #3967
  static TelaJogo + #867, #3967
  static TelaJogo + #868, #3967
  static TelaJogo + #869, #3967
  static TelaJogo + #870, #3967
  static TelaJogo + #871, #3967
  static TelaJogo + #872, #3967
  static TelaJogo + #873, #3967
  static TelaJogo + #874, #3967
  static TelaJogo + #875, #124
  static TelaJogo + #876, #3967
  static TelaJogo + #877, #3967
  static TelaJogo + #878, #3967
  static TelaJogo + #879, #3967

  ;Linha 22
  static TelaJogo + #880, #3967
  static TelaJogo + #881, #3967
  static TelaJogo + #882, #3967
  static TelaJogo + #883, #3967
  static TelaJogo + #884, #3967
  static TelaJogo + #885, #3967
  static TelaJogo + #886, #3967
  static TelaJogo + #887, #3967
  static TelaJogo + #888, #3967
  static TelaJogo + #889, #3967
  static TelaJogo + #890, #3967
  static TelaJogo + #891, #3967
  static TelaJogo + #892, #3967
  static TelaJogo + #893, #3967
  static TelaJogo + #894, #3967
  static TelaJogo + #895, #3967
  static TelaJogo + #896, #3967
  static TelaJogo + #897, #3967
  static TelaJogo + #898, #92
  static TelaJogo + #899, #3967
  static TelaJogo + #900, #3967
  static TelaJogo + #901, #3967
  static TelaJogo + #902, #3967
  static TelaJogo + #903, #25
  static TelaJogo + #904, #3967
  static TelaJogo + #905, #3967
  static TelaJogo + #906, #3967
  static TelaJogo + #907, #3967
  static TelaJogo + #908, #3967
  static TelaJogo + #909, #3967
  static TelaJogo + #910, #3967
  static TelaJogo + #911, #3967
  static TelaJogo + #912, #3967
  static TelaJogo + #913, #3967
  static TelaJogo + #914, #3967
  static TelaJogo + #915, #124
  static TelaJogo + #916, #3967
  static TelaJogo + #917, #3967
  static TelaJogo + #918, #3967
  static TelaJogo + #919, #3967

  ;Linha 23
  static TelaJogo + #920, #3967
  static TelaJogo + #921, #3967
  static TelaJogo + #922, #3967
  static TelaJogo + #923, #3967
  static TelaJogo + #924, #3967
  static TelaJogo + #925, #3967
  static TelaJogo + #926, #3967
  static TelaJogo + #927, #3967
  static TelaJogo + #928, #3967
  static TelaJogo + #929, #3967
  static TelaJogo + #930, #3967
  static TelaJogo + #931, #3967
  static TelaJogo + #932, #3967
  static TelaJogo + #933, #3967
  static TelaJogo + #934, #3967
  static TelaJogo + #935, #3967
  static TelaJogo + #936, #3967
  static TelaJogo + #937, #3967
  static TelaJogo + #938, #3967
  static TelaJogo + #939, #92
  static TelaJogo + #940, #95
  static TelaJogo + #941, #95
  static TelaJogo + #942, #95
  static TelaJogo + #943, #95
  static TelaJogo + #944, #25
  static TelaJogo + #945, #25
  static TelaJogo + #946, #25
  static TelaJogo + #947, #3967
  static TelaJogo + #948, #3967
  static TelaJogo + #949, #95
  static TelaJogo + #950, #95
  static TelaJogo + #951, #95
  static TelaJogo + #952, #95
  static TelaJogo + #953, #95
  static TelaJogo + #954, #47
  static TelaJogo + #955, #3967
  static TelaJogo + #956, #3967
  static TelaJogo + #957, #3967
  static TelaJogo + #958, #3967
  static TelaJogo + #959, #3967

  ;Linha 24
  static TelaJogo + #960, #3967
  static TelaJogo + #961, #3967
  static TelaJogo + #962, #3967
  static TelaJogo + #963, #3967
  static TelaJogo + #964, #3967
  static TelaJogo + #965, #3967
  static TelaJogo + #966, #3967
  static TelaJogo + #967, #3967
  static TelaJogo + #968, #3967
  static TelaJogo + #969, #3967
  static TelaJogo + #970, #3967
  static TelaJogo + #971, #3967
  static TelaJogo + #972, #3967
  static TelaJogo + #973, #3967
  static TelaJogo + #974, #3967
  static TelaJogo + #975, #3967
  static TelaJogo + #976, #3967
  static TelaJogo + #977, #3967
  static TelaJogo + #978, #3967
  static TelaJogo + #979, #3967
  static TelaJogo + #980, #3967
  static TelaJogo + #981, #3967
  static TelaJogo + #982, #3967
  static TelaJogo + #983, #3967
  static TelaJogo + #984, #92
  static TelaJogo + #985, #95
  static TelaJogo + #986, #95
  static TelaJogo + #987, #95
  static TelaJogo + #988, #47
  static TelaJogo + #989, #3967
  static TelaJogo + #990, #3967
  static TelaJogo + #991, #3967
  static TelaJogo + #992, #3967
  static TelaJogo + #993, #3967
  static TelaJogo + #994, #3967
  static TelaJogo + #995, #3967
  static TelaJogo + #996, #3967
  static TelaJogo + #997, #3967
  static TelaJogo + #998, #3967
  static TelaJogo + #999, #3967

  ;Linha 25
  static TelaJogo + #1000, #3967
  static TelaJogo + #1001, #3967
  static TelaJogo + #1002, #3967
  static TelaJogo + #1003, #3967
  static TelaJogo + #1004, #3967
  static TelaJogo + #1005, #3967
  static TelaJogo + #1006, #3967
  static TelaJogo + #1007, #3967
  static TelaJogo + #1008, #3967
  static TelaJogo + #1009, #3967
  static TelaJogo + #1010, #3967
  static TelaJogo + #1011, #3967
  static TelaJogo + #1012, #3967
  static TelaJogo + #1013, #3967
  static TelaJogo + #1014, #3967
  static TelaJogo + #1015, #3967
  static TelaJogo + #1016, #3967
  static TelaJogo + #1017, #3967
  static TelaJogo + #1018, #3967
  static TelaJogo + #1019, #3967
  static TelaJogo + #1020, #3967
  static TelaJogo + #1021, #3967
  static TelaJogo + #1022, #3967
  static TelaJogo + #1023, #3967
  static TelaJogo + #1024, #3967
  static TelaJogo + #1025, #3967
  static TelaJogo + #1026, #3967
  static TelaJogo + #1027, #3967
  static TelaJogo + #1028, #3967
  static TelaJogo + #1029, #3967
  static TelaJogo + #1030, #3967
  static TelaJogo + #1031, #3967
  static TelaJogo + #1032, #3967
  static TelaJogo + #1033, #3967
  static TelaJogo + #1034, #3967
  static TelaJogo + #1035, #3967
  static TelaJogo + #1036, #3967
  static TelaJogo + #1037, #3967
  static TelaJogo + #1038, #3967
  static TelaJogo + #1039, #3967

  ;Linha 26
  static TelaJogo + #1040, #3967
  static TelaJogo + #1041, #3967
  static TelaJogo + #1042, #3967
  static TelaJogo + #1043, #3967
  static TelaJogo + #1044, #3967
  static TelaJogo + #1045, #3967
  static TelaJogo + #1046, #3967
  static TelaJogo + #1047, #3967
  static TelaJogo + #1048, #3967
  static TelaJogo + #1049, #3967
  static TelaJogo + #1050, #3967
  static TelaJogo + #1051, #3967
  static TelaJogo + #1052, #3967
  static TelaJogo + #1053, #3967
  static TelaJogo + #1054, #3967
  static TelaJogo + #1055, #3967
  static TelaJogo + #1056, #3967
  static TelaJogo + #1057, #3967
  static TelaJogo + #1058, #3967
  static TelaJogo + #1059, #3967
  static TelaJogo + #1060, #3967
  static TelaJogo + #1061, #3967
  static TelaJogo + #1062, #3967
  static TelaJogo + #1063, #3967
  static TelaJogo + #1064, #3967
  static TelaJogo + #1065, #3967
  static TelaJogo + #1066, #3967
  static TelaJogo + #1067, #3967
  static TelaJogo + #1068, #3967
  static TelaJogo + #1069, #3967
  static TelaJogo + #1070, #3967
  static TelaJogo + #1071, #3967
  static TelaJogo + #1072, #3967
  static TelaJogo + #1073, #3967
  static TelaJogo + #1074, #3967
  static TelaJogo + #1075, #3967
  static TelaJogo + #1076, #3967
  static TelaJogo + #1077, #3967
  static TelaJogo + #1078, #3967
  static TelaJogo + #1079, #3967

  ;Linha 27
  static TelaJogo + #1080, #3967
  static TelaJogo + #1081, #3967
  static TelaJogo + #1082, #3967
  static TelaJogo + #1083, #3967
  static TelaJogo + #1084, #3967
  static TelaJogo + #1085, #3967
  static TelaJogo + #1086, #3967
  static TelaJogo + #1087, #3967
  static TelaJogo + #1088, #3967
  static TelaJogo + #1089, #3967
  static TelaJogo + #1090, #3967
  static TelaJogo + #1091, #3967
  static TelaJogo + #1092, #3967
  static TelaJogo + #1093, #3967
  static TelaJogo + #1094, #3967
  static TelaJogo + #1095, #3967
  static TelaJogo + #1096, #3967
  static TelaJogo + #1097, #3967
  static TelaJogo + #1098, #3967
  static TelaJogo + #1099, #3967
  static TelaJogo + #1100, #3967
  static TelaJogo + #1101, #3967
  static TelaJogo + #1102, #3967
  static TelaJogo + #1103, #3967
  static TelaJogo + #1104, #3967
  static TelaJogo + #1105, #3967
  static TelaJogo + #1106, #3967
  static TelaJogo + #1107, #3967
  static TelaJogo + #1108, #3967
  static TelaJogo + #1109, #3967
  static TelaJogo + #1110, #3967
  static TelaJogo + #1111, #3967
  static TelaJogo + #1112, #3967
  static TelaJogo + #1113, #3967
  static TelaJogo + #1114, #3967
  static TelaJogo + #1115, #3967
  static TelaJogo + #1116, #3967
  static TelaJogo + #1117, #3967
  static TelaJogo + #1118, #3967
  static TelaJogo + #1119, #3967

  ;Linha 28
  static TelaJogo + #1120, #3967
  static TelaJogo + #1121, #3967
  static TelaJogo + #1122, #3967
  static TelaJogo + #1123, #3967
  static TelaJogo + #1124, #3967
  static TelaJogo + #1125, #3967
  static TelaJogo + #1126, #3967
  static TelaJogo + #1127, #3967
  static TelaJogo + #1128, #3967
  static TelaJogo + #1129, #3967
  static TelaJogo + #1130, #3967
  static TelaJogo + #1131, #3967
  static TelaJogo + #1132, #3967
  static TelaJogo + #1133, #3967
  static TelaJogo + #1134, #3967
  static TelaJogo + #1135, #3967
  static TelaJogo + #1136, #3967
  static TelaJogo + #1137, #3967
  static TelaJogo + #1138, #3967
  static TelaJogo + #1139, #3967
  static TelaJogo + #1140, #3967
  static TelaJogo + #1141, #3967
  static TelaJogo + #1142, #3967
  static TelaJogo + #1143, #3967
  static TelaJogo + #1144, #3967
  static TelaJogo + #1145, #3967
  static TelaJogo + #1146, #3967
  static TelaJogo + #1147, #3967
  static TelaJogo + #1148, #3967
  static TelaJogo + #1149, #3967
  static TelaJogo + #1150, #3967
  static TelaJogo + #1151, #3967
  static TelaJogo + #1152, #3967
  static TelaJogo + #1153, #3967
  static TelaJogo + #1154, #3967
  static TelaJogo + #1155, #3967
  static TelaJogo + #1156, #3967
  static TelaJogo + #1157, #3967
  static TelaJogo + #1158, #3967
  static TelaJogo + #1159, #3967

  ;Linha 29
  static TelaJogo + #1160, #3967
  static TelaJogo + #1161, #3967
  static TelaJogo + #1162, #3967
  static TelaJogo + #1163, #3967
  static TelaJogo + #1164, #3967
  static TelaJogo + #1165, #3967
  static TelaJogo + #1166, #3967
  static TelaJogo + #1167, #3967
  static TelaJogo + #1168, #3967
  static TelaJogo + #1169, #3967
  static TelaJogo + #1170, #3967
  static TelaJogo + #1171, #3967
  static TelaJogo + #1172, #3967
  static TelaJogo + #1173, #3967
  static TelaJogo + #1174, #3967
  static TelaJogo + #1175, #3967
  static TelaJogo + #1176, #3967
  static TelaJogo + #1177, #3967
  static TelaJogo + #1178, #3967
  static TelaJogo + #1179, #3967
  static TelaJogo + #1180, #3967
  static TelaJogo + #1181, #3967
  static TelaJogo + #1182, #3967
  static TelaJogo + #1183, #3967
  static TelaJogo + #1184, #3967
  static TelaJogo + #1185, #3967
  static TelaJogo + #1186, #3967
  static TelaJogo + #1187, #3967
  static TelaJogo + #1188, #3967
  static TelaJogo + #1189, #3967
  static TelaJogo + #1190, #3967
  static TelaJogo + #1191, #3967
  static TelaJogo + #1192, #3967
  static TelaJogo + #1193, #3967
  static TelaJogo + #1194, #3967
  static TelaJogo + #1195, #3967
  static TelaJogo + #1196, #3967
  static TelaJogo + #1197, #3967
  static TelaJogo + #1198, #3967
  static TelaJogo + #1199, #3967

Desenhar_TelaJogo:
  push R0
  push R1
  push R2
  push R3

  loadn R0, #TelaJogo
  loadn R1, #40              ;Para não sobre a linha 0, onde está nosso score;
  loadn R2, #1200

  Desenhar_TelaJogoLoop:

    add R3,R0,R1
    loadi R3, R3
    outchar R3, R1
    inc R1
    cmp R1, R2

    jne Desenhar_TelaJogoLoop

  pop R3
  pop R2
  pop R1
  pop R0
  rts