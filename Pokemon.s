.text

# ====================================================================================================== # 
# 					Pok�mon FireRed/LeafGreen				         #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# Este arquivo cont�m a l�gica central do jogo incluindo o loop principal e a chamada de procedimentos   #
# adquados para renderizar os elementos visuais.							 #
#													 #
# ====================================================================================================== #

call CARREGAR_TELA_INICIAL



loop : j loop	 # loop eterno 

# ====================================================================================================== #

.data
	.include "Codigos/tela_inicial.s"
