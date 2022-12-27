.text

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
#	s0 = guarda a posi��o do personagem no frame 0, marcado pelo endere�o do pixel na parte superior #
# 		esquerda do sprite do RED				 		 		 #
#	s1 = orienta��o do personagem, convencionado da seguinte forma:					 #
#		[ 0 ] = virado para a esquerda								 # 
#		[ 1 ] = virado para a direita								 #
#		[ 2 ] = virado para cima 								 #
#		[ 3 ] = virado para baixo								 #
#	s2 = guarda o endere�o de inicio da subsec��o (320 x 240) da �rea onde o personagem est�  	 #
#	s3 = o tamanho de uma linha da imagem da �rea atual						 # 
#	s4 = guarda o endere�o da posi��o atual do personagem na matriz de movimenta��o da �rea em que	 #
#		ele est�										 #
#	s5 = tamanho de uma linha da matriz de movimenta��o da �rea atual
#	s6 = determina como ser� o pr�ximo passo do RED durante as anima��es de movimento, de modo que   #
#		[ 0 ] = pr�ximo passo ser� dado com o p� esquerdo					 #
#		[ Qualquer outro valor] = pr�ximo passo ser� dado com o p� direito			 #
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

# Inicializando registradores salvos
	
	# Inicializando s0
	# O sprite do personagem sempre fica numa posi��o fixa na tela, o endere�o dessa posi��o � 
	# armazenado em s0
	li a1, 0xFF000000		# seleciona como argumento o frame 0
	li a2, 148 			# numero da coluna do RED = 148
	li a3, 108			# numero da linha do RED = 108
	call CALCULAR_ENDERECO
	
	mv s0, a0		# move para s0 o valor retornado pelo procedimento chamado acima

# Inicializando menus, hist�ria e �rea iniciais 

call INICIALIZAR_TELA_INICIAL		# Chama o procedimento em tela_inicial.s

call INICIALIZAR_INTRO_HISTORIA		# Chama o procedimento em intro_historia.s

li a0, 0xE0	# a0 recebe 0xE0, ou 1110_0000 em bin�rio, de acordo com a conve��o para a codifica��o
		# de transi��es de �reas (ver detalhes em areas.s)
		# Dessa forma a0 codifica: 
		# 1(indicativo de transi��o de �rea)11(sem nenhuma anima��o de transi��o) +
		# 000(para o quarto do RED)00(Entrando por lugar nenhum) 
		
call RENDERIZAR_AREA		# chama o procedimento em areas.s
		

# Loop principal de gameplay do jogo

LOOP_PRINCIPAL_JOGO:
	call VERIFICAR_TECLA_MOVIMENTACAO
	
	j  LOOP_PRINCIPAL_JOGO
				

# ====================================================================================================== #

.data
	.include "Codigos/tela_inicial.s"
	.include "Codigos/intro_historia.s"
	.include "Codigos/areas.s"
	.include "Codigos/controles_movimentacao.s"	
	.include "Codigos/procedimentos_auxiliares.s"
