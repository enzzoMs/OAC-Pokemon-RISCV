.text

# ====================================================================================================== # 
# 				        CONTROLES E MOVIMENTA��O				         #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# C�digo respons�vel por renderizar a hist�ria introdut�ria do jogo com todas as suas anima��es.         # 
#													 #
# ====================================================================================================== #

VERIFICAR_TECLA_MOVIMENTACAO:
	# Este procedimento � respons�vel por coordenar a movimenta��o do personagem,
	# ele chama VERIFICAR_TECLA e decide a partir do retorno os procedimentos adequados

	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	call VERIFICAR_TECLA
	
	
	# Verifica se alguma tecla (a, w, s ou d) foi apertada, chamando o procedimento adequado
		li t0, 'w'
		beq a0, t0, MOVIMENTACAO_TECLA_W
		li t0, 'a'
		beq a0, t0, MOVIMENTACAO_TECLA_A
		li t0, 's'
		beq a0, t0, MOVIMENTACAO_TECLA_S
		li t0, 'd'
		beq a0, t0, MOVIMENTACAO_TECLA_D
	
	
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret

# ====================================================================================================== #	

MOVIMENTACAO_TECLA_W:
	# Procedimento que coordena a movimenta��o do personagem para cima
	
	# OBS: n�o � necess�rio empilhar o valor de ra pois a chegada a este procedimento � por meio
	# de uma instru��o de branch
	
	# Primeiro verifica se o personagem est� virado para cima
		li t0, 2
		beq s2, t0, INICIO_MOVIMENTACAO_W
			la a4, red_cima		# carrega como argumento o sprite do RED virada para cima		
			call MUDAR_ORIENTACAO_PERSONAGEM
			
			li s2, 2	# atualiza o valor de s2 dizendo que agora o RED est� virado 
					# para cima
							
	INICIO_MOVIMENTACAO_W:
	
	li t3, 26		# n�mero de pixels que o personagem vai se deslocar, ou seja,
				# o n�mero de loops a serem executados abaixo
	
	# Calcula o endere�o de onde renderizar a imagem do RED no frame 0
		li a1, 0xFF000000		# seleciona como argumento o frame 0
		mv a2, s0 			# numero da coluna do RED = s0
		mv a3, s1			# numero da linha do RED = s1
		call CALCULAR_ENDERECO	
		
		mv t4, a0		# salva o endere�o retornado em t4
		
		
		la a0, red_cima			# o loop de movimenta��o come�a imprimindo a imagem do RED 
						# virado para cima normalmente	
						
		# Decide se o RED vai ser renderizado dando o passo com o p� esquedo ou direito
		# de acordo com o valor de s4
		
		la t5, red_cima_passo_direito
		
		beq s4, zero, LOOP_MOVIMENTACAO_W		
			la t5, red_cima_passo_esquerdo
	
														
	LOOP_MOVIMENTACAO_W:
		# Primeiro renderiza o sprite do RED
			# a0 j� possui o endere�o da imagem a ser renderizar
			mv a1, t4		# passa para a1 o endere�o de onde renderizar o sprite
			mv a2, s3		# passa para a2 o endere�o da �rea atual
			lw a3, 0(a0)		# numero de colunas do sprite
			lw a4, 4(a0)		# numero de linhas do sprite
			call PRINT_SPRITE
		
		# Limpa a tela, ou seja, remove o sprite antigo do RED
			addi a0, t4, 10240	# passa para a0 o endere�o de onde limpar a tela, ou seja,
						# uma linha para baixo de onde o RED terminou de ser renderizado
						# para encontrar esse lugar � s� adicionar a altura do
						# sprite do RED (32) vezes o tamanho de uma linha (320)
						# 32 * 320 = 10240 
			mv a1, s3		# passa para a1 o endere�o da �rea atual
			li a2, 26		# numero de colunas a serem limpas
			li a3, 1		# numero de linhas a serem limpas
			call LIMPAR_TELA

		addi t4, t4, -320	# move o endere�o de onde renderizar o RED uma linha para tr�s
																																																																								
		addi t3, t3, -1		# decrementa o n�mero de loops restantes
		
		# Espera alguns milisegundos	
		li a7, 32			# selecionando syscall sleep
		li a0, 1			# sleep por 1 ms
		ecall
		
		# Determina qual � o pr�ximo sprite do RED a ser renderizado,
		# de modo que a anima��o siga o seguinte padr�o:
		# RED PARADO -> RED DANDO UM PASSO -> RED PARADO
		
		la a0, red_cima
		li t0, 22
		bgt t3, t0, LOOP_MOVIMENTACAO_W
		mv a0, t5				# t5 tem o endere�o da imagem do RED dando um passo
		li t0, 4
		bgt t3, t0, LOOP_MOVIMENTACAO_W
		la a0, red_cima
		bne t3, zero, LOOP_MOVIMENTACAO_W
		
	addi s1, s1, -25	# atualiza a linha atual do personagem pelo n�mero de loops executados	
	
	not s4, s4		# inverte o valor de s4, ou seja, se o RED deu um passo esquerdo o pr�ximo
				# ser� direito e vice-versa
					
	FIM_MOVIMENTACAO_W:
													
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret	

