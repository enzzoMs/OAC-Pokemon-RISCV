.text

# ====================================================================================================== # 
# 						TELA INICIAL				                 #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# C�digo respons�vel por renderizar a tela inicial do jogo, incluindo pequenas anima��es.                # 
#													 #
# ====================================================================================================== #


CARREGAR_TELA_INICIAL:

	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra

	call RENDERIZAR_ANIMACAO_FAIXA
	
	# Espera alguns milisegundos	
	li a7, 32			# selecionando syscall sleep
	li a0, 500			# sleep por 500 ms
	ecall
	
	call RENDERIZAR_ANIMACAO_POKEMONS
	
	# Imprimindo a tela inicial
	la a0, tela_inicial		# carregando a imagem da tela inicial
	li a1, 0xFF100000		# selecionando como argumento o frame 1
	call PRINT_TELA
	
	
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret
	

# ------------------------------------------------------------------------------------------------------ #

RENDERIZAR_ANIMACAO_FAIXA:

	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Antes de mostrar a tela inicial ocorre uma pequena anima��o onde as imagem do bulbasaur e 
	# charizard s�o atravessadas por uma faixa branca, esse procedimento � respons�vel por execut�-la

	# Imprimindo a tela de pr� anima��o
		la a0, pre_animacao_inicial	# carrega a imagem
		li a1, 0xFF100000		# seleciona como argumento o frame 1
		call PRINT_TELA	
	
	call TROCAR_FRAME 			# trocando o frame para o 1
		
	# Espera alguns milisegundos			
	li a7, 32			# selecionando syscall sleep
	li a0, 1000			# sleep por 1 ms
	ecall
		
		
	# Calcula o endere�o do final da imagem do bulbasaur
		li a1, 0xFF100000		# seleciona como argumento o frame 1
		li a2, 3 			# coluna = 3
		li a3, 199			# linha = 199
		call CALCULAR_ENDERECO

		mv a4, a0			# coloca o retorno do procedimento chamado acima em a4

	# Calcula o endere�o do final da imagem do charizard
		li a1, 0xFF100000		# seleciona como argumento o frame 1
		li a2, 206 			# coluna = 206
		li a3, 199			# linha = 199
		call CALCULAR_ENDERECO

		mv a5, a0			# coloca o retorno do procedimento chamado acima em a5


	# Renderizando faixa
		li a6, 115			# numero de vezes que a faixa ser� renderizada
		
		
	LOOP_RENDERIZAR_FAIXA:
		# Espera alguns milisegundos	
		li a7, 32			# selecionando syscall sleep
		li a0, 1			# sleep por 1 ms
		ecall
	
		# renderizando a faixa no bulbasaur
		mv a1, a4			# a1 = a4 = endereco de onde colocar a faixa
		la a0, animacao_faixa		# carrega a imagem da faixa	
		call PRINT_FAIXA
		
		# renderizando a faixa no charizard
		mv a1, a5			# a1 = a5 = endereco de onde colocar a faixa
		la a0, animacao_faixa		# carrega a imagem da faixa	
		call PRINT_FAIXA
		
		addi a4, a4, -320		# passando o endereco da faixa para a linha anterior
		addi a5, a5, -320		# passando o endereco da faixa para a linha anterior
		addi a6, a6, -1			# decrementa a6
		
		bne a6, zero, LOOP_RENDERIZAR_FAIXA	# verifica se a6 == 0 para terminar o loop
			
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
				
	ret


# ------------------------------------------------------------------------------------------------------ #

PRINT_FAIXA:

	# Procedimento auxiliar ao RENDERIZAR_ANIMACAO_FAIXA que imprime a faixa no bitmap, a diferen�a 
	# desse procedimento para o PRINT_IMG � que a faixa � impressa somente onde os bits n�o s�o pretos, 
	# de forma a aparecer o contorno do bulbasaur e charizard
	
	# Argumentos: 
	# 	a0 = endere�o da imgagem		
	# 	a1 = endere�o de onde, no frame escolhido, a imagem deve ser renderizada
	
	lw t0, 0(a0)		# t0 = largura da imagem / numero de colunas da imagem
	lw t1, 4(a0)		# t1 = altura da imagem / numero de linhas da imagem
	
	addi a0, a0, 8		# pula para onde come�a os pixels no .data

	li t2, 0		# contador para o numero de linhas ja impressas
	
	PRINT_LINHAS_FAIXA:
		li t3, 0		# contador para o numero de colunas ja impressas
		mv t4, a1		# copia do endere�o de a1 para usar no loop de colunas
			
		PRINT_COLUNAS_FAIXA:
			lb t5, (a0)			# pega 1 pixel do .data e coloca em t5
			
			lb t6, (t4)			# pega 1 pixel do bitmap

			beq t6, zero, NAO_COLOCAR_PIXEL	# renderiza a faixa somente se o pixel n�o for preto
			sb t5, 0(t4)			# pega o pixel de t5 e coloca no bitmap
	
			NAO_COLOCAR_PIXEL:
			addi t3, t3, 1			# incrementando o numero de colunas impressas
			addi a0, a0, 1			# vai para o pr�ximo pixel da imagem
			addi t4, t4, 1			# vai para o pr�ximo pixel do bitmap
			bne t3, t0, PRINT_COLUNAS_FAIXA	# reinicia o loop se t3 != t0
			
		addi t2, t2, 1				# incrementando o numero de linhas impressas
		addi a1, a1, 320			# passa o endere�o do bitmap para a proxima linha
		bne t2, t1, PRINT_LINHAS_FAIXA	        # reinicia o loop se t2 != t1
			
	ret

