.data

# Matrizes de texto
# Uma matriz de texto � uma matriz em que cada elemento representa um tile de tiles_alfabeto.data, sendo usados
# para imprimir um nome geralmente curto na tela. Os labels est�o no formato matriz_texto_Y, onde Y � o texto
# que a matriz se refere

matriz_texto_atacar: .word 6, 1 
		     .byte 39,60,39,36,39,35
			
matriz_texto_defesa: .word 6, 1 
		       .byte 34,22,62,22,30,39

matriz_texto_item: .word 4, 1 
		     .byte 57,60,22,27
		     
matriz_texto_fugir: .word 5, 1 
		     .byte 62,40,61,57,35

matriz_texto_um: .word 3, 1 
		 .byte 40,69,77			# inclui espa�o no final
		     
matriz_texto_selvagem: .word 9, 1 
		     .byte 77,71,4,76,11,0,5,4,69	# inclui espa�o no come�o     	
		     
matriz_texto_apareceu: .word 9, 1 
		     .byte 0,9,0,70,4,2,4,73,74		# inclui exclama��o no final 

matriz_texto_escolha_o_seu_pokemon: .word 22, 1 		# inclui exclama��o no final 
		     .byte 22,71,2,8,76,6,0,77,8,77,71,4,73,77,24,25,26,29,27,25,28,74	
			
matriz_texto_escolhido: .word 11, 1 		# inclui espa�o no come�o e ponto no final
		.byte 77,4,71,2,8,76,6,78,3,8,54	
				
.text
		     			 			 
# ====================================================================================================== # 
# 						 COMBATE				                 #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# C�digo com os procedimentos necess�rios para renderizar e executar a logica das cenas de batalha	 # 
# do jogo.												 #
#												 	 # 
# ====================================================================================================== #

VERIFICAR_COMBATE:
	# Procedimento principal de combate.s, ele � chamado depois de cada procedimento de movimenta��o 
	# e verifica se: 1) o RED est� em um tile de grama e 2} de acordo com uma certa chance, verificar se 
	# esse tile vai iniciar um combate com um pokemon selvagem. Caso inicie o combate ele vai chamar
	# os outros procedimentos necess�rios

	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra
		
	lb t0, 0(s6)			# checa a posi��o do RED na matriz de movimenta��o (s6)
	li t1, 7			# 7 � codigo de um tile de grama
	bne t0, t1, FIM_VERIFICAR_COMBATE
	
	li a0, 5				# encontra um numero randomico entre 0 e 4
	call ENCONTRAR_NUMERO_RANDOMICO		
	bne a0, zero, FIM_VERIFICAR_COMBATE	# se o numero encontrado for 0 ent�o esse tile vai iniciar o
						# combate com um pokemon, desse modo o combate tem em teoria 
						# 1/5 chance de acontecer cada vez que o RED passa pela grama
		call EXECUTAR_COMBATE
	
	FIM_VERIFICAR_COMBATE:
	
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret 

# ====================================================================================================== #

EXECUTAR_COMBATE:
	# Procedimento que vai coordenar o combate do jogo, chamado todos os outros procedimentos necess�rios
	
	call INICIAR_TELA_DE_COMBATE		# inicia a tela de combate

	call INICIAR_POKEMON_INIMIGO	# imprime os sprites e outros elementos relacionados ao pokemon inimigo

	call INICIAR_POKEMON_RED	# imprime os sprites e outros elementos relacionados ao pokemon do RED
	
	a: j a
	
# ====================================================================================================== #

