.text

# ====================================================================================================== # 
# 					PROCEDIMENTOS AUXILIARES				         #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# Este arquivo cont�m uma cole��o de procedimentos auxiliares com o objetivo de facilitar a execu��o de  # 
# certas tarefas ao longo da execu��o do programa.							 #
#													 #
# ====================================================================================================== #

PRINT_IMG:
	# Procedimento que imprime imagens de tamanho variado, menores que 320 x 240, no frame de escolha.
	# Esse procedimento tamb�m � equipado para lidar com imagens que cont�m pixels de cor transparente
	# (0xC7), nesse caso PRINT_IMG vai verificar se algum pixel tem essa cor, e os que tiverem n�o
	# ser�o renderizados na tela. Isso precisa ser feito ao inv�s de simplesmente renderizar os
	# os pixels transparentes por conta de alguns bugs visuais, sobretudo no RARS. 
	# Geralmente esse procedimento � usado para imprimir imagens pequenas, cosias muito grandes s�o
	# divididas e impressas com o PRINT_TILES
	#
	# Argumentos: 
	# 	a0 = endere�o da imagem		
	# 	a1 = endere�o de onde, no frame escolhido, a imagem deve ser renderizada
	# 	a2 = numero de colunas da imagem
	#	a3 = numero de linhas da imagem
	
	li t0, 0xC7		# t0 tem o valor da cor de um pixel transparente
	
	PRINT_IMG_LINHAS:
		mv t1, a2		# copia do numero de a2 para usar no loop de colunas
			
		PRINT_IMG_COLUNAS:
			lbu t2, 0(a0)			# pega 1 pixel do .data e coloca em t2
			
			# Se o valor do pixel do .data (t2) for 0xC7 (pixel transparente), 
			# o pixel n�o � armazenado no bitmap, e por consequ�ncia n�o � renderizado na tela
			beq t2, t0, NAO_ARMAZENAR_PIXEL
				sb t2, 0(a1)			# pega o pixel de t2 e coloca no bitmap
	
			NAO_ARMAZENAR_PIXEL:
			addi t1, t1, -1			# decrementa o numero de colunas restantes
			addi a0, a0, 1			# vai para o pr�ximo pixel da imagem
			addi a1, a1, 1			# vai para o pr�ximo pixel do bitmap
			bne t1, zero, PRINT_IMG_COLUNAS	# reinicia o loop se t1 != 0
			
		addi a3, a3, -1			# decrementando o numero de linhas restantes
		
		sub a1, a1, a2			# volta o ende�o do bitmap pelo numero de colunas impressas
		addi a1, a1, 320		# passa o endere�o do bitmap para a proxima linha
		
		bne a3, zero, PRINT_IMG_LINHAS	# reinicia o loop se a3 != 0
			
	ret

# ====================================================================================================== #

PRINT_IMG_INVERTIDA:
	# Mesma coisa que o PRINT_IMG, exceto que imprime a imagem de maneira espelhada
	#
	# Argumentos: 
	# 	a0 = endere�o da imagem		
	# 	a1 = endere�o de onde, no frame escolhido, a imagem deve ser renderizada
	# 	a2 = numero de colunas da imagem
	#	a3 = numero de linhas da imagem

	add a0, a0, a2		# como a imagem deve ser impressa de forma invertida ent�o o endere�o
				# de a0 deve estar no final da primeira linha	
	addi a0, a0, -1		# tamb�m � necessario voltar o endere�o por 1 coluna (por motivos desconhecidos)	
				
	li t0, 0xC7		# t0 tem o valor da cor de um pixel transparente
	
	PRINT_IMG_INVERTIDA_LINHAS:
		mv t1, a2		# copia do numero de a2 para usar no loop de colunas
			
		PRINT_IMG_INVERTIDA_COLUNAS:
			lbu t2, 0(a0)			# pega 1 pixel do .data e coloca em t2
			
			# Se o valor do pixel do .data (t2) for 0xC7 (pixel transparente), 
			# o pixel n�o � armazenado no bitmap, e por consequ�ncia n�o � renderizado na tela
			beq t2, t0, NAO_ARMAZENAR_PIXEL_IMG_INVERTIDA
				sb t2, 0(a1)			# pega o pixel de t2 e coloca no bitmap
	
			NAO_ARMAZENAR_PIXEL_IMG_INVERTIDA:
			addi t1, t1, -1			# decrementa o numero de colunas restantes
			addi a0, a0, -1			# vai para o pr�ximo pixel anterior da imagem
			addi a1, a1, 1			# vai para o pr�ximo pixel do bitmap
			bne t1, zero, PRINT_IMG_INVERTIDA_COLUNAS	# reinicia o loop se t1 != 0
			
		addi a3, a3, -1			# decrementando o numero de linhas restantes

		add a0, a0, a2		# como a imagem deve ser impressa de forma invertida ent�o o endere�o
		add a0, a0, a2		# deve estar no final da proxima linha a ser impressa,
					# o que requer soma a2 duas vezes

		sub a1, a1, a2			# volta o ende�o do bitmap pelo numero de colunas impressas
		addi a1, a1, 320		# passa o endere�o do bitmap para a proxima linha
		
		bne a3, zero, PRINT_IMG_INVERTIDA_LINHAS	# reinicia o loop se a3 != 0
			
	ret
	
