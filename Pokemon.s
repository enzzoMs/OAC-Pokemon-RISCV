.text

# ====================================================================================================== # 
# 					Pok�mon FireRed/LeafGreen				         #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# Este arquivo cont�m a l�gica central do jogo incluindo o loop principal e a chamada de procedimentos   #
# adquados para renderizar os elementos visuais.							 #
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

call INICIALIZAR_INTRO_HISTORIA		# Chama o procedimento em intro_historia.s


loop : j loop	 # loop eterno 

# ====================================================================================================== #

.data
	.include "Codigos/tela_inicial.s"
	.include "Codigos/intro_historia.s"
	.include "Codigos/procedimentos_auxiliares.s"
