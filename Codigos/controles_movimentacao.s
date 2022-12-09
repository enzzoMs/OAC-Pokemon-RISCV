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
		beq s2, t0, FIM_MOVIMENTACAO_W
			la a4, red_cima		# carrega como argumento o sprite do RED virada para cima		
			call MUDAR_ORIENTACAO_PERSONAGEM
			
			li s2, 2	# atualiza o valor de s2 dizendo que agora o RED est� virado 
					# para cima
	
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
		beq s2, zero, FIM_MOVIMENTACAO_A
			la a4, red_esquerda	# carrega como argumento o sprite do RED virada para a esquerda		
			call MUDAR_ORIENTACAO_PERSONAGEM
			
			li s2, 0	# atualiza o valor de s2 dizendo que agora o RED est� virado 
					# para a esquerda
	
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
		beq s2, t0, FIM_MOVIMENTACAO_S
			la a4, red_baixo	# carrega como argumento o sprite do RED virada para baixo		
			call MUDAR_ORIENTACAO_PERSONAGEM
			
			li s2, 3	# atualiza o valor de s2 dizendo que agora o RED est� virado 
					# para baixo
	
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
		beq s2, t0, FIM_MOVIMENTACAO_D
			la a4, red_direita	# carrega como argumento o sprite do RED virada para a direita		
			call MUDAR_ORIENTACAO_PERSONAGEM
			
			li s2, 1	# atualiza o valor de s2 dizendo que agora o RED est� virado 
					# para a direita
										
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
		
		li s2, 1		# atualiza o valor de s2
		
			
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret	
	
# ====================================================================================================== #										
	
LIMPAR_TELA:
	# Procedimento que "limpa a tela", ou seja, remove o sprite de um personagem da tela (frame 0) e o 
	# substitui pela imagem adequada de uma �rea
	# Argumentos:
	#	a0 = endere�o, no frame 0, de onde renderizar a imagem e remover o sprite
	#		tamb�m pode ser entendido como o endere�o onde o sprite est�
	# 	a1 = endere�o da �rea onde o personagem est�	
	#	a2 = numero de colunas do sprite a ser removido
	# 	a3 = numero de linhas do sprite a ser removido
	
	
	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	li t0, 0xFF000000	# t0 = endere�o base do frame 0
	sub t0, a0, t0		# a0 (endere�o de onde o sprite est� no frame 0) - 
				# t0 (endere�o base do frame 0) = quantos pixels � necess�rio pular
				# na imagem da �rea (a1) para encontrar onde o sprite est�
	
	addi a1, a1, 8		# pula para onde come�a os pixels no .data
	add a1, a1, t0		# pula para o endere�o da imagem onde o sprite est�
	
	li t0, 0		# contador para o numero de linhas ja impressas
	
	LIMPA_TELA_LINHAS:
		li t1, 0		# contador para o numero de colunas ja impressas
		addi t2, a0, 0		# copia do endere�o de t4 para usar no loop de colunas
		addi t3, a1, 0		# copia do endere�o de a4 para usar no loop de colunas
			
		LIMPA_TELA_COLUNAS:
			lb t4, 0(t3)			# pega 1 pixel do .data e coloca em t4
			sb t4, 0(t2)			# pega o pixel de t4 e coloca no bitmap
	
			addi t1, t1, 1			# incrementando o numero de colunas impressas
			addi t3, t3, 1			# vai para o pr�ximo pixel da imagem
			addi t2, t2, 1			# vai para o pr�ximo pixel do bitmap
			bne t1, a2, LIMPA_TELA_COLUNAS	# reinicia o loop se t1 != t2
			
		addi t0, t0, 1				# incrementando o numero de linhas impressas
		addi a0, a0, 320			# passa o endere�o do bitmap para a proxima linha
		addi a1, a1, 320			# passa o endere�o da imagem para a proxima linha
		bne t0, a3, LIMPA_TELA_LINHAS	        # reinicia o loop se t0 != a3

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret	

# ====================================================================================================== #									
.data
	.include "../Imagens/red/red_direita.data"
	.include "../Imagens/red/red_cima.data"
	.include "../Imagens/red/red_baixo.data"	
	.include "../Imagens/red/red_esquerda.data"
