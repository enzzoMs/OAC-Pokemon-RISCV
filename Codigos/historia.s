.text

# ====================================================================================================== # 
# 						 HISTORIA				                 #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# C�digo com os procedimentos necess�rios para renderizar os momentos de hist�ria do jogo, incluindo	 #
# imprimir caixas de di�logo e executar algumas anima��es 						 #
#													 #
# Esse arquivo possui 3 procedimentos principais, um para cada momento de hist�ria do jogo:		 #
#	RENDERIZAR_ANIMACAO_PROF_OAK, RENDERIZAR_DIALOGO_PROFESSOR_LABORATORIO,				 #
#	RENDERIZAR_ESCOLHA_DE_POKEMON_INICIAL								 #
#													 #
# ====================================================================================================== #

RENDERIZAR_ANIMACAO_PROF_OAK:
	# Esse procedimento � chamado quando o RED tenta pela primeira vez sair da �rea principal de Pallet
	# e andar sobre um tile de grama. Quando o jogador passa por esses tiles existe a chance de um 
	# Pokemon aparecer e iniciar uma batalha, mas como na primeria vez o jogador ainda n�o tem Pokemon 
	# ele precisa ir ao laborat�rio. Portanto, esse procedimento renderiza a anima��o do Professor 
	# Carvalho indo ao jogador, renderiza o dial�go explicando que o RED tem que escolher seu Pokemon 
	# inicial, e depois renderiza a anima��o do professor voltando de onde ele veio.

	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, 0(sp)		# empilha ra
	
	# Espera alguns milisegundos	
		li a0, 1000			# sleep 1 s
		call SLEEP			# chama o procedimento SLEEP	
		
	# Como primeira parte da anima�a� � necess�rio imprimir um bal�o de exclama��o sobre a cabe�a do RED
	# no frame 0. O bal�o funciona que nem um tile normal, a diferen�a � que tem fundo transparentes
	
	mv a0, s0			# calcula o endere�o de inicio do tile onde a cabe�a do RED est� (s0)
	call CALCULAR_ENDERECO_DE_TILE	
	
	# Imprimindo o bal�o de exclama��o no frame 1			
		la a0, balao_exclamacao		# carrega a imagem
		addi a0, a0, 8			# pula para onde come�a os pixels no .data
		# do retorno do procedimento CALCULAR_ENDERECO_DE_TILE a1 j� tem o endere�o de inicio 
		# do tile onde a cabe�a do RED est� 
		li a2, 16			# a2 = numero de colunas de um tile
		li a3, 16			# a3 = numero de linhas de um tile
		call PRINT_IMG

	# Espera alguns milisegundos	
		li a0, 1000			# sleep 1 s
		call SLEEP			# chama o procedimento SLEEP	
	
	# Imprime o dialogo inicial do professor
	la a4, matriz_dialogo_oak_pallet_1	# carrega a matriz de tiles do dialogo
	li a5, 1			# renderiza 1 dialogo		
	call RENDERIZAR_DIALOGOS
	
	# Agora � necess�rio trocar a orienta��o do RED para que ele fique virado para baixo
			
	la a4, red_baixo	# carrega como argumento o sprite do RED virada para baixo		
	call MUDAR_ORIENTACAO_RED
			
	li s1, 3	# atualiza o valor de s1 dizendo que agora o RED est� virado para baixo
	
	# Obs: a mudan�a de orienta��o naturalmente vai retirar a imagem do bal�o de exclama��o
	
	# Agora come�a a anima��o do professor Carvalho
	# Na primeira parte o sprite do professor dando um passo para cima ser� lentamente impressa,
	# pixel por pixel, na tela, dando a impress�o de que o professor est� entrando em cena
	
	# O endere�o onde o sprite do professor ser� impresso depende da posi��o do RED.
	
	li t0, 41600	# 41600 = 130 linhas * 320 (tamanho de uma linha do frame)
	
	add t3, s0, t0	# o endere�o do professor est� sempre a 130 linhas do RED (s0)
	
	# O endere�o do professor pode ainda estar a -16 ou -32 colunas do RED dependendo de onde ele est�
	# Para definir isso � poss�vel usar a matriz de movimenta��o e checar a posi��o a esquerda do RED
	
	addi t3, t3, -16	# primeiro move o endere�o de t3 para 16 a esquerda
	
	lb t0, -1(s6)	# checa na matriz de movimenta��o a posi��o a esquerda do RED  
	
	li t1, 16	# multiplicando 16 pelo valor lido em t0 retorna a quantidade certa de pixels (0 ou 
	mul t0, t0, t1	# 16) que � necess�rio subtrair do endere�o de t3
	sub t3, t3, t0 
		
	
	# Imprimindo o sprite do professor entrando em cena
	
	mv t4, t3	# faz uma copia do endere�o de t3 em t4
			# essa copia guarda o endere�o do tile inicial onde o sprite do professor foi renderizado
			
		
	li t5, 0		# contador para o numero de loops feitos
				
	li t6, 0x00100000	# t6 ser� usada para fazer a troca entre frames no loop de movimenta��o	
				# O loop abaixo come�a imprimindo os sprites no frame 1 j� que se parte
				# do pressuposto de que o frame 0 � o que est� sendo mostrado
				
	LOOP_PROFESSOR_ENTRANDO:
		# Limpa o tile onde o professor ser� renderizado
		mv a0, t4			# encontra o endere�o do tile na matriz e o endere�o do
		call CALCULAR_ENDERECO_DE_TILE	# frame onde o sprite foi renderizado
	
		# Agora imprime o tile e limpa a tela
		mv a0, a2	# pelo retorno do procedimento chamado acima a2 tem o endere�o da imagem do 
				# tile correspondente a t4
		# pelo retorno do procedimento a1 tem o endere�o de inicio do tile no frame 0
		add a1, a1, t6		# decide a partir do valor de t6 qual o frame onde a imagem
					# ser� impressa			
		li a2, 16		# numero de colunas de um tile
		li a3, 16		# numero de linhas de um tile
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		call PRINT_IMG			
	
	
		# Agora imprime a imagem do professor no frame
		la a0, oak_cima_passo_esquerdo	# carrega o sprite do professor	
		mv a1, t3		# t3 possui o endere�o de onde renderizar o sprite
		add a1, a1, t6		# decide a partir do valor de t6 qual o frame onde a imagem
					# ser� impressa			
		lw a2, 0(a0)		# numero de colunas de uma imagem do professor
		addi a3, t5, 1		# o numero de linhas a serem impressas depende do numero da itera��o
					# + 1 (porque t5 come�a no 0)
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		call PRINT_IMG	
	
		# Espera alguns milisegundos	
		li a0, 20			# sleep 20 ms
		call SLEEP			# chama o procedimento SLEEP
			
		call TROCAR_FRAME		# inverte o frame sendo mostrado
			
		li t0, 0x00100000	# com essa opera��o xor se t6 for 0 ele recebe 0x0010000
		xor t6, t6, t0		# e se for 0x0010000 ele recebe 0, ou seja, com isso � poss�vel
					# ficar alternando entre esses valores
		
		addi t3, t3, -320	# volta o endere�o de onde imprimir o professor para linha acima			
											
		addi t5, t5, 1		# incrementa o numero de loops restantes
		li t0, 20		# 20 � a altura do sprite do professor 
		bne t5, t0, LOOP_PROFESSOR_ENTRANDO	# reinicia o loop se t5 != 20
	
	addi t3, t3, 320	# na ultima itera��o o valor de t3 � decrementado mais uma vez desnecessariamente
				# portanto, � necess�rio reverter essa mudan�a 				

	# Agora realiza a anima��o de movimenta��o do professor 
	
	mv a0, t3		# dos calculos acima t3 ainda tem a posi��o do ultimo sprite do 
				# professor no frame 0 
	
	li t6, -1		# contador para o loop abaixo, de modo que cada loop representa uma movimenta��o
				# do professor em alguma orienta��o

	LOOP_ANIMACAO_PROFESSOR:
	
	addi t6, t6, 1		# incrementa o numero de loops feitos
	
	# Primeiro determina qual � o sentido da movimenta��o do professor de acordo com o numero da itera��o,
	# de modo que a anima��o siga o seguinte padr�o:
	# Prof sobe at� o RED -> DIALOGO DO PROFESSOR -> Prof sai da �rea dependendo de onde o RED est�
	li t0, 3		
	ble t6, t0, MOVER_PROFESSOR_CIMA
	
	addi t0, t0, 1 			# a movimenta��o do professor para a direita depende de onde o RED 
	lb t1, -1(s6)			# est�. Para decidir isso � poss�vel utilizar o valor da posi��o a 
	add t0, t0, t1			# esquerda de onde ele est� na matriz de movimenta��o. 
					# Obs: essa posi��o da matriz s� pode ter 0 ou 1 
	ble t6, t0, MOVER_PROFESSOR_DIREITA
	
	addi t0, t0, 1		
	ble t6, t0, MOVER_PROFESSOR_CIMA
	
	addi t0, t0, 1			# caso o n�mero de itera��es chegue nesse ponto ent�o � necessario
					# imprimir o pr�ximo dialogo do professor
	ble t6, t0, ANIMACAO_PROFESSOR_PRINT_DIALOGO
		
	# Ao chegar nesse ponto � necessario fazer com que o professor ande at� uma posi��o no canto inferior 
	# da tela para que ele possa sair de cena, mas qual � essa posi��o vai ser determinada pela posi��o
	# do RED. Se a posi��o ao lado do RED estiver livre ent�o o prof vai ir para a direita e depois descer, 
	# sen�o ele vai para a esquerda e depois desce
	lb t1, -1(s6)		 
	bne t1, zero, ANIMACAO_PROFESSOR_ESQUERDA		
	
	li t0, 8			
	ble t6, t0, MOVER_PROFESSOR_DIREITA

	addi t0, t0, 1			
	ble t6, t0, MOVER_PROFESSOR_BAIXO					

	addi t0, t0, 7			
	ble t6, t0, MOVER_PROFESSOR_DIREITA															
	j ANIMACAO_PROFESSOR_DESCER

	ANIMACAO_PROFESSOR_ESQUERDA:
	li t0, 8					
	ble t6, t0, MOVER_PROFESSOR_ESQUERDA					

	addi t0, t0, 1			
	ble t6, t0, MOVER_PROFESSOR_BAIXO	
	
	addi t0, t0, 1		
	ble t6, t0, MOVER_PROFESSOR_ESQUERDA	
	
	ANIMACAO_PROFESSOR_DESCER:
	addi t0, t0, 4			
	ble t6, t0, MOVER_PROFESSOR_BAIXO
																																																																																											
	j FIM_ANIMACAO_PROFESSOR

		MOVER_PROFESSOR_CIMA:
		# Decide os valores de a4 e a7 para a movimenta��o	
		
		la a4, oak_cima		# carrega a imagem do professor parado virado para cima
		li a7, 0		# a = 0 = anima��o para cima																
		
		# Decide se o professor vai ser renderizado dando o passo com o p� esquerdo ou direito
		# de acordo com o valor de t6	
						
		# Com o branch abaixo � possivel alternar entre os passos esquerdo e direito a cada itera��o		
		andi t0, t6, 1					# se t6 for par o professor d� um passo
		beq t0, zero, PROFESSOR_CIMA_PASSO_DIREITO	# direito, sen�o um passo esquerdo
			la a5, oak_cima_passo_esquerdo	
			j MOVER_PROFESSOR
			
		PROFESSOR_CIMA_PASSO_DIREITO:		
			la a5, oak_cima_passo_direito
			j MOVER_PROFESSOR
					
		# -------------------------------------------------------------------------------------------
					
		MOVER_PROFESSOR_DIREITA:
		# Decide os valores de a4 e a7 para a movimenta��o	
		
		la a4, oak_direita	# carrega a imagem do professor parado virado para a direita
		li a7, 3		# a7 = 0 = anima��o para a direita																
		
		# Decide se o professor vai ser renderizado dando o passo com o p� esquerdo ou direito
		# de acordo com o valor de t6	
						
		# Com o branch abaixo � possivel alternar entre os passos esquerdo e direito a cada itera��o		
		andi t0, t6, 1					# se t6 for par o professor d� um passo
		bne t0, zero, PROFESSOR_DIREITA_PASSO_DIREITO	# esquerdo, sen�o um passo direito
			la a5, oak_direita_passo_esquerdo	
			j MOVER_PROFESSOR
			
		PROFESSOR_DIREITA_PASSO_DIREITO:		
			la a5, oak_direita_passo_direito
			j MOVER_PROFESSOR
			
		# -------------------------------------------------------------------------------------------
		
		MOVER_PROFESSOR_ESQUERDA:
		# Decide os valores de a4 e a7 para a movimenta��o	
		
		la a4, oak_esquerda	# carrega a imagem do professor parado virado para a esquerda
		li a7, 1		# a7 = 1 = anima��o para a esquerda																
		
		# Decide se o professor vai ser renderizado dando o passo com o p� esquerdo ou direito
		# de acordo com o valor de t6	
						
		# Com o branch abaixo � possivel alternar entre os passos esquerdo e direito a cada itera��o		
		andi t0, t6, 1					# se t6 for par o professor d� um passo
		bne t0, zero, PROFESSOR_ESQUERDA_PASSO_DIREITO	# esquerdo, sen�o um passo direito
			la a5, oak_esquerda_passo_esquerdo	
			j MOVER_PROFESSOR
			
		PROFESSOR_ESQUERDA_PASSO_DIREITO:		
			la a5, oak_esquerda_passo_direito
			j MOVER_PROFESSOR
			
		# -------------------------------------------------------------------------------------------
		
		MOVER_PROFESSOR_BAIXO:
		# Decide os valores de a4 e a7 para a movimenta��o	
		
		la a4, oak_baixo	# carrega a imagem do professor parado virado para baixo
		li a7, 2		# a = 2 = anima��o para baixo																
		
		# Decide se o professor vai ser renderizado dando o passo com o p� esquerdo ou direito
		# de acordo com o valor de t6	
						
		# Com o branch abaixo � possivel alternar entre os passos esquerdo e direito a cada itera��o		
		andi t0, t6, 1					# se t6 for par o professor d� um passo
		beq t0, zero, PROFESSOR_BAIXO_PASSO_DIREITO	# direito, sen�o um passo esquerdo
			la a5, oak_baixo_passo_esquerdo	
			j MOVER_PROFESSOR
			
		PROFESSOR_BAIXO_PASSO_DIREITO:		
			la a5, oak_baixo_passo_direito
			
		# -------------------------------------------------------------------------------------------
																																																																						
		MOVER_PROFESSOR:				
			# a4 j� tem a imagem do professor parado
			# a5 tem a a imagem do professor dando um passo	
			mv a6, a0		# a0 tem o endere�o de onde imprimir o sprite do professor
			# a7 tem o n�mero indicando qual o sentido da movimenta��o															
			call MOVER_PERSONAGEM	
		
			j LOOP_ANIMACAO_PROFESSOR
		
		ANIMACAO_PROFESSOR_PRINT_DIALOGO:
			addi sp, sp, -4		# cria espa�o para 1 word na pilha
			sw a0, 0(sp)		# empilha ra
	
			# Imprime o proximo dialogo do professor
			la a4, matriz_dialogo_oak_pallet_2	# carrega a matriz de tiles do dialogo
			li a5, 3			# renderiza 3 dialogos		
			call RENDERIZAR_DIALOGOS
		
			li t6, 7 	# como o RENDERIZAR_DIALOGOS modifica o valor de t6 � necess�rio voltar
					# esse registrador para o valor antigo. Felizmente nesse ponto do c�digo
					# � poss�vel saber quase exatamente que valor t6 tinha antes do
					# procedimento: no m�ximo 7 quando o ANIMACAO_PROFESSOR_PRINT_DIALOGO 
					# foi chamado
					
			lw a0, (sp)		# desempilha ra
			addi sp, sp, 4		# remove 1 word da pilha
					
			j LOOP_ANIMACAO_PROFESSOR
		
	FIM_ANIMACAO_PROFESSOR:
	
	# Agora � necess�rio imprimir o sprite do professor saindo de cena
	
	# Do loop acima a0 ainda tem o endere�o de onde o ultimo sprite do professor foi renderizado
	
	mv t4, a0		# salva a0 em t4	
			
	li t5, 0		# contador para o numero de loops feitos
				
	li t6, 0x00100000	# t6 ser� usada para fazer a troca entre frames no loop de movimenta��o	
				# O loop abaixo come�a imprimindo os sprites no frame 1 j� que se parte
				# do pressuposto de que o frame 0 � o que est� sendo mostrado
				
	LOOP_PROFESSOR_SAINDO:
		# Limpa os 2 tiles onde o professor est� 
		mv a0, t4			# encontra o endere�o do tile na matriz e o endere�o do
		call CALCULAR_ENDERECO_DE_TILE	# frame onde o professor est�

		# Imprimindo os tiles e limpando a tela no frame
		# do retorno do procedimento a0 tem o endere�o do tile onde a cabe�a do professor est�
		# do retorno do procedimento a1 tem o endere�o de inicio do tile a0 no frame 0, ou seja, o 
		# endere�o onde os tiles v�o come�ar a ser impressos para a limpeza
		add a1, a1, t6		# decide a partir do valor de t6 qual o frame onde a imagem
					# ser� impressa	
		li a2, 1	# a limpeza vai ocorrer em 1 coluna
		li a3, 2	# a limpeza vai ocorrer em 2 linhas 
		call PRINT_TILES_AREA
		
		# Agora imprime a imagem do professor no frame
		la a0, oak_baixo_passo_esquerdo		# carrega o sprite do professor	
		mv a1, t4		# t4 possui o endere�o de onde o ultimo sprite do professor estava

		li t0, 320		# a linha onde o sprite ser� impresso depende do n�mero da intera��o
		mul t0, t0, t5		# de modo que quanto maior for t5 mais baixo o sprite ser� renderizado
		add a1, a1, t0		# dando a impress�o que o professar est� saindo de cena
		
		add a1, a1, t6		# decide a partir do valor de t6 qual o frame onde a imagem
					# ser� impressa		
						
		lw a2, 0(a0)		# numero de colunas de uma imagem do professor	
		
		li a3, 20		# o numero de linhas a serem impressas depende do numero da itera��o
		sub a3, a3, t5		# diminuindo conforme o valor de t5
					
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		call PRINT_IMG	
	
		# Espera alguns milisegundos	
		li a0, 20			# sleep 20 ms
		call SLEEP			# chama o procedimento SLEEP
			
		call TROCAR_FRAME		# inverte o frame sendo mostrado
			
		li t0, 0x00100000	# com essa opera��o xor se t6 for 0 ele recebe 0x0010000
		xor t6, t6, t0		# e se for 0x0010000 ele recebe 0, ou seja, com isso � poss�vel
					# ficar alternando entre esses valores
												
		addi t5, t5, 1		# incrementa o numero de loops restantes
		li t0, 20		# 20 � a altura do sprite do professor
		bne t5, t0, LOOP_PROFESSOR_SAINDO	# reinicia o loop se t5 != 20
	
	# Pela maneira como o loop acima � feito ainda sobram alguns sprites no frame 0 e 1 que precisam ser
	# limpos
		mv a0, t4			# encontra o endere�o do tile na matriz e o endere�o do
		call CALCULAR_ENDERECO_DE_TILE	# frame onde o sprite do professor foi renderizado
				
		mv t4, a0	# salva o a0 retornado em t4
		mv t5, a1	# salva o a1 retornado em t5

		# Limpa o tile onde o professor estava no frame 0
		# do retorno do procedimento a0 tem o endere�o do tile onde a cabe�a do professor est�
		# do retorno do procedimento a1 tem o endere�o de inicio do tile a0 no frame 0, ou seja, o 
		# endere�o onde os tiles v�o come�ar a ser impressos para a limpeza
		li a2, 1	# a limpeza vai ocorrer em 1 coluna
		li a3, 2	# a limpeza vai ocorrer em 2 linhas 
		call PRINT_TILES_AREA
		
		# Limpa o tile onde o professor estava no frame 1
		mv a0, t4 	# t4 tem o endere�o do tile onde a cabe�a do professor est�
		mv a1, t5	# t5 tem o endere�o de inicio do tile a0 no frame 0, ou seja, o 
				# endere�o onde os tiles v�o come�ar a ser impressos para a limpeza
		li t0, 0x00100000	
		add a1, a1, t0		# passa o endere�o de a1 para o equivalente no frame 1		
		li a2, 1	# a limpeza vai ocorrer em 1 coluna
		li a3, 2	# a limpeza vai ocorrer em 2 linhas 
		call PRINT_TILES_AREA
	
	# Agora � preciso atualizar os valores da matriz de grama que est�o acima no RED para que eles
	# n�o chamem mais esse procedimento
	
	sub t0, s6, s7		# t0 tem o endere�o na linha anterior a s6 na matriz de movimenta��o
	
	# armazena 0 na posi��o de t0 e nas duas adjacentes de modo que essas posi��es da matriz de movimenta��o
	# n�o v�o mais permitir movimenta��o
	sb zero, -1(t0)		
	sb zero, 0(t0)
	sb zero, 1(t0)
	
	# Por fim, � necess�rio atualizar a matriz de movimenta��o novamente para permitir a entrada
	# no laborat�rio
	
	lb t0, 1(s6)		# para encontrar o elemento da matriz de movimenta��o
				# que corresponde a ponta para o laboratorio � possivel
	li t1, 14 		# usar as rela��es ao lado que usam a posi��o do RED para calcular
	mul t1, t1, s7		# qual o endere�o da porta
	add t0, t0, t1
	
	addi t0, t0, 3
	add t0, t0, s6
	
	li t1, 108		# armazena 108 em t0 (endere�o na matriz de movimenta��o para a porta
	sb t1, 0(t0)		# do laborat�rio), sendo que 108 representa o codigo para entrar na �rea
				# do laborat�rio
															
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha

	ret