INICIAR_TELA_DE_COMBATE:
	# Procedimento que vai imprimir um bal�o de exclama��o sobre o RED indicando que um combate vai acontecer,
	# e imprimir a tela de combate com todos os textos iniciais do menu de op��es

	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Espera alguns milisegundos	
		li a0, 800			# sleep 800 ms
		call SLEEP			# chama o procedimento SLEEP	

	# Imprimindo o bal�o de exclama��o sobre a cabe�a do RED no frame 0
	# O bal�o funciona que nem um tile normal, a diferen�a � que tem fundo transparente
	
	mv a0, s0			# calcula o endere�o de inicio do tile onde a cabe�a do RED est� (s0)
	call CALCULAR_ENDERECO_DE_TILE	# no frame 0
	
	# Imprimindo o bal�o de exclama��o no frame 0			
		la a0, balao_exclamacao		# carrega a imagem
		addi a0, a0, 8			# pula para onde come�a os pixels no .data
		# do retorno do procedimento CALCULAR_ENDERECO_DE_TILE a1 j� tem o endere�o de inicio 
		# do tile onde a cabe�a do RED est� 
		li a2, 16			# a2 = numero de colunas de um tile
		li a3, 16			# a3 = numero de linhas de um tile
		call PRINT_IMG

	# Espera alguns milisegundos	
		li a0, 1200			# sleep 1.2 s
		call SLEEP			# chama o procedimento SLEEP	

	call TROCAR_FRAME	# troca o frame sendo mostrado, mostrando o frame 1

	# De inicio � necess�rio imprimir alguns retangulos com a cor 190, isso porque os tiles do inventario
	# e combate s�o compartilhados para economizar memoria, ent�o especificamente os cantos da caixa
	# onde os dialogos e menu de a��o estar�o s�o transparentes, mas o ideal � que apare�a a cor do fundo
	# da tela de combate (190)

	# Calculando o endere�o de onde imprimir o primeiro retangulo
		li a1, 0xFF000000		# seleciona como argumento o frame 0
		li a2, 16 			# numero da coluna 
		li a3, 176			# numero da linha
		call CALCULAR_ENDERECO		
			
		mv a1, a0	# move o retorno para a1
			
		# Imprimindo o rentangulo com a cor
		li a0, 190		# a0 tem o valor do fundo do menu da tela do combate
		# a1 j� tem o endere�o de onde come�ar a impressao		
		li a2, 4		# numero de colunas da imagem da seta
		li a3, 48		# numero de linhas da imagem da seta			
		call PRINT_COR

		# Imprimindo o rentangulo com a cor
		li a0, 182		# a0 tem o valor do fundo do menu do inventario
		li a0, 190		# a0 tem o valor do fundo do menu da tela do combate
		li t0, -15075 		# -15075 = -48 * 320 + 285			
		add a1, a1, t0		# o proximo retangulo come�a a -48 linhas e 285 colunas de onde o ultimo
					# terminou de ser impresso
		li a2, 4		# numero de colunas da imagem da seta
		li a3, 48		# numero de linhas da imagem da seta			
		call PRINT_COR
		
	# Agora imprime a tela de combate no frame 0 com os textos necess�rios
		# Imprimindo a tela no frame 0
		la a0, matriz_tiles_tela_combate	# carrega a matriz de tiles
		la a1, tiles_combate_e_inventario	# carrega a imagem com os tiles
		li a2, 0xFF000000			# os tile ser�o impressos no frame indicado por t6
		call PRINT_TILES

		# Imprimindo os textos do menu de combate no frame 0
			# Calculando o endere�o de onde imprimir o primeiro texto (ATACAR) no frame 0
			li a1, 0xFF000000	# seleciona o frame 0
			li a2, 195		# numero da coluna 
			li a3, 185		# numero da linha
			call CALCULAR_ENDERECO	
			
			mv a1, a0		# move o retorno para a1
			
			# Imprime o texto com o ATACAR
			# a1 j� tem o endere�o de onde imprimir o texto
			la a4, matriz_texto_atacar 	
			call PRINT_TEXTO
			
			# Imprime o texto com o FUGIR
			addi a1, a1, 18		# pelo PRINT_TEXTO acima a1 ainda est� no ultimo endere�o onde
						# imprimiu o tile, de modo que est� a 18 colunas do proximo texto
			la a4, matriz_texto_fugir 	
			call PRINT_TEXTO
			
			# Imprime o texto com o DEFESA
			addi a1, a1, -95	# pelo PRINT_TEXTO acima a1 ainda est� no ultimo endere�o onde
			li t0, 5440		# imprimiu o tile, de modo que est� a -95 colunas e +17 linhas
			add a1, a1, t0		# do proximo texto (5440 = 17 * 320)
			la a4, matriz_texto_defesa 	
			call PRINT_TEXTO
			
			# Imprime o texto com o ITEM
			addi a1, a1, 18		# pelo PRINT_TEXTO acima a1 ainda est� no ultimo endere�o onde
						# imprimiu o tile, de modo que est� a 18 colunas do proximo texto
			la a4, matriz_texto_item 	
			call PRINT_TEXTO
												
	call TROCAR_FRAME	# troca o frame sendo mostrado, mostrando o frame 0

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret 

# ====================================================================================================== #																																			

