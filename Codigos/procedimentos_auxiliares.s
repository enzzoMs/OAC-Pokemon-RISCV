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
	#
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
	# Procedimento que imprime imagens de tamanho variado, menores que 320 x 240, no frame de escolha.
	# Esse procedimento tamb�m � equipado para lidar com imagens que cont�m pixels de cor transparente
	# (0xC7), nesse caso PRINT_IMG vai verificar se algum pixel tem essa cor, e os que tiverem n�o
	# ser�o renderizados na tela. Isso precisa ser feito ao inv�s de simplesmente renderizar os
	# os pixels transparentes por conta de alguns bugs visuais, sobretudo no RARS. 
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
	
PRINT_TILES:
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
	#
	# Argumentos:
	# 	a0 = endere�o, na matriz de tiles, de onde come�am os tiles a serem impressos
	#	a1 = endere�o no frame 0 ou 1 de onde os tiles v�o come�ar a ser impressos
	# 	a2 = n�mero de colunas de tiles a serem impressas
	# 	a3 = n�mero de linhas de tiles a serem impressas
																	
	# o loop abaixo vai imprimir a6 x a7 tiles
																														
	PRINT_TILES_LINHAS:
		mv t0, a2		# copia de a2 para usar no loop de colunas
				
		PRINT_TILES_COLUNAS:
			lb t1, 0(a0)	# pega 1 elemento da matriz de tiles e coloca em t1
		
			li t2, 256	# t2 recebe 16 * 16 = 256, ou seja, a �rea de um tile							
			mul t1, t1, t2	# como dito na descri��o do procedimento t1 (n�mero do tile) * (16 * 16)
					# retorna quantos pixels esse tile est� do come�o da imagem
			
			add t1, t1, s4	# t1 recebe o endere�o do tile a ser impresso
	
			# O loop abaixo emula um PRINT_IMG, a diferen�a � que como PRINT_IMG pode imprimir
			# imagens com uma tamanho arbitr�rio de colunas e linhas ele tem que utlizar instru��es
			# load e store byte, mas como cada tile sempre tem 16 x 16 de tamanho � poss�vel usar
			# load e store word para agilizar o processo
			
			li t2, 256	# numero de pixels de um tile (16 x 16)
			
			PRINT_TILE_COLUNAS:
			lw t3, 0(t1)		# pega 4 pixels do .data do tile (t1) e coloca em t3
			
			sw t3, 0(a1)		# pega os 4 pixels de t3 e coloca no bitmap
	
			addi t1, t1, 4		# vai para os pr�ximos pixels da imagem
			addi a1, a1, 4		# vai para os pr�ximos pixels do bitmap
			addi t2, t2, -4		# decrementa o numero de pixels restantes
			
			li t3, 16		# largura de um tile
			rem t3, t2, t3		# se o resto de t2 / 16 n�o for 0 ent�o ainda restam pixels
						# da linha atual para serem impressos
			bne t3, zero, PRINT_TILE_COLUNAS	# reinicia o loop se t3 != 0
			
			addi a1, a1, -16	# volta o ende�o do bitmap pelo numero de colunas impressas
			addi a1, a1, 320	# passa o endere�o do bitmap para a proxima linha
			bne t2, zero, PRINT_TILE_COLUNAS	# reinicia o loop se t2 != 0
	
			addi a0, a0, 1		# vai para o pr�ximo elemento da matriz de tiles
			
			li t1, 5120		# t1 recebe 16 (altura de um tile) * 320 
						# (tamanho de uma linha do frame)
			sub a1, a1, t1		# volta o endere�o de a5 pelas linhas impressas			
			addi a1, a1, 16		# pula 16 colunas no bitmap j� que o tile impresso tem
						# 16 colunas de tamanho 
			
			addi t0, t0, -1			# decrementando o numero de colunas de tiles restantes
			bne t0, zero, PRINT_TILES_COLUNAS	# reinicia o loop se t0 != 0
			
		sub a0, a0, a2		# volta o ende�o da matriz de tiles pelo numero de colunas impressas
		add a0, a0, s3		# passa o endere�o da matriz para a proxima linha (s3 tem o tamanho
					# de uma linha na matriz)
	
		li t1, 16		# t1 recebe a largura de um tile
		mul t1, t1, a2		# 16 * a2 retorna o numero de pixels em a1 foi incrementado no loop acima
		sub a1, a1, t1		# volta a1 pelo numero de colunas de tiles impressas

		li t1, 5120		# t1 recebe 16 (altura de um tile) * 320 (tamanho de uma linha do frame)
		add a1, a1, t1		# avan�a o endere�o de a5 para a proxima linha de tiles		
			
		addi a3, a3, -1				# decrementando o numero de linhas restantes
		bne a3, zero, PRINT_TILES_LINHAS	# reinicia o loop se a3 != 0
				
	ret

