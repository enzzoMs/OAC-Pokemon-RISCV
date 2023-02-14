.text

# ====================================================================================================== # 
# 						   AREAS				                 #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# Este arquivo possui os procedimentos neces�rios para renderizar as diferentes �reas do jogo, fazendo   #
# as altera��es necess�rias nos registradores salvos s0 - s7						 #
#            												 #	 
# Al�m disso, esse arquivo tamb�m cont�m os procedimentos para realizar as transi��es entre �rea.	 #
# A transi��o entre uma �rea e outra acontece quando o jogador se encontra em uma posi��o especial na	 #
# matriz de movimenta��o de uma �rea.									 #
# O procedimento VERIFICAR_MATRIZ_DE_MOVIMENTACAO vai verificar o valor da pr�xima posi��o do personagem #
# na matriz de movimenta��o, caso o valor dessa posi��o seja maior ou igual a 64 (1_0_000_00 em bin�rio) #
# os procedimentos de transi��o de �rea ser�o chamados.							 #		 #
# A raz�o para esse n�mero � que o valor desses elementos especiais � codificado em bin�rio no seguinte  #
# formato 1_M_AAA_PP, onde:									         #
# 	 1... -> 1 bit fixo que indica que essa posi��o se trata de uma transi��o para outra �rea +  	 #
#	    M -> 1 bit que indica o tipo de mensagem que ser� impressa na tela durante a transi��o (sair #
#		 ou entrar na �rea)									 #
# 	  AAA -> 3 bits identificando a �rea para onde o personagem est� indo +				 #
#	   PP -> 2 bits que indicam por qual ponto de entrada o personagem vai entrar na �rea 		 #
#													 #
# Ent�o cada elemento de transi��o da matriz guarda as informa��es necess�rias para que os procedimentos #
# saibam o que fazer.											 #
# Os poss�veis valores de AAA e YY podem ser encontrados abaixo:					 #
# 	�reas (AAA): 										 	 #
#		Casa do do RED -> 000									 #
#		Pallet -> 010										 #
#		Laborat�rio -> 011									 #
# 													 #
# J� os valores de PP variam dependendo da �rea. Algumas �reas possuem mais de uma maneira de acessa-las #
# A sala do RED, por exemplo, pode ser acessada tanto pelo quarto do RED ou pela porta da frente, nesse  #
# caso PP indica por qual entrada o personagem vai acessar a �rea:					 #
#	Casa do RED:											 #
#		PP = 00 -> Entrada por lugar nenhum (quando o jogo come�a)				 #							 #
#		PP = 01 -> Entrada pela porta da frente							 #
#	Pallet:												 #
#		PP = 00 -> Entrada pela casa do RED							 #
#		PP = 01 -> Entrada pelo laboratorio							 #
#	Laborat�rio:											 #
#		PP = 00 -> Entrada pela porta								 #
#            												 #	 
# ====================================================================================================== #

RENDERIZAR_AREA:
	# Procedimento principal de areas.s, coordena a renderiza��o de �reas e a transi��o entre elas
	# Argumentos:
	# 	a4 = n�mero codificando as informa��es de renderiza��o de �rea, ou seja, um n�mero em que 
	# 	todos os bits s�o 0, exceto o 7 bits menos significativo, que seguem o formato 1_AAA_PP onde 
	# 	AAA � o c�digo da �rea a ser renderizada e PP o ponto de entrada na �rea.
	# 	Para mais explica��es ler texto acima.
	
	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	# Antes de renderizar a pr�xima �rea � necess�rio imprimir uma pequena seta indicando que o jogador
	# est� prester a sair de uma �rea, al�m disso � necess�rio perguntar se o jogador quer mesmo sair
		# A �nica exce��o para esse caso � se a0 = 1_0_000_00, em que a pr�xima �rea � o quarto do RED
		# entrando por lugar nenhum, ou seja, o jogo est� come�ando
		
		li t0, 64	# 64 = 1_0_000_00 em bin�rio
		beq a4, t0, ESCOLHER_PROXIMA_AREA
	
	andi a0, a4, 32		# Preparando o argumento de TRANSICAO_ENTRE_AREAS indicando o tipo de mensagem
				# a se impressa. 
				# Fazendo o AND de a4 com 32, 1000000 em bin�rio, deixa somente o bit 
				# de a4 que deve ser de M intacto, enquanto o restante fica todo 0		
	call TRANSICAO_ENTRE_AREAS
		
	ESCOLHER_PROXIMA_AREA:

	# Agora � necess�rio verificar a �rea a ser renderizada (AAA)
		# Para usar como argumento nos procedimentos de renderiza��o de �reas � necess�rio
		# separar tamb�m o PP (ponto de entrada da �rea)
	
		andi t0, a4, 3		# fazendo o AND de a4 com 3, 011 em bin�rio, deixa somente os dois 
					# primeiros bits de a4 intactos, enquanto o restante fica todo 0
		
		# Agora Separando o campo AAA
			
		andi t1, a4, 0x1C	# fazendo o AND de a0 com 0x1C, 01_1100 em bin�rio, deixa somente os 
					# bits de a4 que devem ser de AAA intactos, enquanto o restante 
					# fica todo 0	
	
		# Agora o procedimento de renderiza��o de �rea adequado ser� chamado de acordo com AAA
		mv a0, t0	# move para a0 o valor de PP para que a0 possa ser usado como 
				# argumento nos procedimentos de renderiza��o de �rea
		
		# se t1 (AAA) = 000 renderiza a casa do RED
		beq t1, zero, RENDERIZAR_CASA_RED
	
		li t0, 8	# 8 ou 010 00 em bin�rio � o c�digo da �rea de Pallet
		# se t1 (AAA) = 010 00 renderiza Pallet
		beq t1, t0, RENDERIZAR_PALLET
		
		li t0, 12	# 12 ou 011 00 em bin�rio � o c�digo da �rea de Pallet
		# se t1 (AAA) = 011 00 renderiza o laboratorio
		beq t1, t0, RENDERIZAR_LABORATORIO

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret

# ====================================================================================================== #

RENDERIZAR_CASA_RED:
	# Procedimento que imprime a imagem da casa do RED e o sprite do RED no frame 0 e no frame 1 de 
	# acordo com o ponto de entrada, al�m de atualizar os registradores salvos
	# Argumentos:
	# 	a0 = indica o ponto de entrada na �rea, ou seja, por onde o RED est� entrando nessa �rea
	#	Para essa �rea os pontos de entrada poss�veis s�o:
	#		PP = 00 -> Entrada por lugar nenhum (quando o jogo come�a)	
	#		PP = 01 -> Entrada pela porta da frente

	# OBS: n�o � necess�rio empilhar o valor de ra pois a chegada a este procedimento � por meio
	# de uma instru��o de branch e a sa�da � pelo ra empilhado por RENDERIZAR_AREA
 	
 	# Primeiro verifica qual o ponto de entrada (PP = a0)		
	bne a0, zero, CASA_RED_PP_PORTA	
		
	# Se a0 == 00 ent�o o ponto de entrada � por lugar nenhum
					
	# Atualizando os registradores salvos para essa �rea
		# Atualizando o valor de s0 (posi��o atual do RED no frame 0)
			li a1, 0xFF000000		# seleciona como argumento o frame 0
			li a2, 65 			# numero da coluna do RED = 65
			li a3, 77			# numero da linha do RED = 77
			call CALCULAR_ENDERECO	
		
			mv s0, a0		# move o endere�o retornado para s0
	
		# Atualizando o valor de s1 (orienta��o do personagem)
			li s1, 2	# inicialmente virado para cima
		
		# Atualizando o valor de s2 (endere�o da subsec��o na matriz de tiles ques est� sendo 
		# mostrada) e s3 (tamanho de uma linha da matriz de tiles)
			la s2, matriz_tiles_casa_red	# carregando em s2 o endere�o da matriz
		
			lw s3, 0(s2)		# s3 recebe o tamanho de uma linha da matriz
		
			addi s2, s2, 8		# pula para onde come�a os pixels no .data
		
			addi s2, s2, 23		# pula para onde come�a a subsec��o que ser� mostrada na tela
						
		# Atualizando o valor de s4 (endere�o da imagem com os tiles da �rea)
			la s4, tiles_casa_red				
			addi s4, s4, 8		# pula para onde come�a os pixels no .data			
		
		# Atualizando o valor de s5 (posi��o atual do personagem na matriz de tiles)						
			la t0, matriz_tiles_casa_red
			addi t0, t0, 8			# pula para onde come�a os pixels no .data
			addi s5, t0, 115		# o RED come�a na linha 5 e coluna 5 da matriz
							# de tiles, ent�o � somado (5 * 22(tamanho de
							# uma linha da matriz)) + 5		
																																												
		# Atualizando o valor de s6 (posi��o atual na matriz de movimenta��o da �rea) e 
		# s7 (tamanho de linha na matriz de movimenta��o)	
		la t0, matriz_movimentacao_casa_red	
		
		lw s7, 0(t0)			# s7 recebe o tamanho de uma linha da matriz da �rea
				
		addi t0, t0, 8
	
		addi s6, t0, 42		# o personagem come�a na linha 3 e coluna 1 da matriz
					# ent�o � somado o endere�o base da matriz (t0) a 
		addi s6, s6, 1		# 3 (n�mero da linha) * 14 (tamanho de uma linha da matriz) 
					# e a 1 (n�mero da coluna) 
											
	# Imprimindo as imagens da �rea e o sprite inicial do RED no frame 0
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 1
											
		# Imprimindo a imagem do quarto do RED no frame 0
		mv a0, s2		# endere�o, na matriz de tiles, de onde come�a a imagem a ser impressa
		li a1, 0xFF000000	# a imagem ser� impressa no frame 0
		li a2, 20		# n�mero de colunas de tiles a serem impressas
		li a3, 15		# n�mero de linhas de tiles a serem impressas
		call PRINT_TILES_AREA				
						
		# Imprimindo a imagem do RED virado para cima no frame 0
		la a0, red_cima		# carrega a imagem				
		mv a1, s0		# s0 tem a posi��o do RED no frame 0
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		call PRINT_IMG	
		
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 0
	# Imprimindo a imagem da �rea no frame 1	
		# Imprimindo a imagem do quarto do RED no frame 1
		mv a0, s2		# endere�o, na matriz de tiles, de onde come�a a imagem a ser impressa
		li a1, 0xFF100000	# a imagem ser� impressa no frame 0
		li a2, 20		# n�mero de colunas de tiles a serem impressas
		li a3, 15		# n�mero de linhas de tiles a serem impressas
		call PRINT_TILES_AREA		
										
		# Imprimindo a imagem do RED virado para cima no frame 0
		
		la a0, red_cima		# carrega a imagem			
			
		mv a1, s0		# s0 tem a posi��o do RED no frame 0
		li t0, 0x00100000	# passando o endere�o de s0 para o seu endere�o correspondente no
		add a1, a1, t0		# frame 1
		
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		call PRINT_IMG	
		
		j FIM_RENDERIZAR_CASA_RED
	
	
	CASA_RED_PP_PORTA:
	# Se a0 == 01 (ou != 0) ent�o o ponto de entrada � pela porta da frente	
	
	# Atualizando os registradores salvos para essa �rea
		# Atualizando o valor de s0 (posi��o atual do RED no frame 0)
			li a1, 0xFF000000		# seleciona como argumento o frame 0
			li a2, 113 			# numero da coluna do RED = 113
			li a3, 173			# numero da linha do RED = 173
			call CALCULAR_ENDERECO	
		
			mv s0, a0		# move o endere�o retornado para s0
	
		# Atualizando o valor de s1 (orienta��o do personagem)
			li s1, 2	# inicialmente virado para cima
		
		# Atualizando o valor de s2 (endere�o da subsec��o na matriz de tiles que est� sendo 
		# mostrada) e s3 (tamanho de uma linha da matriz de tiles)
			la s2, matriz_tiles_casa_red	# carregando em s2 o endere�o da matriz
		
			lw s3, 0(s2)		# s3 recebe o tamanho de uma linha da matriz
		
			addi s2, s2, 8		# pula para onde come�a os pixels no .data
		
			addi s2, s2, 23		# pula para onde come�a a subsec��o que ser� mostrada na tela
						
		# Atualizando o valor de s4 (endere�o da imagem com os tiles da �rea)
			la s4, tiles_casa_red				
			addi s4, s4, 8		# pula para onde come�a os pixels no .data			
		
		# Atualizando o valor de s5 (posi��o atual do personagem na matriz de tiles)						
			la t0, matriz_tiles_casa_red
			addi t0, t0, 8			# pula para onde come�a os pixels no .data
			addi s5, t0, 250		# o RED come�a na linha 11 e coluna 8 da matriz
							# de tiles, ent�o � somado (11 * 22(tamanho de
							# uma linha da matriz)) + 8		
																																												
		# Atualizando o valor de s6 (posi��o atual na matriz de movimenta��o da �rea) e 
		# s7 (tamanho de linha na matriz de movimenta��o)	
		la t0, matriz_movimentacao_casa_red	
		
		lw s7, 0(t0)			# s7 recebe o tamanho de uma linha da matriz da �rea
				
		addi t0, t0, 8
	
		addi s6, t0, 126	# o personagem come�a na linha 9 e coluna 4 da matriz
					# ent�o � somado o endere�o base da matriz (t0) a 
		addi s6, s6, 4		# 9 (n�mero da linha) * 14 (tamanho de uma linha da matriz) 
					# e a 4 (n�mero da coluna) 
											
		# Imprimindo as imagens da �rea no frame 0	
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 1
							
		# Imprimindo a imagem da sala do RED no frame 0
		mv a0, s2		# endere�o, na matriz de tiles, de onde come�a a imagem a ser impressa
		li a1, 0xFF000000	# a imagem ser� impressa no frame 0
		li a2, 20		# n�mero de colunas de tiles a serem impressas
		li a3, 15		# n�mero de linhas de tiles a serem impressas
		call PRINT_TILES_AREA
						
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 0
								
		# Imprimindo a imagem da �rea no frame 1	
		# Imprimindo a imagem da sala do RED no frame 1
		mv a0, s2		# endere�o, na matriz de tiles, de onde come�a a imagem a ser impressa
		li a1, 0xFF100000	# a imagem ser� impressa no frame 0
		li a2, 20		# n�mero de colunas de tiles a serem impressas
		li a3, 15		# n�mero de linhas de tiles a serem impressas
		call PRINT_TILES_AREA																				
						
	FIM_RENDERIZAR_CASA_RED:									
																												
	# Mostra o frame 0		
	li t0, 0xFF200604		# t0 = endere�o para escolher frames 
	sb zero, (t0)			# armazena 0 no endere�o de t0

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret

# ====================================================================================================== #	

RENDERIZAR_PALLET:
	# Procedimento que imprime a imagem de pallet no frame 0 e no frame 1
	# de acordo com o ponto de entrada, al�m de atualizar os registradores salvos
	# Argumentos:
	# 	a0 = indica o ponto de entrada na �rea, ou seja, por onde o RED est� entrando nessa �rea
	#	Para essa �rea os pontos de entrada poss�veis s�o:
	#		PP = 00 -> Entrada pela casa do RED						

	# OBS: n�o � necess�rio empilhar o valor de ra pois a chegada a este procedimento � por meio
	# de uma instru��o de branch e a sa�da � pelo ra empilhado por RENDERIZAR_AREA
	
	# Primeiro verifica qual o ponto de entrada (PP = a0)		
	beq a0, zero, PALLET_PP_CASA_RED		
	# Se a0 == 01 (ou != 0) ent�o o ponto de entrada � pelo laboratorio

	# Atualizando os registradores salvos para essa �rea
		# Atualizando o valor de s0 (posi��o atual do RED no frame 0)
			li a1, 0xFF000000		# seleciona como argumento o frame 0
			li a2, 193 			# numero da coluna do RED = 193
			li a3, 141			# numero da linha do RED = 141
			call CALCULAR_ENDERECO	
		
			mv s0, a0		# move o endere�o retornado para s0
	
		# Atualizando o valor de s1 (orienta��o do personagem)
			li s1, 3	# inicialmente virado para baixo
		
		# Atualizando o valor de s2 (endere�o da subsec��o na matriz de tiles ques est� sendo 
		# mostrada) e s3 (tamanho de uma linha da matriz de tiles)
			la s2, matriz_tiles_pallet	# carregando em s2 o endere�o da matriz
		
			lw s3, 0(s2)		# s3 recebe o tamanho de uma linha da matriz
		
			addi s2, s2, 8		# pula para onde come�a os pixels no .data
		
			addi s2, s2, 1175	# pula para onde come�a a subsec��o que ser� mostrada na tela
						# (5a coluna e 45a linha da matriz de tiles)
						
		# Atualizando o valor de s4 (endere�o da imagem com os tiles da �rea)
			la s4, tiles_pallet				
			addi s4, s4, 8		# pula para onde come�a os pixels no .data			
		
		# Atualizando o valor de s5 (posi��o atual do personagem na matriz de tiles)						
			la t0, matriz_tiles_pallet
			addi t0, t0, 8			# pula para onde come�a os pixels no .data
			addi s5, t0, 1395		# o RED come�a na linha 53 e coluna 17 da matriz
							# de tiles, ent�o � somado (53 * 26(tamanho de
							# uma linha da matriz)) + 17		
																																												
		# Atualizando o valor de s6 (posi��o atual na matriz de movimenta��o da �rea) e 
		# s7 (tamanho de linha na matriz de movimenta��o)	
		la t0, matriz_movimentacao_pallet	
		
		lw s7, 0(t0)			# s7 recebe o tamanho de uma linha da matriz da �rea
				
		addi t0, t0, 8
	
		addi s6, t0, 1272	# o personagem come�a na linha 53 e coluna 16 da matriz
					# ent�o � somado o endere�o base da matriz (t0) a 
		addi s6, s6, 16		# 53 (n�mero da linha) * 24 (tamanho de uma linha da matriz) 
					# e a 16 (n�mero da coluna) 		

		j FIM_RENDERIZAR_PALLET

	PALLET_PP_CASA_RED:
	# Se a0 == 00 ent�o o ponto de entrada � pela casa do RED
		
	# Atualizando os registradores salvos para essa �rea
		# Atualizando o valor de s0 (posi��o atual do RED no frame 0)
			li a1, 0xFF000000		# seleciona como argumento o frame 0
			li a2, 97 			# numero da coluna do RED = 97
			li a3, 109			# numero da linha do RED = 109
			call CALCULAR_ENDERECO	
		
			mv s0, a0		# move o endere�o retornado para s0
	
		# Atualizando o valor de s1 (orienta��o do personagem)
			li s1, 3	# inicialmente virado para baixo
		
		# Atualizando o valor de s2 (endere�o da subsec��o na matriz de tiles ques est� sendo 
		# mostrada) e s3 (tamanho de uma linha da matriz de tiles)
			la s2, matriz_tiles_pallet	# carregando em s2 o endere�o da matriz
		
			lw s3, 0(s2)		# s3 recebe o tamanho de uma linha da matriz
		
			addi s2, s2, 8		# pula para onde come�a os pixels no .data
		
			addi s2, s2, 1067	# pula para onde come�a a subsec��o que ser� mostrada na tela
						# (1a coluna e 41a linha da matriz de tiles)
						
		# Atualizando o valor de s4 (endere�o da imagem com os tiles da �rea)
			la s4, tiles_pallet				
			addi s4, s4, 8		# pula para onde come�a os pixels no .data			
		
		# Atualizando o valor de s5 (posi��o atual do personagem na matriz de tiles)						
			la t0, matriz_tiles_pallet
			addi t0, t0, 8			# pula para onde come�a os pixels no .data
			addi s5, t0, 1229		# o RED come�a na linha 47 e coluna 7 da matriz
							# de tiles, ent�o � somado (47 * 26(tamanho de
							# uma linha da matriz)) + 7		
																																												
		# Atualizando o valor de s6 (posi��o atual na matriz de movimenta��o da �rea) e 
		# s7 (tamanho de linha na matriz de movimenta��o)	
		la t0, matriz_movimentacao_pallet	
		
		lw s7, 0(t0)			# s7 recebe o tamanho de uma linha da matriz da �rea
				
		addi t0, t0, 8
	
		addi s6, t0, 1128	# o personagem come�a na linha 47 e coluna 6 da matriz
					# ent�o � somado o endere�o base da matriz (t0) a 
		addi s6, s6, 6		# 47 (n�mero da linha) * 24 (tamanho de uma linha da matriz) 
					# e a 6 (n�mero da coluna) 		
	
	FIM_RENDERIZAR_PALLET:
																															
	# Imprimindo as imagens da �rea no frame 0	
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 1
							
		# Imprimindo a imagem de pallet no frame 0
		mv a0, s2		# endere�o, na matriz de tiles, de onde come�a a imagem a ser impressa
		li a1, 0xFF000000	# a imagem ser� impressa no frame 0
		li a2, 20		# n�mero de colunas de tiles a serem impressas
		li a3, 15		# n�mero de linhas de tiles a serem impressas
		call PRINT_TILES_AREA				
		
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 0
									
	# Imprimindo a imagem da �rea no frame 1	
		# Imprimindo a imagem de pallet no frame 1
		mv a0, s2		# endere�o, na matriz de tiles, de onde come�a a imagem a ser impressa
		li a1, 0xFF100000	# a imagem ser� impressa no frame 0
		li a2, 20		# n�mero de colunas de tiles a serem impressas
		li a3, 15		# n�mero de linhas de tiles a serem impressas
		call PRINT_TILES_AREA
																				
	# Mostra o frame 0		
	li t0, 0xFF200604		# t0 = endere�o para escolher frames 
	sb zero, (t0)			# armazena 0 no endere�o de t0

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret
		
			
# ====================================================================================================== #