# ====================================================================================================== #
			
PRINT_TILES_AREA:
	# Procedimento auxiliar que tem por objetivo usar uma matriz de tiles para imprimir uma imagem
	# de uma �rea 
	# As imagens podem ter tamanho variado, sempre medido pelo numero de tiles impressos
	# Cada �rea do jogo � dividida em quadrados de 16 x 16, cada um desses quadrados �nicos configura 
	# um tile diferente. Esses tiles s�o organizados em uma imagem pr�pria de modo que cada 
	# tile fica um em baixo do outro (ver "../Imagens/areas/tiles_casa_red.bmp" para um exemplo).
	# Cada tile recebe um n�mero diferente que representa a posi��o do tile nessa imagem, 
	# dessa forma, as imagens das �reas podem simplesmente ser codificadas como uma matriz
	# em que cada elemento representa o n�mero de um tile, com isso, renderizar a imagem de uma
	# �rea se trata apenas de analisar a matriz e encontrar os tiles correspondentes.
	# Como cada tile tem 16 x 16 eles recebem n�meros de modo que o tile na posi��o 1
	# est� a (16 * 16) * 1 pixels do �nicio da imagem, o tile na posi��o 5 est� a 
	# (16 * 16) * 5 pixels do incio, e assim por diante, facilitando o processo de "traduzir" os n�meros
	# da matriz para o tile correspondente 
	# O procedimento sempre parte do pressuposto que a matriz de tiles que est� sendo passada
	# no argumento a5 � a mesma matriz que est� em s2, e portanto, o procedimento usa o valor de s3
	# Al�m disso, � esperado que a matriz fa�a refer�ncia aos tiles que est�o na imagem de 
	# s4 (endere�o base da imagem contendo os tiles da �rea atual)
	# Obs: ver a descri��o de PRINT_TILES para a diferen�a entre os dois procedimentos
	# 
	# Argumentos:
	# 	a0 = endere�o, na matriz de tiles, de onde come�am os tiles a serem impressos
	#	a1 = endere�o no frame 0 ou 1 de onde os tiles v�o come�ar a ser impressos
	# 	a2 = n�mero de colunas de tiles a serem impressas
	# 	a3 = n�mero de linhas de tiles a serem impressas
																	
	# o loop abaixo vai imprimir a6 x a7 tiles
																														
	PRINT_TILES_AREA_LINHAS:
		mv t0, a2		# copia de a2 para usar no loop de colunas
				
		PRINT_TILES_AREA_COLUNAS:
			lb t1, 0(a0)	# pega 1 elemento da matriz de tiles e coloca em t1
		
			li t2, 256	# t2 recebe 16 * 16 = 256, ou seja, a �rea de um tile							
			mul t1, t1, t2	# como dito na descri��o do procedimento t1 (n�mero do tile) * (16 * 16)
					# retorna quantos pixels esse tile est� do come�o da imagem
			
			add t1, t1, s4	# t1 recebe o endere�o do tile a ser impresso
						
			# O modo de impressao se baseia em um loop que emula um PRINT_IMG, a diferen�a � que
			# como PRINT_IMG pode imprimir imagens com uma tamanho arbitr�rio de colunas e linhas 
			# ele tem que utlizar instru��es load e store byte, mas como cada tile sempre tem 
			# 16 x 16 de tamanho � poss�vel usar load e store word para agilizar o processo
		
			li t2, 256	# numero de pixels de um tile (16 x 16)
			
			PRINT_TILE_AREA_COLUNAS:
			lw t3, 0(t1)		# pega 4 pixels do .data do tile (t1) e coloca em t3
			
			sw t3, 0(a1)		# pega os 4 pixels de t3 e coloca no bitmap
	
			addi t1, t1, 4		# vai para os pr�ximos pixels da imagem
			addi a1, a1, 4		# vai para os pr�ximos pixels do bitmap
			addi t2, t2, -4		# decrementa o numero de pixels restantes
			
			li t3, 16		# largura de um tile
			rem t3, t2, t3		# se o resto de t2 / 16 n�o for 0 ent�o ainda restam pixels
						# da linha atual para serem impressos
			bne t3, zero, PRINT_TILE_AREA_COLUNAS	# reinicia o loop se t3 != 0
			
			addi a1, a1, -16	# volta o ende�o do bitmap pelo numero de colunas impressas
			addi a1, a1, 320	# passa o endere�o do bitmap para a proxima linha
			bne t2, zero, PRINT_TILE_AREA_COLUNAS	# reinicia o loop se t2 != 0
	
			addi a0, a0, 1		# vai para o pr�ximo elemento da matriz de tiles
			
			li t1, 5120		# t1 recebe 16 (altura de um tile) * 320 
						# (tamanho de uma linha do frame)
			sub a1, a1, t1		# volta o endere�o de a5 pelas linhas impressas			
			addi a1, a1, 16		# pula 16 colunas no bitmap j� que o tile impresso tem
						# 16 colunas de tamanho 
			
			addi t0, t0, -1			# decrementando o numero de colunas de tiles restantes
			bne t0, zero, PRINT_TILES_AREA_COLUNAS	# reinicia o loop se t0 != 0
			
		sub a0, a0, a2		# volta o ende�o da matriz de tiles pelo numero de colunas impressas
		add a0, a0, s3		# passa o endere�o da matriz para a proxima linha (s3 tem o tamanho
					# de uma linha na matriz)
	
		li t1, 16		# t1 recebe a largura de um tile
		mul t1, t1, a2		# 16 * a2 retorna o numero de pixels em a1 foi incrementado no loop acima
		sub a1, a1, t1		# volta a1 pelo numero de colunas de tiles impressas

		li t1, 5120		# t1 recebe 16 (altura de um tile) * 320 (tamanho de uma linha do frame)
		add a1, a1, t1		# avan�a o endere�o de a5 para a proxima linha de tiles		
			
		addi a3, a3, -1				# decrementando o numero de linhas restantes
		bne a3, zero, PRINT_TILES_AREA_LINHAS	# reinicia o loop se a3 != 0
				
	ret

