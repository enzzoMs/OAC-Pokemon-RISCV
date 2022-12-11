.text

# ====================================================================================================== # 
# 					PROCEDIMENTOS AUXILIARES				         #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# Este arquivo cont�m uma cole��o de procedimentos auxiliares com o objetivo de facilitar a execu��o de  # 
# certas tarefas ao longo da execu��o do programa.							 #
#													 #
# ====================================================================================================== #

PRINT_TELA:
	# Procedimento que imprime uma imagem de 320 x 240 no frame de escolha
	# Argumentos: 
	# 	a0 = endere�o da imgagem		
	# 	a1 = endere�o do frame
	
	li t0, 76800		# area total da imagem -> 320 x 240 = 76800 pixels
	addi a0, a0, 8		# pula para onde come�a os pixels no .data
	li t1, 0		# contador de quantos pixels j� foram impressos

	LOOP_PRINT_IMG: 
		beq t0, t1, FIM_PRINT_IMG	# verifica se todos os pixels foram colocados
		lw t3, 0(a0)			# pega 4 pixels do .data e coloca em t3
		sw t3, 0(a1)			# pega os pixels de t3 e coloca no bitmap
		addi a0, a0, 4			# vai para os pr�ximos pixels da imagem
		addi a1, a1, 4			# vai para os pr�ximos pixels do bitmap
		addi t1, t1, 4			# incrementa contador com os pixels colocados
		j LOOP_PRINT_IMG		# reinicia o loop

	FIM_PRINT_IMG:
		ret 

# ====================================================================================================== #

PRINT_IMG:
	# Procedimento que imprime imagens de tamanho variado, menores que 320 x 240, no frame de escolha
	# Argumentos: 
	# 	a0 = endere�o da imgagem		
	# 	a1 = endere�o de onde, no frame escolhido, a imagem deve ser renderizada
	# 	a2 = numero de colunas da imagem
	#	a3 = numero de linhas da imagem
	
	li t0, 0		# contador para o numero de linhas ja impressas
	
	PRINT_IMG_LINHAS:
		li t1, 0		# contador para o numero de colunas ja impressas
			
		PRINT_IMG_COLUNAS:
			lb t2, 0(a0)			# pega 1 pixel do .data e coloca em t3
			sb t2, 0(a1)			# pega o pixel de t3 e coloca no bitmap
	
			addi t1, t1, 1			# incrementando o numero de colunas impressas
			addi a0, a0, 1			# vai para o pr�ximo pixel da imagem
			addi a1, a1, 1			# vai para o pr�ximo pixel do bitmap
			bne t1, a2, PRINT_IMG_COLUNAS	# reinicia o loop se t1 != t2
			
		addi t0, t0, 1			# incrementando o numero de linhas impressas
		sub a1, a1, a2			# volta o ende�o do bitmap pelo numero de colunas impressas
		addi a1, a1, 320		# passa o endere�o do bitmap para a proxima linha
		bne t0, a3, PRINT_IMG_LINHAS	# reinicia o loop se t0 != a3
			
	ret

# ====================================================================================================== #

