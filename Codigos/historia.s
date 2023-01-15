.text

# ====================================================================================================== # 
# 						 HISTORIA				                 #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# C�digo com os procedimentos necess�rios para renderizar os momentos de hist�ria do jogo, incluindo	 #
# imprimir caixas de di�logo e executar algumas anima��es 						 #
#													 #
# Esse arquivo possui 3 procedimentos principais, um para cada momento de hist�ria do jogo:		 #
#	RENDERIZAR_ANIMACAO_PROF_OAK, ...								 #
#													 #
# ====================================================================================================== #

RENDERIZAR_ANIMACAO_PROF_OAK:
	# Esse procedimento � chamado quando o RED tenta pela primeira vez sair da �rea principal de Pallet
	# e andar sobre um tile de grama. Quando o jogador passa por esses tiles existe a chance de um 
	# Pokemon aparecer e iniciar uma batalha, mas como na primeria vez o jogador ainda n�o tem Pokemon 
	# ele precisa ir ao laborat�rio. Portanto, esse procedimento renderiza a anima��o do Professor 
	# Carvalho indo ao jogador, renderiza o dial�go explicando que o RED tem que escolher seu Pokemon 
	# inicial, e depois renderiza a anima��o do professor voltanto de onde ele veio.




