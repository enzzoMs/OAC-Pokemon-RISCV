.text

# ====================================================================================================== # 
# 						   AREAS				                 #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# Este arquivo possui os procedimentos neces�rios para renderizar as diferentes �reas do jogo, fazendo   #
# as altera��es necess�rias nos registradores s1 (orienta��o do personagem), s2 (endere�o da subse��o da #
# area atual onde o personagem est�), s3 (tamanho de uma linha da �rea atual), s4 (posi��o na matriz de  #
# movimenta��o) e s5 (tamanho de linha na matriz)			  				 #
#            												 #	 
# Al�m disso, esse arquivo tamb�m cont�m os procedimentos para realizar as transi��es entre �rea.	 #
# A transi��o entre uma �rea e outra acontece quando o jogador se encontra em uma posi��o especial na	 #
# matriz de movimenta��o de uma �rea.									 #
# Os procedimentos de movimenta��o v�o verificar o valor da pr�xima posi��o do personagem na matriz de   #
# movimenta��o, caso o valor dessa posi��o seja maior ou igual a 128 (1000_0000 em bin�rio) os 		 #
# procedimentos de transi��o de �rea ser�o chamados.							 #		 #
# A raz�o para esse n�mero � que o byte desses elementos especiais � codificado em bin�rio no seguinte   #
# formato 1_YY_AAA_PP, onde:									         #
# 	 1... -> 1 bit fixo que indica que essa posi��o se trata de uma transi��o para outra �rea +  	 #
#	   YY -> 2 bits identificando o modo como o personagem est� indo, por escadas ou por uma porta,  #
# 		por exemplo, +										 #
# 	  AAA -> 3 bits identificando a �rea para onde o personagem est� indo +				 #
#	   PP -> 2 bits que indicam por qual ponto de entrada o personagem vai entrar na �rea 		 #
#													 #
# Ent�o cada elemento de transi��o da matriz guarda as informa��es necess�rias para que os procedimentos #
# saibam o que fazer.											 #
# Os poss�veis valores de AAA e YY podem ser encontrados abaixo:					 #
# 	�reas (AAA): 										 	 #
#		Quarto do RED -> 000									 #
#		Sala da casa do RED -> 001								 #
#													 #
#	Maneiras de fazer a transi��o entre �reas (YY):							 #
#		Por escada, descendo -> 00 								 #
#		Por escada, subindo -> 01 								 #
#		Entrando por uma porta -> 10 								 #
#		Nada deve acontecer na trasi��o -> 11 							 #
# 													 #
# J� os valores de PP variam dependendo da �rea. Algumas �reas possuem mais de uma maneira de acessa-las #
# a sala do RED, por exemplo, pode ser acessada tanto pelo quarto do RED ou pela porta da frente, nesse  #
# caso PP indica por qual entrada o personagem vai acessar a �rea:					 #
#	Quarto do RED:											 #
#		PP = 00 -> Entrada por lugar nenhum (quando o jogo come�a)				 #
#		PP = 01 -> Entrada pelas escadas							 #
#	Sala do RED:											 #
#		PP = 00 -> Entrada pela porta da frente							 #
#		PP = 01 -> Entrada pelas escadas							 #
#            												 #	 
# ====================================================================================================== #

