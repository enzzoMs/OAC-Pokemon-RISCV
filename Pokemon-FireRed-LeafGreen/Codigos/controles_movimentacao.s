.text

# ====================================================================================================== # 
# 				        CONTROLES E MOVIMENTA��O				         #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# C�digo respons�vel por coordenar os procedimentos de anima��o do personagem de acordo com as teclas	 #
# W, A, S ou D											         # 
#													 #
# Existem duas modalidades de movimenta��o diferente, ou a tela se move ou o RED se move, cada um desses #
# acontece dependendo da matriz de tiles da �rea. Isso acontece porque a �rea aberta do jogo tem um 	 #
# tamanho maior do que pode ser mostrado na tela (320 x 240), ent�o se a �rea ainda tem espa�o para ser  #
# movida quem se move � ela, sen�o o RED que se move							 # 															 
#													 #
# Para a movimenta��o do personagem � utilizado uma matriz para cada �rea do jogo.			 #
# Cada �rea � dividida em quadrados de 16 x 16 pixels, de forma que cada elemento dessas matrizes	 #
# representa um desses quadrados. Durante os procedimentos de movimenta��o a matriz da �rea		 #
# � consultada e dependendo do valor do elemento referente a pr�xima posi��o do personagem � determinado #
# se o jogador pode ou n�o se mover para l�. Por exemplo, elementos da matriz com valor 0 indicam que    #
# o quadrado 16 x 16 correspondente est� ocupado, ent�o o personagem n�o pode ser mover para l�.	 #
# Cada procedimento de movimenta��o, seja para cima, baixo, esquerda ou direita, move a tela/RED por  	 #
# exatamente 16 pixels, ou seja, o personagem passa de uma posi��o da matriz para outra, sendo que o	 #
# registrador s6 vai acompanhar a posi��o do personagem nessa matriz.  					 #
# 													 #
# ====================================================================================================== #

VERIFICAR_TECLA_JOGO:
	# Este procedimento verifica se alguma tecla relacionada a movimenta��o (w, a, s ou d) ou
	# inventario (i) foi apertada e decide a partir do retorno os procedimentos adequados

	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	call VERIFICAR_TECLA
	
	ESCOLHER_PROCEDIMENTO_DE_MOVIMENTACAO:
	
		# Verifica se alguma tecla de movimenta��o (a, w, s ou d) foi apertada, chamando o
		# procedimento adequado
		li t0, 'w'
		beq a0, t0, MOVIMENTACAO_TECLA_W
		li t0, 'a'
		beq a0, t0, MOVIMENTACAO_TECLA_A
		li t0, 's'
		beq a0, t0, MOVIMENTACAO_TECLA_S
		li t0, 'd'
		beq a0, t0, MOVIMENTACAO_TECLA_D
		
		# Verifica se a tecla do inventario (i) foi apertada 	
		li t0, 'i'
		bne a0, t0, FIM_VERIFICAR_TECLA_JOGO
			li a5, 0		# a5 = 0 porque o inventario foi mostrado atrav�s da tecla 'i'
			li a6, 0		# a6 = 0 para mostrar o inventario normalmente			
			call MOSTRAR_INVENTARIO
	
	FIM_VERIFICAR_TECLA_JOGO:	

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
		beq s1, t0, INICIO_MOVIMENTACAO_W
			la a4, red_cima		# carrega como argumento o sprite do RED virada para cima		
			call MUDAR_ORIENTACAO_RED
			
			li s1, 2	# atualiza o valor de s1 dizendo que agora o RED est� virado 
					# para cima
							
	INICIO_MOVIMENTACAO_W:
	# Primeiro � preciso verificar a posi��o acima da atual na matriz de movimenta��o da �rea em rela��o ao
	# personagem (s6). 
	
	sub a0, s6, s7		# verifica a posi��o uma linha acima (s7 tem o tamanho de uma linha na
				# na matriz) da atual a partir de s6
				
	call VERIFICAR_MATRIZ_DE_MOVIMENTACAO
	
	# Como retorno a0 tem comandos para o procedimento de movimenta��o.
	# Se a0 == 0 ent�o a movimenta��o deve ocorrer
	
	bne a0, zero, FIM_MOVIMENTACAO_W
	
	# � necess�rio decidir se o que vai se mover � a tela ou o personagem
	# O personagem se move se a tela n�o permitir movimento. No caso da tecla W isso acontece quando o 
	# endere�o uma linha acima da �rea atual de tiles for -1. 
		
	sub t0, s2, s3	# t0 recebe o endere�o da linha anterior a s2
	
	lb t0, (t0)	# checa se a matriz da �rea permite movimento		
		
	li t1, -1				# se t0 for -1 a tela n�o permite movimento, ent�o o que								
	bne t0, t1, MOVER_TELA_W		# deve se mover � o personagem
	
	
	# Com tudo feito agora � possivel chamar o procedimento de movimenta��o para o personagem
		# Decide se o RED vai ser renderizado dando o passo com o p� esquedo ou direito
		# de acordo com o valor de s8		
		la a5, red_cima_passo_direito
							
		beq s8, zero, MOVER_RED_W		
			la a5, red_cima_passo_esquerdo
						
		MOVER_RED_W:				
		la a4, red_cima	# carrega a imagem do RED parado
		# a5 tem a a imagem do RED dando um passo	
		mv a6, s0		# a anima��o vai come�ar onde o RED est� (s0)
		li a7, 0		# a3 = 0 = anima��o para cima																
		call MOVER_PERSONAGEM																																																															
		
	mv s0, a0		# De acordo com o retorno de MOVER_PERSONAGEM a0 tem o endere�o de s0 
				# atualizado pela movimenta��o feita
	
	sub s5, s5, s3		# atualizando o lugar do personagem na matriz de tiles para a posi��o uma linha
				# acima

	sub s6, s6, s7		# atualiza o valor de s6 para o endere�o uma linha acima da atual na matriz 
				# de movimenta��o 
						
	xori s8, s8, 1		# inverte o valor de s8, ou seja, se o RED deu um passo esquerdo o pr�ximo
				# ser� direito e vice-versa
	
	j FIM_MOVIMENTACAO_W									
		
	# -------------------------------------------------------------------------------------------------																				
	
	MOVER_TELA_W:
	# Caso a tela ainda permita movimento � ela que tem que se mover
	# O movimento da tela tem como base o loop abaixo, que tem 4 partes: 
	#	(1) -> move toda a imagem da �rea que est� na tela em um 1 pixel para baixo
	#	(2) -> limpar o sprite antigo do RED do frame
	#  	(3) -> imprime os sprites de movimenta��o do RED
	#	(4) -> imprime a linha anterior da subsec��o da �rea 1 pixel para baixo
	# Com esses passos � poss�vel passar a sensa��o de que a tela est� se movendo para baixo e revelando
	# uma nova parte da �rea
	
	li t5, 1		# contador para o n�mero de loops realizados
	li t6, 0x00100000	# t6 ser� usado para fazer a troca entre frames no loop abaixo	
	
	LOOP_MOVER_TELA_W:
				
		# Parte (1) -> move toda a imagem da �rea que est� na tela em um 1 pixel para baixo
		# Para fazer isso � poss�vel simplesmente trocar os pixels de uma linha do frame com os pixels
		# da proxima linha atrav�s do loop abaixo
		
		li t0, 240		# n�mero de linhas de um frame, ou seja, a quantidade de loops abaixo
		sub t0, t0, t5		# o n�mero de loops � controlado pelo n�mero da itera��o atual (t5)
		addi t0, t0, 1		# adiciona + 1 porque t5 come�a no 1 e n�o no 0

		li t1, 0xFF012980	# endere�o da penultima linha da 1a coluna do frame 0
				
		add t1, t1, t6		# decide a partir do valor de t6 qual o frame onde a imagem
					# ser� impressa	
								
		MOVER_TELA_W_LOOP_LINHAS:
			li t2, 320		# n�mero de colunas de um frame
			
		MOVER_TELA_W_LOOP_COLUNAS:		
			lw t3, 0(t1)		# pega 4 pixels do bitmap e coloca em t3
		
			# Na 1a itera��o os pixels ser�o armazenados proxima linha (320), mas nas 
			# itera��es seguintes ser�o armazenados 2 linhas para frente (640)
			
			li t4, 1
			beq t5, t4, MOVER_TELA_W_PRIMEIRA_ITERACAO
				sw t3, 640(t1)	# armazena os 4 pixels de t5 na 2 linhas para frente (640) do 
						# endere�o apontado por t1
				j MOVER_TELA_W_PROXIMA_ITERACAO	
				
			MOVER_TELA_W_PRIMEIRA_ITERACAO:	
			
			sw t3, 320(t1)		# armazena os 4 pixels de t5 na proxima linha (320) do endere�o
						# apontado por t1
						
			MOVER_TELA_W_PROXIMA_ITERACAO:			
			addi t1, t1, 4		# passa o endere�o do bitmap para os pr�ximos pixels
			addi t2, t2, -4		# decrementa o n�mero de colunas restantes
			bne t2, zero, MOVER_TELA_W_LOOP_COLUNAS		# reinicia o loop se t2 != 0    
		
		addi t1, t1, -640		# volta o endere�o de t1 duas linhas para tr�s	
		addi t0, t0, -1			# decrementa o n�mero de linhas restantes
		bne t0, zero, MOVER_TELA_W_LOOP_LINHAS	# reinicia o loop se t0 != 0 
		
		# Parte (2) -> limpar o sprite antigo do RED do frame
		# Para limpar os sprites antigos � poss�vel usar o PRINT_TILES_AREA imprimindo 1 coluna
		# 3 linhas (2 tiles do RED + 1 tile de folga)
		
		mv a0, s5	# endere�o, na matriz de tiles, de onde come�am os tiles a ser impressos,
				# nesse caso, o come�o � o tile onde o RED est�
		mv a1, s0	# a imagem ser� impressa onde o RED est� (s0)
		
		li t0, 4161	# o endere�o do RED na verdade est� um pouco abaixo do inicio do tile,
		sub a1, a1, t0	# portanto � necess�rio voltar o endere�o de a1 em 4164 pixels (13 linhas * 
				# 320 + 1 coluna)
		
		li t0, 320	# o endere�o de onde os tiles v�o ser impressos tamb�m muda de acordo com a
		mul t0, t0, t5	# itera��o, j� que o pixels da tela ser�o trocados para fazer a imagem "descer"
		add a1, a1, t0	# portanto, 320 * t5 retorna quantos pixels � necess�rio avan�ar para encontrar
				# a linha certa onde devem ser impressos os tiles nessa itera��o
		
		add a1, a1, t6		# decide a partir do valor de t6 qual o frame onde os tiles
					# ser� impressa	
					
		li a2, 1		# n�mero de colunas de tiles a serem impressas
		li a3, 3		# n�mero de linhas de tiles a serem impressas
		call PRINT_TILES_AREA
		
		# Parte (3) -> imprime o sprite do RED
		# O pr�ximo sprite do RED vai ser decidido de acordo com o n�mero da intera��o (t3)
		# de modo que a anima��o siga o seguinte padr�o:
		# RED PARADO -> RED DANDO UM PASSO -> RED PARADO
		
		# a0 vai receber o endere�o da pr�xima imagem do RED dependendo do n�mero da itera��o (t5)	
		la a0, red_cima
		li t0, 14
		bgt t5, t0, PRINT_RED_MOVER_TELA_W
		
		# Se 2 < t5 <= 14 a imagem a ser impressa � a do RED dando um passo, que � decidida a 
		# partir do valor de s8
		la a0, red_cima_passo_direito
							
		beq s8, zero, PROXIMO_RED_MOVER_TELA_W		
			la a0, red_cima_passo_esquerdo
	
		PROXIMO_RED_MOVER_TELA_W:
		
		li t0, 2
		bgt t5, t0, PRINT_RED_MOVER_TELA_W
		la a0, red_cima
		
		PRINT_RED_MOVER_TELA_W:					
		# Agora imprime a imagem do RED no frame
			# a0 tem o endere�o da pr�xima imagem do RED 			
			mv a1, s0		# s0 possui o endere�o do RED no frame 0
			add a1, a1, t6		# decide a partir do valor de t6 qual o frame onde a imagem
						# ser� impressa		
			lw a2, 0(a0)		# numero de colunas de uma imagem do RED
			lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
			addi a0, a0, 8		# pula para onde come�a os pixels no .data	
			call PRINT_IMG	
		
		# Se o RED estiver indo para um tile de grama � preciso imprimir uma pequena anima��o
		# de folhas subindo enquanto ele estiver indo para o tile		
		beq s10, zero, MOVER_TELA_W_PARTE_4
			
			la t0, tiles_grama_animacao	
			addi t0, t0, 8			# pula para onde come�a os pixels no .data
			
			# t2 vai receber a quantidade de pixels que ser� pulada em tiles_grama_animacao para
			# encontrar a imagem certa para imprimir de acordo com a itera��o atual (t5)
			li t2, 0		
			li t1, 11			
			bge t5, t1, MOVER_TELA_W_PRINT_GRAMA
			li t2, 256
			li t1, 6			
			bge t5, t1, MOVER_TELA_W_PRINT_GRAMA	
			li t2, 512
			li t1, 2
			bge t5, t1, MOVER_TELA_W_PRINT_GRAMA
			li t2, 0
									
			MOVER_TELA_W_PRINT_GRAMA:
			add a0, t0, t2		# a0 recebe o endere�o da imagem da grama a ser impressa
			mv a1, s0		# O endere�o onde esse tile ser� impresos onde o RED est�
			addi a1, a1, 959	# (s0), 3 linhas para baixo e uma coluna para a esquerda	
						# (959 = 320 * 3 - 1)
			add a1, a1, t6		# decide a partir do valor de t5 qual o frame onde a imagem
						# ser� impressa	
			li t0, 320		# a linha do endere�o tamb�m ser� decidia pelo numero
			mul t0, t0, t5		# da itera��o atual (t5), no caso da MOVER_TELA_W o endere�o
			add a1, a1, t0		# ser� atualizado algumas linhas para baixo
			
			li a2, 16		# numero de colunas do tile
			li a3, 16		# numero de linhas do tile
			call PRINT_IMG				
		
		MOVER_TELA_W_PARTE_4:
		
		# Parte (4) -> imprime a linha anterior da subsec��o da �rea 1 pixel para baixo
		# O que tem que ser feito � imprimir os tiles dessa linha de modo que s� v�o ser impressas uma 
		# parte da imagem de cada tile de forma a dar a impress�o de que a linha desceu 1 pixel e que
		# uma nova parte da �rea est� sendo lentamente revelada
						
		li t3, 0		# contador para o n�mero de tiles impressos
		li t4, 0xFF000000	# t4 vai guardar o endere�o de onde os tiles v�o ser impressos, sendo
					# que ele � incrementado a cada loop abaixo. Esse endere�o aponta
					# para o come�o do frame 0
		add t4, t4, t6		# decide a partir do valor de t6 qual o frame onde a imagem
					# ser� impressa		
							
		LOOP_PRINT_PROXIMA_AREA_W:
		
		# Encontrando a imagem do tile	
		sub t0, s2, s3	# basta fazer s2 - s3 para encontrar o endere�o de in�cio da linha 
				# anterior da subsec��o de tiles que est� na tela
			
		add t0, t0, t3	# decide qual o tile a ser impresso de acordo com t3 (n�mero da itera��o atual)
		
		lb t0, 0(t0)	# pega o valor do elemento da matriz de tiles apontado por t0
		
		li t1, 256	# t1 recebe 16 * 16 = 256, ou seja, a �rea de um tile							
		mul t0, t0, t1	# t0 (n�mero do tile) * (16 * 16) retorna quantos pixels esse tile est� do 
				# come�o da imagem dos tiles
		
		addi t0, t0, 256	# adiciona mais 256 em t0 porque na verdade as imagens s�o impressas
					# de baixo para cima nesse caso	
						
		li t1, 16		# 16 � o tamanho de uma linha de um tile
		mul t1, t1, t5		# 16 * t5 retorna quantos pixels � necess�rio voltar para encontrar
		sub t0, t0, t1		# o endere�o da linha certa do tile a ser impresso nessa itera��o
									
		# Imprimindo a imagem do tile		
		add a0, s4, t0	# a0 recebe o endere�o do tile a ser impresso a partir de s4 (imagem dos tiles)
		mv a1, t4	# a1 recebe o endere�o de onde imprimir o tile
		li a2, 16	# a2 = numero de colunas de um tile
		mv a3, t5	# a3 tem o n�mero de linhas a serem impressas = o valor de t5 (itera��o atual)
		call PRINT_IMG
	
		addi t4, t4, 16		# incrementando o endere�o onde os tiles v�o ser impressos em 16 pixels
					# porque o tile que acabou de ser impresso tem 16 colunas
		addi t3, t3, 1		# incrementando o n�mero de tiles impressos
		
		li t0, 20
		bne t3, t0, LOOP_PRINT_PROXIMA_AREA_W	# reinicia o loop se t3 != 20
		
	
		# Espera alguns milisegundos	
		mv a0, s9			# sleep por s9 ms de acordo com o definido em Pokemon.s
		call SLEEP			# chama o procedimento SLEEP	
		
		call TROCAR_FRAME	# inverte o frame sendo mostrado		
				
		li t0, 0x00100000	# fazendo essa opera��o xor se t4 for 0 ele recebe 0x0010000
		xor t6, t6, t0		# e se for 0x0010000 ele recebe 0, ou seja, com isso � poss�vel
					# trocar entre esses valores
		
		addi t5, t5, 1		# incrementa o n�mero de loops realizados						
		li t0, 16
		bne t5, t0, LOOP_MOVER_TELA_W	# reinicia o loop se t3 != 16
	
																																																																																																															
	sub s2, s2, s3		# atualizando a subsec��o da �rea para a linha anterior da atual (s2) 
	
	# Pela maneira que o loop acima � executado na verdade s� s�o feitas 15 itera��es e n�o 16, 
	# portanto, � necess�rio imprimir novamente as imagem da �rea em ambos os frames + o sprite do RED 
	# no frame 0 e 1 para que tudo fique no lugar certo
		
		# Imprimindo a imagem da �rea no frame 0
		mv a0, s2		# endere�o, na matriz de tiles, de onde come�a a imagem a ser impressa
		li a1, 0xFF000000	# a imagem ser� impressa no frame 0
		li a2, 20		# n�mero de colunas de tiles a serem impressas
		li a3, 15		# n�mero de linhas de tiles a serem impressas
		call PRINT_TILES_AREA	

		# Imprimindo o sprite do RED no frame 0
		la a0, red_cima		# carrega a imagem do sprite			
		mv a1, s0		# s0 tem a posi��o do RED no frame 0
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		call PRINT_IMG	

	call TROCAR_FRAME	# inverte o frame sendo mostrado
				# � necess�rio inverter o frame mais 1 vez para que o frame sendo mostrado
				# seja o 0		
					
		# Imprimindo a imagem da �rea no frame 1
		mv a0, s2		# endere�o, na matriz de tiles, de onde come�a a imagem a ser impressa
		li a1, 0xFF100000	# a imagem ser� impressa no frame 0
		li a2, 20		# n�mero de colunas de tiles a serem impressas
		li a3, 15		# n�mero de linhas de tiles a serem impressas
		call PRINT_TILES_AREA	
				
		# Imprimindo o sprite do RED no frame 1
		la a0, red_cima		# carrega a imagem do sprite			
		mv a1, s0		# s0 tem a posi��o do RED no frame 0
		li t0, 0x00100000
		add a1, a1, t0		# passa o endere�o de a1 para o frame 1
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		call PRINT_IMG	
						
	sub s5, s5, s3		# atualizando o lugar do personagem na matriz de tiles para a posi��o uma linha
				# acima

	sub s6, s6, s7		# atualiza o valor de s6 para o endere�o uma linha acima da atual na matriz 
				# de movimenta��o 
						
	xori s8, s8, 1		# inverte o valor de s8, ou seja, se o RED deu um passo esquerdo o pr�ximo
				# ser� direito e vice-versa
																								
	FIM_MOVIMENTACAO_W:

	call PRINT_FAIXA_DE_GRAMA	# imprime a faixa de grama sobre o RED caso seja necess�rio 
	 
	call VERIFICAR_COMBATE		# verifica se o tile para onde o RED se moveu � um tile de grama e
					# se ele vai iniciar um combate
																																
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret	