# ====================================================================================================== #	

RENDERIZAR_DIALOGO_PROFESSOR_LABORATORIO:
	# Esse procedimento � chamado quando o RED entra pela primeira vez no laborat�rio, renderizando
	# um pequeno dialogo para a escolha do pokemon inicial e atualizando a matriz de movimenta��o

	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, 0(sp)		# empilha ra	
	
	# Imprime o dialogo do professor
	la a4, matriz_dialogo_oak_laboratorio_1	# carrega a matriz de tiles do dialogo
	li a5, 3				# renderiza 3 dialogos	
	call RENDERIZAR_DIALOGOS
	
	# Agora � preciso atualizar os valores das posi��es adjacentes ao RED na matriz de movimenta��o
	# para que esse procedimento n�o seja mais chamado
	
	sub t0, s6, s7		# t0 tem o endere�o na linha anterior a s6 na matriz de movimenta��o
	
	# armazena 0 na posi��o de t0 e nas adjacentes de modo que essas posi��es da matriz de movimenta��o
	# v�o permitir movimenta��o normal
	li t1, 1
	sb t1, -2(t0)			
	sb t1, -1(t0)		
	sb t1, 0(t0)
	sb t1, 1(t0)
	sb t1, 2(t0)			
	
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha

	ret
	