RENDERIZAR_AREA:
	# Procedimento principal de areas.s, coordena a renderiza��o de �reas e a transi��o entre elas
	# Argumentos:
	# 	a0 = n�mero codificando as informa��es de renderiza��o de �rea, ou seja, um n�mero em que 
	# 	todos os bits s�o 0, exceto o byte menos significativo, que segue o formato 1YYAAAPP onde 
	# 	AAA � o c�digo da �rea a ser renderizada, YY como a transi��o para essa �rea ser� feita e PP o 
	# 	ponto de entrada na �rea.
	# 	Para mais explica��es ler texto acima.
	
	addi sp, sp, -8		# cria espa�o para 2 word na pilha
	sw a0, (sp)		# empilha a0
	sw ra, 4(sp)		# empilha ra
	
	# Primeiro verifica a transi��o a ser feita (YY)
		andi t0, a0, 0x60	# fazendo o AND de a0 com 0x60, que � 0110_000 em bin�rio, deixa 
					# somente os dois bits de a0 que devem ser de YY intactos, 
					# enquanto o restante fica todo 0
		
		# se t0 (YY) = 0000_0000 ent�o a transi��o para a pr�xima �rea deve incluir uma
		# anima��o do RED descendo escadas
		beq t0, zero, TRANSICAO_DESCENDO_ESCADAS		
	
	ESCOLHER_PROXIMA_AREA:

	lw a0, (sp)		# desempilha a0
	addi sp, sp, 4		# remove 1 word da pilha

	# Agora � necess�rio verificar a �rea a ser renderizada (YYY)
		# Para usar como argumento nos procedimentos de renderiza��o de �reas � necess�rio
		# separar tamb�m o PP (ponto de entrada da �rea)
	
		andi t0, a0, 3		# fazendo o AND de a0 com 3, 011 em bin�rio, deixa somente os dois 
					# primeiros bits de a0 intactos, enquanto o restante fica todo 0
		
		# Agora Separando o campo AAA
			
		andi t1, a0, 0x1C	# fazendo o AND de a0 com 0x1C, 0001_1100 em bin�rio, deixa somente os 
					# bits de a0 que devem ser de AAA intactos, enquanto o restante 
					# fica todo 0	
	
		# Agora o procedimento de renderiza��o de �rea adequado ser� chamado de acordo com AAA
		mv a0, t0	# move para a0 o valor de PP para que a0 possa ser usado como 
				# argumento nos procedimentos de renderiza��o de �rea
		
		# se t1 (AAA) = 000 renderiza o quarto do RED
		beq t1, zero, RENDERIZAR_QUARTO_RED

		li t0, 4	# 4 ou 001 00 em bin�rio � o c�digo da �rea da sala da casa do RED
		# se t1 (AAA) = 001 00 renderiza a sala da casa do RED
		beq t1, t0, RENDERIZAR_SALA_RED

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret

# ====================================================================================================== #

RENDERIZAR_QUARTO_RED:
	# Procedimento que imprime a imagem do quarto do RED e o sprite do RED no frame 0 e no frame 1 de 
	# acordo com o ponto de entrada, al�m de atualizar os registradores salvos
	# Argumentos:
	# 	a0 = indica o ponto de entrada na �rea, ou seja, por onde o RED est� entrando nessa �rea
	#	Para essa �rea os pontos de entrada poss�veis s�o:
	#		PP = 00 -> Entrada por lugar nenhum (quando o jogo come�a)	
	#		PP = 01 -> Entrada pelas escadas

	# OBS: n�o � necess�rio empilhar o valor de ra pois a chegada a este procedimento � por meio
	# de uma instru��o de branch e a sa�da � pelo ra empilhado por RENDERIZAR_AREA
 			
	# Atualizando os registradores salvos para essa �rea
		# Atualizando o valor de s1 (orienta��o do personagem)
		li s1, 2	# inicialmente virado para cima
		
		# Atualizando o valor de s2 (endere�o da subsec��o onde o personagem est� na �rea atual) e
		# s3 (tamanho de uma linha da �rea atual)
		la s2, casa_red_quarto		# carregando em s2 o endere�o da imagem da �rea
		
		lw s3, 0(s2)			# s3 recebe o tamanho de uma linha da imagem da �rea
		
		addi s2, s2, 7			# pula para onde come�a os pixels no .data
		
		li t0, 24000			# 40 linhas * 600 (tamanho de uma linha da imagem da �rea)  
						# = 24.000, assim, move o endere�o de s2 em algumas 
		add s2, s2, t0			# posi��es, de modo que s2 tem o endere�o da subsec��o onde o
						# personagem vai estar	
						
		# Atualizando o valor de s4 (posi��o atual na matriz de movimenta��o da �rea) e 
		# s5 (tamanho de linha na matriz)	
		la t0, matriz_casa_red_quarto	
		
		lw s5, 0(t0)			# s5 recebe o tamanho de uma linha da matriz da �rea
				
		addi t0, t0, 8
	
		addi s4, t0, 72		# o personagem come�a na linha 4 e coluna 1 da matriz
					# ent�o � somado o endere�o base da matriz (t0) a 
		addi s4, s4, 1		# 4 (n�mero da linha) * 18 (tamanho de uma linha da matriz) 
					# e a 1 (n�mero da coluna) 
											
	# Imprimindo as imagens da �rea e o sprite inicial do RED no frame 0					
		# Imprimindo a casa_red_quarto no frame 0
		mv a0, s2		# move para a0 o endere�o de s2
		li a1, 0xFF000000	# a imagem ser� impressa no frame 0
		li a2, 240		# numero de linhas da sub imagem a ser impressa
		li a3, 320		# numero de colunas da sub imagem a ser impressa
		mv a4, s3		# s3 = tamanho de uma linha da imagem dessa �rea
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
		li a1, 0xFF100000	# a imagem ser� impressa no frame 1
		li a2, 240		# numero de linhas da sub imagem a ser impressa
		li a3, 320		# numero de colunas da sub imagem a ser impressa
		mv a4, s3		# s3 = tamanho de uma linha da imagem dessa �rea
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
				
	# Mostra o frame 0		
	li t0, 0xFF200604		# t0 = endere�o para escolher frames 
	sb zero, (t0)			# armazena 0 no endere�o de t0

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret

# ====================================================================================================== #	

RENDERIZAR_SALA_RED:
	# Procedimento que imprime a imagem da sala da casa do RED e o sprite do RED no frame 0 e no frame 1
	# de acordo com o ponto de entrada, al�m de atualizar os registradores salvos
	# Argumentos:
	# 	a0 = indica o ponto de entrada na �rea, ou seja, por onde o RED est� entrando nessa �rea
	#	Para essa �rea os pontos de entrada poss�veis s�o:
	#		PP = 00 -> Entrada pela porta da frente							
	#		PP = 01 -> Entrada pelas escadas

	# OBS: n�o � necess�rio empilhar o valor de ra pois a chegada a este procedimento � por meio
	# de uma instru��o de branch e a sa�da � pelo ra empilhado por RENDERIZAR_AREA
	
	# Primeiro verifica qual o ponto de entrada (PP = a0)		
	beq a0, zero, SALA_RED_PP_PORTA		
		
	# Se a0 == 01 (ou != 0) ent�o o ponto de entrada � pelas escadas

	# Atualizando os registradores salvos para essa �rea
		# Atualizando o valor de s1 (orienta��o do personagem)
		li s1, 0	# inicialmente virado para a esquerda
		
		# Atualizando o valor de s2 (endere�o da subsec��o onde o personagem est� na �rea atual) e
		# s3 (tamanho de uma linha da �rea atual)
		la s2, casa_red_sala		# carregando em s2 o endere�o da imagem da �rea
		
		lw s3, 0(s2)			# s3 recebe o tamanho de uma linha da imagem da �rea
		
		addi s2, s2, 7			# pula para onde come�a os pixels no .data
		
		li t0, 24240			# 40 linhas * 600 (tamanho de uma linha da imagem da �rea) + 
						# 240 colunas = 24.240, assim, move o endere�o de s2 em algumas 
		add s2, s2, t0			# posi��es, de modo que s2 tem o endere�o da subsec��o onde o
						# personagem vai estar			
						
		# Atualizando o valor de s4 (posi��o atual na matriz de movimenta��o da �rea) e 
		# s5 (tamanho de linha na matriz)	
		la t0, matriz_casa_red_sala	
		
		lw s5, 0(t0)			# s5 recebe o tamanho de uma linha da matriz da �rea
				
		addi t0, t0, 8
	
		addi s4, t0, 72		# o personagem come�a na linha 4 e coluna 13 da matriz
					# ent�o � somado o endere�o base da matriz (t0) a 
		addi s4, s4, 13		# 4 (n�mero da linha) * 18 (tamanho de uma linha da matriz) 
					# e a 13 (n�mero da coluna) 
											
	# Imprimindo as imagens da �rea e o sprite inicial do RED no frame 0					
		# Imprimindo a casa_red_sala no frame 0
		mv a0, s2		# move para a0 o endere�o de s2
		li a1, 0xFF000000	# a imagem ser� impressa no frame 0
		li a2, 240		# numero de linhas da sub imagem a ser impressa
		li a3, 320		# numero de colunas da sub imagem a ser impressa
		mv a4, s3		# s3 = tamanho de uma linha da imagem dessa �rea
		call PRINT_AREA		
			
		# Imprimindo a imagem do RED virado para cima no frame 0
		la a0, red_esquerda	# carrega a imagem				
		mv a1, s0		# move para a1 o endere�o de s0 (endere�o de onde o RED fica na tela)
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		call PRINT_IMG	

	# Imprimindo as imagens da �rea e o sprite inicial do RED no frame 1					
		# Imprimindo a casa_red_sala no frame 1
		mv a0, s2		# move para a0 o endere�o de s2
		li a1, 0xFF100000	# a imagem ser� impressa no frame 1
		li a2, 240		# numero de linhas da sub imagem a ser impressa
		li a3, 320		# numero de colunas da sub imagem a ser impressa
		mv a4, s3		# s3 = tamanho de uma linha da imagem dessa �rea
		call PRINT_AREA		
			
		# Imprimindo a imagem do RED virado para cima no frame 1
		la a0, red_esquerda	# carrega a imagem				
		mv a1, s0		# move para a1 o endere�o de s0 (endere�o de onde o RED fica na tela)
		
		li t0, 0x00100000	# passa o endere�o de a1 para o equivalente no frame 1
		add a1, a1, t0
			
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		call PRINT_IMG	
		
		j FIM_RENDERIZAR_SALA_RED
	
	SALA_RED_PP_PORTA:
		
		# Aqui deve vir os procedimentos para a entrada por porta			
	
	FIM_RENDERIZAR_SALA_RED:
																			
	# Mostra o frame 0		
	li t0, 0xFF200604		# t0 = endere�o para escolher frames 
	sb zero, (t0)			# armazena 0 no endere�o de t0

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret
	
