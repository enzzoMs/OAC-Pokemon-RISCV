.text

# ====================================================================================================== # 
# 						 HISTORIA				                 #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# C�digo com os procedimentos necess�rios para renderizar os momentos de hist�ria do jogo, incluindo	 #
# imprimir caixas de di�logo e executar algumas anima��es 						 #
#													 #
# Esse arquivo possui 3 procedimentos principais, um para cada momento de hist�ria do jogo:		 #
#	RENDERIZAR_ANIMACAO_PROF_OAK, ...								 #
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
	
	# Imprimindo o bal�o de exclama��o no frame 0			
		la a0, balao_exclamacao		# carrega a imagem
		addi a0, a0, 8			# pula para onde come�a os pixels no .data
		# do retorno do procedimento CALCULAR_ENDERECO_DE_TILE a1 j� tem o endere�o de inicio 
		# do tile onde a cabe�a do RED est� 
		li a2, 16			# a2 = numero de colunas de um tile
		li a3, 16			# a3 = numero de linhas de um tile
		call PRINT_IMG

	# Espera alguns milisegundos	
		li a0, 1500			# sleep 1,5 s
		call SLEEP			# chama o procedimento SLEEP	
		
	# Agora � necess�rio trocar a orienta��o do RED para que ele fique virado para baixo
			
	la a4, red_baixo	# carrega como argumento o sprite do RED virada para baixo		
	call MUDAR_ORIENTACAO_RED
			
	li s1, 3	# atualiza o valor de s1 dizendo que agora o RED est� virado para baixo
	
	# Obs: a mudan�a de orienta��o naturalmente vai retirar a imagem do bal�o de exclama��o
	
	# Agora come�a a anima��o do professor Carvalho
	# Na primeira parte o sprite do professor dando um passo direito para cima ser� lentamente impressa,
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
		la a0, oak_cima_passo_direito	# carrega o sprite do professor	
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
		li t0, 20		# 19 � a altura do sprite do professor (+ 1 porque t5 come�a no 0)
		bne t5, t0, LOOP_PROFESSOR_ENTRANDO	# reinicia o loop se t5 != 19 		
	
	addi t3, t3, 320	# na ultima itera��o o valor de t3 � decrementado mais uma vez desnecessariamente
				# portanto, � necess�rio reverter essa mudan�a 				

	# Agora realiza a anima��o de movimenta��o do professor 
	
	mv a0, t3		# dos calculos acima t3 ainda tem a posi��o do ultimo sprite do 
				# professor no frame 0 
	
	li t6, -1		# contador para o loop abaixo, de modo que cada loop representa uma movimenta��o
				# do professor em alguma orienta��o

	LOOP_MOVER_PROFESSOR:
	
	addi t6, t6, 1		# incrementa o numero de loops feitos
	
	# Primeiro determina qual � o sentido da movimenta��o do professor de acordo com o numero da itera��o,
	# de modo que a anima��o siga o seguinte padr�o:
	# PROF SOBE 4 TILES -> PERSONAGEM DANDO UM PASSO -> PERSONAGEM PARADO	
	li t0, 3		
	ble t6, t0, MOVER_PROFESSOR_CIMA
	
	addi t0, t0, 1 			# a movimenta��o do professor para a direita depende de onde o RED 
	lb t1, -1(s6)			# est�. Para decidir isso � poss�vel utilizar o valor da posi��o a 
	add t0, t0, t1			# esquerda de onde ele est� na matriz de movimenta��o. 
					# Obs: essa posi��o da matriz s� pode ter 0 ou 1 
	ble t6, t0, MOVER_PROFESSOR_DIREITA
	
	addi t0, t0, 1		
	ble t6, t0, MOVER_PROFESSOR_CIMA
					
	j FIM_MOVER_PROFESSOR

		MOVER_PROFESSOR_CIMA:
		# Decide os valores de a4 e a7 para a movimenta��o	
		
		la a4, oak_cima		# carrega a imagem do professor parado virado para cima
		li a7, 0		# a = 0 = anima��o para cima																
		
		# Decide se o professor vai ser renderizado dando o passo com o p� esquerdo ou direito
		# de acordo com o valor de a5	
						
		# Com o branch abaixo � possivel alternar entre os passos esquerdo e direito a cada itera��o		
		la t0, oak_cima_passo_esquerdo				
		beq a5, t0, PROFESSOR_CIMA_PASSO_DIREITO
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
		# de acordo com o valor de a5	
						
		# Com o branch abaixo � possivel alternar entre os passos esquerdo e direito a cada itera��o		
		la t0, oak_direita_passo_esquerdo				
		beq a5, t0, PROFESSOR_DIREITA_PASSO_DIREITO
			la a5, oak_direita_passo_esquerdo	
			j MOVER_PROFESSOR_DIREITA
			
		PROFESSOR_DIREITA_PASSO_DIREITO:		
			la a5, oak_direita_passo_direito
			j MOVER_PROFESSOR
			
		# -------------------------------------------------------------------------------------------
																																																																					
		MOVER_PROFESSOR:				
		# a4 j� tem a imagem do professor parado
		# a5 tem a a imagem do professor dando um passo	
		mv a6, a0		# a0 tem o endere�o de onde imprimir o sprite do professor
		# a7 tem o n�mero indicando qual o sentido da movimenta��o															
		call MOVER_PERSONAGEM	
	
		j LOOP_MOVER_PROFESSOR
		
	FIM_MOVER_PROFESSOR:
																							
	a: j a

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