# ====================================================================================================== #

MOVIMENTACAO_TECLA_A:
	# Procedimento que coordena a movimenta��o do personagem para a esquerda
	
	# OBS: n�o � necess�rio empilhar o valor de ra pois a chegada a este procedimento � por meio
	# de uma instru��o de branch
	
	# Primeiro verifica se o personagem est� virado para a esquerda
		beq s2, zero, INICIO_MOVIMENTACAO_A
			la a4, red_esquerda	# carrega como argumento o sprite do RED virada para a esquerda		
			call MUDAR_ORIENTACAO_PERSONAGEM
			
			li s2, 0	# atualiza o valor de s2 dizendo que agora o RED est� virado 
					# para a esquerda
							
	INICIO_MOVIMENTACAO_A:
	
	li t3, 26		# n�mero de pixels que o personagem vai se deslocar, ou seja,
				# o n�mero de loops a serem executados abaixo
	
	# Calcula o endere�o de onde renderizar a imagem do RED no frame 0
		li a1, 0xFF000000		# seleciona como argumento o frame 0
		mv a2, s0 			# numero da coluna do RED = s0
		mv a3, s1			# numero da linha do RED = s1
		call CALCULAR_ENDERECO	
		
		mv t4, a0		# salva o endere�o retornado em t4
		
		
		la a0, red_esquerda		# o loop de movimenta��o come�a imprimindo a imagem do RED 
						# virado para a esquerda normalmente	
						
		# Decide se o RED vai ser renderizado dando o passo com o p� esquedo ou direito
		# de acordo com o valor de s4
		
		la t5, red_esquerda_passo_direito
		
		beq s4, zero, LOOP_MOVIMENTACAO_A		
			la t5, red_esquerda_passo_esquerdo
	
														
	LOOP_MOVIMENTACAO_A:
		# Primeiro renderiza o sprite do RED
			# a0 j� possui o endere�o da imagem a ser renderizar
			mv a1, t4		# passa para a1 o endere�o de onde renderizar o sprite
			mv a2, s3		# passa para a2 o endere�o da �rea atual
			lw a3, 0(a0)		# numero de colunas do sprite
			lw a4, 4(a0)		# numero de linhas do sprite
			call PRINT_SPRITE
		
		# Limpa a tela, ou seja, remove o sprite antigo do RED
			addi a0, t4, 26		# passa para a0 o endere�o de onde limpar a tela, ou seja,
						# um pixel para frente de onde o RED terminou de 
						# ser renderizado
						# para encontrar esse lugar � s� somar a largura do
						# sprite do RED ->  26 
			mv a1, s3		# passa para a1 o endere�o da �rea atual
			li a2, 1		# numero de colunas a serem limpas
			li a3, 32		# numero de linhas a serem limpas
			call LIMPAR_TELA

		addi t4, t4, -1		# move o endere�o de onde renderizar o RED um pixel para tr�s
																																																																								
		addi t3, t3, -1		# decrementa o n�mero de loops restantes
		
		# Espera alguns milisegundos	
		li a7, 32			# selecionando syscall sleep
		li a0, 1			# sleep por 1 ms
		ecall
		
		# Determina qual � o pr�ximo sprite do RED a ser renderizado,
		# de modo que a anima��o siga o seguinte padr�o:
		# RED PARADO -> RED DANDO UM PASSO -> RED PARADO
		
		la a0, red_esquerda
		li t0, 22
		bgt t3, t0, LOOP_MOVIMENTACAO_A
		mv a0, t5				# t5 tem o endere�o da imagem do RED dando um passo
		li t0, 4
		bgt t3, t0, LOOP_MOVIMENTACAO_A
		la a0, red_esquerda
		bne t3, zero, LOOP_MOVIMENTACAO_A
		
	addi s0, s0, -25	# atualiza a coluna atual do personagem pelo n�mero de loops executados	
	
	not s4, s4		# inverte o valor de s4, ou seja, se o RED deu um passo esquerdo o pr�ximo
				# ser� direito e vice-versa
				
	FIM_MOVIMENTACAO_A:
													
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret	