# ------------------------------------------------------------------------------------------------------ #

RENDERIZAR_ANIMACAO_POKEMONS:

	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Depois de RENDERIZAR_ANIMACAO_FAIXA esse procedimento realiza tamb�m uma pequena anima��o onde
	# o charizard e bulbasaur v�o lentamente sendo mostrados na tela

	# Calcula o endere�o do come�o da imagem do bulbasaur
		li a1, 0xFF100000		# seleciona como argumento o frame 1
		li a2, 3 			# coluna = 3
		li a3, 115			# linha = 115
		call CALCULAR_ENDERECO

		mv a4, a0			# salva o retorno do procedimento chamado acima em a4

	# Calcula o endere�o do come�o da imagem do charizard
		li a1, 0xFF100000		# seleciona como argumento o frame 1
		li a2, 206 			# coluna = 206
		li a3, 99			# linha = 99
		call CALCULAR_ENDERECO

		mv a5, a0			# salva o retorno do procedimento chamado acima em a5


	# Imprimindo bulba_0
	la a0, bulba_0		# carregando a imagem bulba_0
	mv a1, a4		# a1 = argumento com a posicao onde a imagem do bulbasur ser� impressa
	call PRINT_IMG		
		
	# Imprimindo chari_0
	la a0, chari_0		# carregando a imagem chari_0
	mv a1, a5		# a5 = argumento com a posicao onde a imagem do charizard ser� impressa
	call PRINT_IMG	
	
	# Espera alguns milisegundos	
	li a7, 32		# selecionando syscall sleep
	li a0, 1000		# sleep por 1 s
	ecall
	
	# -------------------------------------------------------------------------------------------- #

	# Imprimindo bulba_1
	la a0, bulba_1		# carregando a imagem bulba_1
	mv a1, a4		# a1 = argumento com a posicao onde a imagem do bulbasur ser� impressa
	call PRINT_IMG		
		
	# Imprimindo chari_1
	la a0, chari_1		# carregando a imagem chari_1
	mv a1, a5		# a5 = argumento com a posicao onde a imagem do charizard ser� impressa
	call PRINT_IMG	
	
	# Espera alguns milisegundos	
	li a7, 32		# selecionando syscall sleep
	li a0, 1000		# sleep por 1 s
	ecall
	
	# -------------------------------------------------------------------------------------------- #

	# Imprimindo bulba_2
	la a0, bulba_2		# carregando a imagem bulba_2
	mv a1, a4		# a1 = argumento com a posicao onde a imagem do bulbasur ser� impressa
	call PRINT_IMG		
		
	# Imprimindo chari_2
	la a0, chari_2		# carregando a imagem chari_2
	mv a1, a5		# a5 = argumento com a posicao onde a imagem do charizard ser� impressa
	call PRINT_IMG	
	
	# Espera alguns milisegundos	
	li a7, 32		# selecionando syscall sleep
	li a0, 1000		# sleep por 1 s
	ecall
	
	# -------------------------------------------------------------------------------------------- #

	# Imprimindo bulba_3
	la a0, bulba_3		# carregando a imagem bulba_3
	mv a1, a4		# a1 = argumento com a posicao onde a imagem do bulbasur ser� impressa
	call PRINT_IMG		
		
	# Imprimindo chari_3
	la a0, chari_3		# carregando a imagem chari_3
	mv a1, a5		# a5 = argumento com a posicao onde a imagem do charizard ser� impressa
	call PRINT_IMG	
	
	# Espera alguns milisegundos	
	li a7, 32		# selecionando syscall sleep
	li a0, 1000		# sleep por 1 s
	ecall
	
	# -------------------------------------------------------------------------------------------- #

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
				
	ret

# ====================================================================================================== #

.data
	.include "../Imagens/tela_inicial/pre_animacao_inicial.data"
	.include "../Imagens/tela_inicial/animacao_faixa.data"
	.include "../Imagens/tela_inicial/bulba_0.data"
	.include "../Imagens/tela_inicial/chari_0.data"	
	.include "../Imagens/tela_inicial/bulba_1.data"
	.include "../Imagens/tela_inicial/chari_1.data"	
	.include "../Imagens/tela_inicial/bulba_2.data"
	.include "../Imagens/tela_inicial/chari_2.data"	
	.include "../Imagens/tela_inicial/bulba_3.data"	
	.include "../Imagens/tela_inicial/chari_3.data"
	.include "../Imagens/tela_inicial/tela_inicial.data"
	
	.include "procedimentos_auxiliares.s"
	
	