# ====================================================================================================== #
	
RENDERIZAR_ESCOLHA_DE_POKEMON_INICIAL:
	# Esse procedimento � chamado quando o RED interage com uma das mesas com pokebolas no laborat�rio.
	# O procedimento vai usar o valor da posi��o da mesa para escolher e renderizar corretamente a
	# imagem do respectivo pokemon inicial e perguntar ao jogador se ele deseja escolhe-lo, se ele 
	# escolher sim o procedimento tamb�m renderiza os pr�ximos dialogos da historia.
	# 
	# Argumentos:
	#	a5 = valor da posi��o da mesa com pokebola na matriz de movimenta��o. Os possiveis valores
	#	s�o:
	#		[ 0 ] -> mesa com a pokebola do BULBASAUR
	#		[ 1 ] -> mesa com a pokebola do CHARMANDER
	#		[ 2 ] -> mesa com a pokebola do SQUIRTLE
	
	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, 0(sp)		# empilha ra	
	
	# Primeiro � necess�rio renderizar a caixa com a imagem do pokemon e o dialogo perguntando se o
	# RED deseja escolher esse pokemon
		call TROCAR_FRAME	# inverte o frame sendo mostrado, nesse caso mostra o frame 1
		
		# No frame 0 vai ficar o dialogo com o SIM selecionado
			# Renderiza a caixa de dialogo
			li a0, 0xFF000000		# renderiza a caixa de dialogo no frame 0
			call PRINT_CAIXA_DE_DIALOGO
			
			# Renderiza o dialogo. Todos os dialogos com o SIM selecionado para cada um dos tr�s
			# pokemons iniciais est�o em matriz_dialogo_escolha_pokemon_sim, sendo que um est�
			# debaixo do outro, de modo que � possivel usar o valor de a5 para encontrar o 
			# dialogo do pokemon correto
			
			la a4, matriz_dialogo_escolha_pokemon_sim	# carrega a matriz de dialogos
			lw a6, 0(a4)		# a6 recebe o tamanho de uma linha da matriz a4
			addi a4, a4, 8		# pula para onde come�a os tiles no .data
			
			li t0, 86		# cada linha da matriz tem 43 elementos, cada dialogo inclui
						# duas linhas, ent�o t0 = tamanho de um dialogo na matriz a4
			mul t0, t0, a5	# multiplica a5 * 86 de modo que t0 recebe a quantidade de elementos 
			add a4, a4, t0	# entre o inicio da matriz a4 e o dialogo para o pokemon correto
			li a7, 0xFF000000	# os dialogos ser�o renderizados no frame 0
			call PRINT_DIALOGO
		
		# Imprimindo no frame 0 a caixa com a imagem do pokemon 
			# Calcula o endere�o de onde imprimir a caixa (ele sempre � fixo independente do pokemon)
			li a1, 0xFF000000		# seleciona como argumento o frame 0
			li a2, 52 			# numero da coluna 
			li a3, 125			# numero da linha
			call CALCULAR_ENDERECO	
		
			mv t6, a0		# salva em t6 o endere�o retornado
		
			# Imprimindo a caixa no frame 0
			la a0, matriz_tiles_caixa_escolha_pokemon	# carrega a matriz de tiles da caixa
			la a1, tiles_caixa_escolha_pokemon		# carrega a imagem com os tiles da caixa
			mv a2, t6		 # t6 tem o endere�o de onde imprimir as caixas
			call PRINT_TILES
			
			# Calcula o endere�o de onde imprimir a imagem do pokemon (ele sempre � fixo independente 
			# do pokemon)
			li a1, 0xFF000000		# seleciona como argumento o frame 0
			li a2, 64 			# numero da coluna 
			li a3, 136			# numero da linha
			call CALCULAR_ENDERECO	
		
			mv t5, a0		# salva em t5 o endere�o retornado
			
			# Imprimindo o pokemon no frame 0		
			la a0, pokemons_menu	# carrega a imagem dos pokemons
			addi a0, a0, 8		# pula para onde come�a os pixels no .data
			
			li t0, 1482 		# t0 recebe o tamanho de uma imagem de um pokemon
			mul t0, a5, t0		# decide qual imagem renderizar de acordo com a5
			add a0, a0, t0
			
			mv a1, t5	# t5 tem o endere�o de onde a imagem
			li a2, 38	# a2 = numero de colunas de uma imagem de um pokemon
			li a3, 39	# a3 = numero de linhas de uma imagem de um pokemon
			call PRINT_IMG
				
		call TROCAR_FRAME	# inverte o frame sendo mostrado, nesse caso mostra o frame 0	
	
		# Imprimindo no frame 1 a caixa com a imagem do pokemon
			# Imprimindo a caixa no frame 1
			la a0, matriz_tiles_caixa_escolha_pokemon	# carrega a matriz de tiles da caixa
			la a1, tiles_caixa_escolha_pokemon		# carrega a imagem com os tiles da caixa
			mv a2, t6		 # t6 tem o endere�o de onde imprimir a caixa no frame 0
			li t0, 0x00100000
			add a2, a2, t0		# passa o endere�o de a2 para o frame 1

			mv t6, t5		# move para t6 o endere�o de t5 (onde imprimir o pokemon)

			call PRINT_TILES
		
			# Imprimindo o pokemon no frame 1		
			la a0, pokemons_menu	# carrega a imagem dos pokemons
			addi a0, a0, 8		# pula para onde come�a os pixels no .data
			
			li t0, 1482 		# t0 recebe o tamanho de uma imagem de um pokemon
			mul t0, a5, t0		# decide qual imagem renderizar de acordo com a5
			add a0, a0, t0
			
			mv a1, t6	# t6 tem o endere�o de onde a imagem no frame 0
			li t0, 0x00100000
			add a1, a1, t0		# passa o endere�o de a2 para o frame 1
			li a2, 38	# a2 = numero de colunas de uma imagem de um pokemon
			li a3, 39	# a3 = numero de linhas de uma imagem de um pokemon
			call PRINT_IMG
			
		# No frame 1 vai ficar o dialogo com o NAO selecionado
			# Renderiza a caixa de dialogo
			li a0, 0xFF100000		# renderiza a caixa de dialogo no frame 1
			call PRINT_CAIXA_DE_DIALOGO
			
			# Renderiza o dialogo. Todos os dialogos com o NAO selecionado para cada um dos tr�s
			# pokemons iniciais est�o em matriz_dialogo_escolha_pokemon_sim do mesmo modo como 
			# explicado acima
			
			la a4, matriz_dialogo_escolha_pokemon_nao	# carrega a matriz de dialogos
			lw a6, 0(a4)		# a6 recebe o tamanho de uma linha da matriz a4
			addi a4, a4, 8		# pula para onde come�a os tiles no .data
			
			li t0, 86		# cada linha da matriz tem 44 elementos, cada dialogo inclui
						# duas linhas, ent�o t0 = tamanho de um dialogo na matriz a4
			mul t0, t0, a5	# multiplica a5 * 86 de modo que t0 recebe a quantidade de elementos 
			add a4, a4, t0	# entre o inicio da matriz a4 e o dialogo para o pokemon correto
			li a7, 0xFF100000	# os dialogos ser�o renderizados no frame 1
			call PRINT_DIALOGO
		
	# Agora fica em loop, mudando de um frame para o outro de acordo com a tecla apertada (A ou D), 
	# esperando o jogador escolher uma op��o (apertar ENTER)		
				
	LOOP_TECLA_ESCOLHER_POKEMON_INICIAL:
		call VERIFICAR_TECLA
		
		li t0, 0xFF200604	# t0 = endere�o para escolher frames 
		
		li t1, 'd'
		bne a0, t1, TECLA_A_ESCOLHER_POKEMON
			# se o jogador apertou 'd' mostra o frame 1 (onde tem o NAO selecionado)
			li t1, 1
			sb t1, (t0)	# armazena 1 no endere�o de t0 de modo que � mostrado o frame 1
			j LOOP_TECLA_ESCOLHER_POKEMON_INICIAL
			
		TECLA_A_ESCOLHER_POKEMON:
		li t1, 'a'
		bne a0, t1, TECLA_ENTER_ESCOLHER_POKEMON																										
			# se o jogador apertou 'a' mostra o frame 0 (onde tem o SIM selecionado)
			sb zero, (t0)	# armazena 0 no endere�o de t0 de modo que � mostrado o frame 0
			j LOOP_TECLA_ESCOLHER_POKEMON_INICIAL
			
		TECLA_ENTER_ESCOLHER_POKEMON:
		li t1, 10		# 10 � c�digo do ENTER	
		bne a0, t1, LOOP_TECLA_ESCOLHER_POKEMON_INICIAL	
		
	# a5 vai receber o numero do frame que est� na tela, representando a escolha do jogador (0 = Sim, 1 = Nao)	
	li t0, 0xFF200604		# t0 = endere�o para escolher frames 
	lb a5, (t0)			# a5 = valor armazenado em t0 = qual o frame (0 ou 1) que est� na tela			
											
	# Independente do escolhido � necess�rio limpar a tela
	# N�o � possivel saber no final qual dos dois frame � que est� sendo mostrado
	# Sendo assim, a limpeza da tela vai acontecer do seguinte modo:
	# 	(1) ->  analise de qual frame est� sendo mostrado
	#	(2) -> limpa o outro frame
	#	(3) -> mostra o outro frame
	#	(4) -> limpa o frame que estava na tela
	#	(5) -> mostra o frame 0
	
	# (1) ->  analise de qual frame est� sendo mostrado
		li t0, 0xFF200604		# t0 = endere�o para escolher frames 
		lb t4, (t0)			# t4 = valor armazenado em t0 = qual o frame (0 ou 1) que 
						# est� na tela
	
	# (2) -> limpa o outro frame
		# Calculando o endere�o de onde foi impresso a caixa no frame 0
		li a1, 0xFF000000		# seleciona como argumento o frame 0
		li a2, 48 			# numero da coluna 
		li a3, 192			# numero da linha
		call CALCULAR_ENDERECO	
		
		# do retorno do procedimento acima a0 tem o endere�o de onde a caixa de dialogo come�ou
		# a ser impressa. Dessa forma, � necess�rio encontrar o endere�o do tile correspondente na matriz 
		# e no frame
		call CALCULAR_ENDERECO_DE_TILE	
		
		mv t5, a0	# salva o a0 retornado em t5			
		mv t6, a1	# salva o a1 retornado em t6	
		
		# Imprimindo novamente os tiles e limpando a tela no frame inverso a t4
		
		# o a0 retornado tem o endere�o do tile correspondente na matriz		
		# o a1 tem o endere�o de inicio do tile a0 no frame 0, ou seja, o endere�o onde os tiles 
		# v�o come�ar a ser impressos
		xori t0, t4, 1			# inverte o valor de t4
		li t1, 0x00100000		# multiplica 0x0010000 com o inverso de t4 e soma com a1
		mul t0, t0, t1			# de modo que o endere�o de a1 vai para o frame inverso
		add a1, a1, t0			# do que est� na tela
		li a2, 14	# n�mero de colunas de tiles a serem impressas (largura da caixa de dialogo)
		li a3, 3	# n�mero de linhas de tiles a serem impressas (altura da caixa de dialogo)
		call PRINT_TILES_AREA
		
		# Calcula o endere�o de onde foi impresso a caixa com o pokemon no frame 0
		li a1, 0xFF000000		# seleciona como argumento o frame 0
		li a2, 52 			# numero da coluna 
		li a3, 125			# numero da linha
		call CALCULAR_ENDERECO	
		
		# do retorno do procedimento acima a0 tem o endere�o de a caixa com o pokemon come�ou
		# a ser impressa. Dessa forma, � necess�rio encontrar o endere�o do tile correspondente na matriz 
		# e no frame
		call CALCULAR_ENDERECO_DE_TILE	
		
		# Imprimindo novamente os tiles e limpando a tela no frame inverso a t4
		
		# o a0 retornado tem o endere�o do tile correspondente na matriz		
		# o a1 tem o endere�o de inicio do tile a0 no frame 0, ou seja, o endere�o onde os tiles 
		# v�o come�ar a ser impressos
		xori t0, t4, 1			# inverte o valor de t4
		li t1, 0x00100000		# multiplica 0x0010000 com o inverso de t4 e soma com a1
		mul t0, t0, t1			# de modo que o endere�o de a1 vai para o frame inverso
		add a1, a1, t0			# do que est� na tela
		li a2, 5	# n�mero de colunas de tiles a serem impressas (largura da caixa do pokemon)
		li a3, 5	# n�mero de linhas de tiles a serem impressas (altura da caixa do pokemon)
		call PRINT_TILES_AREA
			
	# (3) -> mostra o outro frame
		call TROCAR_FRAME
	
	# (4) -> limpa o frame que estava na tela
		mv a0, t5	# t5 tem salvo o a0 retornado de CALCULAR_ENDERECO_DE_TILE com 
				# o endere�o do tile correspondente		
		mv a1, t6 	# t6 tem salvo o a1 retornado de CALCULAR_ENDERECO_DE_TILE com o endere�o 
				# de inicio do tile a0 no frame 0, ou seja, o endere�o onde os tiles 
				# v�o come�ar a ser impressos
		li t1, 0x00100000	# multiplica 0x0010000 com o valor de t4  soma com a1 de modo que
		mul t0, t4, t1		# que o endere�o de a1 vai para o endere�o correspondente 
		add a1, a1, t0		# no frame que estava na tela
		li a2, 14	# n�mero de colunas de tiles a serem impressas (largura da caixa de dialogo)
		li a3, 3	# n�mero de linhas de tiles a serem impressas (altura da caixa de dialogo)
		call PRINT_TILES_AREA
		
		# Calcula o endere�o de onde foi impresso a caixa com o pokemon no frame 0
		li a1, 0xFF000000		# seleciona como argumento o frame 0
		li a2, 49 			# numero da coluna 
		li a3, 125			# numero da linha
		call CALCULAR_ENDERECO	
		
		# do retorno do procedimento acima a0 tem o endere�o de a caixa com o pokemon come�ou
		# a ser impressa. Dessa forma, � necess�rio encontrar o endere�o do tile correspondente na matriz 
		# e no frame
		call CALCULAR_ENDERECO_DE_TILE	
		
		# Imprimindo novamente os tiles e limpando a tela no frame t4
		
		# o a0 retornado tem o endere�o do tile correspondente na matriz		
		# o a1 tem o endere�o de inicio do tile a0 no frame 0, ou seja, o endere�o onde os tiles 
		# v�o come�ar a ser impressos
		xori t0, t4, 1			# inverte o valor de t4
		li t1, 0x00100000		# multiplica 0x0010000 com o inverso de t4 e soma com a1
		mul t0, t4, t1			# de modo que o endere�o de a1 vai para o frame inverso
		add a1, a1, t0			# do que est� na tela
		li a2, 5	# n�mero de colunas de tiles a serem impressas (largura da caixa do pokemon)
		li a3, 5	# n�mero de linhas de tiles a serem impressas (altura da caixa do pokemon)
		call PRINT_TILES_AREA
							
	# (5) -> mostra o frame 0																				
		li t0, 0xFF200604		# t0 = endere�o para escolher frames 
		sb zero, (t0)			# armazena 0 no endere�o de t0
	
	bne a5, zero, FIM_ESCOLHA_DE_POKEMON_INICIAL	
	# Caso o jogador tem escolhido a op��o SIM � necess�rio renderizar o pr�ximo dialogo do professor	
	# e atualizar a matriz de movimenta��o para que n�o seja poss�vel escolher um pokemon novamente
		
		# Imprime o dialogo do professor
		la a4, matriz_dialogo_oak_laboratorio_2	# carrega a matriz de tiles do dialogo
		li a5, 1				# renderiza 1 dialogo	
		call RENDERIZAR_DIALOGOS																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																								
						
		# Para atualizar a matriz � necess�rio substituir os tiles onde tem as mesas com as
		# pokebolas por 0 para impedir a escolha e a movimenta��o do RED
		
		la t0, matriz_movimentacao_laboratorio	# carrega a matriz do laboratorio
		addi t0, t0, 8		# pula para onde come�a os tiles no .data
		
		addi t0, t0, 89		# t0 � movido por 5 linhas e 9 colunas (16 * 5 + 9 = 89), recebendo
					# o endere�o de inicio da primeira mesa (Bulbasaur)
		
		sb zero, 0(t0)		# substitui os elementos das duas posi��es com a mesa com zero
		sb zero, 16(t0)
		
		addi t0, t0, 2		# t0 � movido por 2 colunas, recebendo o endere�o de inicio da
					# proxima mesa (Charmander)
		
		sb zero, 0(t0)		# substitui os elementos das duas posi��es com a mesa com zero
		sb zero, 16(t0)
				
		addi t0, t0, 2		# t0 � movido por 2 colunas, recebendo o endere�o de inicio da
					# proxima mesa (Squirtle)
		
		sb zero, 0(t0)		# substitui os elementos das duas posi��es com a mesa com zero
		sb zero, 16(t0)		
		
		# Por fim, � necess�rio liberar a saida do RED pela saida do laboratorio
		
		la t0, matriz_movimentacao_laboratorio	# carrega a matriz do laboratorio
		addi t0, t0, 8		# pula para onde come�a os tiles no .data
		
		addi t0, t0, 231	# t0 � movido por 14 linhas e 7 colunas (16 * 14 + 7 = 231), recebendo
					# o endere�o de inicio da saida do laboratorio
		
		li t1, 73
		sb t1, 0(t0)		# armazena na matriz o codigo para sair do laboratorio e entrar em Pallet		
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																											
	FIM_ESCOLHA_DE_POKEMON_INICIAL:
	
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha

	ret

