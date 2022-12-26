.text

# ====================================================================================================== # 
# 						   AREAS				                 #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# Este arquivo possui os procedimentos neces�rios para renderizar as diferentes �reas do jogo, fazendo   #
# as altera��es necess�rias nos registradores s1 (orienta��o do personagem), s2 (endere�o da subse��o da #
# area atual onde o personagem est�), s3 (tamanho de uma linha da �rea atual), s4 (posi��o na matriz de  #
# movimenta��o) e s5 (tamanho de linha na matriz)			  				 #		 #								 #											 #
#            												 #	 
# ====================================================================================================== #

RENDERIZAR_QUARTO_RED:
	# Procedimento que imprime a imagem do quarto do RED e o sprite do RED no frame 0 e no frame 1
	
	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	# Atualizando os registradores salvos para essa �rea
		# Atualizando o valor de s1 (orienta��o do personagem)
		li s1, 2	# inicialmente virado para cima
		
		# Atualizando o valor de s2 (endere�o da subsec��o onde o personagem est� na �rea atual) e
		# s3 (tamanho de uma linha da �rea atual)
		la s2, casa_red_quarto		# carregando em s2 o endere�o da imagem da �rea
		
		lw s3, 0(s2)			# s3 recebe o tamanho de uma linha da imagem da �rea
		
		addi s2, s2, 8			# pula para onde come�a os pixels no .data
		
		li t0, 24000			# 40 * 600 = 24.000, move o endere�o de s2 algumas linhas para
		add s2, s2, t0			# baixo, de modo que s2 tem o endere�o da subsec��o onde o
						# personagem vai estar
						
		# Atualizando o valor de s4 (posi��o atual na matriz de movimenta��o da �rea) e 
		# s5 (tamanho de linha na matriz)	
		la t0, matriz_casa_red_quarto	
		
		lw s5, 0(t0)			# s5 recebe o tamanho de uma linha da matriz da �rea
				
		addi t0, t0, 8
	
		addi s4, t0, 72		# o personagem come�a na linha 10 e coluna 8 da matriz
					# ent�o � somado o endere�o base da matriz (t0) a 
		addi s4, s4, 1		# 10 (n�mero da linha) * 18 (tamanho de uma linha da matriz) 
					# e a 8 (n�mero da coluna) 
											
	# Imprimindo as imagens da �rea e o sprite inicial do RED no frame 0					
		# Imprimindo a casa_red_quarto no frame 0
		mv a0, s2		# move para a0 o endere�o de s2
		li a1, 0xFF000000	# selecionando como argumento o frame 0
		li a2, 600		# 600 = tamanho de uma linha da imagem dessa �rea
		call PRINT_AREA		
			
		# Imprimindo a imagem do RED virado para cima no frame 0
		la a0, red_cima		# carrega a imagem				
		mv a1, s0		# move para a1 o endere�o de s0 (endere�o de onde o RED fica na tela)
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		call PRINT_IMG	

	# Imprimindo as imagens da �rea e o sprite inicial do RED no frame 1					
		# Imprimindo a casa_red_quarto no frame 1
		mv a0, s2		# move para a0 o endere�o de s2
		li a1, 0xFF100000	# selecionando como argumento o frame 1
		li a2, 600		# 600 = tamanho de uma linha da imagem dessa �rea
		call PRINT_AREA		
			
		# Imprimindo a imagem do RED virado para cima no frame 1
		la a0, red_cima		# carrega a imagem				
		mv a1, s0		# move para a1 o endere�o de s0 (endere�o de onde o RED fica na tela)
		
		li t0, 0x00100000	# passa o endere�o de a1 para o equivalente no frame 1
		add a1, a1, t0
			
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		call PRINT_IMG	
				
		
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
	.include "../Imagens/areas/matriz_casa_red_quarto.data"