# ====================================================================================================== #	
	
PRINT_TILES:
	# Procedimento que tem por objetivo usar uma matriz de tiles para imprimir uma imagem arbitr�ria
	# Esse procedimento segue os mesmos principios do PRINT_TILES_AREA, utilizando as matrizes e fazendo 
	# a impess�o dos tiles da mesma forma. A diferen�a entre um e outro n�o � que PRINT_TILES_AREA � 
	# exatamente exclusivo para a impress�o de �reas (esse PRINT_TILES tamb�m pode imprimir imagens
	# de uma �rea se quiser), mas sim o n�mero de registradores utilizados entre um e outro. PRINT_TILES_AREA
	# � usado nos procedimentos de movimenta��o, como existem muitos procedimentos encadeados o resultado
	# � que de um jeito ou de outro todos os registradores (inclusive os de argumentos) s�o usados. Como
	# a movimenta��o s� reimprime imagens da �rea ent�o PRINT_TILES_AREA usa esse fato para fazer alguns
	# pressupostos (que a matriz passada no argumento faz refer�ncia aos tiles que est�o na imagem de s4, 
	# por exemplo) para reduzir o n�mero de registradores usados. Mas esses pressupostos fazem com que
	# n�o d� para usar o PRINT_TILES_AREA para imprimir uma matriz de tiles que n�o seja a da �rea atual
	# (s2), ent�o esse PRINT_TILES supre essa necessidade, podendo receber uma matriz de tiles diferente
	# para a impress�o.
	# Infelizmente esse procedimento tamb�m tem que fazer alguma suposi��o para usar menos registradores,
	# nesse caso ele sup�e que todos os tiles de a0 ser�o impressos, ou seja, o numero de linhas e colunas
	# de tiles � o que est� especificado no .data mesmo. 
	# 
	# Argumentos:
	# 	a0 = endere�o base da matriz de tiles com os tiles a serem impressos
	# 	a1 = endere�o base com as imagens dos tiles que a matriz em a0 faz refer�ncia
	#	a2 = endere�o no frame 0 ou 1 de onde os tiles v�o come�ar a ser impressos

	lw t0, 4(a0)	# t0 recebe a altura da matriz, ou seja, o numero de linhas de tiles a serem impressas
	lw t1, 0(a0)	# t1 recebe a largura da matriz, ou seja, o numero de colunas de tiles a serem impressas
			# a cada linha de t0
	
	addi a0, a0, 8				# pula para onde come�a os pixels no .data
	addi a1, a1, 8				# pula para onde come�a os pixels no .data
		
	PRINT_TILES_LINHAS:
		mv t2, t1		# copia de t1 para usar no loop de colunas
				
		PRINT_TILES_COLUNAS:
			lb t3, 0(a0)	# pega 1 elemento da matriz de tiles e coloca em t3
		
			li t4, 256	# t4 recebe 16 * 16 = 256, ou seja, a �rea de um tile							
			mul t3, t4, t3	# como dito na descri��o do procedimento t3 (n�mero do tile) * (16 * 16)
					# retorna quantos pixels esse tile est� do come�o da imagem
			
			add t3, t3, a1	# t3 recebe o endere�o do tile a ser impresso
	
			# O loop abaixo emula um PRINT_IMG, a diferen�a � que como PRINT_IMG pode imprimir
			# imagens com uma tamanho arbitr�rio de colunas e linhas ele tem que utlizar instru��es
			# load e store byte, mas como cada tile sempre tem 16 x 16 de tamanho � poss�vel usar
			# load e store word para agilizar o processo
			
			li t4, 256	# numero de pixels de um tile (16 x 16)
			
			PRINT_TILE_COLUNAS:
			lw t5, 0(t3)		# pega 4 pixels do .data do tile (t3) e coloca em t5
			
			sw t5, 0(a2)		# pega os 4 pixels de t5 e coloca no bitmap
	
			addi t3, t3, 4		# vai para os pr�ximos pixels da imagem
			addi a2, a2, 4		# vai para os pr�ximos pixels do bitmap
			addi t4, t4, -4		# decrementa o numero de pixels restantes
			
			li t5, 16		# largura de um tile
			rem t5, t4, t5		# se o resto de t4 / 16 n�o for 0 ent�o ainda restam pixels
						# da linha atual para serem impressos
			bne t5, zero, PRINT_TILE_COLUNAS	# reinicia o loop se t5 != 0
			
			addi a2, a2, -16	# volta o ende�o do bitmap pelo numero de colunas impressas
			addi a2, a2, 320	# passa o endere�o do bitmap para a proxima linha
			bne t4, zero, PRINT_TILE_COLUNAS	# reinicia o loop se t4 != 0
	
			addi a0, a0, 1		# vai para o pr�ximo elemento da matriz de tiles
			
			li t3, 5120		# t3 recebe 16 (altura de um tile) * 320 
						# (tamanho de uma linha do frame)
			sub a2, a2, t3		# volta o endere�o de a2 pelas linhas impressas			
			addi a2, a2, 16		# pula 16 colunas no bitmap j� que o tile impresso tem
						# 16 colunas de tamanho 
			
			addi t2, t2, -1			# decrementando o numero de colunas de tiles restantes
			bne t2, zero, PRINT_TILES_COLUNAS	# reinicia o loop se t2 != 0
			
		li t2, 16		# t2 recebe a largura de um tile
		mul t2, t2, t1		# 16 * t1 retorna o numero de pixels em a2 foi incrementado no loop acima
		sub a2, a2, t2		# volta a2 pelo numero de colunas de tiles impressas

		li t2, 5120		# t2 recebe 16 (altura de um tile) * 320 (tamanho de uma linha do frame)
		add a2, a2, t2		# avan�a o endere�o de a2 para a proxima linha de tiles		
			
		addi t0, t0, -1				# decrementando o numero de linhas restantes
		bne t0, zero, PRINT_TILES_LINHAS	# reinicia o loop se t0 != 0
				
	ret

		