# ====================================================================================================== #	

RENDERIZAR_DIALOGOS:
	# Procedimento auxiliar aos procedimento de hist�ria que imprime uma caixa de dialogo com uma
	# quantidade vari�vel de textos.
	# Para imprimir os dialogos � necess�rio uma matriz de tiles. Nessa matriz cada dialogo s� pode 
	# ter no m�ximo 2 linhas, mas � poss�vel encadear um dialogo com outro na mesma matriz, de modo que
	# quando 2 linhas da matriz forem renderizadas o procedimento vai esperar o jogador apertar ENTER e 
	# vai imprimir as proximas 2 linhas, e assim por diante imprimindo a5 dialogos.
	# Para que o procedimento funcione � necess�rio que a matriz em a5 especifique um n�mero par de dialogos
	# (j� que ser�o impressas 2 linhas por vez) e que cada linha da matriz tenha o mesmo numero de elementos
	#
	# Argumentos:
	#	a4 = matriz de tiles condificando o texto do dialogo de acordo com tiles_alfabeto
	#	a5 = n�mero de dialogos especificados na matriz (lembrando que cada dialogo tem 2 linhas)
			
	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, 0(sp)		# empilha ra	
		
	lw a6, 0(a4)		# a6 recebe o tamanho de uma linha da matriz de tiles	
	addi a4, a4, 8		# pula para onde come�a os tiles no .data	
	
	# Impreme os a5 dialogos
	LOOP_PRINT_DIALOGO:	
		# Primeiro imprime a caixa de dialogo na tela
		li a0, 0xFF000000	# a0 tem o endere�o base do frame 0
		
		li t0, 0xFF200604		# t0 = endere�o para escolher frames 
		lb t1, (t0)			# t1 = valor armazenado em t0 = qual o frame (0 ou 1) que 
						# est� na tela
		xori t0, t1, 1			# inverte o valor de t1				
		li t1, 0x00100000
		mul t0, t0, t1		# multiplica o bit de t0 por 0x00100000 e soma com a0 de modo que o				
		add a0, a0, t0		# endere�o de a0 vai para o frame que n�o est� sendo mostrado
		call PRINT_CAIXA_DE_DIALOGO
			
		# Impreme o dialogo
			
		# a4 j� tem a matriz de tiles do dialogo
		# a6 j� tem tamanho de uma linha da matriz de tiles	
		li a7, 0xFF000000	# a7 tem o endere�o base do frame 0
		
		li t0, 0xFF200604		# t0 = endere�o para escolher frames 
		lb t1, (t0)			# t1 = valor armazenado em t0 = qual o frame (0 ou 1) que 
						# est� na tela
		xori t0, t1, 1			# inverte o valor de t1				
		li t1, 0x00100000
		mul t0, t0, t1		# multiplica o bit de t0 por 0x00100000 e soma com a0 de modo que o				
		add a7, a7, t0		# endere�o de a7 vai para o frame que n�o est� sendo mostrado		
		call PRINT_DIALOGO
		# pelo funcionamento do PRINT_DIALOGO o valor de a4 j� � convenientemente atualizado de modo
		# que ele aponta para as pr�ximas 2 linhas de dialogo	
		# al�m disso, o valor de a6 � preservado durante o loop	
		
		call TROCAR_FRAME		# inverte o frame sendo mostrado
				
		LOOP_TECLA_ENTER_PRINT_DIALOGO:
			# Espera o jogador apertar ENTER para ir para o proximo dialogo
			call VERIFICAR_TECLA			# verifica se alguma tecla foi apertada	
			li t0, 10				# t0 = 10 = valor da tecla ENTER
			bne a0, t0, LOOP_TECLA_ENTER_PRINT_DIALOGO	# se a0 = 10 -> tecla ENTER foi apertada 
		
		addi a5, a5, -1				# decrementa o numero de dialogos restantes
		bne a5, zero, LOOP_PRINT_DIALOGO	# reinicia o loop se a5 != 0																																							

	# Agora � necess�rio limpar a caixa de dialogo da tela imprindo novamente os tiles nos dois frames
	
	# O loop acima pode ser executado um numero arbitrario de vezes de acordo com o valor de a5,
	# assim n�o � possivel saber no final qual dos dois frame � que est� sendo mostrado
	# Sendo assim, a limpeza da tela vai acontecer do seguinte modo:
	# 	(1) ->  analise de qual frame est� sendo mostrado
	#	(2) -> limpa o outro frame
	#	(3) -> mostra o outro frame
	#	(4) -> limpa o frame que estava na tela
	#	(5) -> mostra o frame 0
	
	# (1) ->  analise de qual frame est� sendo mostrado
		li t0, 0xFF200604		# t0 = endere�o para escolher frames 
		lb t4, (t0)			# t4 = valor armazenado em t0 = qual o frame (0 ou 1) que 
						# est� na tela
	
	# (2) -> limpa o outro frame
		# Calculando o endere�o de onde foi impresso a caixa no frame 0
		li a1, 0xFF000000		# seleciona como argumento o frame 0
		li a2, 48 			# numero da coluna 
		li a3, 192			# numero da linha
		call CALCULAR_ENDERECO	
		
		# do retorno do procedimento acima a0 tem o endere�o de onde a caixa de dialogo come�ou
		# a ser impressa. Dessa forma, � necess�rio encontrar o endere�o do tile correspondente na matriz 
		# e no frame
		call CALCULAR_ENDERECO_DE_TILE	
		
		mv t5, a0	# salva o a0 retornado em t5			
		mv t6, a1	# salva o a1 retornado em t6	
		
		# Imprimindo novamente os tiles e limpando a tela no frame inverso a t4
		
		# o a0 retornado tem o endere�o do tile correspondente na matriz		
		# o a1 tem o endere�o de inicio do tile a0 no frame 0, ou seja, o endere�o onde os tiles 
		# v�o come�ar a ser impressos
		xori t0, t4, 1			# inverte o valor de t4
		li t1, 0x00100000		# multiplica 0x0010000 com o inverso de t4 e soma com a1
		mul t0, t0, t1			# de modo que o endere�o de a1 vai para o frame inverso
		add a1, a1, t0			# do que est� na tela
		li a2, 14	# n�mero de colunas de tiles a serem impressas (largura da caixa de dialogo)
		li a3, 3	# n�mero de linhas de tiles a serem impressas (altura da caixa de dialogo)
		call PRINT_TILES_AREA
		
	# (3) -> mostra o outro frame
		call TROCAR_FRAME
	
	# (4) -> limpa o frame que estava na tela
		mv a0, t5	# t5 tem salvo o a0 retornado de CALCULAR_ENDERECO_DE_TILE com 
				# o endere�o do tile correspondente		
		mv a1, t6 	# t6 tem salvo o a1 retornado de CALCULAR_ENDERECO_DE_TILE com o endere�o 
				# de inicio do tile a0 no frame 0, ou seja, o endere�o onde os tiles 
				# v�o come�ar a ser impressos
		li t1, 0x00100000	# multiplica 0x0010000 com o valor de t4  soma com a1 de modo que
		mul t0, t4, t1		# que o endere�o de a1 vai para o endere�o correspondente 
		add a1, a1, t0		# no frame que estava na tela
		li a2, 14	# n�mero de colunas de tiles a serem impressas (largura da caixa de dialogo)
		li a3, 3	# n�mero de linhas de tiles a serem impressas (altura da caixa de dialogo)
		call PRINT_TILES_AREA
			
	# (5) -> mostra o frame 0																				
		li t0, 0xFF200604		# t0 = endere�o para escolher frames 
		sb zero, (t0)			# armazena 0 no endere�o de t0

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha

	ret
	