# ====================================================================================================== #

MOVIMENTACAO_TECLA_S:
	# Procedimento que coordena a movimenta��o do personagem para baixo
	
	# OBS: n�o � necess�rio empilhar o valor de ra pois a chegada a este procedimento � por meio
	# de uma instru��o de branch
	
	# Primeiro verifica se o personagem est� virado para baixo
		li t0, 3
		beq s2, t0, INICIO_MOVIMENTACAO_S
			la a4, red_baixo	# carrega como argumento o sprite do RED virada para baixo		
			call MUDAR_ORIENTACAO_PERSONAGEM
			
			li s2, 3	# atualiza o valor de s2 dizendo que agora o RED est� virado 
					# para baixo
							
	INICIO_MOVIMENTACAO_S:
	
	li t3, 26		# n�mero de pixels que o personagem vai se deslocar, ou seja,
				# o n�mero de loops a serem executados abaixo
	
	# Calcula o endere�o de onde renderizar a imagem do RED no frame 0
		li a1, 0xFF000000		# seleciona como argumento o frame 0
		mv a2, s0 			# numero da coluna do RED = s0
		mv a3, s1			# numero da linha do RED = s1
		call CALCULAR_ENDERECO	
		
		mv t4, a0		# salva o endere�o retornado em t4
		
		
		la a0, red_baixo		# o loop de movimenta��o come�a imprimindo a imagem do RED 
						# virado para baixo normalmente	
						
		# Decide se o RED vai ser renderizado dando o passo com o p� esquedo ou direito
		# de acordo com o valor de s4
		
		la t5, red_baixo_passo_direito
		
		beq s4, zero, LOOP_MOVIMENTACAO_S		
			la t5, red_baixo_passo_esquerdo
	
														
	LOOP_MOVIMENTACAO_S:
		# Primeiro renderiza o sprite do RED
			# a0 j� possui o endere�o da imagem a ser renderizar
			mv a1, t4		# passa para a1 o endere�o de onde renderizar o sprite
			mv a2, s3		# passa para a2 o endere�o da �rea atual
			lw a3, 0(a0)		# numero de colunas do sprite
			lw a4, 4(a0)		# numero de linhas do sprite
			call PRINT_SPRITE
		
		# Limpa a tela, ou seja, remove o sprite antigo do RED
			addi a0, t4, -320	# passa para a0 o endere�o de onde limpar a tela, ou seja,
						# uma linha atr�s de onde o RED foi renderizado 
			mv a1, s3		# passa para a1 o endere�o da �rea atual
			li a2, 26		# numero de colunas a serem limpas
			li a3, 1		# numero de linhas a serem limpas
			call LIMPAR_TELA

		addi t4, t4, 320	# move o endere�o de onde renderizar o RED uma linha para frente
																																																																								
		addi t3, t3, -1		# decrementa o n�mero de loops restantes
		
		# Espera alguns milisegundos	
		li a7, 32			# selecionando syscall sleep
		li a0, 1			# sleep por 1 ms
		ecall
		
		# Determina qual � o pr�ximo sprite do RED a ser renderizado,
		# de modo que a anima��o siga o seguinte padr�o:
		# RED PARADO -> RED DANDO UM PASSO -> RED PARADO
		
		la a0, red_baixo
		li t0, 22
		bgt t3, t0, LOOP_MOVIMENTACAO_S
		mv a0, t5				# t5 tem o endere�o da imagem do RED dando um passo
		li t0, 4
		bgt t3, t0, LOOP_MOVIMENTACAO_S
		la a0, red_baixo
		bne t3, zero, LOOP_MOVIMENTACAO_S
		
	addi s1, s1, 25		# atualiza a linha atual do personagem pelo n�mero de loops executados	
	
	not s4, s4		# inverte o valor de s4, ou seja, se o RED deu um passo esquerdo o pr�ximo
				# ser� direito e vice-versa
	
	FIM_MOVIMENTACAO_S:
													
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret	