# ====================================================================================================== #
			
REIMPRIMIR_RED_E_AREA:
	# Procedimento que renderiza novamente os tiles da �rea atual (seguindo o apontado por s2) e o
	# sprite do RED com a orienta��o correta (seguindo s1) em ambos os frames
	# Para funcionar � necess�rio garantir que os dois frame est�o identicos antes de chamar esse 
	# procedimento
	
	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra	
	
	call TROCAR_FRAME		# inverte o frame, mostrando o frame 1

	# Escolhe a imagem do RED de acordo com s1 (orienta��o)
		la t4, red_esquerda				
		beq s1, zero, INICIO_REIMPRIMIR_RED_E_AREA
		la t4, red_direita	
		li t0, 1				
		beq s1, t0, INICIO_REIMPRIMIR_RED_E_AREA
		la t4, red_cima	
		li t0, 2				
		beq s1, t0, INICIO_REIMPRIMIR_RED_E_AREA
		la t4, red_baixo
	
	INICIO_REIMPRIMIR_RED_E_AREA:				
	# Imprimindo as imagens da �rea e o sprite do RED no frame 0					
		# Imprimindo a imagem do quarto do RED no frame 0
		mv a0, s2		# endere�o, na matriz de tiles, de onde come�a a imagem a ser impressa
		li a1, 0xFF000000	# a imagem ser� impressa no frame 0
		li a2, 20		# n�mero de colunas de tiles a serem impressas
		li a3, 15		# n�mero de linhas de tiles a serem impressas
		call PRINT_TILES_AREA				
						
		# Imprimindo a imagem do RED no frame 0
		mv a0, t4		# t4 tem a imagem do RED na orienta��o correta 				
		mv a1, s0		# s0 tem a posi��o do RED no frame 0
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		call PRINT_IMG	
	
		# Verifica se o RED est� em um tile de grama e imprime a faixa caso necessario
		lbu t0, 0(s6)		# s6 � a posicao do RED na matriz de movimenta��o
		li t1, 7		# 7 � o codigo de um tile de grama
		bne t0, t1, REIMPRIMIR_RED_E_AREA_FRAME_1
		
		# Imprimindo faixa no frame 0
		la a0, tiles_pallet	# para encontrar a faixa de grama que ser� impressa pode ser usado o
		addi a0, a0, 8		# tilles pallet, partindo do fato de que essa imagem vai estar 
		li t0, 22688		# na linha 1418 (22688 = 1418 * 16 (largura de uma linha de tiles_pallet))
		add a0, a0, t0
		
		mv t5, a0		# salva o endere�o de a0 em t5
		
		mv a1, s0		# O endere�o onde essa faixa ser� impressa � no novo endere�o do
		li t0, 4160		# personagem (s0), 13 linhas para baixo (4160 = 13 * 320) e uma coluna
		add a1, a1, t0		# para a esquerda (-1)
		addi a1, a1, -1
		
		mv t6, a1		# salva o endere�o de a1 em t6
					
		li a2, 16		# numero de colunas da faixa de grama	
		li a3, 6		# numero de linhas da faixa de grama	
		call PRINT_IMG	

	REIMPRIMIR_RED_E_AREA_FRAME_1:		
	call TROCAR_FRAME		# inverte o frame, mostrando o frame 0
		
	# Imprimindo a imagem da �rea no frame 1	
		# Imprimindo a imagem do quarto do RED no frame 1
		mv a0, s2		# endere�o, na matriz de tiles, de onde come�a a imagem a ser impressa
		li a1, 0xFF100000	# a imagem ser� impressa no frame 0
		li a2, 20		# n�mero de colunas de tiles a serem impressas
		li a3, 15		# n�mero de linhas de tiles a serem impressas
		call PRINT_TILES_AREA		
										
		# Imprimindo a imagem do RED no frame 0
		
		mv a0, t4		# t4 tem a imagem do RED na orienta��o correta 				
			
		mv a1, s0		# s0 tem a posi��o do RED no frame 0
		li t0, 0x00100000	# passando o endere�o de s0 para o seu endere�o correspondente no
		add a1, a1, t0		# frame 1
		
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		call PRINT_IMG	
	
		# Verifica se o RED est� em um tile de grama e imprime a faixa caso necessario
		lbu t0, 0(s6)		# s6 � a posicao do RED na matriz de movimenta��o
		li t1, 7		# 7 � o codigo de um tile de grama
		bne t0, t1, FIM_REIMPRIMIR_RED_E_AREA
		
		# Imprimindo faixa no frame 1
		mv a0, t5		# t5 ainda tem salvo o endere�o da imagem da grama	
			
		li t0, 0x00100000
		add a1, t6, t0 		# passa o endere�o de t6 (onde imprimir a grama) para o frame 1	
						
		li a2, 16		# numero de colunas da faixa de grama	
		li a3, 6		# numero de linhas da faixa de grama	
		call PRINT_IMG	
						
	FIM_REIMPRIMIR_RED_E_AREA:			
	
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
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