# ====================================================================================================== #

PRINT_DIALOGO:
	# Procedimento auxiliar a RENDERIZAR_DIALOGOS que usa uma matriz de tiles para imprimir duas 
	# linhas de um dialogo no frame 0.
	# Cada texto de um dialogo � codificado em uma matriz de tiles, a diferen�a � que enquanto 
	# normalmente os tiles do jogo tem 16 x 16, os tiles dos textos tem 8 x 15.
	# Todos os textos s�o construidos com os tiles em "../Imagens/historia/dialogos/tiles_alfabeto".
	# Para renderizar o dialogo � necess�rio fornecer uma matriz de tiles, onde cada tile
	# � uma letra desse alfebeto.
	# Esse procedimento s� imprime 2 linhas da matriz de tiles do dialogo.
	# 
	# Argumentos:
	#	a4 = matriz de tiles condificando o texto do dialogo de acordo com tiles_alfabeto
	# 	a6 = tamanho de uma linha da matriz em a4
	# 	a7 = endere�o base do frame 0 ou 1 indicando o frame onde os tile ser�o impressos

	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, 0(sp)		# empilha ra

	# Calculando o endere�o de onde imprimir a primeira letra do dialogo
		mv a1, a7		# move para a1 o endere�o do frame onde os tiles ser�o renderizados 
		li a2, 63 			# numero da coluna 
		li a3, 198			# numero da linha
		call CALCULAR_ENDERECO	
		
		mv a1, a0	# do retorno do procedimento acima a0 tem o endere�o de onde come�ar a 
				# imprimir as letras

	la t3, tiles_alfabeto	# carrega a imagem com os tiles do alfabeto
	addi t3, t3, 8		# pula para onde come�a os pixels no .data

	li t4, 2		# numero de linhas de tiles a serem impressas

	PRINT_DIALOGO_LINHAS:
		mv t5, a6		# copia do numero de colunas para usar no loop abaixo 
				
		PRINT_DIALOGO_COLUNAS:
			lb t0, 0(a4)	# pega 1 elemento da matriz de tiles e coloca em t0
		
			# um tile com valor -1 significa um fim de linha, eles s�o usados porque cada
			# dialogo precisa ter linhas de mesmo tamanho, ent�o tiles com valor -1 completam
			# as linhas para que esse criterio seja cumprido, por�m eles n�o s�o renderizados
			li t1, -1
			beq t0, t1, PROXIMO_TILE_DIALOGO
		
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
			
			li t1, 1		# se o numero do tile for menor do que 63		
			li t2, 63		# ent�o � necess�rio voltar 1 pixel
			blt t0, t2, PROXIMO_TILE_DIALOGO
			li t1, 2		# se o numero do tile for maior ou igual a 63 e menor do que 73
			li t2, 73		# ent�o � necess�rio voltar 2 pixels
			blt t0, t2, PROXIMO_TILE_DIALOGO
			li t1, 4		# se o numero do tile for maior que 73 e menor que 75 volta 
			li t2, 75		# 4 pixels
			ble t0, t2, PROXIMO_TILE_DIALOGO			
			li t2, 5		# caso contr�rio volta 5 pixels
									
			PROXIMO_TILE_DIALOGO:
			
			sub a1, a1, t1	# atualiza o endere�o onde o proximo tile ser� impresso de acordo com
					# o valor de t1 decidido acima		
						
			addi a4, a4, 1		# vai para o pr�ximo elemento da matriz de tiles
									
			addi t5, t5, -1			# decrementando o numero de colunas de tiles restantes
			bne t5, zero, PRINT_DIALOGO_COLUNAS	# reinicia o loop se t5 != 0
		
		# Calculando o endere�o de onde imprimir a segunda linha do dialogo
		mv a1, a7		# move para a1 o endere�o do frame onde os tiles ser�o renderizados 
		li a2, 63 			# numero da coluna 
		li a3, 213			# numero da linha
		call CALCULAR_ENDERECO	
			
		mv a1, a0	# como retorno do procedimento acima a0 tem o endere�o de inicio da segunda 
				# linha do dialogo
				
		addi t4, t4, -1				# decrementando o numero de linhas restantes
		bne t4, zero, PRINT_DIALOGO_LINHAS	# reinicia o loop se t4 != 0
				
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha

	ret
	