# ====================================================================================================== #

MOVIMENTACAO_TECLA_A:
	# Procedimento que coordena a movimenta��o do personagem para a esquerda
	
	# OBS: n�o � necess�rio empilhar o valor de ra pois a chegada a este procedimento � por meio
	# de uma instru��o de branch
	
	# Primeiro verifica se o personagem est� virado para a esquerda
		beq s1, zero, INICIO_MOVIMENTACAO_A
			la a4, red_esquerda	# carrega como argumento o sprite do RED virada para a esquerda		
			call MUDAR_ORIENTACAO_RED
			
			li s1, 0	# atualiza o valor de s0 dizendo que agora o RED est� virado 
					# para a esquerda
							
	INICIO_MOVIMENTACAO_A:
	# Primeiro � preciso verificar a proxima posi��o anterior na matriz de movimenta��o da �rea em rela��o ao
	# personagem (s6). 
	
	addi a0, s6, -1		# verifica a posi��o anterior na matriz a partir de s6
	call VERIFICAR_MATRIZ_DE_MOVIMENTACAO
	
	# Como retorno a0 tem comandos para o procedimento de movimenta��o.
	# Se a0 == 0 ent�o a movimenta��o deve ocorrer
	
	bne a0, zero, FIM_MOVIMENTACAO_A
	
	# � necess�rio decidir se o que vai se mover � a tela ou o personagem
	# O personagem se move se a tela n�o permitir movimento. No caso da tecla A isso acontece quando o 
	# endere�o anterior de s2 (subsec��� de tiles atual) for -1	
	
	lb t0, -1(s2)		# checa se a matriz da �rea permite movimento		
		
	li t1, -1				# se t0 for -1 a tela n�o permite movimento, ent�o o que								
	bne t0, t1, MOVER_TELA_A		# deve se mover � o personagem
						
	# Com tudo feito agora � possivel chamar o procedimento de movimenta��o para o personagem
		# Decide se o RED vai ser renderizado dando o passo com o p� esquedo ou direito
		# de acordo com o valor de s8		
		la a5, red_esquerda_passo_direito
							
		beq s8, zero, MOVER_RED_A		
			la a5, red_esquerda_passo_esquerdo
						
		MOVER_RED_A:				
		la a4, red_esquerda	# carrega a imagem do RED parado
		# a5 tem a a imagem do RED dando um passo	
		mv a6, s0		# a anima��o vai come�ar onde o RED est� (s0)
		li a7, 1		# a3 = 1 = anima��o para a esquerda																
		call MOVER_PERSONAGEM																																																															
		
	mv s0, a0		# De acordo com o retorno de MOVER_PERSONAGEM a0 tem o endere�o de s0 
				# atualizado pela movimenta��o feita
	
	addi s5, s5, -1		# atualizando o lugar do personagem na matriz de tiles para a posi��o anterior

	addi s6, s6, -1		# atualiza o valor de s6 para o endere�o anterior da matriz de movimenta��o 
						
	xori s8, s8, 1		# inverte o valor de s8, ou seja, se o RED deu um passo esquerdo o pr�ximo
				# ser� direito e vice-versa
	
	j FIM_MOVIMENTACAO_A									
		
	# -------------------------------------------------------------------------------------------------																				
	
	MOVER_TELA_A:
	# Caso a tela ainda permita movimento � ela que tem que se mover
	# O movimento da tela tem como base o loop abaixo, que tem 4 partes: 
	#	(1) -> move toda a imagem da �rea que est� na tela em um 1 pixel para a direita
	#	(2) -> limpar o sprite antigo do RED do frame
	#  	(3) -> imprime os sprites de movimenta��o do RED
	#	(4) -> imprime a coluna anterior da subsec��o da �rea 1 pixel para a direita
	# Com esses passos � poss�vel passar a sensa��o de que a tela est� se movendo para a direita e revelando
	# uma nova parte da �rea
	
	li t5, 1		# contador para o n�mero de loops realizados
	li t6, 0x00100000	# t6 ser� usado para fazer a troca entre frames no loop abaixo	
	
	LOOP_MOVER_TELA_A:
				
		# Parte (1) -> move toda a imagem da �rea que est� na tela em um 1 pixel para a direita
		# Para fazer isso � poss�vel simplesmente trocar os pixels de uma coluna do frame com os pixels
		# da proxima coluna atrav�s do loop abaixo
		# O loop tem como base uma maneira de realizar as trocas de pixels evitando ao m�ximo
		# que os endere�os fiquem desalinhados, ao mesmo tempo que tenta executar quase o mesmo 
		# n�mero de intru��es do que os outros procedimentos de movimenta��o de tela
		
		li t0, 0		# contador para o numero de linhas feitas
		
		li t1, 0xFF00013C	# endere�o da ultima word de pixels do frame 0
	
		add t1, t1, t6		# decide a partir do valor de t6 qual o frame onde a imagem
					# ser� impressa	
								
		MOVER_TELA_A_LOOP_LINHAS:
			li t2, 316	# n�mero de colunas de pixels que ser�o trocados
						
			# Na primeira itera��o (t5 == 1) a troca de pixels do frame vai acontecer a partir de
			# t1 movendo os pixels em 1 endere�o de distancia, mas nas pr�ximas a troca vai acontecer 
			# movendo os pixels em 2 endere�os
			li t3, 1
			beq t5, t3, MOVER_TELA_A_PRIMEIRA_ITERACAO
										
		MOVER_TELA_A_LOOP_COLUNAS:
			lh t3, 0(t1)		# pega os dois primeiros pixels de t1
			sh t3, 2(t1)		# armazena esses pixels nos proximos 2 endere�os da word de t1
			lh t3, -2(t1)		# pega os dois primeiros pixels da word anterior a t1
			sh t3, 0(t1)		# armazena esses pixels nos primeiros endere�os da word de t1
			addi t1, t1, -4		# passa o endere�o do bitmap para a word anterior
			addi t2, t2, -4		# decrementa o n�mero de colunas restantes
			bne t2, zero, MOVER_TELA_A_LOOP_COLUNAS	# reinicia o loop se t2 != 0   
			# O loop acima s� � executado 316/4 vezes, mas um frame tem 320 pixels de largura.
			# Essa word restante tem que ser analisada de modo independente j� que n�o tem mais 
			# bytes a esquerda de t1 para que fazer a troca de pixels
			lh t3, 0(t1)		# pega os dois primeiros pixels de t1
			sh t3, 2(t1)		# armazena esses pixels nos proximos 2 endere�os da word de t1	
			j MOVER_TELA_A_PROXIMA_LINHA							
						
			MOVER_TELA_A_PRIMEIRA_ITERACAO:
			lw t3, 0(t1)		# pega os 4 pixels de t1 e os desloca por 8 bits de modo 
			slli t3, t3, 8		# que t3 tem apenas os 3 primeiros pixels de t1
			sw t3, 0(t1)		# armazena esses pixels deslocados em t1
			lb t3, -1(t1)		# pega o 1o pixel da word anterior a t1 e 
			sb t3, 0(t1)		# armazena no primeiro endere�o de t1 (aquele que foi aberto
						# pelo deslocamente a esquerda)
			addi t1, t1, -4		# passa o endere�o do bitmap para a word anterior
			addi t2, t2, -4		# decrementa o n�mero de colunas restantes
			bne t2, zero, MOVER_TELA_A_PRIMEIRA_ITERACAO	# reinicia o loop se t2 != 0   
			
			# O loop acima s� � executado 316/4 vezes, mas um frame tem 320 pixels de largura.
			# Essa word restante tem que ser analisada de modo independente j� que n�o tem mais 
			# bytes a esquerda de t1 para que fazer a troca de pixels
			lw t3, 0(t1)		# pega os 4 pixels de t1 e os desloca por 8 bits de modo 
			slli t3, t3, 8		# que t3 tem apenas os 3 primeiros pixels de t1
			sw t3, 0(t1)		# armazena esses pixels deslocados em t1
			
		MOVER_TELA_A_PROXIMA_LINHA:	 
			 
		addi t0, t0, 1		# incrementa o n�mero de linhas feitas

		li t1, 0xFF00013C	# endere�o da ultima word de pixels do frame 0
		
		add t1, t1, t6		# decide a partir do valor de t6 qual o frame onde a imagem
					# ser� impressa	
					
		li t3, 320		# 320 � o tamanho de uma linha do frame
		mul t3, t3, t0		# decide a partir do valor de t0 para qual linha o endere�o de t1 vai		
		add t1, t1, t3							
							
		li t3, 240		# n�mero de linhas de um frame																													
		bne t0, t3, MOVER_TELA_A_LOOP_LINHAS	# reinicia o loop se t0 != 240 
		
		
		# Parte (2) -> limpar o sprite antigo do RED do frame
		# Diferente dos outros casos a limpeza do sprite vai acontecer por outra abordagem.
		# Como PRINT_TILES_AREA utiliza lw e sw, al�m de que esse MOVER_TELA_D move a tela 1 pixel por vez,
		# em certos momentos o endere�o de onde imprimir os tiles n�o vai estar alinhado para o 
		# store word, portanto n�o � poss�vel usar o PRINT_TILES_AREA aqui.
		# Para a limpeza ser� usado o endere�o do personagem (s0) junto do PRINT_IMG (que usa lb e sb)
		# imprimindo novamente os 2 tiles onde o RED est� e os 2 tiles atr�s como uma folga
		
		# Primeiro limpa o tile da cabe�a do RED 
		mv a0, s0	# endere�o de onde o RED est� no frame 0
		call CALCULAR_ENDERECO_DE_TILE
		
		mv a0, a2 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a2 tem o endere�o da imagem do 
				# tile correspondente
		add a1, a1, t5 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a1 tem o endere�o de inicio do tile
				# no frame 0. Al�m disso, � necess�rio avan�ar a1 por t5 colunas para imprimir
				# o tile no lugar certo nessa itera��o
		add a1, a1, t6	# decide a partir do valor de t6 qual o frame onde o tile ser� impresso	
		li a2, 16		# n�mero de colunas de tiles a serem impressas
		li a3, 16		# n�mero de linhas de tiles a serem impressas
		call PRINT_IMG

		# Limpa o tile do corpo do RED
		addi a0, s0, 960	# somando s0 com 960 passa o endere�o de onde o RED est� 
					# para o inicio do tile abaixo dele
		call CALCULAR_ENDERECO_DE_TILE
		
		mv a0, a2 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a2 tem o endere�o da imagem do 
				# tile correspondente
		add a1, a1, t5 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a1 tem o endere�o de inicio do tile
				# no frame 0. Al�m disso, � necess�rio avan�ar a1 por t5 colunas para imprimir
				# o tile no lugar certo nessa itera��o
		add a1, a1, t6	# decide a partir do valor de t6 qual o frame onde o tile ser� impresso	
		li a2, 16		# n�mero de colunas de tiles a serem impressas
		li a3, 16		# n�mero de linhas de tiles a serem impressas
		call PRINT_IMG


		# Limpa o tile a esquerda da cabe�a do RED
		addi a0, s0, -16	# somando s0 com -16 passa o endere�o de onde o RED est� 
					# para o inicio do tile a esquerda dele
		call CALCULAR_ENDERECO_DE_TILE
		
		mv a0, a2 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a2 tem o endere�o da imagem do 
				# tile correspondente
		add a1, a1, t5 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a1 tem o endere�o de inicio do tile
				# no frame 0. Al�m disso, � necess�rio avan�ar a1 por t5 colunas para imprimir
				# o tile no lugar certo nessa itera��o
		add a1, a1, t6	# decide a partir do valor de t6 qual o frame onde o tile ser� impresso	
		li a2, 16		# n�mero de colunas de tiles a serem impressas
		li a3, 16		# n�mero de linhas de tiles a serem impressas
		call PRINT_IMG
		
		# Limpa o tile na diagonal inferior esquerda da cabe�a do RED
		addi a0, s0, -16	# somando s0 com -16 passa o endere�o de onde o RED est� 
					# para o inicio do tile a esquerda dele
		addi a0, a0, 960	# somando a0 com 960 passa o endere�o de a0 para o inicio do tile 
					# abaixo dele
		call CALCULAR_ENDERECO_DE_TILE
		
		mv a0, a2 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a2 tem o endere�o da imagem do 
				# tile correspondente
		add a1, a1, t5 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a1 tem o endere�o de inicio do tile
				# no frame 0. Al�m disso, � necess�rio avan�ar a1 por t5 colunas para imprimir
				# o tile no lugar certo nessa itera��o
		add a1, a1, t6	# decide a partir do valor de t6 qual o frame onde o tile ser� impresso	
		li a2, 16		# n�mero de colunas de tiles a serem impressas
		li a3, 16		# n�mero de linhas de tiles a serem impressas
		call PRINT_IMG
		
		# Parte (3) -> imprime o sprite do RED
		# O pr�ximo sprite do RED vai ser decidido de acordo com o n�mero da intera��o (t3)
		# de modo que a anima��o siga o seguinte padr�o:
		# RED PARADO -> RED DANDO UM PASSO -> RED PARADO
		
		# a0 vai receber o endere�o da pr�xima imagem do RED dependendo do n�mero da itera��o (t5)	
		la a0, red_esquerda
		li t0, 14
		bgt t5, t0, PRINT_RED_MOVER_TELA_A
		
		# Se 2 < t5 <= 14 a imagem a ser impressa � a do RED dando um passo, que � decidida a 
		# partir do valor de s8
		la a0, red_esquerda_passo_direito
							
		beq s8, zero, PROXIMO_RED_MOVER_TELA_A		
			la a0, red_esquerda_passo_esquerdo
	
		PROXIMO_RED_MOVER_TELA_A:
		
		li t0, 2
		bgt t5, t0, PRINT_RED_MOVER_TELA_A
		la a0, red_esquerda
		
		PRINT_RED_MOVER_TELA_A:					
		# Agora imprime a imagem do RED no frame
			# a0 tem o endere�o da pr�xima imagem do RED 			
			mv a1, s0		# s0 possui o endere�o do RED no frame 0
			add a1, a1, t6		# decide a partir do valor de t6 qual o frame onde a imagem
						# ser� impressa		
			lw a2, 0(a0)		# numero de colunas de uma imagem do RED
			lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
			addi a0, a0, 8		# pula para onde come�a os pixels no .data	
			call PRINT_IMG	
			
		# Se o RED estiver indo para um tile de grama � preciso imprimir uma pequena anima��o
		# de folhas subindo enquanto ele estiver indo para o tile		
		beq s10, zero, MOVER_TELA_A_PARTE_4
			
			la t0, tiles_grama_animacao	
			addi t0, t0, 8			# pula para onde come�a os pixels no .data
			
			# t2 vai receber a quantidade de pixels que ser� pulada em tiles_grama_animacao para
			# encontrar a imagem certa para imprimir de acordo com a itera��o atual (t5)
			li t2, 0		
			li t1, 11			
			bge t5, t1, MOVER_TELA_A_PRINT_GRAMA
			li t2, 256
			li t1, 6			
			bge t5, t1, MOVER_TELA_A_PRINT_GRAMA	
			li t2, 512
			li t1, 2
			bge t5, t1, MOVER_TELA_A_PRINT_GRAMA
			li t2, 0
									
			MOVER_TELA_A_PRINT_GRAMA:
			add a0, t0, t2		# a0 recebe o endere�o da imagem da grama a ser impressa
			mv a1, s0		# O endere�o onde esse tile ser� impresos onde o RED est�
			addi a1, a1, 959	# (s0), 3 linhas para baixo e uma coluna para a esquerda	
						# (959 = 320 * 3 - 1)
			add a1, a1, t6		# decide a partir do valor de t5 qual o frame onde a imagem
						# ser� impressa	
			add a1, a1, t5		# a coluna do endere�o tamb�m ser� decidia pelo numero
						# da itera��o atual (t5), no caso da MOVER_TELA_A o endere�o
						# ser� atualizado algumas colunas para frente
			
			li a2, 16		# numero de colunas do tile
			li a3, 16		# numero de linhas do tile
			call PRINT_IMG				
		
		MOVER_TELA_A_PARTE_4:
		
		# Parte (4) -> imprime a coluna anterior da subsec��o da �rea 1 pixel para a direita
		# O que tem que ser feito � imprimir os tiles dessa coluna de modo que s� v�o ser impressas uma 
		# parte da imagem de cada tile de forma a dar a impress�o de que a coluna avan�ou 1 pixel e que
		# uma nova parte da �rea est� sendo lentamente revelada
		
		# O procedimento PRINT_IMG tem uma limita��o: ele n�o � capaz de imprimir partes de imagens se
		# essas partes tem um n�mero de colunas diferente da imagem completa, por exemplo: imprimir 
		# uma parte 6 x 15 de uma imagem 10 x 15, para imprimir uma parte de imagem � necess�rio que essa 
		# parte tenha o mesmo n�mero de colunas que a imagem original 				
		# Essa limita��o dificulta essa parte do procedimneto, portanto a abordagem ser� diferente:
		# Para cada 1 dos 20 tiles da coluna ser�o impressas individualmente as 16 linhas do tile
																														
		li t3, 0		# contador para o n�mero de tiles impressos
						
		LOOP_TILES_PROXIMA_AREA_A:
		
		li t4, 0		# contador para o n�mero de linhas de cada tile impressas

		LOOP_LINHAS_PROXIMA_AREA_A:	
					
		# Encontrando a imagem do tile	
		addi t0, s2, -1		# s2 - 1 retorna o endere�o de in�cio da coluna anterior da
					# subsec��o de tiles que est� na tela 
		
		mul t1, s3, t3		# decide qual o tile da coluna que ser� impresso de acordo com 
		add t0, t0, t1		# t3 (n�mero do tile atual)		
		
		lb t0, 0(t0)	# pega o valor do elemento da matriz de tiles apontado por t0
			
		li t1, 256	# t1 recebe 16 * 16 = 256, ou seja, a �rea de um tile							
		mul t0, t0, t1	# t0 (n�mero do tile) * (16 * 16) retorna quantos pixels esse tile est� do 
				# come�o da imagem dos tiles
		
		li t1, 16	# decide qual a coluna do tile que ser� impressa de acordo com t5 (n�mero
		sub t1, t1, t5 	# da itera��o atual)
		add t0, t0, t1	
		
		li t1, 16	# decide qual a linha do tile que ser� impressa de acordo com 
		mul t1, t1, t4	# t4 (n�mero da linha atual do tile)	
		add t0, t0, t1		
												
		# Imprimindo a linha do tile		
		add a0, s4, t0	# a0 recebe o endere�o da linha do tile a ser impresso a partir 
				# de s4 (imagem dos tiles)
		
		li a1, 0xFF000000	# a1 recebe o endere�o do 1o pixel da primaira linha do frame 0,
					# ou seja, onde o 1o tile dessa coluna ser� impresso 
						
		li t0, 5120	# 5120 = 320 (tamanho de uma linha do frame) * 16 (altura de um tile)
		mul t0, t0, t3	# o endere�o de a1 vai ser avan�ado por t3 * 5120 pixels de modo que vai apontar
		add a1, a1, t0	# para o endere�o onde o tile dessa itera��o (t3) deve ser impresso

		li t0, 320	# 320 � o tamanho de uma linha do frame
		mul t0, t0, t4	# 320 * t4 vai retornar em quantos pixels a1 precisar ser avan�ado para encontrar
		add a1, a1, t0	# o endere�o onde imprimir a linha atual (t4) do tile (t3)
		
		add a1, a1, t6 	# decide a partir do valor de t6 qual o frame onde a imagem ser� impressa	
		
		mv a2, t5	# o n�mero de colunas a serem impressas = o valor de t5 (itera��o atual)					
		li a3, 1	# numero de linhas a serem impressas
		call PRINT_IMG
	
		addi t4, t4, 1		# incrementando o n�mero de linhas do tile impressas
		li t0, 16
		bne t4, t0, LOOP_LINHAS_PROXIMA_AREA_A		# reinicia o loop se t4 != 16
			
		addi t3, t3, 1		# incrementando o n�mero de tiles impressos
		li t0, 15	
		bne t3, t0, LOOP_TILES_PROXIMA_AREA_A		# reinicia o loop se t3 != 15
		
	
		# Espera alguns milisegundos	
		mv a0, s9			# sleep por s9 ms de acordo com o definido em Pokemon.s
		call SLEEP			# chama o procedimento SLEEP	
		
		call TROCAR_FRAME	# inverte o frame sendo mostrado		

		li t0, 0x00100000	# fazendo essa opera��o xor se t4 for 0 ele recebe 0x0010000
		xor t6, t6, t0		# e se for 0x0010000 ele recebe 0, ou seja, com isso � poss�vel
					# trocar entre esses valores
		
		addi t5, t5, 1		# incrementa o n�mero de loops realizados						
		li t0, 16
		bne t5, t0, LOOP_MOVER_TELA_A	# reinicia o loop se t3 != 16
	
																																																																																																															
	addi s2, s2, -1		# atualizando a subsec��o da �rea para a coluna anterior da atual (s2) 
	
	# Pela maneira que o loop acima � executado na verdade s� s�o feitas 15 itera��es e n�o 16, 
	# portanto, � necess�rio imprimir novamente as imagem da �rea em ambos os frames + o sprite do RED 
	# no frame 0 e 1 para que tudo fique no lugar certo
		
		# Imprimindo a imagem da �rea no frame 0
		mv a0, s2		# endere�o, na matriz de tiles, de onde come�a a imagem a ser impressa
		li a1, 0xFF000000	# a imagem ser� impressa no frame 0
		li a2, 20		# n�mero de colunas de tiles a serem impressas
		li a3, 15		# n�mero de linhas de tiles a serem impressas
		call PRINT_TILES_AREA	
	
		# Imprimindo o sprite do RED no frame 0
		la a0, red_esquerda	# carrega a imagem do sprite			
		mv a1, s0		# s0 tem a posi��o do RED no frame 0
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		call PRINT_IMG	
	
	call TROCAR_FRAME	# inverte o frame sendo mostrado
				# � necess�rio inverter o frame mais 1 vez para que o frame sendo mostrado
				# seja o 0		
					
		# Imprimindo a imagem da �rea no frame 1
		mv a0, s2		# endere�o, na matriz de tiles, de onde come�a a imagem a ser impressa
		li a1, 0xFF100000	# a imagem ser� impressa no frame 0
		li a2, 20		# n�mero de colunas de tiles a serem impressas
		li a3, 15		# n�mero de linhas de tiles a serem impressas
		call PRINT_TILES_AREA			
		
		# Imprimindo o sprite do RED no frame 1
		la a0, red_esquerda	# carrega a imagem do sprite			
		mv a1, s0		# s0 tem a posi��o do RED no frame 0
		li t0, 0x00100000
		add a1, a1, t0		# passa o endere�o de a1 para o frame 1
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		call PRINT_IMG	
										
	addi s5, s5, -1		# atualizando o lugar do personagem na matriz de tiles para a posi��o anterior

	addi s6, s6, -1		# atualiza o valor de s6 para o endere�o anterior da matriz de movimenta��o 
						
	xori s8, s8, 1		# inverte o valor de s8, ou seja, se o RED deu um passo esquerdo o pr�ximo
				# ser� direito e vice-versa
																																	
	FIM_MOVIMENTACAO_A:

	call PRINT_FAIXA_DE_GRAMA	# imprime a faixa de grama sobre o RED caso seja necess�rio  
	
	call VERIFICAR_COMBATE		# verifica se o tile para onde o RED se moveu � um tile de grama e
					# se ele vai iniciar um combate
																																																					
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
		beq s1, t0, INICIO_MOVIMENTACAO_S
			la a4, red_baixo	# carrega como argumento o sprite do RED virada para baixo		
			call MUDAR_ORIENTACAO_RED
			
			li s1, 3	# atualiza o valor de s1 dizendo que agora o RED est� virado 
					# para baixo
							
	INICIO_MOVIMENTACAO_S:
	# Primeiro � preciso verificar a posi��o abaixo da atual na matriz de movimenta��o da �rea em rela��o ao
	# personagem (s6). 
	
	add a0, s6, s7		# verifica a proxima posi��o uma linha abaixo (s7 tem o tamanho de uma linha na
				# na matriz) da atual a partir de s6
	call VERIFICAR_MATRIZ_DE_MOVIMENTACAO
	
	# Como retorno a0 tem comandos para o procedimento de movimenta��o.
	# Se a0 == 0 ent�o a movimenta��o deve ocorrer
	
	bne a0, zero, FIM_MOVIMENTACAO_S
	
	# � necess�rio decidir se o que vai se mover � a tela ou o personagem
	# O personagem se move se a tela n�o permitir movimento. No caso da tecla S isso acontece quando o 
	# endere�o uma linha abaixo da �rea atual de tiles for -1. 
	
	li t0, 15	# t0 recebe o tamanho em tiles de uma linha da �rea sendo mostrada na tela
	mul t0, s3, t0	# t0 * s3 retorna quantos tiles � necess�rio pular para encontrar a pr�xima linha
			# da subsec��o de tiles
	
	add t0, t0, s2	# t0 recebe o endere�o da pr�xima linha depois da �rea atual de tiles que est� na tela
	
	lb t0, (t0)	# checa se a matriz da �rea permite movimento		
		
	li t1, -1				# se t0 for -1 a tela n�o permite movimento, ent�o o que								
	bne t0, t1, MOVER_TELA_S		# deve se mover � o personagem
								
	# Com tudo feito agora � possivel chamar o procedimento de movimenta��o para o personagem
		# Decide se o RED vai ser renderizado dando o passo com o p� esquedo ou direito
		# de acordo com o valor de s8		
		la a5, red_baixo_passo_direito
							
		beq s8, zero, MOVER_RED_S		
			la a5, red_baixo_passo_esquerdo
						
		MOVER_RED_S:				
		la a4, red_baixo	# carrega a imagem do RED parado
		# a5 tem a a imagem do RED dando um passo	
		mv a6, s0		# a anima��o vai come�ar onde o RED est� (s0)
		li a7, 2		# a3 = 2 = anima��o para baixo																
		call MOVER_PERSONAGEM																																																															
		
	mv s0, a0		# De acordo com o retorno de MOVER_PERSONAGEM a0 tem o endere�o de s0 
				# atualizado pela movimenta��o feita
	
	add s5, s5, s3		# atualizando o lugar do personagem na matriz de tiles para a posi��o uma linha
				# abaixo

	add s6, s6, s7		# atualiza o valor de s6 para o endere�o uma linha abaixo da atual na matriz 
				# de movimenta��o 
						
	xori s8, s8, 1		# inverte o valor de s8, ou seja, se o RED deu um passo esquerdo o pr�ximo
				# ser� direito e vice-versa
					
	j FIM_MOVIMENTACAO_S									
		
	# -------------------------------------------------------------------------------------------------																				
	
	MOVER_TELA_S:
	# Caso a tela ainda permita movimento � ela que tem que se mover
	# O movimento da tela tem como base o loop abaixo, que tem 4 partes: 
	#	(1) -> move toda a imagem da �rea que est� na tela em um 1 pixel para cima
	#	(2) -> limpar o sprite antigo do RED do frame
	#  	(3) -> imprime os sprites de movimenta��o do RED
	#	(4) -> imprime a pr�xima linha da subsec��o da �rea 1 pixel para cima
	# Com esses passos � poss�vel passar a sensa��o de que a tela est� se movendo para cima e revelando
	# uma nova parte da �rea
	
	li t5, 1		# contador para o n�mero de loops realizados
	li t6, 0x00100000	# t6 ser� usado para fazer a troca entre frames no loop abaixo	
	
	LOOP_MOVER_TELA_S:
				
		# Parte (1) -> move toda a imagem da �rea que est� na tela em um 1 pixel para cima
		# Para fazer isso � poss�vel simplesmente trocar os pixels de uma linha do frame com os pixels
		# da linha anterior atrav�s do loop abaixo
		
		li t0, 240		# n�mero de linhas de um frame, ou seja, a quantidade de loops abaixo
		sub t0, t0, t5		# o n�mero de loops � controlado pelo n�mero da itera��o atual (t5)
		
		li t1, 0xFF000140	# endere�o da linha 1 do frame 0
		
		# Na primeira itera��o (t5 == 1) a troca de pixels do frame vai acontecer a partir da 1a linha
		# (0xFF000140), mas nas pr�ximas a troca vai acontecer a partir da 2a linha (0xFF000280) 
		# porque a troca vai ser alternada entre os frame 0 e 1
		    
		li t2, 1
		beq t5, t2, INICIO_MOVER_TELA_S
			li t1, 0xFF000280		# endere�o da linha 2 do frame 0
				
		INICIO_MOVER_TELA_S:
		
		add t1, t1, t6		# decide a partir do valor de t6 qual o frame onde a imagem
					# ser� impressa	
								
		MOVER_TELA_S_LOOP_LINHAS:
			li t2, 320		# n�mero de colunas de um frame
			
		MOVER_TELA_S_LOOP_COLUNAS:		
			lw t3, 0(t1)		# pega 4 pixels do bitmap e coloca em t3
			
			# Na 1a itera��o os pixels ser�o armazenados na linha anterior (-320), mas nas 
			# itera��es seguintes ser�o armzenados 2 linhas para tr�s (-640)
			
			li t4, 1
			beq t5, t4, MOVER_TELA_S_PRIMEIRA_ITERACAO
				sw t3, -640(t1)	# armazena os 4 pixels de t5 na 2 linhas para tr�s (-640) do 
						# endere�o apontado por t1
				j MOVER_TELA_S_PROXIMA_ITERACAO	
				
			MOVER_TELA_S_PRIMEIRA_ITERACAO:	
			sw t3, -320(t1)		# armazena os 4 pixels de t5 na linha anterior (-320) ao endere�o
						# apontado por t1
						
			MOVER_TELA_S_PROXIMA_ITERACAO:
			addi t1, t1, 4		# passa o endere�o do bitmap para os pr�ximos pixels
			addi t2, t2, -4		# decrementa o n�mero de colunas restantes
			bne t2, zero, MOVER_TELA_S_LOOP_COLUNAS		# reinicia o loop se t2 != 0    
		
		addi t0, t0, -1			# decrementa o n�mero de linhas restantes
		bne t0, zero, MOVER_TELA_S_LOOP_LINHAS	# reinicia o loop se t0 != 0 
		
		# Parte (2) -> limpar o sprite antigo do RED do frame
		# Para limpar os sprites antigos � poss�vel usar o PRINT_TILES_AREA imprimindo 1 coluna
		# 3 linhas (2 tiles do RED + 1 tile de folga)
		
		mv a0, s5	# endere�o, na matriz de tiles, de onde come�am os tiles a ser impressos,
				# nesse caso, o come�o � o tile onde o RED est�
		mv a1, s0	# a imagem ser� impressa onde o RED est� (s0)
		
		li t0, 4161	# o endere�o do RED na verdade est� um pouco abaixo do inicio do tile,
		sub a1, a1, t0	# portanto � necess�rio voltar o endere�o de a1 em 4164 pixels (13 linhas * 
				# 320 + 1 coluna)
		
		li t0, 320	# o endere�o de onde os tiles v�o ser impressos tamb�m muda de acordo com a
		mul t0, t0, t5	# itera��o, j� que o pixels da tela ser�o trocados para fazer a imagem "subir"
		sub a1, a1, t0	# portanto, 320 * t5 retorna quantos pixels � necess�rio voltar para encontrar
				# a linha certa onde devem ser impressos os tiles nessa itera��o
		
		add a1, a1, t6		# decide a partir do valor de t6 qual o frame onde os tiles
					# ser� impressa	
					
		li a2, 1		# n�mero de colunas de tiles a serem impressas
		li a3, 3		# n�mero de linhas de tiles a serem impressas
		call PRINT_TILES_AREA
		
		# Parte (3) -> imprime o sprite do RED
		# O pr�ximo sprite do RED vai ser decidido de acordo com o n�mero da intera��o (t3)
		# de modo que a anima��o siga o seguinte padr�o:
		# RED PARADO -> RED DANDO UM PASSO -> RED PARADO
		
		# a0 vai receber o endere�o da pr�xima imagem do RED dependendo do n�mero da itera��o (t5)	
		la a0, red_baixo
		li t0, 14
		bgt t5, t0, PRINT_RED_MOVER_TELA_S
		
		# Se 2 < t5 <= 14 a imagem a ser impressa � a do RED dando um passo, que � decidida a 
		# partir do valor de s8
		la a0, red_baixo_passo_direito
							
		beq s8, zero, PROXIMO_RED_MOVER_TELA_S		
			la a0, red_baixo_passo_esquerdo
	
		PROXIMO_RED_MOVER_TELA_S:
		
		li t0, 2
		bgt t5, t0, PRINT_RED_MOVER_TELA_S
		la a0, red_baixo
		
		PRINT_RED_MOVER_TELA_S:					
		# Agora imprime a imagem do RED no frame
			# a0 tem o endere�o da pr�xima imagem do RED 			
			mv a1, s0		# s0 possui o endere�o do RED no frame 0
			add a1, a1, t6		# decide a partir do valor de t6 qual o frame onde a imagem
						# ser� impressa		
			lw a2, 0(a0)		# numero de colunas de uma imagem do RED
			lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
			addi a0, a0, 8		# pula para onde come�a os pixels no .data	
			call PRINT_IMG	
			
		# Se o RED estiver indo para um tile de grama � preciso imprimir uma pequena anima��o
		# de folhas subindo enquanto ele estiver indo para o tile		
		beq s10, zero, MOVER_TELA_S_PARTE_4
			# por�m somente se o tile abaixo do RED for um tile de grama
			add t0, s6, s7		# verifica a posi��o abaixo do RED (s6) na matriz 
			lbu t0, 0(t0)		# de movimenta��o (s7 = tamanho de uma linha da matriz) e
			li t1, 7		# checa se ele � igual a 7 (codigo do tile de grama)
			bne t1, t0, MOVER_TELA_S_PARTE_4
			
			la t0, tiles_grama_animacao	
			addi t0, t0, 8			# pula para onde come�a os pixels no .data
			
			# t2 vai receber a quantidade de pixels que ser� pulada em tiles_grama_animacao para
			# encontrar a imagem certa para imprimir de acordo com a itera��o atual (t5)
			li t2, 512
			li t1, 6
			bge t5, t1, MOVER_TELA_S_PRINT_GRAMA
			li t2, 0
									
			MOVER_TELA_S_PRINT_GRAMA:
			add a0, t0, t2		# a0 recebe o endere�o da imagem da grama a ser impressa
			mv a1, s0		# O endere�o onde esse tile ser� impresos onde o RED est�
			addi a1, a1, 959	# (s0), 3 linhas para baixo e uma coluna para a esquerda	
						# (959 = 320 * 3 - 1)
			add a1, a1, t6		# decide a partir do valor de t5 qual o frame onde a imagem
						# ser� impressa	
			li t0, 5120		# no caso do MOVER_TELA_S a grama ser� impressa no tile abaixo
			add a1, a1, t0		# do RED (5120 = 16 linhas * 320)
			
			li t0, 320		# a coluna do endere�o tamb�m ser� decidia pelo numero
			mul t0, t0, t5		# da itera��o atual (t5), no caso da MOVER_TELA_S o endere�o
			sub a1, a1, t0		# ser� atualizado algumas linhas para tras
	
			li a2, 16		# numero de colunas do tile
			li a3, 16		# numero de linhas do tile
			call PRINT_IMG				
		
		MOVER_TELA_S_PARTE_4:
		
		# Parte (4) -> imprime a pr�xima linha da subsec��o da �rea 1 pixel para cima
		# O que tem que ser feito � imprimir os tiles dessa linha de modo que s� v�o ser impressas uma 
		# parte da imagem de cada tile de forma a dar a impress�o de que a linha subiu 1 pixel e que
		# uma nova parte da �rea est� sendo lentamente revelada
						
		li t3, 0		# contador para o n�mero de tiles impressos
		li t4, 0xFF012C00	# t4 vai guardar o endere�o de onde os tiles v�o ser impressos, sendo
					# que ele � incrementado a cada loop abaixo. Esse endere�o aponta
					# para o endere�o depois da �ltima linha do frame 0
		add t4, t4, t6		# decide a partir do valor de t6 qual o frame onde a imagem
					# ser� impressa		
							
		LOOP_PRINT_PROXIMA_AREA_S:
		
		# Encontrando a imagem do tile	
		li t0, 15		# 15 � o nm�mero de linhas de tiles da subsec��o da �rea que est� na tela
		mul t0, t0, s3		# s3 * 15 retorna quantos elementos � necess�rio pular na matriz de tiles
		add t0, s2, t0		# para encontrar o endere�o de in�cio da pr�xima linha da subsec��o de
					# tiles que est� na tela
			
		add t0, t0, t3	# decide qual o tile a ser impresso de acordo com t3 (n�mero da itera��o atual)
		
		lb t0, 0(t0)	# pega o valor do elemento da matriz de tiles apontado por t0
		
		li t1, 256	# t1 recebe 16 * 16 = 256, ou seja, a �rea de um tile							
		mul t0, t0, t1	# t0 (n�mero do tile) * (16 * 16) retorna quantos pixels esse tile est� do 
				# come�o da imagem dos tiles
				
		# Imprimindo a imagem do tile		
		add a0, s4, t0	# a0 recebe o endere�o do tile a ser impresso a partir de s4 (imagem dos tiles)
		
		mv a1, t4	# a1 recebe o endere�o de onde imprimir o tile
		li t0, 320	# t0 tem o tamanho de uma linha do frame
		mul t0, t0, t5	# 320 * t5 (n�mero da itera��o atual) retorna quantos pixels � necess�rio voltar
		sub a1, a1, t0	# para encontrar o endere�o de onde imprimir os tiles
				
		li a2, 16	# a2 = numero de colunas de um tile
		addi a3, t5, 1	# a3 tem o n�mero de linhas a serem impressas = o valor de t5 (itera��o atual)
				# + 1 porque t5 come�a no 1 e n�o no 0
		call PRINT_IMG
	
		addi t4, t4, 16		# incrementando o endere�o onde os tiles v�o ser impressos em 16 pixels
					# porque o tile que acabou de ser impresso tem 16 colunas
		addi t3, t3, 1		# incrementando o n�mero de tiles impressos
		
		li t0, 20
		bne t3, t0, LOOP_PRINT_PROXIMA_AREA_S	# reinicia o loop se t3 != 20
		
	
		# Espera alguns milisegundos	
		mv a0, s9			# sleep por s9 ms de acordo com o definido em Pokemon.s
		call SLEEP			# chama o procedimento SLEEP	
		
		call TROCAR_FRAME	# inverte o frame sendo mostrado		
				
		li t0, 0x00100000	# fazendo essa opera��o xor se t4 for 0 ele recebe 0x0010000
		xor t6, t6, t0		# e se for 0x0010000 ele recebe 0, ou seja, com isso � poss�vel
					# trocar entre esses valores
		
		addi t5, t5, 1		# incrementa o n�mero de loops realizados						
		li t0, 16
		bne t5, t0, LOOP_MOVER_TELA_S	# reinicia o loop se t3 != 16
	
																																																																																																															
	add s2, s2, s3		# atualizando a subsec��o da �rea para uma linha abaixo da atual (s2) 
	
	# Pela maneira que o loop acima � executado na verdade s� s�o feitas 15 itera��es e n�o 16, 
	# portanto, � necess�rio imprimir novamente as imagem da �rea em ambos os frames + o sprite do RED 
	# no frame 0  e 1 para que tudo fique no lugar certo
		
		# Imprimindo a imagem da �rea no frame 0
		mv a0, s2		# endere�o, na matriz de tiles, de onde come�a a imagem a ser impressa
		li a1, 0xFF000000	# a imagem ser� impressa no frame 0
		li a2, 20		# n�mero de colunas de tiles a serem impressas
		li a3, 15		# n�mero de linhas de tiles a serem impressas
		call PRINT_TILES_AREA	

		# Imprimindo o sprite do RED no frame 0
		la a0, red_baixo	# carrega a imagem do sprite			
		mv a1, s0		# s0 tem a posi��o do RED no frame 0
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		call PRINT_IMG	

	call TROCAR_FRAME	# inverte o frame sendo mostrado
				# � necess�rio inverter o frame mais 1 vez para que o frame sendo mostrado
				# seja o 0		
					
		# Imprimindo a imagem da �rea no frame 1
		mv a0, s2		# endere�o, na matriz de tiles, de onde come�a a imagem a ser impressa
		li a1, 0xFF100000	# a imagem ser� impressa no frame 0
		li a2, 20		# n�mero de colunas de tiles a serem impressas
		li a3, 15		# n�mero de linhas de tiles a serem impressas
		call PRINT_TILES_AREA			
		
		# Imprimindo o sprite do RED no frame 1
		la a0, red_baixo	# carrega a imagem do sprite			
		mv a1, s0		# s0 tem a posi��o do RED no frame 0
		li t0, 0x00100000
		add a1, a1, t0		# passa o endere�o de a1 para o frame 1
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		call PRINT_IMG	
										
	add s5, s5, s3		# atualizando o lugar do personagem na matriz de tiles para a posi��o uma linha
				# abaixo

	add s6, s6, s7		# atualiza o valor de s6 para o endere�o uma linha abaixo da atual na matriz 
				# de movimenta��o 
						
	xori s8, s8, 1		# inverte o valor de s8, ou seja, se o RED deu um passo esquerdo o pr�ximo
				# ser� direito e vice-versa
					
	FIM_MOVIMENTACAO_S:

	call PRINT_FAIXA_DE_GRAMA	# imprime a faixa de grama sobre o RED caso seja necess�rio  

	call VERIFICAR_COMBATE		# verifica se o tile para onde o RED se moveu � um tile de grama e
					# se ele vai iniciar um combate
													
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
		beq s1, t0, INICIO_MOVIMENTACAO_D
			la a4, red_direita	# carrega como argumento o sprite do RED virada para a direita		
			call MUDAR_ORIENTACAO_RED

			li s1, 1	# atualiza o valor de s1 dizendo que agora o RED est� virado 
					# para a direita	
					
	INICIO_MOVIMENTACAO_D:																																				
	# Primeiro � preciso verificar a proxima posi��o da matriz de movimenta��o da �rea em rela��o ao
	# personagem (s6). 
	
	addi a0, s6, 1		# verifica a proxima posi��o na matriz a partir de s6
	call VERIFICAR_MATRIZ_DE_MOVIMENTACAO
	
	# Como retorno a0 tem comandos para o procedimento de movimenta��o.
	# Se a0 == 0 ent�o a movimenta��o deve ocorrer
	
	bne a0, zero, FIM_MOVIMENTACAO_D
	
	# � necess�rio decidir se o que vai se mover � a tela ou o personagem
	# O personagem se move se a tela n�o permitir movimento. No caso da tecla D isso acontece quando o 
	# pr�ximo endere�o de s2 (subsec��� de tiles atual) + 20 (largura em tiles da �rea sendo mostrada na tela) 
	# for -1	
	
	lb t0, 20(s2)		# checa se a matriz da �rea permite movimento		
		
	li t1, -1				# se t0 for -1 a tela n�o permite movimento, ent�o o que								
	bne t0, t1, MOVER_TELA_D		# deve se mover � o personagem
	
								
	# Com tudo feito agora � possivel chamar o procedimento de movimenta��o para o personagem
		# Decide se o RED vai ser renderizado dando o passo com o p� esquedo ou direito
		# de acordo com o valor de s8		
		la a5, red_direita_passo_direito
							
		beq s8, zero, MOVER_RED_D		
			la a5, red_direita_passo_esquerdo
						
		MOVER_RED_D:				
		la a4, red_direita	# carrega a imagem do RED parado
		# a5 tem a a imagem do RED dando um passo	
		mv a6, s0		# a anima��o vai come�ar onde o RED est� (s0)
		li a7, 3		# a3 = 3 = anima��o para a direita																
		call MOVER_PERSONAGEM																																																															
		
	mv s0, a0		# De acordo com o retorno de MOVER_PERSONAGEM a0 tem o endere�o de s0 
				# atualizado pela movimenta��o feita
	
	addi s5, s5, 1		# atualizando o lugar do personagem na matriz de tiles para a pr�xima posi��o

	addi s6, s6, 1		# atualiza o valor de s6 para o proximo endere�o da matriz de movimenta��o 
						
	xori s8, s8, 1		# inverte o valor de s8, ou seja, se o RED deu um passo esquerdo o pr�ximo
				# ser� direito e vice-versa
	
	j FIM_MOVIMENTACAO_D									
		
	# -------------------------------------------------------------------------------------------------																				
	
	MOVER_TELA_D:
	# Caso a tela ainda permita movimento � ela que tem que se mover
	# O movimento da tela tem como base o loop abaixo, que tem 4 partes: 
	#	(1) -> move toda a imagem da �rea que est� na tela em um 1 pixel para a esquerda
	#	(2) -> limpar o sprite antigo do RED do frame
	#  	(3) -> imprime os sprites de movimenta��o do RED
	#	(4) -> imprime a pr�xima coluna da subsec��o da �rea 1 pixel para a esquerda
	# Com esses passos � poss�vel passar a sensa��o de que a tela est� se movendo para a esquerda e revelando
	# uma nova parte da �rea
	
	li t5, 1		# contador para o n�mero de loops realizados
	li t6, 0x00100000	# t6 ser� usado para fazer a troca entre frames no loop abaixo	
	
	LOOP_MOVER_TELA_D:
				
		# Parte (1) -> move toda a imagem da �rea que est� na tela em um 1 pixel para a esquerda
		# Para fazer isso � poss�vel simplesmente trocar os pixels de uma coluna do frame com os pixels
		# da coluna anterior atrav�s do loop abaixo
		
		li t0, 0		# contador para o numero de linhas feitas
		
		li t1, 0xFF000000	# endere�o da primaira word de pixels do frame 0
	
		add t1, t1, t6		# decide a partir do valor de t6 qual o frame onde a imagem
					# ser� impressa	
								
		MOVER_TELA_D_LOOP_LINHAS:
			li t2, 316	# n�mero de colunas de pixels que ser�o trocados
						
			# Na primeira itera��o (t5 == 1) a troca de pixels do frame vai acontecer a partir de
			# t1 movendo os pixels em 1 endere�o de distancia, mas nas pr�ximas a troca vai acontecer 
			# movendo os pixels em 2 endere�os
			li t3, 1
			beq t5, t3, MOVER_TELA_D_PRIMEIRA_ITERACAO
										
		MOVER_TELA_D_LOOP_COLUNAS:
			lh t3, 2(t1)		# pega os 2 ultimos pixels de t1
			sh t3, 0(t1)		# armazena esses pixels nos primeiros 2 endere�os da word de t1
			lh t3, 4(t1)		# pega os dois primeiros pixels da proxima word de t1
			sh t3, 2(t1)		# armazena esses pixels nos 2 ultimos endere�os da word de t1			
			addi t1, t1, 4		# passa o endere�o do bitmap para a proxima word
			addi t2, t2, -4		# decrementa o n�mero de colunas restantes
			bne t2, zero, MOVER_TELA_D_LOOP_COLUNAS	# reinicia o loop se t2 != 0   
			# O loop acima s� � executado 316/4 vezes, mas um frame tem 320 pixels de largura.
			# Essa word restante tem que ser analisada de modo independente j� que n�o tem mais 
			# bytes a esquerda de t1 para que fazer a troca de pixels
			lh t3, 2(t1)		# pega os 2 ultimos pixels de t1
			sh t3, 0(t1)		# armazena esses pixels nos primeiros 2 endere�os da word de t1		
			j MOVER_TELA_D_PROXIMA_LINHA							
						
			MOVER_TELA_D_PRIMEIRA_ITERACAO:
			lw t3, 0(t1)		# pega os 4 pixels de t1 e os desloca por 8 bits de modo 
			srli t3, t3, 8		# que t3 tem apenas os 3 primeiros pixels de t1
			sw t3, 0(t1)		# armazena esses pixels deslocados em t1
			lb t3, 4(t1)		# pega o 1o pixel da proxima word a t1 e 
			sb t3, 3(t1)		# armazena no ultimo endere�o de t1 (aquele que foi aberto
						# pelo deslocamento a direita
																																																																																																																																																																																																																																												# pelo deslocamente a esquerda)
			addi t1, t1, 4		# passa o endere�o do bitmap para a proxima word
			addi t2, t2, -4		# decrementa o n�mero de colunas restantes
			bne t2, zero, MOVER_TELA_D_PRIMEIRA_ITERACAO	# reinicia o loop se t2 != 0   
			
			# O loop acima s� � executado 316/4 vezes, mas um frame tem 320 pixels de largura.
			# Essa word restante tem que ser analisada de modo independente j� que n�o tem mais 
			# bytes a direita de t1 para que fazer a troca de pixels
			lw t3, 0(t1)		# pega os 4 pixels de t1 e os desloca por 8 bits de modo 
			srli t3, t3, 8		# que t3 tem apenas os 3 primeiros pixels de t1
			sw t3, 0(t1)		# armazena esses pixels deslocados em t1
			
		MOVER_TELA_D_PROXIMA_LINHA:	 
			 
		addi t0, t0, 1		# incrementa o n�mero de linhas feitas

		li t1, 0xFF000000	# endere�o da primaira word de pixels do frame 0
		
		add t1, t1, t6		# decide a partir do valor de t6 qual o frame onde a imagem
					# ser� impressa	
					
		li t3, 320		# 320 � o tamanho de uma linha do frame
		mul t3, t3, t0		# decide a partir do valor de t0 para qual linha o endere�o de t1 vai		
		add t1, t1, t3							
							
		li t3, 240		# n�mero de linhas de um frame																													
		bne t0, t3, MOVER_TELA_D_LOOP_LINHAS	# reinicia o loop se t0 != 240 

		
		# Parte (2) -> limpar o sprite antigo do RED do frame
		# Diferente dos outros casos a limpeza do sprite vai acontecer por outra abordagem.
		# Como PRINT_TILES_AREA utiliza lw e sw, al�m de que esse MOVER_TELA_D move a tela 1 pixel por vez,
		# em certos momentos o endere�o de onde imprimir os tiles n�o vai estar alinhado para o 
		# store word, portanto n�o � poss�vel usar o PRINT_TILES_AREA aqui.
		# Para a limpeza ser� usado o endere�o do personagem (s0) junto do PRINT_IMG (que usa lb e sb)
		# imprimindo novamente os 2 tiles onde o RED est� e os 2 tiles a frente como uma folga
		
		# Primeiro limpa o tile da cabe�a do RED 
		mv a0, s0	# endere�o de onde o RED est� no frame 0
		call CALCULAR_ENDERECO_DE_TILE
		
		mv a0, a2 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a2 tem o endere�o da imagem do 
				# tile correspondente
		sub a1, a1, t5 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a1 tem o endere�o de inicio do tile
				# no frame 0. Al�m disso, � necess�rio voltar a1 por t5 colunas para imprimir
				# o tile no lugar certo nessa itera��o
		add a1, a1, t6	# decide a partir do valor de t6 qual o frame onde o tile ser� impresso	
		li a2, 16		# n�mero de colunas de tiles a serem impressas
		li a3, 16		# n�mero de linhas de tiles a serem impressas
		call PRINT_IMG

		# Limpa o tile do corpo do RED
		addi a0, s0, 960	# somando s0 com 960 passa o endere�o de onde o RED est� 
					# para o inicio do tile abaixo dele
		call CALCULAR_ENDERECO_DE_TILE
		
		mv a0, a2 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a2 tem o endere�o da imagem do 
				# tile correspondente
		sub a1, a1, t5 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a1 tem o endere�o de inicio do tile
				# no frame 0. Al�m disso, � necess�rio voltar a1 por t5 colunas para imprimir
				# o tile no lugar certo nessa itera��o
		add a1, a1, t6	# decide a partir do valor de t6 qual o frame onde o tile ser� impresso	
		li a2, 16		# n�mero de colunas de tiles a serem impressas
		li a3, 16		# n�mero de linhas de tiles a serem impressas
		call PRINT_IMG


		# Limpa o tile a direita da cabe�a do RED
		addi a0, s0, 16		# somando s0 com 16 passa o endere�o de onde o RED est� 
					# para o inicio do tile a direita dele
		call CALCULAR_ENDERECO_DE_TILE
		
		mv a0, a2 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a2 tem o endere�o da imagem do 
				# tile correspondente
		sub a1, a1, t5 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a1 tem o endere�o de inicio do tile
				# no frame 0. Al�m disso, � necess�rio voltar a1 por t5 colunas para imprimir
				# o tile no lugar certo nessa itera��o
		add a1, a1, t6	# decide a partir do valor de t6 qual o frame onde o tile ser� impresso	
		li a2, 16		# n�mero de colunas de tiles a serem impressas
		li a3, 16		# n�mero de linhas de tiles a serem impressas
		call PRINT_IMG
		
		# Limpa o tile na diagonal inferior direita da cabe�a do RED
		addi a0, s0, 16		# somando s0 com 16 passa o endere�o de onde o RED est� 
					# para o inicio do tile a direta dele
		addi a0, a0, 960	# somando a0 com 960 passa o endere�o de a0 para o inicio do tile 
					# abaixo dele
		call CALCULAR_ENDERECO_DE_TILE
		
		mv a0, a2 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a2 tem o endere�o da imagem do 
				# tile correspondente
		sub a1, a1, t5 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a1 tem o endere�o de inicio do tile
				# no frame 0. Al�m disso, � necess�rio voltar a1 por t5 colunas para imprimir
				# o tile no lugar certo nessa itera��o
		add a1, a1, t6	# decide a partir do valor de t6 qual o frame onde o tile ser� impresso	
		li a2, 16		# n�mero de colunas de tiles a serem impressas
		li a3, 16		# n�mero de linhas de tiles a serem impressas
		call PRINT_IMG
														
		# Parte (3) -> imprime o sprite do RED
		# O pr�ximo sprite do RED vai ser decidido de acordo com o n�mero da intera��o (t3)
		# de modo que a anima��o siga o seguinte padr�o:
		# RED PARADO -> RED DANDO UM PASSO -> RED PARADO
		
		# a0 vai receber o endere�o da pr�xima imagem do RED dependendo do n�mero da itera��o (t5)	
		la a0, red_direita
		li t0, 14
		bgt t5, t0, PRINT_RED_MOVER_TELA_D
		
		# Se 2 < t5 <= 14 a imagem a ser impressa � a do RED dando um passo, que � decidida a 
		# partir do valor de s8
		la a0, red_direita_passo_direito
							
		beq s8, zero, PROXIMO_RED_MOVER_TELA_D		
			la a0, red_direita_passo_esquerdo
	
		PROXIMO_RED_MOVER_TELA_D:
		
		li t0, 2
		bgt t5, t0, PRINT_RED_MOVER_TELA_D
		la a0, red_direita
		
		PRINT_RED_MOVER_TELA_D:					
		# Agora imprime a imagem do RED no frame
			# a0 tem o endere�o da pr�xima imagem do RED 			
			mv a1, s0		# s0 possui o endere�o do RED no frame 0
			add a1, a1, t6		# decide a partir do valor de t6 qual o frame onde a imagem
						# ser� impressa		
			lw a2, 0(a0)		# numero de colunas de uma imagem do RED
			lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
			addi a0, a0, 8		# pula para onde come�a os pixels no .data	
			call PRINT_IMG	
		
		# Se o RED estiver indo para um tile de grama � preciso imprimir uma pequena anima��o
		# de folhas subindo enquanto ele estiver indo para o tile		
		beq s10, zero, MOVER_TELA_D_PARTE_4
			
			la t0, tiles_grama_animacao	
			addi t0, t0, 8			# pula para onde come�a os pixels no .data
			
			# t2 vai receber a quantidade de pixels que ser� pulada em tiles_grama_animacao para
			# encontrar a imagem certa para imprimir de acordo com a itera��o atual (t5)
			li t2, 0		
			li t1, 11			
			bge t5, t1, MOVER_TELA_D_PRINT_GRAMA
			li t2, 256
			li t1, 6			
			bge t5, t1, MOVER_TELA_D_PRINT_GRAMA	
			li t2, 512
			li t1, 2
			bge t5, t1, MOVER_TELA_D_PRINT_GRAMA
			li t2, 0
									
			MOVER_TELA_D_PRINT_GRAMA:
			add a0, t0, t2		# a0 recebe o endere�o da imagem da grama a ser impressa
			mv a1, s0		# O endere�o onde esse tile ser� impresos onde o RED est�
			addi a1, a1, 959	# (s0), 3 linhas para baixo e uma coluna para a esquerda	
						# (959 = 320 * 3 - 1)
			add a1, a1, t6		# decide a partir do valor de t5 qual o frame onde a imagem
						# ser� impressa	
			sub a1, a1, t5		# a coluna do endere�o tamb�m ser� decidia pelo numero
						# da itera��o atual (t5), no caso da MOVER_TELA_D o endere�o
						# ser� atualizado algumas colunas para tras
			
			li a2, 16		# numero de colunas do tile
			li a3, 16		# numero de linhas do tile
			call PRINT_IMG				
		
		MOVER_TELA_D_PARTE_4:
		
		# Parte (4) -> imprime a pr�xima coluna da subsec��o da �rea 1 pixel para a esquerda
		# O que tem que ser feito � imprimir os tiles dessa coluna de modo que s� v�o ser impressas uma 
		# parte da imagem de cada tile de forma a dar a impress�o de que a coluna voltou 1 pixel e que
		# uma nova parte da �rea est� sendo lentamente revelada
		
		# O procedimento PRINT_IMG tem uma limita��o: ele n�o � capaz de imprimir partes de imagens se
		# essas partes tem um n�mero de colunas diferente da imagem completa, por exemplo: imprimir 
		# uma parte 6 x 15 de uma imagem 10 x 15, para imprimir uma parte de imagem � necess�rio que essa 
		# parte tenha o mesmo n�mero de colunas que a imagem original 				
		# Essa limita��o dificulta essa parte do procedimneto, portanto a abordagem ser� diferente:
		# Para cada 1 dos 20 tiles da coluna ser�o impressas individualmente as 16 linhas do tile
																														
		li t3, 0		# contador para o n�mero de tiles impressos
						
		LOOP_TILES_PROXIMA_AREA_D:
		
		li t4, 0		# contador para o n�mero de linhas de cada tile impressas

		LOOP_LINHAS_PROXIMA_AREA_D:	
					
		# Encontrando a imagem do tile	
		addi t0, s2, 20		# s2 + 20 retorna o endere�o de in�cio da pr�xima coluna da
					# subsec��o de tiles que est� na tela (20 � o tamanho de uma linha de 
					# tiles que � mostrada na tela)
		
		mul t1, s3, t3		# decide qual o tile da coluna que ser� impresso de acordo com 
		add t0, t0, t1		# t3 (n�mero do tile atual)		
		
		lb t0, 0(t0)	# pega o valor do elemento da matriz de tiles apontado por t0
			
		li t1, 256	# t1 recebe 16 * 16 = 256, ou seja, a �rea de um tile							
		mul t0, t0, t1	# t0 (n�mero do tile) * (16 * 16) retorna quantos pixels esse tile est� do 
				# come�o da imagem dos tiles
		
		li t1, 16	# decide qual a linha do tile que ser� impressa de acordo com 
		mul t1, t1, t4	# t4 (n�mero da linha atual do tile)	
		add t0, t0, t1		
												
		# Imprimindo a linha do tile		
		add a0, s4, t0	# a0 recebe o endere�o da linha do tile a ser impresso a partir 
				# de s4 (imagem dos tiles)
		
		li t0, 0xFF000140	# t0 recebe o endere�o do �ltimo pixel da primaira linha do frame 0,
					# ou seja, onde o 1o tile dessa coluna ser� impresso 
						
		sub a1, t0, t5	# a1 recebe o endere�o de onde imprimir o 1o tile dessa coluna 
				# t0 - t5 (n�mero da itera��o atual) retorna quantos pixels � necess�rio voltar
				# para encontrar a coluna certa onde imprimir os tiles para essa itera��o

		li t0, 5120	# 5120 = 320 (tamanho de uma linha do frame) * 16 (altura de um tile)
		mul t0, t0, t3	# o endere�o de a1 vai ser avan�ado por t3 * 5120 pixels de modo que vai apontar
		add a1, a1, t0	# para o endere�o onde o tile dessa itera��o (t3) deve ser impresso

		li t0, 320	# 320 � o tamanho de uma linha do frame
		mul t0, t0, t4	# 320 * t4 vai retornar em quantos pixels a1 precisar ser avan�ado para encontrar
		add a1, a1, t0	# o endere�o onde imprimir a linha atual (t4) do tile (t3)
		
		add a1, a1, t6 	# decide a partir do valor de t6 qual o frame onde a imagem ser� impressa	
		
		mv a2, t5	# o n�mero de colunas a serem impressas = o valor de t5 (itera��o atual)					
		li a3, 1	# numero de linhas a serem impressas
		call PRINT_IMG
	
		addi t4, t4, 1		# incrementando o n�mero de linhas do tile impressas
		li t0, 16
		bne t4, t0, LOOP_LINHAS_PROXIMA_AREA_D		# reinicia o loop se t4 != 16
			
		addi t3, t3, 1		# incrementando o n�mero de tiles impressos
		li t0, 15	
		bne t3, t0, LOOP_TILES_PROXIMA_AREA_D		# reinicia o loop se t3 != 15
		
	
		# Espera alguns milisegundos	
		mv a0, s9			# sleep por s9 ms de acordo com o definido em Pokemon.s
		call SLEEP			# chama o procedimento SLEEP	
		
		call TROCAR_FRAME	# inverte o frame sendo mostrado		
				
		li t0, 0x00100000	# fazendo essa opera��o xor se t4 for 0 ele recebe 0x0010000
		xor t6, t6, t0		# e se for 0x0010000 ele recebe 0, ou seja, com isso � poss�vel
					# trocar entre esses valores
		
		addi t5, t5, 1		# incrementa o n�mero de loops realizados						
		li t0, 16
		bne t5, t0, LOOP_MOVER_TELA_D	# reinicia o loop se t3 != 16
	
																																																																																																															
	addi s2, s2, 1		# atualizando a subsec��o da �rea para uma coluna a frente da atual (s2) 
	
	# Pela maneira que o loop acima � executado na verdade s� s�o feitas 15 itera��es e n�o 16, 
	# portanto, � necess�rio imprimir novamente as imagem da �rea em ambos os frames + o sprite do RED 
	# no frame 0  e 1 para que tudo fique no lugar certo
		
		# Imprimindo a imagem da �rea no frame 0
		mv a0, s2		# endere�o, na matriz de tiles, de onde come�a a imagem a ser impressa
		li a1, 0xFF000000	# a imagem ser� impressa no frame 0
		li a2, 20		# n�mero de colunas de tiles a serem impressas
		li a3, 15		# n�mero de linhas de tiles a serem impressas
		call PRINT_TILES_AREA	
	
		# Imprimindo o sprite do RED no frame 0
		la a0, red_direita	# carrega a imagem do sprite			
		mv a1, s0		# s0 tem a posi��o do RED no frame 0
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		call PRINT_IMG	
	
	call TROCAR_FRAME	# inverte o frame sendo mostrado
				# � necess�rio inverter o frame mais 1 vez para que o frame sendo mostrado
				# seja o 0		
					
		# Imprimindo a imagem da �rea no frame 1
		mv a0, s2		# endere�o, na matriz de tiles, de onde come�a a imagem a ser impressa
		li a1, 0xFF100000	# a imagem ser� impressa no frame 0
		li a2, 20		# n�mero de colunas de tiles a serem impressas
		li a3, 15		# n�mero de linhas de tiles a serem impressas
		call PRINT_TILES_AREA			
		
		# Imprimindo o sprite do RED no frame 1
		la a0, red_direita	# carrega a imagem do sprite			
		mv a1, s0		# s0 tem a posi��o do RED no frame 0
		li t0, 0x00100000
		add a1, a1, t0		# passa o endere�o de a1 para o frame 1
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		call PRINT_IMG					
						
	addi s5, s5, 1		# atualizando o lugar do personagem na matriz de tiles para a pr�xima posi��o

	addi s6, s6, 1		# atualiza o valor de s6 para o proximo endere�o da matriz de movimenta��o 
						
	xori s8, s8, 1		# inverte o valor de s8, ou seja, se o RED deu um passo esquerdo o pr�ximo
				# ser� direito e vice-versa
																	
	FIM_MOVIMENTACAO_D:

	call PRINT_FAIXA_DE_GRAMA	# imprime a faixa de grama sobre o RED caso seja necess�rio  	

	call VERIFICAR_COMBATE		# verifica se o tile para onde o RED se moveu � um tile de grama e
					# se ele vai iniciar um combate																																																																														
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret	

