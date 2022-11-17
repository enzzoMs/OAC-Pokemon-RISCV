.text

# ====================================================================================================== # 
# 						TELA INICIAL				                 #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# C�digo respons�vel por renderizar a tela inicial do jogo, incluindo pequenas anima��es.                # 
#													 #
# ====================================================================================================== #


INICIALIZAR_TELA_INICIAL:

	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, 0(sp)		# empilha ra

	call RENDERIZAR_ANIMACAO_FAIXA
	
	# Espera alguns milisegundos	
		li a7, 32			# selecionando syscall sleep
		li a0, 500			# sleep por 500 ms
		ecall
	
	call RENDERIZAR_ANIMACAO_POKEMONS
	
	call MOSTRAR_TELA_INICIAL
	
	call MOSTRAR_TELA_CONTROLES

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
	
	# Mostrando o frame 1		
		li t0, 0xFF200604		# t0 = endere�o para escolher frames 
		li t1, 1
		sb t1, (t0)			# armazena 0 no endere�o de t0
		
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

		mv t4, a0			# salva o retorno do procedimento chamado acima em t4

	# Calcula o endere�o do come�o da imagem do charizard
		li a1, 0xFF100000		# seleciona como argumento o frame 1
		li a2, 206 			# coluna = 206
		li a3, 99			# linha = 99
		call CALCULAR_ENDERECO

		mv t5, a0			# salva o retorno do procedimento chamado acima em t5


	# O loop abaixo tem como base os arquivos bulbasaur_tela_inicial.data e charizard_tela_inicial.data, 
	# verificando os .bmp correspondentes � poss�vel perceber que as imagens foram colocadas de maneira 
	# sequencial, nesse sentido, fica convencionado que o registrador t5 = endere�o base das imagens do 
	# bulbasaur e t6 = endere�o base das imagens do charizard, de forma que quando uma imagem 
	# termina de ser renderizada os registradores j� v�o apontar automaticamente para o endere�o da 
	# pr�xima imagem.

	la a4, bulbasaur_tela_inicial	# carrega o endere�o da imagem
	addi a4, a4, 8			# pula para onde come�a os pixels
	 
	la a5, charizard_tela_inicial	# carrega o endere�o da imagem
	addi a5, a5, 8			# pula para onde come�a os pixels
	
	li t6, 4			# numero de loops
	
	LOOP_ANIMACAO_POKEMONS:
		
		# Imprimindo a imagem do bulbasaur
			mv a0, a4		# a0 = endere�o da imagem
			mv a1, t4		# a1 = endere�o de onde a imagem deve ser renderizada
			li a2, 110 		# a2 = numero de colunas
			li a3, 85		# a3 = numero de linhas
			call PRINT_IMG
		
		mv a4, a0		# atualiza o endere�o da imagem do bulbasur
		
		# Imprimindo a imagem do charizard
			mv a0, a5		# a0 = endere�o da imagem
			mv a1, t5		# a1 = endere�o de onde a imagem deve ser renderizada
			li a2, 111 		# a2 = numero de colunas
			li a3, 100		# a3 = numero de linhas
			call PRINT_IMG
			
		mv a5, a0		# atualiza o endere�o da imagem do charizard	
		
		# Espera alguns milisegundos	
			li a7, 32		# selecionando syscall sleep
			li a0, 1000		# sleep por 1 s
			ecall
			
		addi t6, t6, -1				# decrementa a6
		
		bne t6, zero, LOOP_ANIMACAO_POKEMONS	# se t0 != 0 recome�a o loop
			

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
				
	ret

# ====================================================================================================== #