INICIAR_POKEMON_INIMIGO:
	# Procedimento que atualiza o valor de s11 com o pokemon inimigo e imprime todos os sprites,
	# anima��es e textos relacionados a esse pokemon aparecendo na tela

	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	# Primeiro sorteia qual � o pokemon inimigo, atualiza os primeiros bits de s11 com o codigo correto,
	# e escolhe a matriz de texto correta com o nome do pokemon (t5)
	
	li a0, 5				# encontra um numero randomico entre 0 e 4
	call ENCONTRAR_NUMERO_RANDOMICO		
	
	# se a0 == 0 ent�o � pokemon inimigo ser� o BULBASAUR 
	li s11, BULBASAUR 			# codigo do BULBASAUR
	la t5, matriz_texto_bulbasaur		# carrega a matriz de texto do pokemon
	beq a0, zero, PRINT_TEXTO_POKEMON_INIMIGO
			
	# se a0 == 1 ent�o � pokemon inimigo ser� o CHARMANDER 
	li t0, 1	
	li s11, CHARMANDER 			# codigo do CHARMANDER	
	la t5, matriz_texto_charmander		# carrega a matriz de texto do pokemon	
	beq a0, t0, PRINT_TEXTO_POKEMON_INIMIGO
			
	# se a0 == 2 ent�o � pokemon inimigo ser� o SQUIRTLE 
	li t0, 2	
	li s11, SQUIRTLE 			# codigo do SQUIRTLE
	la t5, matriz_texto_squirtle		# carrega a matriz de texto do pokemon				
	beq a0, t0, PRINT_TEXTO_POKEMON_INIMIGO
										
	# se a0 == 3 ent�o � pokemon inimigo ser� o CATERPIE 
	li t0, 3	
	li s11, CATERPIE 			# codigo do CATERPIE	
	la t5, matriz_texto_caterpie		# carrega a matriz de texto do pokemon			
	beq a0, t0, PRINT_TEXTO_POKEMON_INIMIGO
	
	# se a0 == 4 ent�o � pokemon inimigo ser� o DIGLETT 
	li t0, 4	
	li s11, DIGLETT 			# codigo do DIGLETT
	la t5, matriz_texto_diglett		# carrega a matriz de texto do pokemon		
	
	PRINT_TEXTO_POKEMON_INIMIGO:
	
	mv t6, a0	# salva em t6 o numero do pokemon escolhido
	
	# Agora imprime o texto "Um YYY selvagem apareceu!", onde YYY � o nome do pokemon
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 1
	
		# Calculando o endere�o de onde imprimir o primeiro texto (Um) no frame 0
			li a1, 0xFF000000	# seleciona o frame 0
			li a2, 28		# numero da coluna 
			li a3, 185		# numero da linha
			call CALCULAR_ENDERECO	
			
			mv a1, a0		# move o retorno para a1

		# Imprime o texto com o 'Um '
		# a1 j� tem o endere�o de onde imprimir o texto
		la a4, matriz_texto_um 	
		call PRINT_TEXTO
		
		# Imprime o texto com o nome do Pokemon
		# pelo PRINT_TEXTO acima a1 ainda est� no ultimo endere�o onde imprimiu o tile,
		# de modo que est� na posi��o exata do proximo texto
		mv a4, t5		# a4 recebe a matriz de texto do pokemon decidido acima
		call PRINT_TEXTO

		# Imprime o texto com o ' selvagem'
		# pelo PRINT_TEXTO acima a1 ainda est� no ultimo endere�o onde imprimiu o tile,
		# de modo que est� na posi��o exata do proximo texto
		la a4, matriz_texto_selvagem 	
		call PRINT_TEXTO
		
		# Calculando o endere�o de onde imprimir o ultimo texto ('apareceu!') no frame 0
			li a1, 0xFF000000	# seleciona o frame 0
			li a2, 28		# numero da coluna 
			li a3, 201		# numero da linha
			call CALCULAR_ENDERECO	
			
			mv a1, a0		# move o retorno para a1		
					
		# Imprime o texto com o 'apareceu!'
		# a1 j� tem o endere�o de onde imprimir o texto					
		la a4, matriz_texto_apareceu 	
		call PRINT_TEXTO
			
		# Por fim, imprime uma pequena seta indicando que o jogador pode apertar ENTER para avan�ar
		# o dialogo						
			# Calculando o endere�o de onde imprimir a seta no frame 0
			li a1, 0xFF000000	# seleciona o frame 0
			li a2, 159		# numero da coluna 
			li a3, 207		# numero da linha
			call CALCULAR_ENDERECO											
			
			mv t3, a0		# move o retorno para t3		
						
			# Imprimindo a imagem da seta no frame 0
			la a0, seta_proximo_dialogo_combate		# carrega a imagem				
			mv a1, t3		# t3 tem o endere�o de onde imprimir a imagem
			lw a2, 0(a0)		# numero de colunas da imagem
			lw a3, 4(a0)		# numero de linhas da imagem
			addi a0, a0, 8		# pula para onde come�a os pixels no .data	
			call PRINT_IMG																							
																																																											
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 0
	
	# Espera o jogador apertar ENTER	
	LOOP_ENTER_POKEMON_INIMIGO:
		call VERIFICAR_TECLA
		
		li t0, 10		# 10 � o codigo do ENTER	
		bne a0, t0, LOOP_ENTER_POKEMON_INIMIGO
	
	# Limpa a caixa de dialogo no frame 0 somente para indicar que o n�o mais necess�rio apertar ENTER					
		# Para retirar a imagem da seta basta imprimir uma �rea de mesmo tamanho com a cor
		# de fundo do inventario
		li a0, 0xFF		# a0 tem o valor do fundo do menu da caixa de dialogo (branco)
		mv a1, t3		# t3 ainda tem o endere�o de onde a seta est�		
		li a2, 10		# numero de colunas da imagem da seta
		li a3, 6		# numero de linhas da imagem da seta	
		call PRINT_COR						
							
	# Agora renderiza o pokemon inimigo aparecendo na tela
		mv a0, t6		# t6 ainda tem o numero do pokemon escolhido
		li a5, 0		# a5 = 0 para renderizar o pokemon inimigo
		call RENDERIZAR_POKEMON
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																						
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret 

# ====================================================================================================== #