# ====================================================================================================== #

MOVIMENTACAO_TECLA_D:
	# Procedimento que coordena a movimenta��o do personagem para a direita
	
	# OBS: n�o � necess�rio empilhar o valor de ra pois a chegada a este procedimento � por meio
	# de uma instru��o de branch
	
	# Primeiro verifica se o personagem est� virado para a direita
		li t0, 1
		beq s2, t0, INICIO_MOVIMENTACAO_D
			la a4, red_direita	# carrega como argumento o sprite do RED virada para a direita		
			call MUDAR_ORIENTACAO_PERSONAGEM
			
			li s2, 1	# atualiza o valor de s2 dizendo que agora o RED est� virado 
					# para a direita
							
	INICIO_MOVIMENTACAO_D:
	
	li t3, 26		# n�mero de pixels que o personagem vai se deslocar, ou seja,
				# o n�mero de loops a serem executados abaixo
	
	# Calcula o endere�o de onde renderizar a imagem do RED no frame 0
		li a1, 0xFF000000		# seleciona como argumento o frame 0
		mv a2, s0 			# numero da coluna do RED = s0
		mv a3, s1			# numero da linha do RED = s1
		call CALCULAR_ENDERECO	
		
		mv t4, a0		# salva o endere�o retornado em t4
		
		
		la a0, red_direita		# o loop de movimenta��o come�a imprimindo a imagem do RED 
						# virado para a direita normalmente	
						
		# Decide se o RED vai ser renderizado dando o passo com o p� esquedo ou direito
		# de acordo com o valor de s4
		
		la t5, red_direita_passo_direito
		
		beq s4, zero, LOOP_MOVIMENTACAO_D		
			la t5, red_direita_passo_esquerdo
	
														
	LOOP_MOVIMENTACAO_D:
		# Primeiro renderiza o sprite do RED
			# a0 j� possui o endere�o da imagem a ser renderizar
			mv a1, t4		# passa para a1 o endere�o de onde renderizar o sprite
			mv a2, s3		# passa para a2 o endere�o da �rea atual
			lw a3, 0(a0)		# numero de colunas do sprite
			lw a4, 4(a0)		# numero de linhas do sprite
			call PRINT_SPRITE
		
		# Limpa a tela, ou seja, remove o sprite antigo do RED
			addi a0, t4, -1		# passa para a0 o endere�o de onde limpar a tela, ou seja,
						# um pixel atr�s de onde o RED foi renderizado 
			mv a1, s3		# passa para a1 o endere�o da �rea atual
			li a2, 1		# numero de colunas a serem limpas
			li a3, 32		# numero de linhas a serem limpas
			call LIMPAR_TELA

		addi t4, t4, 1		# move o endere�o de onde renderizar o RED um pixel para frente
																																																																								
		addi t3, t3, -1		# decrementa o n�mero de loops restantes
		
		# Espera alguns milisegundos	
		li a7, 32			# selecionando syscall sleep
		li a0, 1			# sleep por 1 ms
		ecall
		
		# Determina qual � o pr�ximo sprite do RED a ser renderizado,
		# de modo que a anima��o siga o seguinte padr�o:
		# RED PARADO -> RED DANDO UM PASSO -> RED PARADO
		
		la a0, red_direita
		li t0, 22
		bgt t3, t0, LOOP_MOVIMENTACAO_D
		mv a0, t5				# t5 tem o endere�o da imagem do RED dando um passo
		li t0, 4
		bgt t3, t0, LOOP_MOVIMENTACAO_D
		la a0, red_direita
		bne t3, zero, LOOP_MOVIMENTACAO_D
		
	addi s0, s0, 25		# atualiza a coluna atual do personagem pelo n�mero de loops executados	
	
	not s4, s4		# inverte o valor de s4, ou seja, se o RED deu um passo esquerdo o pr�ximo
				# ser� direito e vice-versa
				
	FIM_MOVIMENTACAO_D:
													
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret	

# ====================================================================================================== #									