# ====================================================================================================== #

PRINT_CAIXA_DE_DIALOGO:
	# Procedimento auxiliar a RENDERIZAR_DIALOGOS que imprime uma caixa de dialogo em uma posi��o
	# fixa no frame 0 ou 1. Para imprimir a caixa � usado "../Imagens/historia/dialogos/tiles_caixa_dialogo",
	# de modo que a impress�o funciona de maneira similar a qualquer outra matriz de tiles.
	#
	# Argumentos:
	#	a0 = endere�o base do frame 0 ou 1 indicando o frame onde a caixa ser� renderizada
 	
	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, 0(sp)		# empilha ra

	# Calculando o endere�o de onde imprimir a caixa no frame 0
		mv a1, a0		# move para a1 o endere�o do frame onde a caixa ser� renderizada 
		li a2, 48 		# numero da coluna 
		li a3, 192		# numero da linha
		call CALCULAR_ENDERECO	
		
		mv a2, a0	# do retorno do procedimento acima a0 tem o endere�o de onde imprimir a caixa
		
	# Imprimindo os tiles da caixa
		la a0, matriz_tiles_caixa_dialogo	# carrega a matriz de tiles da caixa
		la a1, tiles_caixa_dialogo		# carrega a imagem com os tiles da caixa
		# a2 j� tem o endere�o de onde imprimir as caixas
		call PRINT_TILES

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha

	ret
		
