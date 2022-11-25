.text

# ====================================================================================================== # 
# 						   AREAS				                 #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# Este arquivo possui os procedimentos neces�rios para renderizar as diferentes �reas do jogo.           # 
#													 #
# ====================================================================================================== #

RENDERIZAR_QUARTO_RED:
	# Procedimento que imprime a imagem do quarto do RED no frame 0
	
	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	# Imprimindo a casa_red_quarto no frame 0
		la a0, casa_red_quarto		# carregando a imagem em a0
		li a1, 0xFF000000		# selecionando como argumento o frame 0
		call PRINT_TELA

	j FIM_RENDERIZAR_AREA



FIM_RENDERIZAR_AREA:

	# Mostra o frame 0		
	li t0, 0xFF200604		# t0 = endere�o para escolher frames 
	sb zero, (t0)			# armazena 0 no endere�o de t0

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret

# ====================================================================================================== #					
 
.data
	.include "../Imagens/areas/casa_red_quarto.data"
	.include "../Imagens/intro_historia/intro_dialogos.data"