# ====================================================================================================== #									

MUDAR_ORIENTACAO_RED:
	# Procedimento que muda a orienta��o do personagem a depender do argumento, ou seja,
	# imprime o sprite do RED em uma determinada orienta��o.
	# OBS: O procedimento n�o altera o valor de s1, apenas imprime o sprite em uma orienta��o
	# Argumentos:
	# 	 a4 = endere�o base da imagem do RED na orienta��o desejada
	
	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra
			
	# Primeiro � necess�rio "limpar" o antigo sprite do RED dos frames. Isso � feito imprimindo novamente
	# os dois tiles onde o RED est� atrav�s de PRINT_TILES_AREA
		
	# Imprimindo os tiles e limpando a tela no frame 1
		mv a0, s0		# a0 recebe o endere�o de onde o RED est� no frame 0 (s0)
		call CALCULAR_ENDERECO_DE_TILE	# encontra o endere�o do tile onde o RED est� na matriz e o 
						# no frame 0
		
		mv t4, a0	# salva o retorno a0 em t4
		mv t5, a1	# salva o retorno a1 em t5
		
		# o a0 retornado tem o endere�o do tile cnde o RED est�
		li t0, 0x00100000	# o a1 retornado tem o endere�o de inicio do tile a0 no frame 0, ou seja, 
		add a1, a1, t0 		# o endere�o onde os tiles v�o come�ar a ser impressos para a limpeza
					# atrav�s da soma com t0 o endere�o de a1 passa para o frame 1
		li a2, 1	# a limpeza vai ocorrer em 1 coluna
		li a3, 3	# a limpeza vai ocorrer em 3 linhas (2 onde o RED est� e mais 1 de folga)
		call PRINT_TILES_AREA
				
	# Agora imprime a nova imagem do RED no frame 1
		mv a0, a4		# a4 tem o endere�o da imagem a ser impressa
		mv a1, s0		# s0 possui o endere�o do RED no frame 0
		li t0, 0x00100000 	# atrav�s da soma com t0 o endere�o de a1 passa para o frame 1
		add a1, a1, t0		
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		call PRINT_IMG	
				
	call TROCAR_FRAME		# inverte o frame sendo mostrado, ou seja, mostra o frame 1
	
	# Imprimindo os tiles e limpando a tela no frame 0
		mv a0, t4	# t4 tem salvo o endere�o do tile cnde o RED est�
		mv a1, t5	# t5 tem salvo o endere�o de inicio do tile a0 no frame 0, ou seja, o 
				# endere�o onde os tiles v�o come�ar a ser impressos para a limpeza
		li a2, 1	# a limpeza vai ocorrer em 1 coluna
		li a3, 3	# a limpeza vai ocorrer em 3 linhas (2 onde o RED est� e mais 1 de folga)
		call PRINT_TILES_AREA
				
	# Agora imprime a nova imagem do RED no frame 0
		mv a0, a4		# a4 tem o endere�o da imagem a ser impressa
		mv a1, s0		# s0 possui o endere�o do RED no frame 0
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		call PRINT_IMG	
								
	FIM_MUDAR_ORIENTACAO_RED:
	 
	call TROCAR_FRAME		# inverte o frame sendo mostrado, ou seja, mostra o frame 0
	
	call PRINT_FAIXA_DE_GRAMA	# imprime a faixa de grama sobre o RED caso seja necess�rio  
														
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha

	ret
	