INICIAR_POKEMON_RED:
	# Procedimento que atualiza o valor de s11 com o pokemon do RED e imprime todos os sprites,
	# anima��es e textos relacionados a esse pokemon aparecendo na tela

	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Replica o frame 0 no frame 1 para que os dois estejam iguais
	li a0, 0xFF000000	# copia o frame 0 no frame 1
	li a1, 0xFF100000
	li a2, 320		# numero de colunas a serem copiadas
	li a3, 240		# numero de linhas a serem copiadas
	call REPLICAR_FRAME

	call TROCAR_FRAME	# inverte o frame sendo mostrado, mostrando o frame 1

	# Primeiro limpa a caixa de dialogo	
		# Calculando o endere�o de onde come�ar a limpeza no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 28		# numero da coluna 
		li a3, 185		# numero da linha
		call CALCULAR_ENDERECO	

		mv t5, a0		# move o retorno para t5

		# Imprimindo o rentangulo com a cor de fundo da caixa no frame 0
		li a0, 0xFF		# a0 tem o valor do fundo da caixa
		mv a1, t5		# t5 tem o endere�o de onde come�ar a impressao		
		li a2, 147		# numero de colunas da imagem da seta
		li a3, 30		# numero de linhas da imagem da seta			
		call PRINT_COR
					
	# Agora imprime o texto "Escolha o seu POK�MON!"
		mv a1, t5	# o texto ser� impresso no mesmo endere�o onde a limpeza foi feita acima
		la a4, matriz_texto_escolha_o_seu_pokemon 	
		call PRINT_TEXTO	

		# Por fim, imprime uma pequena seta indicando que o jogador pode apertar ENTER para avan�ar
		# o dialogo						
		# Calculando o endere�o de onde imprimir a seta no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 159		# numero da coluna 
		li a3, 207		# numero da linha
		call CALCULAR_ENDERECO											
		
		mv t3, a0		# move o retorno para t3		
									
		# Imprimindo a imagem da seta no frame 0
		la a0, seta_proximo_dialogo_combate		# carrega a imagem				
		mv a1, t3 		# t3 tem o endere�o de onde imprimir a imagem
		lw a2, 0(a0)		# numero de colunas da imagem
		lw a3, 4(a0)		# numero de linhas da imagem
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		call PRINT_IMG	

	call TROCAR_FRAME	# inverte o frame sendo mostrado, mostrando o frame 0

	# Espera o jogador apertar ENTER	
	LOOP_ENTER_ESCOLHER_POKEMON_RED:
		call VERIFICAR_TECLA
		
		li t0, 10		# 10 � o codigo do ENTER	
		bne a0, t0, LOOP_ENTER_ESCOLHER_POKEMON_RED
	
	# Antes � necess�rio preparar o frame 1 para mostrar o inventario
		# Limpa a caixa de dialogo no frame 0 somente para indicar que n�o mais necess�rio apertar ENTER					
		# Para retirar a imagem da seta basta imprimir uma �rea de mesmo tamanho com a cor
		# de fundo do inventario
		li a0, 0xFF		# a0 tem o valor do fundo do menu da caixa de dialogo (branco)
		mv a1, t3		# t3 ainda tem o endere�o de onde a seta est�		
		li a2, 10		# numero de colunas da imagem da seta
		li a3, 6		# numero de linhas da imagem da seta	
		call PRINT_COR	
	
		# De inicio copia o que acabou de ser impresso no frame 0 (o texto na caixa de dialogo) para
		# o frame 1
		mv a0, t5	# a copia se inicio no frame 0 no mesmo endere�o onde o texto foi impresso
		li t0, 0x00100000
		add a1, t5, t0	# a copia vai para o endere�o de a0, mas no frame 1
		li a2, 148		# numero de colunas a serem copiadas
		li a3, 32		# numero de linhas a serem copiadas
		call REPLICAR_FRAME	
		
		# Depois limpa algumas partes do frame de modo que s� o que vai aparecer � a caixa de dialogo
		# e o inventario
			# Calculando o endere�o de onde come�ar a limpeza no frame 1
			li a1, 0xFF100000	# seleciona o frame 1
			li a2, 32		# numero da coluna 
			li a3, 32		# numero da linha
			call CALCULAR_ENDERECO	

			mv a1, a0		# move o retorno para a1

			# Imprimindo o rentangulo com a cor de fundo da tela de combate no frame 1
			li a0, 190		# a0 tem o valor do fundo do menu da tela do combate
			# a1 j� tem o endere�o de onde come�ar a impressao		
			li a2, 128		# numero de colunas da area a ser impressa
			li a3, 4		# numero de linhas da area a ser impressa		
			call PRINT_COR	
						
			# Imprimindo o rentangulo com a cor de fundo da tela de combate no frame 1
			li a0, 190		# a0 tem o valor do fundo do menu da tela do combate
			# a1 j� tem o endere�o de onde come�ar a impressao		
			li a2, 26		# numero de colunas da area a ser impressa
			li a3, 28		# numero de linhas da area a ser impressa		
			call PRINT_COR
							
			# Imprimindo o rentangulo com a cor de fundo da tela de combate no frame 1
			li a0, 190		# a0 tem o valor do fundo do menu da tela do combate
			li t0, 21440		# 24017 = 67 * 320 
			add a1, a1, t0		# o proximo retangulo come�a a 75 linhas de 
						# onde o ultimo terminou de ser impresso
			li a2, 24		# numero de colunas da area a ser impressa
			li a3, 26		# numero de linhas da area a ser impressa		
			call PRINT_COR											

			# Imprimindo o rentangulo com a cor de fundo da tela de combate no frame 1
			li a0, 190		# a0 tem o valor do fundo do menu da tela do combate
			li t0, -28568		# -28568 = -90 * 320 + 232
			add a1, a1, t0		# o proximo retangulo come�a a -90 linhas e 232 colunas de 
						# onde o ultimo terminou de ser impresso
			li a2, 23		# numero de colunas da area a ser impressa
			li a3, 28		# numero de linhas da area a ser impressa	
			call PRINT_COR	
																																					
	li a5, 1		# a5 = 1 porque o inventario foi mostrado atrav�s do combate
	call MOSTRAR_INVENTARIO	

	# do retorno de MOSTRAR_INVENTARIO a0 tem um valor de 0 a 4 representando a op��o, e consequentemente,
	# qual pokemon o jogador escolheu

	mv t6, a0	# salva o numero do pokemon escolhido em t6

	# Primeiro a matriz de texto correta com o nome do pokemon (t5)

	# se a0 == 0 ent�o � pokemon escolhido � o BULBASAUR 
	la t5, matriz_texto_bulbasaur		# carrega a matriz de texto do pokemon
	beq a0, zero, PRINT_TEXTO_POKEMON_RED
			
	# se a0 == 1 ent�o � pokemon escolhido � o CHARMANDER 
	li t0, 1	
	la t5, matriz_texto_charmander		# carrega a matriz de texto do pokemon	
	beq a0, t0, PRINT_TEXTO_POKEMON_RED
			
	# se a0 == 2 ent�o � pokemon escolhido � o SQUIRTLE 
	li t0, 2	
	la t5, matriz_texto_squirtle		# carrega a matriz de texto do pokemon				
	beq a0, t0, PRINT_TEXTO_POKEMON_RED
										
	# se a0 == 3 ent�o � pokemon escolhido � o CATERPIE 
	li t0, 3	
	la t5, matriz_texto_caterpie		# carrega a matriz de texto do pokemon			
	beq a0, t0, PRINT_TEXTO_POKEMON_RED
	
	# se a0 == 4 ent�o � pokemon escolhido � o DIGLETT 
	li t0, 4	
	la t5, matriz_texto_diglett		# carrega a matriz de texto do pokemon		
	
	PRINT_TEXTO_POKEMON_RED:
	
	# Agora imprime o texto "O YYY foi escolhido.", onde YYY � o nome do pokemon
	
	# Limpa a caixa de dialogo	
		# Calculando o endere�o de onde come�ar a limpeza no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 28		# numero da coluna 
		li a3, 185		# numero da linha
		call CALCULAR_ENDERECO	

		mv a1, a0		# move o retorno para t5

		# Imprimindo o rentangulo com a cor de fundo da caixa no frame 0
		li a0, 0xFF		# a0 tem o valor do fundo da caixa
		# a1 j� tem o endere�o de onde come�ar a impressao		
		li a2, 147		# numero de colunas da imagem da seta
		li a3, 30		# numero de linhas da imagem da seta			
		call PRINT_COR
	
	# Replica o frame 0 no frame 1 para que os dois estejam iguais
		li a0, 0xFF000000	# copia o frame 0 no frame 1
		li a1, 0xFF100000
		li a2, 320		# numero de colunas a serem copiadas
		li a3, 240		# numero de linhas a serem copiadas
		call REPLICAR_FRAME
			
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 1
	
		# Calculando o endere�o de onde imprimir o primeiro texto ('O ') no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 28		# numero da coluna 
		li a3, 185		# numero da linha
		call CALCULAR_ENDERECO	
			
		mv a1, a0		# move o retorno para a1
	
		# Imprime o texto com o nome do Pokemon
		# a1 j� tem o endere�o de onde imprimir o texto
		mv a4, t5		# a4 recebe a matriz de texto do pokemon decidido acima
		call PRINT_TEXTO

		# Imprime o texto com o ('escolhido.')
		# pelo PRINT_TEXTO acima a1 ainda est� no ultimo endere�o onde imprimiu o tile,
		# de modo que est� na posi��o exata do proximo texto
		la a4, matriz_texto_escolhido 	
		call PRINT_TEXTO
			
	# Por fim, imprime uma pequena seta indicando que o jogador pode apertar ENTER para avan�ar
	# o dialogo						
		# Calculando o endere�o de onde imprimir a seta no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 159		# numero da coluna 
		li a3, 207		# numero da linha
		call CALCULAR_ENDERECO											
			
		mv t3, a0		# move o retorno para t3		
						
		# Imprimindo a imagem da seta no frame 0
		la a0, seta_proximo_dialogo_combate		# carrega a imagem				
		mv a1, t3		# t3 tem o endere�o de onde imprimir a imagem
		lw a2, 0(a0)		# numero de colunas da imagem
		lw a3, 4(a0)		# numero de linhas da imagem
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		call PRINT_IMG																							
																																																											
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 0
	
	# Espera o jogador apertar ENTER	
	LOOP_ENTER_POKEMON_ESCOLHIDO:
		call VERIFICAR_TECLA
		
		li t0, 10		# 10 � o codigo do ENTER	
		bne a0, t0, LOOP_ENTER_POKEMON_ESCOLHIDO
	
	# Limpa a caixa de dialogo no frame 0 somente para indicar que o n�o mais necess�rio apertar ENTER					
		# Para retirar a imagem da seta basta imprimir uma �rea de mesmo tamanho com a cor
		# de fundo do inventario
		li a0, 0xFF		# a0 tem o valor do fundo do menu da caixa de dialogo (branco)
		mv a1, t3		# t3 ainda tem o endere�o de onde a seta est�		
		li a2, 10		# numero de colunas da imagem da seta
		li a3, 6		# numero de linhas da imagem da seta	
		call PRINT_COR					
																																																																																																																		
	# Agora renderiza o pokemon do RED aparecendo na tela
		mv a0, t6		# t6 ainda tem o numero do pokemon escolhido
		li a5, 1		# a5 = 1 para renderizar o pokemon do RED
		call RENDERIZAR_POKEMON
																								
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret 
	