CALCULAR_ENDERECO_DE_TILE:
	# Procedimento que recebe um endere�o no frame 0 ou 1 e descobre qual � o endere�o do tile 
	# correspondente na subsec��o da matriz de tiles que est� na tela (s2), retornando tamb�m o
	# endere�o de inicio desse tile no frame e o endere�o da imagem correspondente a esse tile
	#
	# Argumentos:
	#	a0 = um endere�o no frame 0 ou 1
	#
	# Retorno:
	#	a0 = endere�o do tile correspondente a partir de s2
	#	a1 = endere�o de inicio do tile no frame
	# 	a2 = endere�o da imagem correspondente a esse tile com base em s4
	
	# Primeiro descobre se o endere�o de a0 est� no frame 0 ou 1 para que o endere�o de a1 j� esteja
	# no frame certo
	
	li a1, 0xFF100000
	bge a0, a1, INICIO_CALCULAR_ENDERECO_DE_TILE
		li a1, 0xFF000000
	
	INICIO_CALCULAR_ENDERECO_DE_TILE:
	
	# Para encontrar o endere�o do tile � necess�rio saber o n�mero da coluna e linha desse tile na tela
	
	sub a0, a0, a1	# a0 - endere�o base do frame decidido acima retorna a posi��o de a0 em rela��o ao 
			# inicio do frame
	
	li t0, 5120	# t0 recebe 16 (altura de um tile) * 320 (tamanho de uma linha do frame), ou seja,
			# o tamanho de uma linha de tiles no frame
			
	div t0, a0, t0	# a0 / 5120 retorna o n�mero da linha de tiles onde a0 est� 	
	
	li t1, 320	# t1 recebe o tamanho de uma linha do frame
	remu t1, a0, t1	# o resto de a0 / 320 retorna o numero da coluna de a0 no frame			
	li t2, 16 	# t2 recebe a largura de um tile	
	div t1, t1, t2	# o resto de t1 / 16 retorna o n�mero da coluna de a0 na matriz de tiles 
					
	# Com o n�mero da linha (t0) e coluna (t1) � f�cil encontrar o tile correspondente na matriz
			
	mul t2, t0, s3	# t0 * s3 (tamanho de uma linha na matriz de tiles) retorna quantos elementos � necess�rio
			# pular em s2 para encontrar a linha certa do tile correspondente
	
	add a0, t2, t1		# s2 + t2 (n�mero de elementos at� a linha certa) + t1 (n�mero de elementos at�
	add a0, a0, s2		# a coluna correta) = endere�o do tile correspondente na matriz a partir de a0
												
	# Agora e encess�rio encontrar o endere�o de inicio do tile a0 no frame
	
	li t2, 5120	# t2 recebe 16 (altura de um tile) * 320 (tamanho de uma linha do frame), ou seja,
			# o tamanho de uma linha de tiles no frame
	
	mul t0, t0, t2	# multiplicando a linha do tile (t0) por t2 retorna a quantos pixels � necess�rio pular
			# para encontrar a linha do tile a0 no frame 
	
	li t2, 16	# t2 recebe a largura de um tile
	mul t1, t1, t2 	# multiplicando a coluna do tile (t1) por 16 retorna a quantos pixels � necess�rio pular
			# para encontrar a coluna do tile a0
	
	add a1, a1, t0	# movendo o endere�o de a1 para o endere�o da linha do tile			
	add a1, a1, t1	# movendo o endere�o de a1 para o endere�o da coluna do tile

	lb t0, 0(a0)	# armazena o valor do tile a0 em t0
		
	li t1, 256	# t1 recebe 16 * 16 = 256, ou seja, a �rea de um tile							
	mul t0, t0, t1	# t0 (n�mero do tile) * (16 * 16) retorna quantos pixels esse tile est� do come�o 
			# da imagem dos tiles
	add a2, s4, t0	# a2 recebe o endere�o de inicio da imagem correspondente ao tile a0		

	ret
	
