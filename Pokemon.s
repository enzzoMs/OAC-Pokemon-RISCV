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
#	s0 = n�mero da COLUNA atual do personagem na tela, marcado pelo pixel na parte superior esquerda #
#       do sprite do RED.										 #
#	s1 = n�mero da LINHA atual do personagem na tela, marcado pelo pixel na parte superior esquerda  #
#       do sprite do RED.										 #
#	s2 = orienta��o do personagem, convencionado da seguinte forma:					 #
#		[ 0 ] = virado para a esquerda								 # 
#		[ 1 ] = virado para a direita								 #
#		[ 2 ] = virado para cima 								 #
#		[ 3 ] = virado para baixo								 #
#	s3 = guarda o endere�o base da imagem da �rea atual onde o personagem est�  			 #	
#	s4 = determina como ser� o pr�ximo passo do RED durante as anima��es de movimento, de modo que   #
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


call INICIALIZAR_TELA_INICIAL		# Chama o procedimento em tela_inicial.s

call INICIALIZAR_INTRO_HISTORIA	# Chama o procedimento em intro_historia.s

call RENDERIZAR_QUARTO_RED		# chama o procedimento em areas.s
		

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