# ====================================================================================================== #	

LIMPAR_TILE:
	# Procedimento que tem como objetivo "limpar" um tile que esteja na tela.
	# Durante o funcionamento do programa as vezes alguns sprites, sobretudo do personagem, ser�o impressos
	# na tela, esse procededimento tem como objetivo limpar esses sprites da tela imprimindo novamente 
	# os tiles 
	# Como esse procedimento limpa um tile que esteja na tela ele parte de alguns pressupostos:
	# 	- o tile a ser limpo pertence a matriz indicada por s2, e est� dentro
	#	da subsec��o de 20 x 15 tiles que est� sendo mostrada na tela
	#	- o tile correspondente pertence a imagem de s4
	# O uso desse procedimento fornece alguns benef�cios em rela��o ao PRINT_TILES, como usar menos
	# registradores e n�o precisar de argumento indicando o endere�o de onde o tile ser� impresso,
	# j� que o pr�prio procedimento vai calcular o endere�o de onde o tile est� na tela
	# 
	# Argumentos:
	#	a4 = endere�o, na matriz de tiles, do tile a ser limpo 
	#	a5 = endere�o base do frame 0 ou 1 onde o tile ser� impresso
	
	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	# Primeiro � preciso encontrar o endere�o de onde imprimir o tile, para isso 
	# � necess�rio saber o n�mero da coluna e linha desse tile na tela
	
	sub t0, a4, s2	# s2 (inicio da subse��o 20 x 15 na matriz de tiles na tela) - a4 (tile a ser limpo)
			# retorna a quantos elementos s2 est� de a4 na matriz de tiles
	
	div t1, t0, s3	# dividindo t0 por s3 (tamanho de uma linha na matriz de tiles) retorna o n�mero da 
			# linha de a4 com rela��o a s2
	
	rem t0, t0, s3	# o resto da divis�o de t0 por s3 (tamanho de uma linha na matriz de tiles) retorna 
			# o n�mero da coluna de a4 com rela��o a s2
	
	# Como s2 � o inicio da subse��o de 20 x 15 tiles que est� na tela podemos entender tamb�m que s2 
	# representa o inicio do frame, e o valor de t1 e t0 em rela��o a s2 diz qual � a coluna e linha do 
	# tile em a4 no frame
	
	# Agora e encess�rio encontrar o endere�o do tile a4 no frame
	
	li t2, 5120	# t2 recebe 16 (altura de um tile) * 320 (tamanho de uma linha do frame), ou seja,
			# o tamanho de uma linha de tiles no frame
	
	mul t1, t1, t2	# multiplicando a linha do tile (t1) por t2 retorna a quantos pixels � necess�rio pular
			# para encontrar a linha do tile a4 no frame 
	
	add a5, a5, t1	# movendo o endere�o base do frame (a5) para o endere�o da linha do tile
	
	
	li t1, 16	# t1 recebe a largura de um tile
	mul t0, t0, t1 	# multiplicando a coluna do tile (t0) por 16 retorna a quantos pixels � necess�rio pular
			# para encontrar a coluna do tile a4
	
	add a5, a5, t0	# movendo o endere�o com a linha do tile para a coluna certa

	# Com o endere�o encontrado agora tudo que resta � imprimir o tile

	li t0, 256	# t4 recebe 16 * 16 = 256, ou seja, a �rea de um tile							
																													
	lb t1, 0(a4)	# pega o valor do tile em a4 e coloca em t1
		
	mul t0, t1, t0	# t1 (n�mero do tile) * (16 * 16) retorna a quantos pixels esse tile 
			# est� do come�o da imagem de tiles (s4)
	
	# Imprimindo tile no frame				
		add a0, s4, t0	# a0 recebe o endere�o do tile a ser impresso
		mv a1, a5	# a1 recebe o endere�o de onde imprimir o tile
		li a2, 16	# a2 = numero de colunas de um tile
		li a3, 16	# a3 = numero de linhas de um tile
		call PRINT_IMG
						
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
	# endere�o de inicio desse tile no frame
	#
	# Argumentos:
	#	a0 = um endere�o no frame 0 ou 1
	#
	# Retorno:
	#	a0 = endere�o do tile correspondente a partir de s2
	#	a1 = endere�o de inicio do tile no frame
	
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
																											