PRINT_SPRITE:
	# Esse procedimento funciona de maneira similar ao PRINT_IMG, a diferen�a � que possui algumas 
	# altera��es espec�ficas para a renderiza��o dos sprites de personagens na tela.
	# Para entender esse procedimento � ncess�rio perceber que alguns sprites, como os do RED que podem
	# ser encontrados em "../Imagens/red", possuem um fundo rosa, com base nisso, o que esse procedimento
	# faz � imprimir um sprite na tela, por�m ao inv�s de imprimir esses pixels rosas ele imprime os 
	# pixels correspondentes de uma �rea, ou seja, podemos pensar que esse procedimento imprime um
	# sprite emulando uma esp�cie de transpar�ncia.
	# Essa obordagem foi utilizada porque usar somente pixels com a cor transparente (0xC7) 
	# n�o estava funcionando t�o bem assim nas anima��es de movimenta��o. O uso desse procedimento
	# elimina a maior parte (mas n�o toda) da necessidade de fazer algum tipo de "limpeza" na tela para 
	# remover os sprites antigos, resolvendo grande parte desses problemas. 
	# Esse procedimento � usado nas anima��es de movimenta��o, para simplesmente imprimir o sprite de
	# um personagem / objeto na tela sem se preocupar em limpar a tela depois pode ser usado tamb�m
	# o procedimento PRINT_IMG
	# O procedimento parte do pressuposto que todos os sprites de personagens tem o mesmo tamanho: 
	# 26 (colunas) x 32 (linhas)
	# Argumentos: 
	# 	a0 = endere�o base da imagem do sprite		
	# 	a1 = endere�o de onde, no frame escolhido, o sprite deve ser renderizado
	#	a2 = endere�o base da �rea onde o sprite ser� renderizado
	#	a3 = n�mero de colunas do sprite
	#	a4 = n�mero de linhas do sprite	
	
	
	addi a2, a2, 8		# pula para onde come�a os pixels no .data da imagem da �rea
	
	li t0, 0xFF000000	# t0 = endere�o base do frame 0
	sub t0, a1, t0		# a1 (endere�o de onde renderizar o sprite) - t0 (endere�o base do frame 0) = 
				# quantos pixels � necess�rio pular na imagem da �rea (a2) para encontrar 
				# onde a sub imagem que ser� usada no procedimento 

	add a2, a2, t0		# pula para o endere�o da sub imagem da �rea que ser� usada no procedimento 
	
	li t0, 0xC7		# t1 = valor da cor do pixel transparente
		
	addi a0, a0, 8		# pula para onde come�a os pixels no .data do sprite
	
	PRINT_SPRITE_LINHAS:
		mv t1, a3		# t1 = copia de a3 para usar no loop de colunas
			
		PRINT_SPRITE_COLUNAS:
			lbu t2, 0(a0)			# pega 1 pixel do .data e coloca em t2
	
			# se o pixel em t2 for o transparente ent�o ele vai ser substituido pelo
			# pixel correspondente na imagem da �rea passada no argumento a2
			bne t2, t0, ARMAZENAR_PIXEL_SPRITE		
				lb t2, 0(a2)	# pega 1 pixel do .data da imagem da �rea e coloca em t2
	
			ARMAZENAR_PIXEL_SPRITE:
			sb t2, 0(a1)		# pega 1 pixel do .data escolhido e coloca no bitmap
			
			addi t1, t1, -1				# decrementando o numero de colunas impressas
			addi a0, a0, 1				# vai para o pr�ximo pixel da imagem do sprite
			addi a2, a2, 1				# vai para o pr�ximo pixel da imagem da �rea
			addi a1, a1, 1				# vai para o pr�ximo pixel do bitmap
			bne t1, zero, PRINT_SPRITE_COLUNAS	# reinicia o loop se t1 != 0
			
		addi a4, a4, -1			# decrementando o numero de linhas impressas
		sub a1, a1, a3			# volta o endere�o do bitmap pelo n�mero de colunas impressas
		addi a1, a1, 320		# passa o endere�o do bitmap para a proxima linha
		sub a2, a2, a3			# volta o endere�o da �rea pelo n�mero de colunas impressas
		addi a2, a2, 320		# passa o endere�o da �rea para a proxima linha
		bne a4, zero, PRINT_SPRITE_LINHAS	# reinicia o loop se t0 != 0
			
	ret
			
# ====================================================================================================== #
																	
CALCULAR_ENDERECO:
	# Procedimento que calcula um endere�o no frame de escolha ou em uma imagem
	# Argumentos: 
	#	a1 = endere�o do frame ou imagem
	# 	a2 = numero da coluna
	# 	a3 = numero da linha
	# a0 = retorno com o endere�o
	
	li t0, 320			# t0 = 320
	
	mul t1, a3, t0			# linha x 320	
	add a0, a1, t1			# ender�o base + (linha x 320)
	add a0, a0, a2			# a0 = ender�o base + (linha x 320) + coluna
	
	ret 

# ====================================================================================================== #

TROCAR_FRAME:
	# Procedimento que troca o frame que est� sendo mostrado de 0 -> 1 e de 1 -> 0
	
	li t0, 0xFF200604		# t0 = endere�o para escolher frames 
	lb t1, (t0)			# t1 = valor armazenado em t0
	xori t1, t1, 1			# inverte o valor de t1
	sb t1, (t0)			# armazena t1 no endere�o de t0

	ret

# ====================================================================================================== #

VERIFICAR_TECLA:
	# Procedimento que verifica se alguma tecla foi apertada
	# Retorna a0 com o valor da tecla ou a0 = -1 caso nenhuma tecla tenha sido apertada		
	
	li a0, -1 		# a0 = -1
	 
	li t0, 0xFF200000	# carrega em t0 o endere�o de controle do KDMMIO
 	lw t1, 0(t0)		# carrega em t1 o valor do endere�o de t0
   	andi t1, t1, 0x0001	# t1 = 0 = n�o tem tecla, t1 = 1 = tem tecla. 
   				# realiza opera��o andi de forma a deixar em t0 somente o bit necessario para an�lise
   	
    	beq t1, zero, FIM_VERIFICAR_TECLA	# t1 = 0 = n�o tem tecla pressionada ent�o vai para fim
   	lw a0, 4(t0)				# le o valor da tecla no endere�o 0xFF200004
   		 	
	FIM_VERIFICAR_TECLA:					
		ret
		
# ====================================================================================================== #
	