# ====================================================================================================== #
					
TRANSICAO_DESCENDO_ESCADAS:
	# Procedimento que renderiza uma pequena anima��o do RED descendo um conjunto de escadas para a 
	# transi��o com a pr�xima �rea
	 
 	# OBS: n�o � necess�rio empilhar o valor de ra pois a chegada a este procedimento � por meio
	# de uma instru��o de branch e a sa�da � sempre para o label ESCOLHER_PROXIMA_AREA
	
	# S� tem como descer uma escada em uma �rea do jogo, portanto � garantido que as escadas est�o
	# sempre a esquerda do RED
	
	# Diferente da movimenta��o nesse procedimento quem se move tanto � o RED quanto a tela
	
	# De inicio � tomado proveito de uma parte do procedimento de movimenta��o da tecla A
	# para mover o RED mais uma posi��o para a esquerda
	
	# Para chamar esse procedimento � necess�rio empilhar ra para garantir que o retorno seja em
	# INICIO_DESCER_ESCADAS
	
	addi sp, sp, -4			# cria espa�o para 1 word na pilha
	la t0, INICIO_DESCER_ESCADAS
	sw t0, (sp)			# empilha o endere�o de t0
	
	call INICIO_MOVIMENTACAO_A
															
	INICIO_DESCER_ESCADAS: 	
	
	# Agora � necess�rio imprimir uma nova imagem completa da subsec��o da �rea atual no frame 1
	# Isso deve acontecer por conta dos procedimentos de movimenta��o que sempre deixam o frame 1
	# diferente (geralmente com 1 pixel de diferen�a) do frame 0
	
		# Imprime a imagem da subse��o da �rea no frame 1
			mv a0, s2		# s2 tem o endere�o da subsec��o da �rea
			li a1, 0xFF100000	# seleciona como argumento o frame 1
			li a2, 320		# numero de linhas da sub imagem a ser impressa
			li a3, 240		# numero de colunas da sub imagem a ser impressa
			mv a4, s3		# s3 = tamanho de uma linha da imagem dessa �rea
			call PRINT_AREA		
	
	# Agora renderiza o RED dando um passo esquerdo no frame 1
		# Imprime o sprite do RED no frame 
			la a0, red_esquerda_passo_esquerdo	# carrega a imagem em a0
			
			mv a1, s0		# decide qual ser� o endere�o onde a imagem ser� impressa,
			addi a1, a1, -5		# nesse caso o sprite ser� renderizado onde o RED est� (s0)
			addi a1, a1, 960	# por�m cinco colunas para a esquerda (-5) e 4 linhas para 
						# baixo (4 * 320 = 960)
						
			li t0, 0x00100000	# al�m disso, a imagem ser� impressa no frame 1, portanto
			add a1, a1, t0		# passa o endere�o de a1 para o seu equivalente no frame 1
					
			lw a2, 0(a0)		# numero de colunas do sprite
			lw a3, 4(a0)		# numero de linhas do sprite
			addi a0, a0, 8		# pula para onde come�a os pixels no .data	
			call PRINT_IMG
		
		call TROCAR_FRAME	# inverte o frame sendo mostrado, ou seja, mostra o frame 1
				
		# Espera alguns milisegundos	
		li a0, 160			# sleep por 160 ms
		call SLEEP			# chama o procedimento SLEEP
	
	# Agora renderiza o RED dando um passo esquerdo no frame 0
		# Antes � necess�rio "limpar" uma parte da tela, ou seja, remover o antigo sprite do RED. 
		# Para n�o ter que imprimir uma tela inteira (320 x 240) s� ser� impresso uma sub imagem da 
		# �rea no lugar
		
		# Essa sub imagem se trata da imagem da �rea extamente onde o sprite do RED est�
		
		li t0, 108		# para encontrar essa sub imagem podemos usar o fato de que o endere�o
		mul t0, t0, s3 		# em s2 est� a exatamente 108 linhas e 148 colunas colunas de dist�ncia 
		addi t0, t0, 148	# de onde o personagem est� (s0)
					# assim, t0 recebe a quantidade de pixels que precisam ser pulados
		add a0, t0, s2		# em s2 para encontrar o endere�o de inicio dessa sub imagem
		
		
		# Imprime a sub imagem da �rea no frame 1
			# a0 j� tem o endere�o da sub imagem da �rea
			mv a1, s0		# a imagem ser� impressa onde o RED est� (s0)
			li a2, 40		# numero de linhas da sub imagem a ser impressa
			li a3, 30		# numero de colunas da sub imagem a ser impressa
			mv a4, s3		# s3 = tamanho de uma linha da imagem dessa �rea
			call PRINT_AREA		
	
	
		# Por fim, imprime o sprite do RED no frame 0 
			la a0, red_esquerda_passo_direito 	# carrega a imagem em a0		 
			
			mv a1, s0		# decide qual ser� o endere�o onde a imagem ser� impressa,
			addi a1, a1, -14	# nesse caso o sprite ser� renderizado onde o RED est� (s0)
			addi a1, a1, 1920	# por�m 14 colunas para a esquerda (-14) e 6 linhas para 
						# baixo (6 * 320 = 1920)
						
			lw a2, 0(a0)		# numero de colunas do sprite
			lw a3, 4(a0)		# numero de linhas do sprite
			addi a0, a0, 8		# pula para onde come�a os pixels no .data	
			call PRINT_IMG
				
		call TROCAR_FRAME	# inverte o frame sendo mostrado, ou seja, mostra o frame 0
		
		# Espera alguns milisegundos	
		li a0, 160			# sleep por 160 ms
		call SLEEP			# chama o procedimento SLEEP

	j ESCOLHER_PROXIMA_AREA
	
# ====================================================================================================== #	
				
.data
	.include "../Imagens/areas/casa_red_quarto.data"
	.include "../Imagens/areas/matriz_casa_red_quarto.data"
	.include "../Imagens/areas/casa_red_sala.data"
	.include "../Imagens/areas/matriz_casa_red_sala.data"	
	