# ====================================================================================================== #									

MOVER_PERSONAGEM:
	# Procedimento que realiza uma anima��o de movimenta��o para um personagem.
	# Esse procedimento existe para que possa ser usado tanto para a anima��o do RED quanto do 
	# professor Carvalho, portanto parte do pressuposto de que os sprites tem no m�ximo 2 tiles de tamanho,
	# de modo que executa a aniama��o pixel por pixel, de um tile para o outro.
	# A anima��o sempre segue o padr�o: PERSONAGEM PARADO -> PERSONAGEM DANDO UM PASSO -> PERSONAGEM PARADO.
	# O procedimento funciona imprimindo os sprites do personagem de maneira alternada entres os 
	# frames 0 e 1. Para fazer corretamente a troca entre frames o endere�o de a6 precisa ser do
	# frame 0. Al�m disso, esse procedimento sempre � chamado com o frame 0 sendo msotrado e, apesar
	# das tracas de frames, sempre retorna com o frame 0 na tela.  
	#
	# Argumentos:
	# 	a4 = sprite do personagem parado (qualquer dire��o)
	# 	a5 = sprite do personagem dando um passo (seja esquerdo ou direito para qualquer dire��o)
	# 	a6 = endere�o no frame 0 de onde come�ar a movimenta��o
	# 	a7 = qual a dire��o da movimenta��o, de modo que:
	#		[ 0 ] -> movimenta��o para cima
	#		[ 1 ] -> movimenta��o para a esquerda
	#		[ 2 ] -> movimenta��o para baixo
	#		[ 3 ] -> movimenta��o para a direita
	#
	# Retorno:
	#	a0 = endere�o de a6 atualizado para a nova posi��o de acordo com a movimenta��o feita
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																									
	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, 0(sp)		# empilha ra
	
	li t4, 16		# contador para o n�mero de pixels que o personagem vai se deslocar, ou seja,
				# o n�mero de loops a serem executados abaixo					
	
	li t5, 0x00100000	# t5 ser� usada para fazer a troca entre frames no loop de movimenta��o	
				# O loop abaixo come�a imprimindo os sprites no frame 1 j� que se parte
				# do pressuposto de que o frame 0 � o que est� sendo mostrado
																																							
	LOOP_MOVER_PERSONAGEM:

		# Primeiro � necess�rio "limpar" o antigo sprite do personagem da tela. 
		# Isso � feito imprimindo novamente os tiles onde o personagem est� atrav�s de PRINT_TILES_AREA
 		# A quantidade de tiles a serem limpos depende da orienta��o da movimenta��o (a7) porque em
		# alguns casos durante o personagem fica na intersec��o entre v�rios tiles diferentes
			
		# Abaixo � decidido a quantidade de pixels em que o endere�o de a6 ser� incrementado 
		# ou decrementado (t0), quantidade de tiles para a limpeza da tela (t1 e t2) e endere�o
		# de inicio da limpeza a partir de a6 (t3)
	
		bne a7, zero, MOVER_PERSONAGEM_ESQUERDA
			li t0, -320 	# Caso a7 == 0 a movimenta��o � para cima, ent�o o endere�o de a6 vai ser 
					# decrementado em -320 pixels, ou seja, vai voltar 1 linha
			li t1, 3	# a limpeza vai ocorrer em 3 linhas
			li t2, 1	# a limpeza vai ocorrer em 1 coluna
			li t3, 0	# a limpeza come�a no mesmo endere�o de a6
			j MOVER_PERSONAGEM_PROXIMA_POSICAO
		
		MOVER_PERSONAGEM_ESQUERDA:
		li t0, 1
		bne a7, t0, MOVER_PERSONAGEM_BAIXO
			li t0, -1 	# Caso a7 == 1 a movimenta��o � para a esquerda, ent�o o endere�o de a6 
					# vai ser decrementado em -1 pixel, ou seja, vai voltar 1 coluna
			li t1, 2	# a limpeza vai ocorrer em 2 linhas
			li t2, 3	# a limpeza vai ocorrer em 3 colunas
			li t3, 0	# a limpeza come�a no mesmo endere�o de a6
			j MOVER_PERSONAGEM_PROXIMA_POSICAO

		MOVER_PERSONAGEM_BAIXO:
		li t0, 2
		bne a7, t0, MOVER_PERSONAGEM_DIREITA
			li t0, 320	# Caso a7 == 2 a movimenta��o � para baixo, ent�o o endere�o de a6 
					# vai ser incrementado em 320 pixels, ou seja, vai avan�ar 1 coluna
			li t1, 3	# a limpeza vai ocorrer em 3 linhas
			li t2, 1	# a limpeza vai ocorrer em 1 coluna
			li t3, -5120	# t3 recebe 16 (altura de um tile) * 320 (tamanho de uma linha do frema),
					# ou seja, a limpeza come�a no tile acima de a6
			j MOVER_PERSONAGEM_PROXIMA_POSICAO
		
		MOVER_PERSONAGEM_DIREITA:
		# Caso a7 == 3 a movimenta��o � para a direita, ent�o o endere�o de a6 vai ser incrementado em 
		# 1 pixels a cada itera��o, ou seja, vai avan�ar 1 coluna
			li t0, 1 	# Caso a7 == 3 a movimenta��o � para a direita, ent�o o endere�o de a6 
					# vai ser incrementado em 1 pixels, ou seja, vai avan�ar 1 coluna
			li t1, 2	# a limpeza vai ocorrer em 2 linhas
			li t2, 3	# a limpeza vai ocorrer em 3 colunas
			li t3, -16	# a limpeza come�a no tile anterior a a6

		MOVER_PERSONAGEM_PROXIMA_POSICAO:
		
		# Pela maneira com que o loop � executado o frame 1 sempre est� desatualizado com rela��o ao 
		# frame 0, por isso � melhor executar o loop mais uma vez (t4 == 0) s� que sem atualizar
		# o valor de a6 para que o sprite do personagem seja impresso no frame 1 e os dois frames
		# fiquem iguais	

		beq t4, zero, MOVER_PERSONAGEM_LIMPAR_TELA
			add a6, a6, t0	# incrementa o endere�o de a6 (endere�o onde o sprite do personagem ser� 
			# impresso) para a pr�xima posi��o de acordo com o valor calculado em t0		
		
		MOVER_PERSONAGEM_LIMPAR_TELA:
		# Imprimindo os tiles e limpando a tela 
			add t0, a6, t3		# t0 recebe o endere�o de a6 atualizado com o valor de t3
						# definido acima
		
			mv t3, t2		# salva t2 em t3
			mv a3, t1		# t1 n�mero de linhas de tiles a serem impressas
		
			mv a0, t0			# encontra o endere�o do tile na matriz e o endere�o do
			call CALCULAR_ENDERECO_DE_TILE	# frame onde os tiles ser�o impressos com base no valor 
							# de t0 definido acima
		
			# o a0 retornado tem o endere�o do tile correspondente
			
			mv a2, t3	# t3 tem o n�mero de colunas de tiles a serem impressas
					
			# o a1 tem o endere�o de inicio do tile a0 no frame, ou seja, o 
			# endere�o onde os tiles v�o come�ar a ser impressos
			
			add a1, a1, t5	# decide a partir do valor de t5 qual o frame onde os tiles ser�o
					# impressos
			call PRINT_TILES_AREA
		
		# Determina qual � o pr�ximo sprite do personagem a ser renderizado,
		# de modo que a anima��o siga o seguinte padr�o:
		# PERSONAGEM PARADO -> PERSONAGEM DANDO UM PASSO -> PERSONAGEM PARADO	
			mv a0, a4		# a4 tem a imagem do personagem parado
			li t0, 14		
			bgt t4, t0, MOVER_PERSONAGEM_PRINT_SPRITE
			mv a0, a5		# a5 tem o endere�o da imagem do personagem dando um passo
			li t0, 2
			bgt t4, t0, MOVER_PERSONAGEM_PRINT_SPRITE
			mv a0, a4		# a4 tem a imagem do personagem parado
		
		MOVER_PERSONAGEM_PRINT_SPRITE:																																																																																				
		# Agora imprime a imagem do personagem no frame
			# a0 j� tem o endere�o da pr�xima imagem do personagem 			
			mv a1, a6		# a6 possui o endere�o de onde renderizar o personagem
			add a1, a1, t5		# decide a partir do valor de t5 qual o frame onde a imagem
						# ser� impressa			
			lw a2, 0(a0)		# numero de colunas de uma imagem do personagem
			lw a3, 4(a0)		# numero de linhas de uma imagem do personagem	
			addi a0, a0, 8		# pula para onde come�a os pixels no .data	
			call PRINT_IMG	
		
		# Se o RED estiver indo para um tile de grama � preciso imprimir uma pequena anima��o
		# de folhas subindo enquanto ele estiver indo para o tile		
		beq s10, zero, LOOP_MOVER_PERSONAGEM_PROXIMA_ITERACAO
			la t0, tiles_grama_animacao	
			addi t0, t0, 8			# pula para onde come�a os pixels no .data
			
			# t2 vai receber a quantidade de pixels que ser� pulada em tiles_grama_animacao para
			# encontrar a imagem certa para imprimir de acordo com a itera��o atual (t4)
			li t2, 0		
			li t1, 11			
			bge t4, t1, LOOP_MOVER_PERSONAGEM_PRINT_GRAMA
			li t2, 256
			li t1, 6			
			bge t4, t1, LOOP_MOVER_PERSONAGEM_PRINT_GRAMA			
			li t2, 512
			li t1, 2
			bge t4, t1, LOOP_MOVER_PERSONAGEM_PRINT_GRAMA
			li t2, 0
									
			LOOP_MOVER_PERSONAGEM_PRINT_GRAMA:
			add a0, t0, t2		# a0 recebe o endere�o da imagem da grama a ser impressa
			mv a1, s0		# O endere�o onde esse tile ser� impresos onde o RED est�
			addi a1, a1, 959	# (s0), 3 linhas para baixo e uma coluna para a esquerda	
						# (959 = 320 * 3 - 1)
			add a1, a1, t5		# decide a partir do valor de t5 qual o frame onde a imagem
						# ser� impressa	
			
			li a2, 16		# numero de colunas do tile
			li a3, 16		# numero de linhas do tile
			call PRINT_IMG				
		
		LOOP_MOVER_PERSONAGEM_PROXIMA_ITERACAO:
										
		# Espera alguns milisegundos	
		li a0, 20			# sleep 20 ms
		call SLEEP			# chama o procedimento SLEEP	
			
		call TROCAR_FRAME		# inverte o frame sendo mostrado
		
		li t0, 0x00100000	# com essa opera��o xor se t5 for 0 ele recebe 0x0010000
		xor t5, t5, t0		# e se for 0x0010000 ele recebe 0, ou seja, com isso � poss�vel
					# ficar alternando entre esses valores
					
		addi t4, t4, -1		# decrementa o n�mero de loops restantes			
		bge t4, zero, LOOP_MOVER_PERSONAGEM	# reinicia o loop se t4 >= 0


	call TROCAR_FRAME		# o loop acima sempre termina mostrando o frame 1, portanto
					# � necess�rio trocar mais uma vez o frame		
		
	FIM_MOVER_PERSONAGEM:	
																																																																																																																																																																																																																																																																																									
	call PRINT_FAIXA_DE_GRAMA	# imprime a faixa de grama sobre o RED caso seja necess�rio  
	
	mv a0, a6	# move para a0 o endere�o de a6 atualizado durante o loop acima	
				
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha

	ret
							