# ====================================================================================================== #

RENDERIZAR_POKEMON:
	# Procedimento auxiliar a INICIAR_POKEMON_INIMIGO e INICIAR_POKEMON_RED que tem como objetivo
	# renderizar o sprite de um pokemon, o seu nome e sua barra de vida na tela de combate.
	# Dependendo do argumento a5 os elementos v�o ser impressos em posi��es diferentes na tela.
	#
	# Argumento:
	#	a0 = n�mero de 0 a 4 representando o pokemon a ser renderizado. 
	#	     [ 0 ] -> BULBASAUR
	#	     [ 1 ] -> CHARMANDER
	#	     [ 2 ] -> SQUIRTLE
	#	     [ 3 ] -> CATERPIE
	#	     [ 4 ] -> DIGLETT
	#	a5 = [ 0 ] -> renderiza o pok�mon inimigo
	#	     [ 1 ] -> renderiza o pok�mon do RED	
	
	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Primeiro encontra a partir de a0 o endere�o da imagem do pokemon (t5) e a matriz de texto com
	# o nome do pokemon (t6)
	
	la t5, pokemons			# t5 tem o inicio da imagem do BULBASAUR
	addi t5, t5, 8			# pula para onde come�a os pixels no .data	
	li t0, 1482			# 1482 = 38 * 39 = tamanho de uma imagem de um pokemon, ou seja,
	mul t0, t0, a0			# passa o endere�o de t5 para a imagem do pokemon correto de acordo com a0
	add t5, t5, t0

	# se a0 == 0 ent�o � pokemon inimigo ser� o BULBASAUR 
	la t6, matriz_texto_bulbasaur		# carrega a matriz de texto do pokemon
	beq a0, zero, PRINT_POKEMON
			
	# se a0 == 1 ent�o � pokemon inimigo ser� o CHARMANDER 
	li t0, 1	
	la t6, matriz_texto_charmander		# carrega a matriz de texto do pokemon	
	beq a0, t0, PRINT_POKEMON
			
	# se a0 == 2 ent�o � pokemon inimigo ser� o SQUIRTLE 
	li t0, 2	
	la t6, matriz_texto_squirtle		# carrega a matriz de texto do pokemon				
	beq a0, t0, PRINT_POKEMON
										
	# se a0 == 3 ent�o � pokemon inimigo ser� o CATERPIE 
	li t0, 3	
	la t6, matriz_texto_caterpie		# carrega a matriz de texto do pokemon			
	beq a0, t0, PRINT_POKEMON
	
	# se a0 == 4 ent�o � pokemon inimigo ser� o DIGLETT 
	li t0, 4	
	la t6, matriz_texto_diglett		# carrega a matriz de texto do pokemon	
	
	PRINT_POKEMON:
																																																	
	# Imprime a imagem do pokemon aparecendo na tela no frame 0	
		# Calculando o endere�o de onde imprimir o pokemon dependendo de a5
		li a1, 0xFF000000	# seleciona o frame 0
		
		# Onde o pokemon inimigo deve ser impresso
		li a2, 204		# numero da coluna 
		li a3, 43		# numero da linha
		beq a5, zero, RENDERIZAR_POKEMON_PRINT_SPRITE
		
		# Onde o pokemon do RED deve ser impresso
		li a2, 77		# numero da coluna 
		li a3, 105		# numero da linha
				
		RENDERIZAR_POKEMON_PRINT_SPRITE:
		
		call CALCULAR_ENDERECO	
		
		mv t3, a0		# move o retorno para t3
		
		# Imprime a silhueta do pokemon		
		mv a0, t5	# t5 ainda tem a imagem do pokemon que foi decidido no inicio procedimento				
		mv a1, t3	# t3 tem o endere�o de onde imprimir a imagem
		li a2, 38	# numero de colunas da imagem
		li a3, 39	# numero de linhas da imagem
		mv a4, a5	# a5 j� tem o numero correto indicando se a silheta � invertida ou n�o
		call PRINT_POKEMON_SILHUETA
	
		# Espera alguns milisegundos	
		li a0, 800			# sleep 800 ms
		call SLEEP			# chama o procedimento SLEEP	
			
		# Imprime a imagem completa do pokemon		
		mv a0, t5	# t5 ainda tem a imagem do pokemon que foi decidido no inicio procedimento				
		mv a1, t3	# t3 tem o endere�o de onde imprimir a imagem
		li a2, 38	# numero de colunas da imagem
		li a3, 39	# numero de linhas da imagem
		
		# decide de acordo com a5 se o pokemon deve ser impresso de forma invertida ou n�o
		bne a5, zero, PRINT_POKEMON_INVERTIDO
				
		call PRINT_IMG
		j PRINT_INFORMACOES_DO_POKEMON
		
		PRINT_POKEMON_INVERTIDO:
				
		call PRINT_IMG_INVERTIDA
	
	PRINT_INFORMACOES_DO_POKEMON:
																	
	# Imprime a imagem da caixa com as informa��es do pokemon (nome, vida, etc) no frame 0
		# Calculando o endere�o de onde imprimir a caixa dependendo de a5
		li a1, 0xFF000000	# seleciona o frame 0
					
		# Onde imprimir a caixa do pokemon inimigo			
		li a2, 32		# numero da coluna 
		li a3, 32		# numero da linha
		beq a5, zero, RENDERIZAR_POKEMON_PRINT_CAIXA
				
		# Onde imprimir a caixa do pokemon do RED			
		li a2, 176		# numero da coluna 
		li a3, 112		# numero da linha	
		
		RENDERIZAR_POKEMON_PRINT_CAIXA:
				
		call CALCULAR_ENDERECO	
		
		mv a2, a0		# move o retorno para a2
		
		# Imprime a caixa do pokemon
		la a0, matriz_tiles_caixa_pokemon_combate	# carrega a matriz de tiles
		la a1, tiles_caixa_pokemon_combate		# carrega a imagem com os tiles
		# a2 j� tem o endere�o de onde imprimir os tiles
		call PRINT_TILES
	
		# Imprime uma pequena seta indicando a orienta��o dessa caixa 
		# Calculando o endere�o de onde imprimir a seta e a imagem da seta dependendo de a5
		li a1, 0xFF000000	# seleciona o frame 0
					
		# Onde imprimir a seta da caixa do pokemon inimigo			
		li a2, 154		# numero da coluna 
		li a3, 55		# numero da linha
		la t2, seta_direcao_caixa_pokemon_combate	# carrega a imagem
		addi t2, t2, 8					# pula para onde come�a os pixels no .data		
		beq a5, zero, RENDERIZAR_POKEMON_PRINT_SETA_DE_CAIXA
				
		# Onde imprimir a seta da caixa do pokemon do RED
		addi t2, t2, 135	# passa o endere�o de t2 para a proxima seta na imagem			
		li a2, 167		# numero da coluna 
		li a3, 135		# numero da linha	
		
		RENDERIZAR_POKEMON_PRINT_SETA_DE_CAIXA:
				
		call CALCULAR_ENDERECO	
		
		mv a1, a0		# move o retorno para a1
		
		# Imprime a seta 
		mv a0, t2	# t2 tem a imagem da seta correta		
		# a1 j� tem o endere�o de onde imprimir a imagem
		li a2, 15	# numero de colunas da imagem
		li a3, 9	# numero de linhas da imagem
		call PRINT_IMG

		# Imprime o nome do pokemon na caixa
		# Calculando o endere�o de onde imprimir o nome na caixa dependendo de a5
		li a1, 0xFF000000	# seleciona o frame 0
					
		# Onde imprimir o nome do pokemon inimigo			
		li a2, 37		# numero da coluna 
		li a3, 35		# numero da linha
		beq a5, zero, RENDERIZAR_POKEMON_PRINT_NOME
				
		# Onde imprimir o nome do pokemon do RED
		li a2, 181		# numero da coluna 
		li a3, 115		# numero da linha	
		
		RENDERIZAR_POKEMON_PRINT_NOME:
		
		call CALCULAR_ENDERECO	
		
		mv a1, a0		# move o retorno para a1
		
		# Imprime o texto com o nome do Pokemon
		# a1 tem o endere�o de onde imprimir o nome
		mv a4, t6	# a4 recebe a matriz de texto do pokemon decidido anteriormente no procedimento	
		call PRINT_TEXTO							

		# Imprime a barra de vida
		# Calculando o endere�o de onde imprimir a barra dependendo de a5
		li a1, 0xFF000000	# seleciona o frame 0
		
		# Onde imprimir a barra do pokemon inimigo			
		li a2, 48		# numero da coluna 
		li a3, 50		# numero da linha
		beq a5, zero, RENDERIZAR_POKEMON_PRINT_BARRA_DE_VIDA
						
		# Onde imprimir a barra do pokemon do RED
		li a2, 192		# numero da coluna 
		li a3, 130		# numero da linha	
		
		RENDERIZAR_POKEMON_PRINT_BARRA_DE_VIDA:		
		
		call CALCULAR_ENDERECO	
		
		mv a1, a0		# move o retorno para a1
		
		# Imprime a imagem da barra de vida
		la a0, combate_barra_de_vida	# carrega a imagem
		# a1 j� tem o endere�o de onde imprimir a imagem
		lw a2, 0(a0)	# numero de colunas da imagem
		lw a3, 4(a0)	# numero de linhas da imagem
		addi a0, a0, 8			# pula para onde come�a os pixels no .data								
		call PRINT_IMG		
		
		# Imprime a vida do pokemon
		# Todos os pokemons tem uma vida de 45 pontos
		
		# Calculando o endere�o de onde imprimir o primeiro numero (4) dependendo de a5
		li a1, 0xFF000000	# seleciona o frame 0
		
		# Onde imprimir a vida do pokemon inimigo			
		li a2, 122		# numero da coluna 
		li a3, 37		# numero da linha
		beq a5, zero, RENDERIZAR_POKEMON_PRINT_PONTOS_DE_VIDA
						
		# Onde imprimir a vida do pokemon do RED
		li a2, 266		# numero da coluna 
		li a3, 117		# numero da linha	
		
		RENDERIZAR_POKEMON_PRINT_PONTOS_DE_VIDA:			
		
		call CALCULAR_ENDERECO			
		
		mv a1, a0		# move o retorno para a1
		
		# O loop come�a imprimindo o numero 4
		la a0, tiles_numeros	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		addi a0, a0, 240 	# 240 = 60 (area de uma imagem de um numero) * 4, ou seja,
					# a0 passa para o inico do tile com o numero 4
					
		li t3, 5		# numero de simbolos a serem impressos 	
				
		LOOP_POKEMON_PRINT_VIDA:
		# Imprimindo o numero 
		# a0 j� tem o endere�o da imagem do numero (ou /)			
		# a1 j� tem o endere�o de onde imprimir o numero
		li a2, 6		# numero de colunas dos tiles a serem impressos
		li a3, 10		# numero de linhas dos tiles a serem impressos	
		call PRINT_IMG										

		addi t3, t3, -1		# decrementa o numero de simbolos restantes

		# Pelo PRINT_IMG o endere�o de a0 j� est� no inicio da imagem do 5
		# pelo PRINT_IMG acima a1 est� naturalmente a -10 linhas +7 colunas de onde imprimir o proximo
		# numero
		li t0, -3193		# -3193 = -10 * 320 + 7
		add a1, a1, t0	
		
		# Pelo PRINT_IMG o endere�o de a0 j� est� no inicio da imagem do 5				
		li t0, 4
		beq t3, t0, LOOP_POKEMON_PRINT_VIDA	# se t3 == 4 imprime o 5
		
		la a0, caractere_barra	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data							
		li t0, 3		
		beq t3, t0, LOOP_POKEMON_PRINT_VIDA	# se t3 == 3 imprime uma imagem de uma barra (/)
			
		la a0, tiles_numeros	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		addi a0, a0, 240 	# 240 = 60 (area de uma imagem de um numero) * 4, ou seja,
					# a0 passa para o inico do tile com o numero 4
		li t0, 2
		beq t3, t0, LOOP_POKEMON_PRINT_VIDA	# se t3 == 2 imprime o 4	
				
		addi a0, a0, 60 	# Pelos calculos acima o endere�o de a0 est� a 60 pixels do inicio 
					# da imagem do 5
		bne t3, zero, LOOP_POKEMON_PRINT_VIDA	# se t3 == 1 imprime o 5
	
	# Espera alguns milisegundos	
		li a0, 800			# sleep 800 ms
		call SLEEP			# chama o procedimento SLEEP	

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret	
																																																																																																																																																																																																																																																																																									
