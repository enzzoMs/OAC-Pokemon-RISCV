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
	# Argumentos: 
	# 	a0 = endere�o da imgagem		
	# 	a1 = endere�o do frame
	
	li t0, 76800		# area total da imagem -> 320 x 240 = 76800 pixels
	addi a0,a0,8		# pula para onde come�a os pixels no .data
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
	# Procedimento que imprime imagens de tamanho variado, menores que 320 x 240, no frame de escolha
	# Argumentos: 
	# 	a0 = endere�o da imgagem		
	# 	a1 = endere�o de onde, no frame escolhido, a imagem deve ser renderizada
	
	lw t0, 0(a0)		# t0 = largura da imagem / numero de colunas da imagem
	lw t1, 4(a0)		# t1 = altura da imagem / numero de linhas da imagem
	
	addi a0, a0, 8		# pula para onde come�a os pixels no .data

	li t2, 0		# contador para o numero de linhas ja impressas
	
	PRINT_IMG_LINHAS:
		li t3, 0		# contador para o numero de colunas ja impressas
		addi t4, a1, 0		# copia do endere�o de a1 para usar no loop de colunas
			
		PRINT_IMG_COLUNAS:
			lb t5, 0(a0)			# pega 1 pixel do .data e coloca em t5
			sb t5, 0(t4)			# pega o pixel de t5 e coloca no bitmap
	
			addi t3, t3, 1			# incrementando o numero de colunas impressas
			addi a0, a0, 1			# vai para o pr�ximo pixel da imagem
			addi t4, t4, 1			# vai para o pr�ximo pixel do bitmap
			bne t3, t0, PRINT_IMG_COLUNAS	# reinicia o loop se t3 != t0
			
		addi t2, t2, 1				# incrementando o numero de linhas impressas
		addi a1, a1, 320			# passa o endere�o do bitmap para a proxima linha
		bne t2, t1, PRINT_IMG_LINHAS	        # reinicia o loop se t2 != t1
			
	ret

# ====================================================================================================== #

CALCULAR_ENDERECO:
	# Procedimento que calcula um endere�o no frame de escolha
	# Argumentos: 
	#	a1 = endere�o do frame
	# 	a2 = numero da coluna
	# 	a3 = numero da linha
	# a0 = retorno com o endere�o
	
	li t0, 320			# t0 = 320
	
	mul t1, a3, t0			# linha x 320	
	add a0, a1, t1			# ender�o base + (linha x 320)
	add a0, a0, a2			# a0 = ender�o base + (linha x 320) + coluna
	
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
	# Retorna a0 com o valor da tecla ou a0 = 0 caso nenhuma tecla tenha sido apertada		
	
	li a0, 0 		# a0 = 0 
	 
	li t0, 0xFF200000	# carrega em t0 o endere�o de controle do KDMMIO
 	lw t1, 0(t0)		# carrega em t1 o valor do endere�o de t0
   	andi t1, t1, 0x0001	# t1 = 0 = n�o tem tecla, t1 = 1 = tem tecla. 
   				# realiza opera��o andi de forma a deixar em t0 somente o bit necessario para an�lise
   	
    	beq t1, zero, FIM_VERIFICAR_TECLA	# t1 = 0 = n�o tem tecla pressionada ent�o vai para fim
   	lw a0, 4(t0)				# le o valor da tecla no endere�o 0xFF200004
   		 	
	FIM_VERIFICAR_TECLA:					
		ret
		
		
		
		