# ====================================================================================================== #									

VERIFICAR_MATRIZ_DE_MOVIMENTACAO:
	# Procedimento auxiliar aos procedimentos de movimenta��o acima.
	# Tem como objetivo receber um endere�o de uma matriz de movimenta��o e partir do valor desse
	# elemento decidir quais procedimentos tem quer ser chamados, como procedimentos de transi��o
	# de �rea por exemplo, no fim retorna o controle para o procedimento de movimenta��o que o chamou
	# Em certos casos o ideal � que n�o ocorra uma movimenta��o do personagem, ou que certas a��es aconte�am
	# depois da movimenta��o, por isso tamb�m � retornado a0 com algum valor correpondente a um comando 
	# para os procedimentos de movimenta��o, como explicado abaixo:
	# Argumentos:
	# 	a0 = endere�o de uma posi��o na matriz de movimenta��o
	# 
	# Retorno:
	#	a0 = -1 se os procedimentos de movimenta��o N�O devem acontecer
	#	a0 = 0 se os procedimentos de movimenta��o DEVEM acontecer
	
	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra

	lbu t0, 0(a0)		# le o valor do endere�o da matriz de movimenta��o
	
	# se t0 == -1 ent�o essa posi��o da matriz est� ocupada e a movimenta��o n�o deve ocorrer
	li a0, -1			
	beq t0, zero, FIM_VERIFICAR_MATRIZ_DE_MOVIMENTACAO

	# se t0 == 1 ent�o essa posi��o da matriz est� livre e a movimenta��o deve ocorrer	
	li a0, 0	
	li t1, 1					
	beq t0, t1, FIM_VERIFICAR_MATRIZ_DE_MOVIMENTACAO
	
	# se t0 == 2 ent�o essa posi��o indica um momento da hist�ria, mas especificamente o momento que o RED
	# tenta sair de Pallet pela primeira vez.
	# Nesse caso RENDERIZAR_ANIMACAO_PROF_OAK tem que ser chamado e depois os procedimentos de 
	# movimenta��o n�o devem ocorrer
	
	li t1, 2						
	bne t0, t1, VERIFICAR_MATRIZ_HISTORIA_LAB
		call RENDERIZAR_ANIMACAO_PROF_OAK												
		li a0, -1		# a0 = -1 porque a movimenta��o n�o tem que acontecer	
		j FIM_VERIFICAR_MATRIZ_DE_MOVIMENTACAO
		
	# se t0 == 3 ent�o essa posi��o indica um momento da hist�ria, mas especificamente o momento que o RED
	# entra no laborat�rio pela primeira vez
	# Nesse caso RENDERIZAR_DIALOGO_PROFESSOR_LABORATORIO tem que ser chamado e depois os procedimentos de 
	# movimenta��o n�o devem ocorrer
	
	VERIFICAR_MATRIZ_HISTORIA_LAB:
	
	li t1, 3																		
	bne t0, t1, VERIFICAR_MATRIZ_POKEMON_INICIAL
		call RENDERIZAR_DIALOGO_PROFESSOR_LABORATORIO											
		li a0, -1		# a0 = -1 porque a movimenta��o n�o tem que acontecer	
		j FIM_VERIFICAR_MATRIZ_DE_MOVIMENTACAO	
	
	
	# se 3 < t0 <= 6 ent�o essa posi��o representa uma das mesas com uma pokebola no laboratorio, 
	# indicando a escolha de um pokemon inicial
	# Nesse caso RENDERIZAR_ESCOLHA_DE_POKEMON_INICIAL tem que ser chamado e depois os procedimentos de 
	# movimenta��o n�o devem ocorrer
	
	VERIFICAR_MATRIZ_POKEMON_INICIAL:
	
	li t1, 6																		
	bgt t0, t1, VERIFICAR_MATRIZ_TRANSICAO_ENTRE_AREAS
		addi a5, t0, -4		# move para o argumento a5 o valor da posi��o da matriz em t0 - 5 
					# de modo que o valor de a5 siga o convencionado no procedimento
					# (ver descri��o de RENDERIZAR_ESCOLHA_DE_POKEMON_INICIAL para detalhes)
		call RENDERIZAR_ESCOLHA_DE_POKEMON_INICIAL									
		li a0, -1		# a0 = -1 porque a movimenta��o n�o tem que acontecer	
		j FIM_VERIFICAR_MATRIZ_DE_MOVIMENTACAO	
	
	# se t0 != 7 ent�o essa posi��o representa um tile que n�o � de grama, portanto � necess�rio atualizar
	# o valor de s10 indicando que o RED n�o vai para um tile de grama
	
	VERIFICAR_MATRIZ_TRANSICAO_ENTRE_AREAS:
	# se t0 >= 64 ent�o essa posi��o indica uma transi��o entre �rea, nesse caso RENDERIZAR_AREA tem
	# que ser chamado e depois os procedimentos de movimenta��o devem ocorrer
	
	li t1, 64						
	blt t0, t1, FIM_VERIFICAR_MATRIZ_DE_MOVIMENTACAO
		mv a4, t0		# move para o argumento a4 o valor da posi��o sendo analisada
		call RENDERIZAR_AREA												
		li a0, 0		# a0 = 0 porque a movimenta��o tem que acontecer
																										
	FIM_VERIFICAR_MATRIZ_DE_MOVIMENTACAO:

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha

	ret