RENDERIZAR_LABORATORIO:
	# Procedimento que imprime a imagem do laboratorio no frame 0 e no frame 1
	# de acordo com o ponto de entrada, al�m de atualizar os registradores salvos
	# Argumentos:
	# 	a0 = indica o ponto de entrada na �rea, ou seja, por onde o RED est� entrando nessa �rea
	#	Para essa �rea os pontos de entrada poss�veis s�o:
	#		PP = 00 -> Entrada pela porta 						

	# OBS: n�o � necess�rio empilhar o valor de ra pois a chegada a este procedimento � por meio
	# de uma instru��o de branch e a sa�da � pelo ra empilhado por RENDERIZAR_AREA
	
	# N�o � nem necess�rio verificar o ponto de entrada por que essa �rea s� tem um (PP = 0) de qualquer forma 	
	
	# Atualizando os registradores salvos para essa �rea
		# Atualizando o valor de s0 (posi��o atual do RED no frame 0)
			li a1, 0xFF000000		# seleciona como argumento o frame 0
			li a2, 145 			# numero da coluna do RED = 145
			li a3, 205			# numero da linha do RED = 205
			call CALCULAR_ENDERECO	
		
			mv s0, a0		# move o endere�o retornado para s0
	
		# Atualizando o valor de s1 (orienta��o do personagem)
			li s1, 2	# inicialmente virado para cima
		
		# Atualizando o valor de s2 (endere�o da subsec��o na matriz de tiles ques est� sendo 
		# mostrada) e s3 (tamanho de uma linha da matriz de tiles)
			la s2, matriz_tiles_laboratorio		# carregando em s2 o endere�o da matriz
		
			lw s3, 0(s2)		# s3 recebe o tamanho de uma linha da matriz
		
			addi s2, s2, 8		# pula para onde come�a os pixels no .data
		
			addi s2, s2, 23		# pula para onde come�a a subsec��o que ser� mostrada na tela
						
		# Atualizando o valor de s4 (endere�o da imagem com os tiles da �rea)
			la s4, tiles_laboratorio			
			addi s4, s4, 8		# pula para onde come�a os pixels no .data			
		
		# Atualizando o valor de s5 (posi��o atual do personagem na matriz de tiles)						
			la t0, matriz_tiles_laboratorio
			addi t0, t0, 8			# pula para onde come�a os pixels no .data
			addi s5, t0, 296		# o RED come�a na linha 13 e coluna 10 da matriz
							# de tiles, ent�o � somado (13 * 22(tamanho de
							# uma linha da matriz)) + 10		
																																												
		# Atualizando o valor de s6 (posi��o atual na matriz de movimenta��o da �rea) e 
		# s7 (tamanho de linha na matriz de movimenta��o)	
		la t0, matriz_movimentacao_laboratorio
		
		lw s7, 0(t0)			# s7 recebe o tamanho de uma linha da matriz da �rea
				
		addi t0, t0, 8
	
		addi s6, t0, 208	# o personagem come�a na linha 13 e coluna 7 da matriz
					# ent�o � somado o endere�o base da matriz (t0) a 
		addi s6, s6, 7		# 13 (n�mero da linha) * 16 (tamanho de uma linha da matriz) 
					# e a 7 (n�mero da coluna) 	
														
	# Imprimindo as imagens da �rea no frame 0
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 1
								
		# Imprimindo a imagem da sala do RED no frame 0
		mv a0, s2		# endere�o, na matriz de tiles, de onde come�a a imagem a ser impressa
		li a1, 0xFF000000	# a imagem ser� impressa no frame 0
		li a2, 20		# n�mero de colunas de tiles a serem impressas
		li a3, 15		# n�mero de linhas de tiles a serem impressas
		call PRINT_TILES_AREA		
				
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 0
									
	# Imprimindo a imagem da �rea no frame 1	
		# Imprimindo a imagem da sala do RED no frame 1
		mv a0, s2		# endere�o, na matriz de tiles, de onde come�a a imagem a ser impressa
		li a1, 0xFF100000	# a imagem ser� impressa no frame 0
		li a2, 20		# n�mero de colunas de tiles a serem impressas
		li a3, 15		# n�mero de linhas de tiles a serem impressas
		call PRINT_TILES_AREA																				
																																																							
	# Mostra o frame 0		
	li t0, 0xFF200604		# t0 = endere�o para escolher frames 
	sb zero, (t0)			# armazena 0 no endere�o de t0

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret

# ====================================================================================================== #
												
TRANSICAO_ENTRE_AREAS:
	# Procedimento que renderiza uma pequena seta para indicar a transi��o entre �rea e pergunta
	# ao jogador se ele deseja sair da �rea atual
	# As setas sempre s�o renderizadas em um tile adjacende ao RED dependendo da sua orienta��o atual
	# e sempre no frame 0
	#
	# Argumentos:
	# 	a0 = n�mero indicando qual o tipo de mensagem deve ser impressa durante a transi��o
	#		a0 = 0 -> mensagem "Sair" da �rea
	#		a0 = 1 -> mensagem "Entrar" na �rea

	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	# Antes � necess�rio imprimir a mensagem indicando qual tecla apertar e a mensagem para sair ou 
	# entrar na �rea
		beq a0, zero, MENSAGEM_SAIR_AREA
		# se a0 != 0 a mensagem a ser impressa � a de entrada na �rea
			la t2, mensagem_entrar_area	# carreaga a imagem
			li a2, 241			# numero da coluna onde a imagem sera impressa
			li a3, 208			# numero da linha onde a imagem sera impressa
			j PRINT_MENSAGEM_TRANSICAO_AREAS
		
		MENSAGEM_SAIR_AREA:
		# se a0 == 0 a mensagem a ser impressa � a de sa�da da �rea
			la t2, mensagem_sair_area	# carreaga a imagem
			li a2, 256			# numero da coluna onde a imagem sera impressa
			li a3, 208			# numero da linha onde a imagem sera impressa
			
		PRINT_MENSAGEM_TRANSICAO_AREAS:
		
		# Essa mensagem sempre fica em uma posi��o fixa no frame 0 que � calculada abaixo
			li a1, 0xFF000000		# seleciona como argumento o frame 0
			# a2 j� tem o numero da coluna 
			# a3 j� tem o numero da linha 
			call CALCULAR_ENDERECO	
		
		mv a1, a0	# move o endere�o retornado para a1
		
		# Imprimindo a mensagem no frame 0				
		mv a0, t2		# t2 tem o endere�o da imagem da mensagem escolhida acima
		# a1 j� tem o endere�o de onde imprimir a mensagem
		lw a2, 0(a0)		# numero de colunas da imagem 
		lw a3, 4(a0)		# numero de linhas da imagem 	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data
		call PRINT_IMG
		
	# O procedimento usa a orienta��o do personagem (s1) para decidir onde e qual seta renderizar 
	
	# Abaixo � decidido o valor de t3 (endere�o no frame 0 de onde colocar o tile da seta) e 
	# t0 (qual a imagem da seta)
	
		bne s1, zero, TRANSICAO_SETA_DIREITA
			# se s1 = 0 o personagem est� virado para a esquerda	
			addi t3, s0, -17	# o endere�o de onde a seta vai estar � o tile a esquerda do RED
						# e uma coluna para a esquerda
			addi t3, t3, 960	# e 3 linhas para baixo (porque s0 tem na verdade o endere�o da 
						# cabe�a do RED)
			la t0, seta_transicao_esquerda	# carregando a imagem em t0
			j RENDERIZAR_SETA_DE_TRANSICAO
	
	TRANSICAO_SETA_DIREITA:
		li t1, 1
		bne s1, t1, TRANSICAO_SETA_CIMA
			# se s1 = 1 o personagem est� virado para a direita
			addi t3, s0, 15	# o endere�o de onde a seta vai estar � o tile a direita do RED
					# e uma coluna para a esquerda			
			addi t3, t3, 960	# e 3 linhas para baixo (porque s0 tem na verdade o endere�o da 
						# cabe�a do RED)	
			la t0, seta_transicao_direita	# carregando a imagem em t0
			j RENDERIZAR_SETA_DE_TRANSICAO
			
	TRANSICAO_SETA_CIMA:
		li t1, 2
		bne s1, t1, TRANSICAO_SETA_BAIXO
			# se s1 = 1 o personagem est� virado para cima	
			li t0, 5120	# 5120 = 320 (tamanho de uma linha do frame) * 16 (altura de um tile)
			sub t3, s0, t0		# o endere�o de onde a seta vai estar � o tile acima do RED
			addi t3, t3, 960	# 3 linhas para baixo (porque s0 tem na verdade o endere�o da 
						# cabe�a do RED)
			addi t3, t3, -1		# e uma coluna para a esquerda			
			la t0, seta_transicao_cima	# carregando a imagem em t0
			j RENDERIZAR_SETA_DE_TRANSICAO
						
	TRANSICAO_SETA_BAIXO:
		li t1, 3
		bne s1, t1, RENDERIZAR_SETA_DE_TRANSICAO
			# se s1 = 3 o personagem est� virado para baixo	
			li t0, 5120	# 5120 = 320 (tamanho de uma linha do frame) * 16 (altura de um tile)
			add t3, s0, t0		# o endere�o de onde a seta vai estar � o tile abaixo do RED
			addi t3, t3, 960	# 3 linhas para baixo (porque s0 tem na verdade o endere�o da 
						# cabe�a do RED)
			addi t3, t3, -1		# e uma coluna para a esquerda									
			la t0, seta_transicao_baixo	# carregando a imagem em t0			
						
						
	RENDERIZAR_SETA_DE_TRANSICAO:

	# As setas que indicam a transi��o de �rea funcionam que nem um tile normal, a diferen�a � que 
	# tem fundo transparentes
	
	# Imprimindo tile da seta no frame 0				
		mv a0, t0	# t0 tem o endere�o da imagem da seta a ser impressa
		addi a0, a0, 8	# pula para onde come�a os pixels no .data
		mv a1, t3	# t3 tem o endere�o de onde imprimir o tile
		li a2, 16	# a2 = numero de colunas de um tile
		li a3, 16	# a3 = numero de linhas de um tile
		call PRINT_IMG

	# Agora o loop abaixo � executado esperando que o jogador aperte F (sair da �rea) ou W,A,S,D 
	LOOP_TRANSICAO_ENTRE_AREAS:
		call VERIFICAR_TECLA
		
		# Se o jogador apertar qualquer tecla de movimento (W, S, A ou D) ent�o ele n�o deseja sair
		# da �rea, e os procedimentos de movimenta��o necess�rios precisam ser chamados.
		# Por�m isso s� vai acontecer se a tecla apertada n�o for a da orienta��o atual do personagem,
		# Por exemplo, se o RED est� virado para a direita ent�o n�o � para checar a tecla D
		
		# Se o personagem est� virado para cima n�o � para checar a tecla W
		li t0, 2
		beq s1, t0, SAIR_DA_AREA_VERIFICAR_A
		li t0, 'w'
		beq a0, t0, NAO_SAIR_DA_AREA
		
		SAIR_DA_AREA_VERIFICAR_A:
		# Se o personagem est� virado para a esquerda n�o � para checar a tecla A
		beq s1, zero, SAIR_DA_AREA_VERIFICAR_S
		li t0, 'a'
		beq a0, t0, NAO_SAIR_DA_AREA
		
		SAIR_DA_AREA_VERIFICAR_S:
		# Se o personagem est� virado para baixo n�o � para checar a tecla S
		li t0, 3
		beq s1, t0, SAIR_DA_AREA_VERIFICAR_D				
		li t0, 's'
		beq a0, t0, NAO_SAIR_DA_AREA
		
		SAIR_DA_AREA_VERIFICAR_D:		
		# Se o personagem est� virado para a direita n�o � para checar a tecla D
		li t0, 1
		beq s1, t0, SAIR_DA_AREA_VERIFICAR_F		
		li t0, 'd'
		beq a0, t0, NAO_SAIR_DA_AREA
		
		SAIR_DA_AREA_VERIFICAR_F:
		# se o jogador apertou 'f' ele deseja sair da �rea, ent�o o procedimento retorna
		# para RENDERIZAR_AREA
		li t0, 'f'
		bne a0, t0, LOOP_TRANSICAO_ENTRE_AREAS
	
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret
	
	NAO_SAIR_DA_AREA:
	
	# Se o jogador n�o deseja sair da �rea � necess�rio retirar a imagem da seta, retirar a mensagem
	# de transi��o de �rea e chamar o procedimento de movimenta��o adequado
	
	mv t5, a0	# salva a0 (tecla apertada) em t5
		
	# Limpando o tile onde est� a seta de transi��o no frame 0
		mv a0, t3	# dos c�lculos acima t3 ainda tem o endere�o no frame 0 onde a seta foi impressa
		call CALCULAR_ENDERECO_DE_TILE	# encontra o endere�o do tile onde a seta foi impressa 
						# e o endere�o no frame 0 
					
		# o a0 retornado tem o endere�o do tile cnde a seta est�
		# o a1 retornado tem o endere�o de inicio do tile a0 no frame 0
		li a2, 1	# a limpeza vai ocorrer em 1 coluna
		li a3, 1	# a limpeza vai ocorrer em 1 linha 
		call PRINT_TILES_AREA
	
	# Limpando mensagem de transi��o de �rea
		# Para isso � necess�rio limpar 10 tiles em 2 linhas, eles sempre s�o os mesmos independente 
		# da �rea. O endere�o do primeiro deles est� na 13a linha e 15a coluna de tiles a partir de s2
		
		# Calcula o endere�o de onde a mensagem est�
		li a1, 0xFF000000		# seleciona como argumento o frame 0
		li a2, 240			# numero da coluna 
		li a3, 208			# numero da linha
		call CALCULAR_ENDERECO	
		
		mv a1, a0		# move o endere�o retornado para a1
		
		li t0, 13		# t0 recebe 13 * s3 (tamanho de uma linha da matriz de tiles), ou
		mul t0, t0, s3		# seja, o tamanho de 16 linhas na matriz de tiles
		addi t0, t0, 15		# move t0 por mais 15 colunas
		add a0, s2, t0		# a0 tem o endere�o do 1o tile a ser limpo
		
		# Imprime novamente os tiles da �rea no lugar da mensagem
	 	# a0 j� tem o endere�o, na matriz de tiles, de onde come�am os tiles a serem impressos
		# a1 j� tem o endere�o onde os tiles v�o come�ar a ser impressos
		li a2, 5		# n�mero de linhas de tiles a serem impressas
		li a3, 2		# n�mero de linhas de tiles a serem impressas
		call PRINT_TILES_AREA						
																						
	# Agora � preciso chamar o procedimento de movimenta��o adequado para a tecla apertada pelo jogador
	
	# Antes � preciso remover os valores de ra que foram empilhados at� aqui
	addi sp, sp, 12		# remove 3 words da pilha, os valores de ra empilhados em 
				# TRANSICAO_ENTRE_AREAS, RENDERIZAR_AREA e VERIFICAR_MATRIZ_DE_MOVIMENTACAO

	# Detalhe que ainda sobrou um valor de ra na pilha, o que veio do procedimento de movimenta��o
	# que chamou VERIFICAR_MATRIZ_DE_MOVIMENTACAO, mas como a chamada abaixo pula para o meio de 
	# VERIFICAR_TECLA_MOVIMENTACAO � esse valor de ra que ser� usado para voltar para o LOOP_PRINCIPAL_JOGO
	 
	mv a0, t5	# t5 ainda tem a tecla que foi apertada pelo jogador, el� sera usada em a0 para
			# escolher o procedimento de movimenta��o
	j ESCOLHER_PROCEDIMENTO_DE_MOVIMENTACAO
			