# ====================================================================================================== #

PRINT_COR:
	# Procedimento que imprime uma �rea de a2 x a3 pixels com a cor a0 a partir de um endere�o em algum frame
	# Esse procedimento geralamente � usado para "limpar" a tela em alguns momentos, como retirar certas
	# imagens de menus ou limpar caixas de di�logo, por exemplo.
	#
	# Argumentos: 
	# 	a0 = cor que ser� impressa 	
	# 	a1 = endere�o de onde, no frame escolhido, a impressao deve come�ar
	# 	a2 = numero de colunas da �rea a ser impressa
	#	a3 = numero de linhas da �rea a ser impressa
	# Obs: por algum motivo esse procedimento n�o funciona no RARS exceto se o endere�o de a1 estiver
	# especificamente no frame que est� na tela

	PRINT_COR_LINHAS:
		mv t0, a2		# copia do numero de a2 para usar no loop de colunas
			
		PRINT_COR_COLUNAS:
			sb a0, 0(a1)			# pega a cor de a0 e coloca no bitmap
	
			addi a1, a1, 1			# vai para o pr�ximo pixel do bitmap
			addi t0, t0, -1			# decrementa o numero de colunas restantes			
			bne t0, zero, PRINT_COR_COLUNAS	# reinicia o loop se t0 != 0
			
		addi a3, a3, -1			# decrementando o numero de linhas restantes
		
		sub a1, a1, a2			# volta o ende�o do bitmap pelo numero de colunas impressas
		addi a1, a1, 320		# passa o endere�o do bitmap para a proxima linha
		
		bne a3, zero, PRINT_COR_LINHAS	# reinicia o loop se a3 != 0		
	ret

# ====================================================================================================== #

REPLICAR_FRAME:
	# Procedimento que faz uma copia de uma �rea em um frame para outro frame
	# 
	# Argumentos: 
	# 	a0 = endere�o no frame do inicio da area que ser� copiada
	#	a1 = endere�o no frame que vai receber a copia
	#	a2 = numero de colunas que ser�o copiadas de a0 para a1
	#	a3 = numero de linhas que ser�o copiadas de a0 para a1	
	# 
	# OBS: se parte do pressuposto que a0 e a1 est�o alinhados para usar lw e sw, e que a �rea a ser copiada
	# tem largura e altura (a2 e a3) multiplos de 4
	
	REPLICAR_FRAME_LINHAS:
		mv t0, a2	# copia do numero de colunas para o loop abaixo
			
		REPLICAR_FRAME_COLUNAS:
			lw t1, 0(a0)			# pega 4 pixels do frame em a0
			sw t1, 0(a1)			# armazena os 4 pixels no frame a1	
	
			addi a0, a0, 4			# vai para os pr�ximos pixels do bitmap a0
			addi a1, a1, 4			# vai para os pr�ximos pixels do bitmap a1
						
			addi t0, t0, -4			# decrementa o numero de colunas de pixels restantes			
			bne t0, zero, REPLICAR_FRAME_COLUNAS	# reinicia o loop se t0 != 0

		sub a0, a0, a2			# volta o ende�o do bitmap pelo numero de colunas impressas
		addi a0, a0, 320		# passa o endere�o do bitmap para a proxima linha
		
		sub a1, a1, a2			# volta o ende�o do bitmap pelo numero de colunas impressas
		addi a1, a1, 320		# passa o endere�o do bitmap para a proxima linha
														
		addi a3, a3, -1			# decrementando o numero de linhas restantes	
		bne a3, zero, REPLICAR_FRAME_LINHAS	# reinicia o loop se t0 != 0		
	ret

# ====================================================================================================== #

