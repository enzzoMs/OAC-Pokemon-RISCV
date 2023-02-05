.text

# Especificando o tempo de sleep em ms de cada uma das op��es poss�veis para o registrador s9 tal como
# explicado abaixo

.eqv FPGA_OU_RARS 0
.eqv FPGRARS 20

# ====================================================================================================== #
#     					        IMPORTANTE!!!!						 #
# ====================================================================================================== #
# Antes de iniciar o jogo � necess�rio definir o valor de s9 de acordo com a plataforma que o jogo vai	 #
# ser rodado (RARS, FPGRARS ou na FPGA). 								 #
# Esse registrador precisa ser inicializado corretamente porque � ele que vai definir o tempo de SLEEP   #
# ideal durante os procedimentos de movimenta��o da tela (movimenta��o em pallet) para a plataforma   	 #
# escolhida.												 #
# As op��es poss�veis s�o:										 #
#	'FPGRARS' ou 'FPGA_OU_RARS' 									 #
# Obs: mesmo com a op��o 'FPGA_OU_RARS' selecionada o RARS provavelmente n�o vai conseguir executar a	 #
# movimenta��o r�pido o suficiente, por isso � melhor usar o FPGRARS					 #
# ------------------------------------------------------------------------------------------------------ #
	li s9, FPGRARS
# ====================================================================================================== # 
# 					Pok�mon FireRed/LeafGreen				         #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# Este arquivo cont�m a l�gica central do jogo incluindo o loop principal e a chamada de procedimentos   #
# adquados para renderizar os elementos visuais.							 #
#													 #
# ====================================================================================================== #
# 				    TABELA DE REGISTRADORES SALVOS					 #
# ====================================================================================================== #
#													 #
#	s0 = guarda a posi��o atual do personagem no frame 0, marcado pelo endere�o do pixel na parte	 #
# 		superior esquerda do sprite do RED							 #
#	s1 = orienta��o do personagem, convencionado da seguinte forma:					 #
#		[ 0 ] = virado para a esquerda								 # 
#		[ 1 ] = virado para a direita								 #
#		[ 2 ] = virado para cima 								 #
#		[ 3 ] = virado para baixo								 #
#	s2 = guarda o endere�o de inicio da subse��o 20 x 15 na matriz de tiles que est� atualmente 	 #
#		sendo mostrada na tela									 #
#	s3 = o tamanho de uma linha na matriz de tiles							 # 
#	s4 = endere�o base da imagem contendo os tiles da �rea atual					 #
#	s5 = guarda a posi��o atual do personagem na matriz de tiles					 #
#	s6 = guarda o endere�o da posi��o atual do personagem na matriz de movimenta��o da �rea em que	 #
#		ele est�										 #
#	s7 = tamanho de uma linha da matriz de movimenta��o da �rea atual				 #
#	s8 = determina como ser� o pr�ximo passo do RED durante as anima��es de movimento, de modo que   #
#		[ 0 ] = pr�ximo passo ser� dado com o p� esquerdo					 #
#		[ Qualquer outro valor] = pr�ximo passo ser� dado com o p� direito			 #
#	s9 = define o tempo de SLEEP durante os procedimentos de movimenta��o da tela (movimenta��o	 #
#		em Pallet). O valor de s9 pode ser trocado acima.					 #
#	s10 = [ 0 ] -> se o RED n�o estiver indo ou n�o est� em um tile de grama 			 #
#	      [ Qualquer outro valor] = caso estiver indo para um tile de grama	 			 #
#	s11 = usado no combate para guardar o codigo do pokemon inimigo e o pokemon escolhido pelo 	 #
#		jogador. O valor � convencionado no formato [11 bits do pokemon do RED][11 bits do 	 #
#		pokemon inimigo], onde os 11 bits se referem ao codigo do pokemon. Para consulta os	 #
#		codigos v�lidos podem ser encontrados em data.s						 #
#													 #											 
# ====================================================================================================== #
# Observa��es:											         #
# 													 #
# -> Este � o arquivo principal do jogo e atrav�s dele s�o chamados outros procedimentos para a execu��o #  
# de determinadas fun��es. Caso esses procedimentos chamem outros procedimentos � usado a pilha e o      #
# registrador sp (stack pointer) para guardar o endere�o de retorno, de modo que os procedimentos possam #
# voltar at� esse arquivo.										 #
# 													 #
# ====================================================================================================== #

# Inicializando menus, hist�ria e �rea iniciais 

#call INICIALIZAR_TELA_INICIAL		# Chama o procedimento em tela_inicial.s

#call INICIALIZAR_INTRO_HISTORIA		# Chama o procedimento em intro_historia.s

li a4, 64	# a4 recebe 32, ou 1_0_000_00 em bin�rio, de acordo com a conve��o para a codifica��o
		# de transi��es de �reas (ver detalhes em areas.s)
		# Dessa forma a0 codifica: 
		# 1(indicativo de transi��o de �rea)X000(para o quarto do RED)00(Entrando por lugar nenhum) 				

call RENDERIZAR_AREA

# Loop principal de gameplay do jogo

LOOP_PRINCIPAL_JOGO:
	# Verifica se alguma tecla relacionada a movimenta��o (w, a, s ou d) ou inventario (i) foi apertada
	call VERIFICAR_TECLA_JOGO
	
	j  LOOP_PRINCIPAL_JOGO
				

# ====================================================================================================== #


.data
	#.include "Codigos/tela_inicial.s"
	#.include "Codigos/intro_historia.s"
	.include "Codigos/inventario.s"		
	.include "Codigos/historia.s"	
	.include "Codigos/areas.s"
	.include "Codigos/controles_movimentacao.s"	
	.include "Codigos/combate.s"			
	.include "Codigos/procedimentos_auxiliares.s"