# ====================================================================================================== #																																			
.data
	.include "../Imagens/outros/balao_exclamacao.data"

	.include "../Imagens/historia/professor_carvalho/oak_cima.data"
	.include "../Imagens/historia/professor_carvalho/oak_cima_passo_direito.data"
	.include "../Imagens/historia/professor_carvalho/oak_cima_passo_esquerdo.data"
	.include "../Imagens/historia/professor_carvalho/oak_direita.data"
	.include "../Imagens/historia/professor_carvalho/oak_direita_passo_direito.data"
	.include "../Imagens/historia/professor_carvalho/oak_direita_passo_esquerdo.data"	
	.include "../Imagens/historia/professor_carvalho/oak_baixo.data"
	.include "../Imagens/historia/professor_carvalho/oak_baixo_passo_direito.data"
	.include "../Imagens/historia/professor_carvalho/oak_baixo_passo_esquerdo.data"	
	.include "../Imagens/historia/professor_carvalho/oak_esquerda.data"
	.include "../Imagens/historia/professor_carvalho/oak_esquerda_passo_direito.data"
	.include "../Imagens/historia/professor_carvalho/oak_esquerda_passo_esquerdo.data"	
			
	.include "../Imagens/historia/dialogos/tiles_caixa_dialogo.data"
	.include "../Imagens/historia/dialogos/matriz_tiles_caixa_dialogo.data"

	.include "../Imagens/historia/dialogos/tiles_alfabeto.data"

	.include "../Imagens/historia/escolha_pokemon_inicial/matriz_dialogo_escolha_pokemon_sim.data"
	.include "../Imagens/historia/escolha_pokemon_inicial/matriz_dialogo_escolha_pokemon_nao.data"	
	
	.include "../Imagens/historia/escolha_pokemon_inicial/matriz_tiles_caixa_escolha_pokemon.data"	
	.include "../Imagens/historia/escolha_pokemon_inicial/tiles_caixa_escolha_pokemon.data"	
			
	.include "../Imagens/pokemons/pokemons_menu.data"	
				
	.include "../Imagens/historia/dialogos/matriz_dialogo_oak_pallet_1.data"	
	.include "../Imagens/historia/dialogos/matriz_dialogo_oak_pallet_2.data"	
	.include "../Imagens/historia/dialogos/matriz_dialogo_oak_laboratorio_1.data"	
	.include "../Imagens/historia/dialogos/matriz_dialogo_oak_laboratorio_2.data"	