MOSTRAR_TELA_INICIAL:

	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Imprimindo a tela inicial no frame 1
		la a0, tela_inicial		# carregando a imagem da tela inicial
		li a1, 0xFF100000		# selecionando como argumento o frame 1
		call PRINT_TELA

	# Imprimindo a tela inicial no frame 0
		la a0, tela_inicial		# carregando a imagem da tela inicial
		li a1, 0xFF000000		# selecionando como argumento o frame 0
		call PRINT_TELA
	
	# Para o frame 0 a tela inicial n�o ter� o texto "Aperte Enter", para isso � necess�rio substituir o
	# texto por um retangulo preto:
	
	# Calcula o endere�o do texto "Aperte Enter"
		li a1, 0xFF000000		# seleciona como argumento o frame 0
		li a2, 127 			# coluna = 127
		li a3, 185			# linha = 185
		call CALCULAR_ENDERECO
	
	li t0, 63		# t0 = largura do texto / numero de colunas = 63
	li t1, 19		# t1 = altura do texto / numero de linhas = 19
	
	li t2, 0		# contador para o numero de linhas ja impressas
	
	# O loop abaixo substitui o texto por um retangulo preto
	
	REMOVE_TEXTO_LINHAS:
		li t3, 0		# contador para o numero de colunas ja impressas
		addi t4, a0, 0		# copia do endere�o de a0 para usar no loop de colunas
			
		REMOVE_TEXTO_COLUNAS:
			sb zero, 0(t4)				# bota um pixel preto no bitmap
	
			addi t3, t3, 1				# incrementando o numero de colunas impressas
			addi t4, t4, 1				# vai para o pr�ximo pixel do bitmap
			bne t3, t0, REMOVE_TEXTO_COLUNAS	# reinicia o loop se t3 != t0
			
		addi t2, t2, 1				# incrementando o numero de linhas impressas
		addi a0, a0, 320			# passa o endere�o do bitmap para a proxima linha
		bne t2, t1, REMOVE_TEXTO_LINHAS	        # reinicia o loop se t2 != t1
	
	# O loop abaixo alterna constantemente entre o frame 0 e o 1 enquanto espera que o 
	# usuario aperte ENTER
	
	LOOP_FRAME_TELA_INICIAL:
		# Espera alguns milisegundos	
		li a7, 32			# selecionando syscall sleep
		li a0, 450			# sleep por 450 ms
		ecall
		
		call TROCAR_FRAME
		
		call VERIFICAR_TECLA			# verifica se alguma tecla foi apertada	
		li t0, 10				# t0 = valor da tecla enter
		bne a0, t0, LOOP_FRAME_TELA_INICIAL	# se a0 = t0 -> tecla Enter foi apertada
	
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret

# ====================================================================================================== #

MOSTRAR_TELA_CONTROLES:

	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Mostrando o frame 0		
	li t0, 0xFF200604		# t0 = endere�o para escolher frames 
	sb zero, (t0)			# armazena 0 no endere�o de t0

	# Imprimindo a tela de controles no frame 1
	la a0, tela_controles		# carregando a imagem em a0
	li a1, 0xFF100000		# selecionando como argumento o frame 1
	call PRINT_TELA
	
	# Na tela de controles tem uma pequena anima��o de uma seta vermelha oscilando na tela,
	# para isso a tela_controles tamb�m ser� impressa no frame 0
	
	# Imprimindo a tela de controles no frame 0
	la a0, tela_controles		# carregando a imagem em a0
	li a1, 0xFF000000		# selecionando como argumento o frame 0
	call PRINT_TELA
	
	# Por�m, no frame 0 essa seta dever� estar um pouco mais para cima:
	
	# Calcula o endere�o do inicio da seta
	li a1, 0xFF000000		# seleciona como argumento o frame 0
	li a2, 0 			# coluna = 0
	li a3, 220			# linha = 220
	call CALCULAR_ENDERECO
	# como retorno a0 = endere�o da imagem da seta
	
	mv a1, a0		# a1 = endere�o de onde a seta deve ser renderizada
	addi a1, a1, -640	# sobe esse endere�o 2 linhas para cima (320 * 2)
	li a2, 320		# largura da seta / numero de colunas = 320
	li a3, 15		# altura da seta / numero de linhas = 15
	
	call PRINT_IMG
	
	# O loop abaixo alterna constantemente entre o frame 0 e o 1 enquanto espera que o 
	# usuario aperte ENTER
		
	LOOP_TELA_CONTROLES:
		# Espera alguns milisegundos	
			li a7, 32			# selecionando syscall sleep
			li a0, 450			# sleep por 450 ms
			ecall
		
		call TROCAR_FRAME
		
		call VERIFICAR_TECLA			# verifica se alguma tecla foi apertada	
		li t0, 10				# t0 = valor da tecla enter
		bne a0, t0, LOOP_TELA_CONTROLES		# se a0 = t0 -> tecla Enter foi apertada
	
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret

# ====================================================================================================== #

.data
	.include "../Imagens/tela_inicial/pre_animacao_inicial.data"
	.include "../Imagens/tela_inicial/animacao_faixa.data"
	.include "../Imagens/tela_inicial/bulbasaur_tela_inicial.data"
	.include "../Imagens/tela_inicial/charizard_tela_inicial.data"	
	.include "../Imagens/tela_inicial/tela_inicial.data"
	.include "../Imagens/tela_inicial/tela_controles.data"
	
	