SELECIONAR_OPCAO_MENU:							
	# Procedimento auxiliar que tem por objetivo selecionar ou retirar a sele��o de um item de um menu,
	# trocando os pixels de um texto por pixels azuis ou pixels cinza dependendo do argumento
	# O texto deve ter sido impresso usando os tiles em tiles_alfabeto.data
	# 
	# Argumentos:
	# 	a0 = [ 0 ] -> selecionar uma op��o, ou seja, trocar os pixels do texto de cinza para azul
	#	     [ != 0 ] -> retirar a sele��o de uma op��o, ou seja, trocar os pixels de azul para cinza
	#	a1 = endere�o onde o texto est�
	#	a2 = numero de linhas de pixels do texto
	#	a3 = numero de colunas de pixels do texto
	
	li t0,	91		# t0 = cor do texto quando ele n�o est� selecionado	
	li t1,	192		# t1 = cor que vai "selecionar" o texto
		
	# Se a0 != 0 ent�o o procedimento vai retirar a sele��o de um item								
	beq a0, zero, SELECIONAR_OPCAO_LINHAS	
		li t0,	192		# t0 = cor do texto quando ele est� selecionada	
		li t1,	91		# t1 = cor que vai retirar a sele��o do texto
					
	SELECIONAR_OPCAO_LINHAS:
		mv t2, a3		# copia do numero de colunas no loop abaixo
			
		SELECIONAR_OPCAO_COLUNAS:
			lbu t3, 0(a1)			# pega 1 pixel do bitmap e coloca em t3
			
			# Se t3 != t0 ent�o o pixel n�o sera modificado,
			# dessa forma somente o texto do item ser� modificados					
			bne t3, t0, NAO_MODIFICAR_OPCAO
				sb t1, 0(a1)
			
			NAO_MODIFICAR_OPCAO:
			addi a1, a1, 1				# vai para o pr�ximo pixel do bitmap
			addi t2, t2, -1				# decrementando o numero de colunas restantes
			bne t2, zero, SELECIONAR_OPCAO_COLUNAS	# reinicia o loop se t2 != 0
			
		sub a1, a1, a3				# volta o ende�o do bitmap pelo numero de colunas impressas
		addi a1, a1, 320			# passa o endere�o do bitmap para a proxima linha
		addi a2, a2, -1				# decrementando o numero de linhas restantes		
		bne a2, zero, SELECIONAR_OPCAO_LINHAS	# reinicia o loop se a2 != 0
			
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

SLEEP:	
	# Procedimento que fica em loop, parando a execu��o do programa, por alguns milissegundos
	# Argumentos:
	# 	a0 = durancao em ms do sleep
	
	csrr t0, time	# le o tempo atual do sistema
	add t0, t0, a0	# adiciona a t0 a durancao do sleep
	
	LOOP_SLEEP:
		csrr t1, time			# le o tempo do sistema
		sltu t1, t1, t0			# t1 recebe 1 se (t1 < t0) e 0 caso contr�rio
		bne t1, zero, LOOP_SLEEP 	# se o tempo de t1 != 0 reinicia o loop
		
	ret
				
# ====================================================================================================== #

ENCONTRAR_NUMERO_RANDOMICO:	
	# Procedimento que encontra um numero "randomico" entre 0 e a0 (nao inclusivo)
	# Argumentos:
	# 	a0 = limite superior para o numero randomico (nao inclusivo)
	# Retorno:
	# 	a0 = n�mero "r�ndomico" entre 0 e a0 - 1
 		
	csrr t0, time		# le o tempo atual do sistema
	
	li t1, 1103515245
	 mul  t0, t0, t1
	 li t1, 123456
   	 add t0, t0, t1
    
	mul t0, t0, t0		# time * time
	li t1, 0x0FF00		# pega os 8 bits do meio
	and t0, t0, t1	
	srli t0, t0, 8		# shifta eles para o inicio
	
	remu a0, t0, a0		# encontra o resto da divis�o do tempo do sistema por a0 de modo que a0 
				# tem um numero entre 0 e a0 - 1 
					
	ret
	
# ====================================================================================================== #