# ====================================================================================================== #
																																			
PRINT_POKEMON_SILHUETA:
	# Procedimento que imprime a silhueta de um pokemon na tela. Por silhueta entende-se uma imagem	
	# de um pokemon em pokemons.bmp, s� que ao inves de imprimir a imagem normalmente o pokemon ser�
	# impresso apenas com pixels rosa, imprimindo s� o "formato" do pokemon.
	# O procedimente tem suporte para imprimir a silheta de forma imvertida
	#
	# Argumentos: 
	# 	a0 = endere�o da imagem	do pokemon	
	# 	a1 = endere�o de onde, no frame escolhido, a imagem deve ser renderizada
	# 	a2 = numero de colunas da imagem
	#	a3 = numero de linhas da imagem
	#	a4 = [ 0 ] -> se a silhueta for impressa na orienta��o normal
	#	     [ 1 ] -> se a sulhueta deve ser impressa de forma invertida
	
	mul t0, a4, a2		# Caso a4 == 1 a imagem deve ser impressa de forma invertida ent�o o endere�o
	add a0, a0, t0		# de a0 deve estar no final da primeira linha
	li t0, -1
	mul t0, t0, a4
	add a0, a0, t0		# tamb�m � necessario voltar o endere�o por 1 coluna (por motivos desconhecidos)	
		
	PRINT_POKEMON_SILHUETA_LINHAS:
		mv t1, a2		# copia do numero de a2 para usar no loop de colunas
			
		PRINT_POKEMON_SILHUETA_COLUNAS:
			lbu t2, 0(a0)			# pega 1 pixel do .data e coloca em t2
			
			# Se o valor do pixel do .data (t2) for 0xC7 (pixel transparente), 
			# o novo pixel n�o � armazenado no bitmap, de modo que somente ser�o impressos os pixels
			# de cor t0 no lugar dos pixels que fazem parte da imagem do pokemon em si
			li t0, 0xC7		# cor do pixel transparente
			beq t2, t0, NAO_IMPRIMIR_PIXEL_DO_POKEMON
				li t0, 231		# t0 tem o valor da cor (rosa) que ser� usada para fazer a
							# impress�o do pokemon
				sb t0, 0(a1)		# pega o pixel de t0 (cor rosa) e coloca no bitmap
	
			NAO_IMPRIMIR_PIXEL_DO_POKEMON:
			addi t1, t1, -1			# decrementa o numero de colunas restantes

			addi a0, a0, 1			# vai para o pr�ximo pixel da imagem
									
			li t0, -2		# Caso a4 == 1 a imagem deve ser impressa de forma invertida 
			mul t0, a4, t0		# ent�o o endere�o de a0 precisa ser decrementado (-1)
			add a0, a0, t0		# (-2 porque foi somado 1 acima)		
			
			addi a1, a1, 1			# vai para o pr�ximo pixel do bitmap
			bne t1, zero, PRINT_POKEMON_SILHUETA_COLUNAS	# reinicia o loop se t1 != 0
				
		sub a1, a1, a2			# volta o ende�o do bitmap pelo numero de colunas impressas
		addi a1, a1, 320		# passa o endere�o do bitmap para a proxima linha

		mul t0, a4, a2		# Caso a4 == 1 a imagem deve ser impressa de forma invertida ent�o o
		add a0, a0, t0		# endere�o de a0 deve estar no final da proxima linha a ser impressa,
		add a0, a0, t0		# o que requer soma t0 duas vezes
				
		addi a3, a3, -1			# decrementando o numero de linhas restantes
				
		bne a3, zero, PRINT_POKEMON_SILHUETA_LINHAS	# reinicia o loop se a3 != 0
			
	ret
	
# ====================================================================================================== #

.data
	.include "../Imagens/combate/matriz_tiles_tela_combate.data"
	.include "../Imagens/combate/seta_proximo_dialogo_combate.data"				
	.include "../Imagens/combate/tiles_caixa_pokemon_combate.data"	
	.include "../Imagens/combate/matriz_tiles_caixa_pokemon_combate.data"					
	.include "../Imagens/combate/seta_direcao_caixa_pokemon_combate.data"									
	.include "../Imagens/combate/combate_barra_de_vida.data"																		
	.include "../Imagens/outros/caractere_barra.data"																		