# ====================================================================================================== #	
																																			
.data
	.include "../Imagens/areas/casa_red/tiles_casa_red.data"
	.include "../Imagens/areas/casa_red/matriz_tiles_casa_red.data"
	.include "../Imagens/areas/casa_red/matriz_movimentacao_casa_red.data"
	.include "../Imagens/areas/pallet/tiles_pallet.data"
	.include "../Imagens/areas/pallet/matriz_tiles_pallet.data"
	.include "../Imagens/areas/pallet/matriz_movimentacao_pallet.data"
	.include "../Imagens/areas/laboratorio/tiles_laboratorio.data"
	.include "../Imagens/areas/laboratorio/matriz_tiles_laboratorio.data"
	.include "../Imagens/areas/laboratorio/matriz_movimentacao_laboratorio.data"
	
	.include "../Imagens/areas/transicao_de_areas/seta_transicao_cima.data"
	.include "../Imagens/areas/transicao_de_areas/seta_transicao_baixo.data"
	.include "../Imagens/areas/transicao_de_areas/seta_transicao_esquerda.data"
	.include "../Imagens/areas/transicao_de_areas/seta_transicao_direita.data"
	.include "../Imagens/areas/transicao_de_areas/mensagem_sair_area.data"
	.include "../Imagens/areas/transicao_de_areas/mensagem_entrar_area.data"						