PRINT_DIALOGOS:
	# Procedimento que imprime uma quantidade variavel de caixas de dialogo em ambos os frames
	# Os dialogos s�o sempre renderizados em uma �rea fixa da tela
	# O n�mero de dialogos � determinado pelo argumento a5.
	# Caso seja mais de 1 dialogo, para o procedimento funcionar corretamente � necess�rio que 
	# as imagens estejam em um mesmo arquivo (ver intro_dialogos.bmp para um exemplo)
	
	# Argumentos: 
	# 	a5 = endere�o da imagem dos dialogos		
	# 	a6 = n�mero de caixas de dial�gos a serem renderizadas		

	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra
				
	# Calcula o endere�o de onde o dialogo vai ser renderizado no frame 0		
		li a1, 0xFF000000		# seleciona como argumento o frame 0
		li a2, 6 			# coluna = 6
		li a3, 172			# linha = 172
		call CALCULAR_ENDERECO
	
	mv t4, a0	# salva o endere�o retornado em t4

	# Calcula o endere�o de onde o dialogo vai ser renderizado no frame 1		
		li a1, 0xFF100000		# seleciona como argumento o frame 1
		# os valores de a2 (coluna) e a3 (linha) continuam os mesmos 
		call CALCULAR_ENDERECO
		
	mv t5, a0	# salva o endere�o retornado em t5
		
	# O loop abaixo � respons�vel por renderizar uma caixa de di�logo em ambos os frames.
	# Essas caixas s�o sempre mostradas em uma �rea fixa.  
	# Esse loop tem como base o arquivo intro_dialogos.data, verificando o .bmp correspondente 
	# � poss�vel perceber que as imagens foram colocadas de maneira sequencial, nesse sentido, 
	# fica convencionado que o registrador a5 = endere�o base da imagem de forma que quando um di�logo 
	# termina de ser renderizado a6 j� vai apontar automaticamente para o endere�o da pr�xima caixa 
	# de di�logo.
	 						
	LOOP_PROXIMO_DIALOGO:
	li a2, 308	# numero de colunas de uma caixa de dialogo
	li a3, 64	# numero de linhas de uma caixa de dialogo
		
		mv a0, a5		# move para a0 o endere�o da imagem
		mv a1, t4		# move para a1 o endere�o de onde o dialogo ser� renderizado (frame 0)
		call PRINT_IMG
	
		mv a0, a5		# move para a0 o endere�o da imagem
		mv a1, t5		# move para a1 o endere�o de onde o dialogo ser� renderizado (frame 1)
		call PRINT_IMG
	
		mv a5, a0		# atualiza o endere�o da imagem para o pr�ximo dialogo
	
		call PRINT_SETA_DIALOGO
	
		LOOP_FRAMES_DIALOGO:
		# Troca constantemente de frame at� o usu�rio apertar ENTER para carregar o proximo dialogo
		
			# Espera alguns milisegundos	
				li a7, 32			# selecionando syscall sleep
				li a0, 450			# sleep por 450 ms
				ecall
		
			call TROCAR_FRAME
		
			call VERIFICAR_TECLA			# verifica se alguma tecla foi apertada	
			li t0, 10				# t0 = valor da tecla enter
			bne a0, t0, LOOP_FRAMES_DIALOGO		# se a0 = t0 -> tecla Enter foi apertada
	
		addi a6, a6, -1					# decrementa o numero de loops
		
		bne a6, zero, LOOP_PROXIMO_DIALOGO		# se a6 != 0 reinicia o loop


	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret
			
# ====================================================================================================== #

PRINT_SETA_DIALOGO:
	# Procedimento auxiliar a PRINT_DIALOGOS_INTRO
	# Imprime setas nas caixas de dialogos em ambos os frames, sendo que no frame 1 a
	# seta est� levemente para cima	
	# As setas sempre est�o em posi��es fixas na tela

	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Calcula o endere�o de onde a seta vai ser renderizada no frame 0		
		li a1, 0xFF000000		# seleciona como argumento o frame 0
		li a2, 280 			# coluna = 284
		li a3, 216			# linha = 216
		call CALCULAR_ENDERECO
	
	mv t6, a0			# salva o retorno do procedimento chamado acima em t4
	
	# Calcula o endere�o de onde a seta vai ser renderizada no frame 1		
		li t0, 0x00100000	# soma a0 com t0 de forma que o endere�o de a0 passa para o 
		add a1, a0, t0		# endere�o correspondente no frame 1
		addi a1, a1, -640	# sobe o endere�o de a1 em duas linhas
	
	# Imprime a seta no frame 1
		la a0, seta_dialogo	# carrega a imagem
		# a1 tem o endere�o onde a seta ser� renderizada
		lw a2, 0(a0)		# a1 = numero de colunas da imagem
		lw a3, 4(a0)		# a2 = numero de linhas da imagem
		addi a0, a0, 8		# pula para onde come�a os pixels no .data
		call PRINT_IMG

	# Imprime a seta no frame 0
		la a0, seta_dialogo	# carrega a imagem
		mv a1, t6		# a1 tem o endere�o onde a seta ser� renderizada
		# os valores de a2 (coluna) e a3 (linha) continuam os mesmos 
		addi a0, a0, 8		# pula para onde come�a os pixels no .data
		call PRINT_IMG

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret
																											
