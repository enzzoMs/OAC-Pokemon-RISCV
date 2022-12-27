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
	
	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Primeiro verifica a transi��o a ser feita (YY)
		andi t0, a0, 0x60	# fazendo o AND de a0 com 0x60, que � 0110_000 em bin�rio, deixa 
					# somente os dois bits de a0 que devem ser de YY intactos, 
					# enquanto o restante fica todo 0
		
		# checagem de transi��es deve acontecer aqui		
		
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
	# de uma instru��o de branch e a sa�da � pelo �ltimo ra empilhado
			
	# Atualizando os registradores salvos para essa �rea
		# Atualizando o valor de s1 (orienta��o do personagem)
		li s1, 2	# inicialmente virado para cima
		
		# Atualizando o valor de s2 (endere�o da subsec��o onde o personagem est� na �rea atual) e
		# s3 (tamanho de uma linha da �rea atual)
		la s2, casa_red_quarto		# carregando em s2 o endere�o da imagem da �rea
		
		lw s3, 0(s2)			# s3 recebe o tamanho de uma linha da imagem da �rea
		
		addi s2, s2, 8			# pula para onde come�a os pixels no .data
		
		li t0, 24000			# 40 * 600 = 24.000, move o endere�o de s2 algumas linhas para
		add s2, s2, t0			# baixo, de modo que s2 tem o endere�o da subsec��o onde o
						# personagem vai estar
						
		# Atualizando o valor de s4 (posi��o atual na matriz de movimenta��o da �rea) e 
		# s5 (tamanho de linha na matriz)	
		la t0, matriz_casa_red_quarto	
		
		lw s5, 0(t0)			# s5 recebe o tamanho de uma linha da matriz da �rea
				
		addi t0, t0, 8
	
		addi s4, t0, 72		# o personagem come�a na linha 10 e coluna 8 da matriz
					# ent�o � somado o endere�o base da matriz (t0) a 
		addi s4, s4, 1		# 10 (n�mero da linha) * 18 (tamanho de uma linha da matriz) 
					# e a 8 (n�mero da coluna) 
											
	# Imprimindo as imagens da �rea e o sprite inicial do RED no frame 0					
		# Imprimindo a casa_red_quarto no frame 0
		mv a0, s2		# move para a0 o endere�o de s2
		li a1, 0xFF000000	# selecionando como argumento o frame 0
		li a2, 600		# 600 = tamanho de uma linha da imagem dessa �rea
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
		li a1, 0xFF100000	# selecionando como argumento o frame 1
		li a2, 600		# 600 = tamanho de uma linha da imagem dessa �rea
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
 
.data
	.include "../Imagens/areas/casa_red_quarto.data"
	.include "../Imagens/areas/matriz_casa_red_quarto.data"