PRINT_TEXTO:
	# Procedimento similar a PRINT_DIALOGOS que usa uma matriz de tiles para imprimir 1 linha
	# de texto em algum frame.
	# A diferen�a entre um e outro � que PRINT_TEXTO s� imprime uma linha e em um endere�o arbitr�rio
	# na tela
	# Cada texto de um dialogo � codificado em uma matriz de tiles, a diferen�a � que enquanto 
	# normalmente os tiles do jogo tem 16 x 16, os tiles dos textos tem 8 x 15.
	# Todos os textos s�o construidos com os tiles em "../Imagens/historia/dialogos/tiles_alfabeto".
	# Para renderizar o dialogo � necess�rio fornecer uma matriz de tiles, onde cada tile
	# � uma letra desse alfebeto.
	# Esse procedimento s� imprime 2 linhas da matriz de tiles do dialogo.
	# 
	# Argumentos:
	# 	a1 = endere�o onde come�ar a imprimir o texto
	#	a4 = matriz de tiles condificando o texto do dialogo de acordo com tiles_alfabeto

	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, 0(sp)		# empilha ra

	la t3, tiles_alfabeto	# carrega a imagem com os tiles do alfabeto
	addi t3, t3, 8		# pula para onde come�a os pixels no .data

	lw t4, 0(a4)		# t4 recebe o numero de elementos que ser�o impresso
	addi a4, a4, 8		# pula para onde come�a os tiles no .data
				
	PRINT_TEXTO_COLUNAS:
		lb t0, 0(a4)	# pega 1 elemento da matriz de tiles e coloca em t0
		
		# um tile com valor -1 significa um fim de linha, eles s�o usados porque cada
		# dialogo precisa ter linhas de mesmo tamanho, ent�o tiles com valor -1 completam
		# as linhas para que esse criterio seja cumprido, por�m eles n�o s�o renderizados
		li t1, -1
		beq t0, t1, PROXIMO_TILE_TEXTO
		
		li t1, 120	# t1 recebe 8 * 15 = 120, ou seja, a �rea de um tile do alfabeto							
		mul t0, t0, t1	# t0 (n�mero do tile) * (8 * 15) etorna quantos pixels esse tile
				# est� do come�o da imagem dos tiles do alfabeto
			
		add a0, t0, t3	# a0 recebe o endere�o da imagem do tile a ser impresso
		# a1 tem o endere�o de onde imprimir a letra			
		li a2, 8		# numero de colunas de um tile do alfabeto
		li a3, 15		# numero de linhas de um tile do alfabeto
		call PRINT_IMG	
			
		li t0, 4800		# t1 recebe 15 (altura de um tile do alfabeto) * 320 
					# (tamanho de uma linha do frame)
		sub a1, a1, t0		# volta o endere�o de a1 pelas linhas impressas			
		addi a1, a1, 8		# pula 8 colunas no bitmap j� que o tile impresso tem
					# 8 colunas de tamanho 
			
		# Na verdade os tiles do alfabeto n�o est�o ordenados em ordem alfab�tica, mas sim
		# em determinados grupos.
		# Nem todas as letras tem exatamente 8 x 15 pixels, na verdade esse tamanho � apenas
		# um limite definido pelo tamanho do maior simbolo nesse alfabeto. 
		# Por isso certos tiles acabam ficando com um excesso de colunas em branco, ent�o
		# as letras est�o arranjadas em grupos que indicam quantos pixels � necess�rio voltar
		# antes de imprimir o proximo tile para que cada letra fique mais ou menos uma do lado
		# da outra.
				
		lb t0, 0(a4)	# pega o elemento da matriz de tiles que foi impresso							
																	
		li t1, 1		# se o numero do tile for menor do que 65	
		li t2, 65		# ent�o � necess�rio voltar 1 pixel
		blt t0, t2, PROXIMO_TILE_TEXTO
		li t1, 2		# se o numero do tile for maior ou igual a 65 e menor do que 75
		li t2, 75		# ent�o � necess�rio voltar 2 pixels
		blt t0, t2, PROXIMO_TILE_TEXTO
		li t1, 4		# se o numero do tile for maior que 75 e menor que 77 volta 
		li t2, 77		# 4 pixels
		ble t0, t2, PROXIMO_TILE_TEXTO			
		li t2, 5		# caso contr�rio volta 5 pixels
									
		PROXIMO_TILE_TEXTO:
			
		sub a1, a1, t1	# atualiza o endere�o onde o proximo tile ser� impresso de acordo com
				# o valor de t1 decidido acima		
						
		addi a4, a4, 1		# vai para o pr�ximo elemento da matriz de tiles
									
		addi t4, t4, -1			# decrementando o numero de colunas de tiles restantes
		bne t4, zero, PRINT_TEXTO_COLUNAS	# reinicia o loop se t4 != 0
					
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha

	ret
	
# ====================================================================================================== #

PRINT_NUMERO:
	# Procedimento que imprime um n�mero de 0 a 99 em algum frame
	# S� ser�o impressos os algarismos necess�rios, de 0 a 9 por exemplo s� imprime 1 numero 
	#
	# Argumentos:
	#	a0 = numero de 0 a 99
	# 	a1 = endere�o de onde os numeros devem ser impressos

	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Primeiro encontra os dois digitos
		li t0, 10
		bge a0, t0, NUMERO_DE_DOIS_DIGITOS
			rem t4, a0, t0		# t4 recebe o algarismo das unidades
			j PRINT_ALGARISMO_UNIDADES

	NUMERO_DE_DOIS_DIGITOS:
		div t3, a0, t0		# t3 recebe o algarismo das dezenas
		rem t4, a0, t0		# t4 recebe o algarismo das unidades

	# Imprimindo o algarismo das dezenas no frame
		la a0, tiles_numeros	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data
		li t0, 60		# cada tile de numero tem 10 * 6 = 60 de tamanho
		mul t0, t0, t3		# 60 * t3 (algarismo das dezenas) retorna a quantos pixels o numero
		add a0, a0, t0 		# de t3 est� do inicio da imagem dos tiles
		# a1 j� tem o endere�o de onde imprimir o numero
		li a2, 6		# numero de colunas dos tiles a serem impressos
		li a3, 10		# numero de linhas dos tiles a serem impressos	
		call PRINT_IMG								

		# pelo PRINT_IMG acima a1 est� naturalmente a -10 linhas +7 colunas de onde imprimir o proximo
		# numero
		li t0, -3193		# -3193 = -10 * 320 + 7
		add a1, a1, t0	

	PRINT_ALGARISMO_UNIDADES:				
	# Imprimindo o algarismo das unidades no frame
		la a0, tiles_numeros	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data
		li t0, 60		# cada tile de numero tem 10 * 6 = 60 de tamanho
		mul t0, t0, t4		# 60 * t4 (algarismo das unidades) retorna a quantos pixels o numero
		add a0, a0, t0 		# de t4 est� do inicio da imagem dos tiles
		# a1 j� tem o endere�o de onde imprimir o numero
		li a2, 6		# numero de colunas dos tiles a serem impressos
		li a3, 10		# numero de linhas dos tiles a serem impressos	
		call PRINT_IMG				

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha

	ret			
																											