# ====================================================================================================== #
	
PRINT_FAIXA_DE_GRAMA:
	# Procedimento que usa o valor de s10 para saber se o RED est� indo para um tile de grama ou n�o
	# Caso ele esteja (s10 != 0) ent�o � imprime uma pequena faixa de grama sobre o sprite do RED nos 
	# frames 0 e 1
		
	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Inicialmente s10 == 0 representando que o RED n�o vai para um tile de grama, caso isso n�o seja 
	# verdade o valor de s10 vai ser atualizado corretamente mais adiante 
	li s10, 0

	# Antes de tudo � conveniente atualizar o valor de s10 indicando se o RED 
	# est� ou n�o em um tile de grama e a partir disso imprimir ou n�o a faixa de grama
	lbu t0, 0(s6)		# s6 � a posicao do RED na matriz de movimenta��o
	li t1, 7		# 7 � o codigo de um tile de grama
	bne t0, t1, FIM_PRINT_FAIXA_DE_GRAMA
		li s10, 1		# indica que o RED est� em um tile de grama
		
		# Imprimindo faixa no frame 0
		la a0, tiles_pallet	# para encontrar a faixa de grama que ser� impressa pode ser usado o
		addi a0, a0, 8		# tilles pallet, partindo do fato de que essa imagem vai estar 
		li t0, 22688		# na linha 1418 (22688 = 1418 * 16 (largura de uma linha de tiles_pallet))
		add a0, a0, t0
		
		mv t3, a0		# salva o endere�o de a0 em t3
		
		mv a1, s0		# O endere�o onde essa faixa ser� impressa � no novo endere�o do
		li t0, 4160		# personagem (s0), 13 linhas para baixo (4160 = 13 * 320) e uma coluna
		add a1, a1, t0		# para a esquerda (-1)
		addi a1, a1, -1
		
		mv t4, a1		# salva o endere�o de a1 em t4
					
		li a2, 16		# numero de colunas da faixa de grama	
		li a3, 6		# numero de linhas da faixa de grama	
		call PRINT_IMG	
		
		# Imprimindo faixa no frame 1
		mv a0, t3		# t3 ainda tem salvo o endere�o da imagem da grama	
			
		li t0, 0x00100000
		add a1, t4, t0 		# passa o endere�o de t4 (onde imprimir a grama) para o frame 1	
						
		li a2, 16		# numero de colunas da faixa de grama	
		li a3, 6		# numero de linhas da faixa de grama	
		call PRINT_IMG			
	
	FIM_PRINT_FAIXA_DE_GRAMA:
			
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha

	ret
																																		