MUDAR_ORIENTACAO_PERSONAGEM:
	# Procedimento que muda a orienta��o do personagem a depender do argumento, ou seja,
	# imprime o sprite do RED em uma determinada orienta��o.
	# OBS: O procedimento n�o altera o valor de s2, apenas imprime o sprite em uma orienta��o
	# Argumentos:
	# 	 a4 = endere�o da imagem do RED na orienta��o desejada
	
	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	# Calcula o endere�o de onde renderizar a imagem do RED no frame 0
		li a1, 0xFF000000		# seleciona como argumento o frame 0
		mv a2, s0 			# numero da coluna do RED = s0
		mv a3, s1			# numero da linha do RED = s1
		call CALCULAR_ENDERECO
	
	mv t5, a0		# guarda temporariamente o endere�o retornado em t5
		
	# Antes de renderizar o novo sprite do RED � necess�rio limpar a tela, removendo
	# o antigo sprite
		# a0 j� possui o endere�o de onde limpar a tela
		mv a1, s3 		# carregando a imagem da area atual salvo em s3
		li a2, 26		# numero de colunas do sprite a serem removidas
		li a3, 32		# numero de linhas do sprite a serem removidas
		call LIMPAR_TELA
		
		mv a1, t5		# move para a1 o endere�o guardado em t5
		
		# Imprimindo a imagem do RED virado para a direita no frame 0
		mv a0, a4		# carrega a imagem a partir do argumento a4
		# a1 j� possui o endere�o de onde renderizar o RED
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		call PRINT_IMG	
			
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret	
	
# ====================================================================================================== #										

								
LIMPAR_TELA:
	# Procedimento que "limpa a tela", ou seja, remove o sprite de um personagem ou objeto da tela 
	# e o substitui pela imagem adequada de uma �rea
	# Argumentos:
	#	a0 = endere�o, no frame 0, de onde renderizar a imagem e limpar a tela
	# 	a1 = endere�o base da imagem da �rea que ser� renderizada para limpar a tela
	#	a2 = numero de colunas do sprite a ser removido
	# 	a3 = numero de linhas do sprite a ser removido
	
	
	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	addi a1, a1, 8		# pula para onde come�a os pixels no .data da imagem da �rea
	
	li t0, 0xFF000000	# t0 = endere�o base do frame 0
	sub t0, a0, t0		# a0 (endere�o de onde limpar a tela ) - t0 (endere�o base do frame 0) = 
				# quantos pixels � necess�rio pular na imagem da �rea (a1) para encontrar 
				# onde a sub imagem que ser� usada na limpeza 

	add a1, a1, t0		# pula para o endere�o da sub imagem da �rea que ser� usada na limpeza
		
		
	LIMPA_TELA_LINHAS:
		mv t0, a2		# copia do valor de a2 para o loop de colunas
			
		LIMPA_TELA_COLUNAS:
			lb t1, 0(a1)		# pega 1 pixel do .data da sub imagem da �rea e coloca em t1
			sb t1, 0(a0)		# pega o pixel de t1 e coloca no bitmap
	
			addi t0, t0, -1			# decrementando o numero de colunas restantes
			addi a1, a1, 1			# vai para o pr�ximo pixel da sub imagem da �rea
			addi a0, a0, 1			# vai para o pr�ximo pixel do bitmap
			bne t0, zero, LIMPA_TELA_COLUNAS	# reinicia o loop se t0 != 0
			
		addi a3, a3, -1			# decrementando o numero de linhas restantes
		sub a0, a0, a2			# volta o endere�o do bitmap pelo n�mero de colunas impressas
		addi a0, a0, 320		# passa o endere�o do bitmap para a proxima linha
		sub a1, a1, a2			# volta o endere�o da imagem da �rea pelo n�mero de colunas impressas
		addi a1, a1, 320		# passa o endere�o da imagem para a proxima linha
		bne a3, zero, LIMPA_TELA_LINHAS	       # reinicia o loop se a3 != 0

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret	

# ====================================================================================================== #									
.data
	.include "../Imagens/red/red_direita.data"
	.include "../Imagens/red/red_direita_passo_esquerdo.data"
	.include "../Imagens/red/red_direita_passo_direito.data"
	.include "../Imagens/red/red_cima.data"
	.include "../Imagens/red/red_cima_passo_esquerdo.data"
	.include "../Imagens/red/red_cima_passo_direito.data"	
	.include "../Imagens/red/red_baixo.data"
	.include "../Imagens/red/red_baixo_passo_esquerdo.data"
	.include "../Imagens/red/red_baixo_passo_direito.data"	
	.include "../Imagens/red/red_esquerda.data"
	.include "../Imagens/red/red_esquerda_passo_esquerdo.data"
	.include "../Imagens/red/red_esquerda_passo_direito.data"	
