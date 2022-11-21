.text

# ====================================================================================================== # 
# 						INTRO HISTORIA				                 #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# C�digo respons�vel por renderizar a hist�ria introdut�ria do jogo.			                 # 
#													 #
# ====================================================================================================== #


INICIALIZAR_INTRO_HISTORIA:
	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Espera alguns milisegundos	
		li a7, 32			# selecionando syscall sleep
		li a0, 1000			# sleep por 1 s
		ecall
		
	# Imprimindo a intro_0 no frame 0
		la a0, intro_0			# carregando a imagem em a0
		li a1, 0xFF000000		# selecionando como argumento o frame 0
		call PRINT_TELA

	# Imprimindo a intro_0 no frame 1
		la a0, intro_0			# carregando a imagem em a0
		li a1, 0xFF100000		# selecionando como argumento o frame 1
		call PRINT_TELA
	
	# Espera alguns milisegundos	
		li a7, 32		# selecionando syscall sleep
		li a0, 1000		# sleep por 1 s
		ecall
	
	# Renderiza 4 caixas de dialogo	
		la a5, intro_dialogos	# carrega o endere�o da imagem 
		addi a5, a5, 8		# pula para onde come�a os pixels no .data
		li a6, 5		# seleciona como argumento o numero de dialogos a serem renderizados
		call PRINT_DIALOGOS	

	mv a6, zero
	
	call RENDERIZAR_ANIMACAO_PROF
	
	# Renderiza 4 caixas de dialogo	
		# atrav�s da chamada do procedimento PRINT_DIALOGOS acima, a5 j� possui o endere�o
		# do pr�ximo di�logo
		li a6, 4		# seleciona como argumento o numero de dialogos a serem renderizados
		call PRINT_DIALOGOS
	
	li a6, 1		
	call RENDERIZAR_ANIMACAO_PROF	
	
	# Renderiza 1 caixas de dialogo	
		# atrav�s da chamada do procedimento PRINT_DIALOGOS acima, a5 j� possui o endere�o
		# do pr�ximo di�logo
		li a6, 1		# seleciona como argumento o numero de dialogos a serem renderizados
		call PRINT_DIALOGOS
		
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret

# ====================================================================================================== #					

RENDERIZAR_ANIMACAO_PROF:
	# Procedimento que imprime uma serie de imagens do professor Carvalho e renderiza os dialogos
	# necessarios ao longo do processo
	# Esse procedimento pode imprimir o come�o ou final da anima��o do professor a depender do argumento
	# Em ambos os casos o procedimento usa o arquivo prof_carvalho_intro.data, a diferen�a � que 
	# o come�o da anima��o segue as imagens de forma sequencial e o final segue as imagens na ordem inversa
	# Argumentos:
	#	a6 = Se 0 -> imprime o come�o da anima��o
	# 	     Se qualquer outro valor -> imprime o final da anima��o

	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Mostra o frame 0 
		li t0, 0xFF200604	# carrega o endere�o para escolher os frames
		sw zero, 0(t0)		# armazena 0 no endere�o de t0

	# Calcula o endere�o de onde renderizar a imagem do professor no frame 0
		li a1, 0xFF000000		# seleciona como argumento o frame 0
		li a2, 94 			# coluna = 94
		li a3, 26			# linha = 26
		call CALCULAR_ENDERECO

	mv t4, a0			# guarda o endere�o em t4

	la a0, prof_carvalho_intro	# carrega a imagem em a0
	addi a0, a0, 8			# pula para onde come�a os pixels no .data
	li a2, 128			# a2 = numero de colunas na imagem a ser renderizada
	li a3, 143			# a3 = numero de linhas na imagem a ser renderizada
	
	mul t5, a2, a3		# t5 = a2 * a3 = colunas * linhas = area total de uma imagem do professor
	
	add a0, a0, t5		# pula para a segunda imagem do .data
	
	li t6, 4		# t6 = numero de loops a serem executados
	
	# Verifica se o argumento a6 == 0, caso sim avan�a a0 para a 4a imagem
	beq a6, zero, LOOP_RENDERIZAR_PROF
		slli t5, t5, 1		# atrav�s de um shif l�gico multiplica t5 por 2	
					# nesse caso t5 possui a area total de 2 imagens do professor		
		
		add a0, a0, t5		# passa o endere�o de a0 para a 4a imagem
	
	LOOP_RENDERIZAR_PROF:
		# a0 j� possui o endere�o da imagem
		mv a1, t4		# move para a1 o endere�o no bitmap onde a imagem ser� impressa
		# a2 e a3 j� possuem o numero de linhas e colunas da imagem
		call PRINT_IMG
		
		mv t0, a0		# guarda o endere�o de a0 em t0
		
		# Espera alguns milisegundos	
			li a7, 32			# selecionando syscall sleep
			li a0, 430			# sleep por 430 ms
			ecall
	
		mv a0, t0		# volta o endere�o de t0 para a0
	
		# Verifica se o argumento a6 == 0, nesse caso o procedimento renderiza as imagens na 
		# ordem inversa do mostrado no prof_carvalho_intro, portanto o endere�o de a0
		# deve "subir" duas imagens
		beq a6, zero, LOOP_PROF_RENDERIZAR_INICIO
			sub a0, a0, t5		# nesse ponto do codigo t5 possui a area total de pixels
						# de duas imagens do professor, portanto essa soma
						# volta o endere�o de a0 em duas imagens
		LOOP_PROF_RENDERIZAR_INICIO:
	
		addi t6, t6, -1				# decrementa t6
	
		bne t6, zero, LOOP_RENDERIZAR_PROF	# reinicia o loop se t6 != 0
	
	# Agora a ultima imagem do professor tamb�m deve ser impressa no frame 1
	
	# Verifica se o argumento a6 == 0, nesse caso a ultima imagem a ser mostrada � a primeira
	# do prof_carvalho_intro.bmp, com o inverso caso a6 != 0 
				
	beq a6, zero, PROF_RENDERIZAR_INICIO
		srli t5, t5, 1		# atrav�s de um shif l�gico divide t5 por 2			
		# nesse caso t5 possui a area total de 1 imagem do professor	
						
		add a0, a0, t5		# passa o endere�o de a0 para a 1a imagem do professor
		j PROF_RENDERIZAR_FIM
		
	PROF_RENDERIZAR_INICIO:
		# Caso a6 == 0 deve ser renderizado a aniama��o inicial do professor,
		# nesse caso o endere�o de a0 deve voltar uma imagem
		
		sub a0, a0, t5
	
	PROF_RENDERIZAR_FIM:
	
	li t0, 0x00100000	# soma t0 com t4 de forma que o endere�o de a1 passa para o 
	add a1, t4, t0		# endere�o correspondente no frame 1
	# a2 e a3 j� possuem o numero de linhas e colunas da imagem
	call PRINT_IMG	
	
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret
		
# ====================================================================================================== #					
 
.data
	.include "../Imagens/intro_historia/intro_0.data"
	.include "../Imagens/intro_historia/intro_dialogos.data"
	.include "../Imagens/intro_historia/prof_carvalho_intro.data"
	.include "../Imagens/outros/seta_dialogo.data"
