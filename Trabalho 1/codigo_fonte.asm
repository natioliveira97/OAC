.data 
	filename: .asciiz "lena.bmp"
	
	headerAdress: .space 54
	
	m1: .asciiz "******************************************************************\n"
	m2: .asciiz "*                  Super Processador de Imagens                  *\n"
	m3: .asciiz "\n1- Abrir imagem.\n"
	m4: .asciiz "\n2- Borra a imagem\n"
	m5: .asciiz "\n3- Detector de bordas\n"
	m6: .asciiz "\n4- Segmentação de cor\n"
	m7: .asciiz "\n5- Sair\n"
	m8: .asciiz "\nSua escolha:"
	m9: .asciiz "\nNome da Imagem:"
	m10: .asciiz "\nValor mínimo de cor Vermelha:"
	m11: .asciiz "\nValor máximo de cor Vermelha:"
	m12: .asciiz "\nValor mínimo de cor Verde:"
	m13: .asciiz "\nValor máximo de cor Verde:"
	m14: .asciiz "\nValor mínimo de cor Azul:"
	m15: .asciiz "\nValor máximo de cor Azul:"
	m16: .asciiz "\nTchauzinho....\n"
	m17: .asciiz "\nCarregando a imagem ...\n"
	m18: .asciiz "\nImagem carregada.\n"
	m19: .asciiz "\nProcessando imagem ...\n"
	m20: .asciiz "\nImagem processada.\n"
	m21: .asciiz "\nVou Borrar\n"
	m22: .asciiz "\nBorrando...\n"
	m23: .asciiz "\nSalvando imagem gerada...\n"
	m24: .asciiz "\nImagem salva...\n"
	m25: .asciiz "\nCopiando imagem para endereco de backup...\n"
	m26: .asciiz "\nAplicando derivador 1\n"
	m27: .asciiz "\nAplicando derivador 2\n"
	m28: .asciiz "\nCombinando efeitos...\n"
	m29: .asciiz "\nPassando para preto e branco \n"
	m30: .asciiz "\nAplicando limiar para clarear bordas\n"
	m31: .asciiz "\nEntre um tamanho ímpar para o kernel\n"
	m32: .asciiz "\nNome para a imagem gerada:\n"
	m33: .asciiz "\nErro ao abrir arquivo\n"
	m34: .asciiz "\nValor mínimo de contraste de borda:"
	m35: .asciiz "\nValor máximo de contraste de borda:"
	
	filenameout: .asciiz "imagem_de_saida.bmp"
	
	r1: .asciiz	
	r2: .asciiz

.text

menu: 	
	#Título
	la $a0, m1
	jal printString
	la $a0, m2
	jal printString
	la $a0, m1	
	jal printString
	
	#Opções
	la $a0, m3
	jal printString
	la $a0, m4
	jal printString
	la $a0, m5
	jal printString
	la $a0, m6
	jal printString
	la $a0, m7
	jal printString
	la $a0, m8
	jal printString
	
	#Resposta do usuário
	addi $v0 , $zero, 5 
	syscall
	
	li $t0, 1			
	beq $v0, $t0, chama_loadImage
	
	li $t0, 2
	beq $v0, $t0, borramento
	
	li $t0, 3
	beq $v0, $t0, edge_detector
	
	li $t0, 4
	beq $v0, $t0, chama_limiar
		
	li $t0, 5
	beq $v0, $t0, fim
		
	j menu
	
chama_limiar: 
	jal loadImage
	move $a0, $zero
	jal limiarBinarization	
	jal writeImage
	j menu

	
chama_loadImage:
	jal loadImage
	j menu
	
	
writeImage:
	la $a0, m32
	jal printString
	
	la $a0, filenameout
	li $a1, 30
	li $v0, 8
	syscall
	
    	li $t0, 0       #loop counter
    	li $t1, 30      #loop end
	clean:
    	beq $t0, $t1, out
    	lb $t3, filenameout($t0)
    	bne $t3, 0x0a, limpa
    	sb $zero, filenameout($t0)
    	limpa:
    	addi $t0, $t0, 1
	j clean
	out:
	
	la $a0, m23
	jal printString
	
	la $a0, filenameout
	
	
	#add $a0, $t0, $zero
	
	li $a1, 1			#flag para escrever no arquivo
	li $a2, 0
	li $v0, 13			#Código syscall para abrir arquivo	
	syscall
	move $a0, $v0
	blt $v0, $zero, erro
			
	la $a1, 0x10010000		# a1 recebe o endereço do cabeçalho
	li $a2, 54			# a2 recebe a quantidade de bytes para escrever
	li $v0, 15			#Código syscall para escrever no arquivo	
	syscall
	blt $v0, $zero, erro
	
	la $t3, 0x10040000		# t3 recebe o endereço do começo da imagem
		
	move $t4, $s4			#espaço para a pilha
	move $t5, $sp			#endereço inicial da imagem na pilha
	sub $sp, $sp, $t4		#abre espaço na pilha para copiar a imagem
	
	mul $t6, $s2, 3			#tamanho da linha
	move $t7, $s3			#quantidade de linhas
	
	sub $t5, $t5, $t6		#vai pro fim da linha
	sll $t6, $t6, 1			#tamanho de duas linhas
	
	move $t8, $s2			#contador
	
	#converte para 3 bytes	
loop6:	beqz $t8, fimDaLinha
	addi $t8, $t8, -1
	 
	lbu $t0, 0($t3)
	sb $t0, 0($t5)
	lbu $t0, 1($t3)
	sb $t0, 1($t5)
	lbu $t0, 2($t3)
	sb $t0, 2($t5)
	
	addi $t3, $t3, 4		#anda na imagem
	addi $t5, $t5, 3		#anda na pilha
	j loop6
	
fimDaLinha:
	beqz $t7, endLoop6
	addi $t7, $t7, -1
	move $t8, $s2	
	sub $t5, $t5, $t6
	
	j loop6

endLoop6:
	move $a1, $sp			# a1 recebe o endereço do cabeçalho
	move $a2, $t4			# a2 recebe a quantidade de bytes para escrever
	li $v0, 15			#Código syscall para escrever no arquivo	
	syscall
	blt $v0, $zero, erro
	
	add $sp, $sp, $t4
	li $v0, 16					
	syscall	
	
	la $a0, m24
	jal printString
	
	j menu
	
#*****************************************************************************************************************#		
	
to_grayscale:

	addi $sp, $sp, -24
	sw $t1, 0($sp)
	sw $t2, 4($sp)
	sw $t3, 8($sp)
	sw $t4, 12($sp)
	sw $t5, 16($sp)
	sw $t8, 20($sp)

	addi $sp, $sp, -28
	sw $ra, 24($sp)

	
	la $a0, m19
	jal printString
	
	move $t1, $s6
	mul $t2 $s2, $s3 	#quantidade de pixels
		
loop5g: 
	beqz $t2, endLoop5g
	addi $t2, $t2, -1
	
	#valores dos canais
	lbu $t3, 0($t1)
	lbu $t4, 1($t1)
	lbu $t5, 2($t1)
	add $t3, $t4, $t3
	add $t3, $t5, $t3
	div $t3, $t3, 3
	addu $t8, $zero, $t3
	sll $t8, $t8, 8
	addu $t8, $t8, $t3
	sll $t8, $t8, 8
	addu $t8, $t8, $t3 	
	sw $t8, 0($t1)	
	addi $t1, $t1, 4
	j loop5g			#Continua o loop
	
				
endLoop5g:
	la $a0, m20
	jal printString
	
	
	lw $ra, 24($sp)
	add $sp, $sp, 28
	
	lw $t1, 0($sp)
	lw $t2, 4($sp)
	lw $t3, 8($sp)
	lw $t4, 12($sp)
	lw $t5, 16($sp)
	lw $t8, 20($sp)
	addi $sp, $sp, 24
	
	jr $ra	
	
#*****************************************************************************************************************#
limiarBinarization:
	addi $sp, $sp, -32
	sw $t1, 0($sp)
	sw $t2, 4($sp)
	sw $t3, 8($sp)
	sw $t4, 12($sp)
	sw $t5, 16($sp)
	sw $t6, 20($sp)
	sw $t7, 24($sp)
	sw $t8, 28($sp)

	addi $sp, $sp, -28
	sw $ra, 24($sp)
	
	beqz $a0, recebe_usuario
	
	la $a0, m34
	jal printString
	addi $v0 , $zero, 5 
	syscall
	move $t1, $v0
	
	la $a0, m35
	jal printString
	addi $v0 , $zero, 5 
	syscall
	move $t2, $v0

	sw $t1, 0($sp)
	sw $t2, 4($sp)
	sw $t1, 8($sp)
	sw $t2, 12($sp)
	sw $t1, 16($sp)
	sw $t2, 20($sp)
	j prossegue_limiarizar
	
	#Recebe as entradas de limiar
	recebe_usuario:	
	la $a0, m10
	jal printString
	addi $v0 , $zero, 5 
	syscall
	sw $v0, 0($sp)
	
	la $a0, m11
	jal printString
	addi $v0 , $zero, 5 
	syscall
	sw $v0, 4($sp)
	
	la $a0, m12
	jal printString
	addi $v0 , $zero, 5 
	syscall
	sw $v0, 8($sp)
	
	la $a0, m13
	jal printString
	addi $v0 , $zero, 5 
	syscall
	sw $v0, 12($sp)

	la $a0, m14
	jal printString
	addi $v0 , $zero, 5 
	syscall
	sw $v0, 16($sp)
	
	la $a0, m15
	jal printString
	addi $v0 , $zero, 5 
	syscall
	sw $v0, 20($sp)
	
	prossegue_limiarizar:		
	
	#Entradas de limiar	
	#0($sp)		R_min
	#4($sp)		R_max
	#8($sp)		G_min
	#12($sp)	G_max
	#16($sp)	B_min
	#20($sp)	B_max

	
	la $a0, m19
	jal printString
	
	la $t1, 0x10040000
	mul $t2 $s2, $s3 	#quantidade de pixels
		
loop5: 
	beqz $t2, endLoop5
	addi $t2, $t2, -1
	
	#Byte Azul
	lbu $t3, 0($t1)
	lw $t4, 16($sp)		#Valor de B_min
	lw $t5, 20($sp)		#Valor de B_max	
	sleu $t6, $t4, $t3	#Se o valor do byte for maior que B_min $t6=1
	sleu $t7, $t3, $t5	#Se o valor do byte for menor que B_max $t7=1	
	and $t6, $t6, $t7
	beqz $t6, pixelPreto
	
	#Byte Verde
	lbu $t3, 1($t1)
	lw $t4, 8($sp)		#Valor de G_min
	lw $t5, 12($sp)		#Valor de G_max	
	sleu $t6, $t4, $t3	#Se o valor do byte for maior que B_min $t6=1
	sleu $t7, $t3, $t5	#Se o valor do byte for menor que B_max $t7=1	
	and $t6, $t6, $t7
	beqz $t6, pixelPreto
	
	#Byte Vermelho
	lbu $t3, 2($t1)
	lw $t4, 0($sp)		#Valor de R_min
	lw $t5, 4($sp)		#Valor de R_max	
	sleu $t6, $t4, $t3	#Se o valor do byte for maior que R_min $t6=1
	sleu $t7, $t3, $t5	#Se o valor do byte for menor que R_max $t7=1	
	and $t6, $t6, $t7
	beqz $t6, pixelPreto

	
pixelBranco:
	li $t8, 255
	sll $t8, $t8, 8
	addi $t8, $t8, 255
	sll $t8, $t8, 8
	addi $t8, $t8, 255	
	sw $t8, 0($t1)	
	addi $t1, $t1, 4
	j loop5			#Continua o loop
	
pixelPreto:
	li $t8, 0
	sw $t8, 0($t1)
	addi $t1, $t1, 4
	j loop5			#Continua o loop
	
endLoop5:
	la $a0, m20
	jal printString
	
	
	lw $ra, 24($sp)
	add $sp, $sp, 28
	
	lw $t1, 0($sp)
	lw $t2, 4($sp)
	lw $t3, 8($sp)
	lw $t4, 12($sp)
	lw $t5, 16($sp)
	lw $t6, 20($sp)
	lw $t7, 24($sp)
	lw $t8, 28($sp)
	addi $sp, $sp, 32
	
	
	jr $ra
	
#*****************************************************************************************************************#	
edge_detector:	
	jal loadImage
	
	la $a0, m29
	jal printString
	
	jal to_grayscale
	
	la $a0, m25
	jal printString
	
	move $a0, $s6
	mul $t8, $s2, $s3
	sll $t8, $t8, 2
	add $a2, $t8, $s6
	jal copia_matriz
	
	
	addi $t1, $zero, 1
	addi $t2, $zero, -1
	add $t3, $zero, $zero
	addi $t4, $zero, 2
	addi $t5, $zero, -2
	
	#sw $t1, 0($gp)
	#sw $t4, 4($gp)
	#sw $t2, 8($gp)
	#sw $t4, 12($gp)
	#sw $t3, 16($gp)
	#sw $t5, 20($gp)
	#sw $t1, 24($gp)
	#sw $t5, 28($gp)
	#sw $t2, 32($gp)
	
	sw $t1, 0($gp)
	sw $t4, 4($gp)
	sw $t1, 8($gp)
	sw $t3, 12($gp)
	sw $t3, 16($gp)
	sw $t3, 20($gp)
	sw $t2, 24($gp)
	sw $t5, 28($gp)
	sw $t2, 32($gp)
	
	la $a0, m26
	jal printString
	
	add $a0, $s6, $t8
	add $a1, $zero, $gp
	li $a2, 0x10040000
	li $a3, 3
	jal aplica_matriz
	
	
	addi $t1, $zero, 1
	addi $t2, $zero, -1
	add $t3, $zero, $zero
	addi $t4, $zero, 2
	addi $t5, $zero, -2
	
	sw $t1, 0($gp)
	sw $t3, 4($gp)
	sw $t2, 8($gp)
	sw $t4, 12($gp)
	sw $t3, 16($gp)
	sw $t5, 20($gp)
	sw $t1, 24($gp)
	sw $t3, 28($gp)
	sw $t2, 32($gp)
	
	la $a0, m27
	jal printString
	
	add $a0, $s6, $t8
	add $a1, $zero, $gp
	li $a3, 3	
	mul $t0, $s2, $s3
	sll $t0, $t0, 3
	addi $a2, $t0, 0x10040000
	jal aplica_matriz
	
	la $a0, m28
	jal printString
	
	mul $t0, $s3, $s2
	sll $t0, $t0, 3
	addi $a0, $t0, 0x10040000
	li $a1, 0x10040000
	li $a2, 0x10040000
	jal soma_matrizes
	
	la $a0, m30
	jal printString
	
	addi $a0, $zero, 1	
	jal limiarBinarization
	jal writeImage
	j menu
		
#*****************************************************************************************************************#

borramento: 
	la $a0, m21
	jal printString
	jal loadImage
	
	la $a0, m25
	jal printString
	
	move $a0, $s6
	mul $t8, $s2, $s3
	sll $t8, $t8, 2
	add $a2, $t8, $s6
	jal copia_matriz
	
	addi $t1, $zero, 1
	
	entra_tamanho:
	
	la $a0, m31
	jal printString
	
	addi $v0 , $zero, 5 
	syscall
	andi $t0, $v0, 0x00000001
	beqz $t0, entra_tamanho
	move $a3, $v0
	
	add $t2, $zero, $gp
	mul $t0, $v0, $v0
	prepara_kernel:
	sw $t1, 0($t2)
	addi $t2, $t2, 4
	subi $t0, $t0, 1
	bnez $t0, prepara_kernel
	
	la $a0, m22
	jal printString
	
	add $a0, $s6, $t8
	add $a1, $zero, $gp
	li $a2, 0x10040000
	jal aplica_matriz
	jal writeImage
	j menu
	
	
	


#*****************************************************************************************************************#

#recebe em $a0 o endereco da imagem a copiar e em $a2 onde salvar

copia_matriz:

	addi $sp, $sp, -32
	sw $t2, 0($sp)
	sw $t3, 4($sp)
	sw $t4, 8($sp)
	sw $t5, 12($sp)
	sw $t0, 16($sp)
	sw $t1, 20($sp)
	sw $t6, 24($sp)
	sw $t8, 28($sp)

	addi $sp, $sp, -28
	sw $ra, 24($sp)
	
	mul $t2 $s2, $s3 	#quantidade de pixels
		
loop5gg: 
	beqz $t2, endLoop5gg
	addi $t2, $t2, -1
	
	#valores dos canais da primeira imagem
	lbu $t3, 0($a0)
	lbu $t4, 1($a0)
	lbu $t5, 2($a0)
	
	
	#checo se houve overflow
	ble $t3, 255, menosR
	li $t3, 255
	menosR: ble $t4, 255, menosG
	li $t4, 255
	menosG: ble $t5, 255, menosB
	li $t5, 255
	menosB: 
	
	
	addu $t8, $zero, $t5
	sll $t8, $t8, 8
	addu $t8, $t8, $t4
	sll $t8, $t8, 8
	addu $t8, $t8, $t3 	
	sw $t8, 0($a2)	
	addi $a0, $a0, 4
	addi $a2, $a2, 4
	j loop5gg			#Continua o loop
	
				
endLoop5gg:
	la $a0, m20
	jal printString
	
	
	lw $ra, 24($sp)
	add $sp, $sp, 28
	
	lw $t2, 0($sp)
	lw $t3, 4($sp)
	lw $t4, 8($sp)
	lw $t5, 12($sp)
	lw $t0, 16($sp)
	lw $t1, 20($sp)
	lw $t6, 24($sp)
	lw $t8, 28($sp)
	addi $sp, $sp, 32
	
	jr $ra



#*****************************************************************************************************************#

#recebe em $a0 o endereco de uma matriz, em $a1 o endereco de outra matriz e em $a2 o endereco onde salvar a soma

soma_matrizes:

	addi $sp, $sp, -32
	sw $t2, 0($sp)
	sw $t3, 4($sp)
	sw $t4, 8($sp)
	sw $t5, 12($sp)
	sw $t0, 16($sp)
	sw $t1, 20($sp)
	sw $t6, 24($sp)
	sw $t8, 28($sp)

	addi $sp, $sp, -28
	sw $ra, 24($sp)
	
	mul $t2 $s2, $s3 	#quantidade de pixels
		
loop5ggg: 
	beqz $t2, endLoop5ggg
	addi $t2, $t2, -1
	
	#valores dos canais da primeira imagem
	lbu $t3, 0($a0)
	lbu $t4, 1($a0)
	lbu $t5, 2($a0)
	
	#valores dos canais da segunda imagem
	lbu $t0, 0($a1)
	lbu $t1, 1($a1)
	lbu $t6, 2($a1)
	
	#soma os canais das imagens
	add $t3, $t3, $t0
	add $t4, $t4, $t1
	add $t5, $t5, $t6
	
	#checo se houve overflow
	ble $t3, 255, menosR2
	li $t3, 255
	menosR2: ble $t4, 255, menosG2
	li $t4, 255
	menosG2: ble $t5, 255, menosB2
	li $t5, 255
	menosB2: 
	
	
	addu $t8, $zero, $t5
	sll $t8, $t8, 8
	addu $t8, $t8, $t4
	sll $t8, $t8, 8
	addu $t8, $t8, $t3 	
	sw $t8, 0($a2)	
	addi $a0, $a0, 4
	addi $a1, $a1, 4
	addi $a2, $a2, 4
	j loop5ggg			#Continua o loop
	
				
endLoop5ggg:
	la $a0, m20
	jal printString
	
	
	lw $ra, 24($sp)
	add $sp, $sp, 28
	
	lw $t2, 0($sp)
	lw $t3, 4($sp)
	lw $t4, 8($sp)
	lw $t5, 12($sp)
	lw $t0, 16($sp)
	lw $t1, 20($sp)
	lw $t6, 24($sp)
	lw $t8, 28($sp)
	addi $sp, $sp, 32
	
	jr $ra


#*****************************************************************************************************************#

#recebe como argumentos em a0 o endereco da imagem a borrar, em a1 o endereco da matriz a aplicar, em a2 o endereco onde salvar o resultado do borramento e em a3 o n da matriz (dimensao)
aplica_matriz: 
	#salvo os valores antigos de tudo aquilo que vou usar e nao e parametro meu
	addi $sp, $sp, -68 #separo espaco para 16 words
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	sw $t6, 24($sp)
	sw $t7, 28($sp)
	sw $t8, 32($sp)
	sw $t9, 36($sp)
	sw $v0, 40($sp)
	sw $v1, 44($sp)
	sw $s0, 48($sp)
	sw $s1, 52($sp)
	sw $s5, 56($sp)
	sw $s7, 60($sp)
	sw $ra, 64($sp)
	
	srl $t6, $a3, 1 #centro = (n-1)/2, determino o centro do núcleo e tamanho das bordas
	mul $v1, $a3, $a3 #v1=n*n
	
	#vou determinar a soma dos pesos do nucleo
	add $t3, $zero, $zero #iterador em 0
	add $t7, $zero, $zero #seto a soma dos pesos (sope) em 0
	soma_peso: sll $t3, $t3, 2 #multiplico por 4 o iterador
	add $a1, $a1, $t3 #somo o endereco da matriz com 4*iterador, obtendo o endereco do elemento de interesse
	lw $v0, 0($a1) #carrego o valor do elemento de interesse
	sub $a1, $a1, $t3 #subtraio o endereco da matriz com 4*iterador, recuperando o endereco original da matriz
	srl $t3, $t3, 2 #divido por 4 o iterador, devolvendo ao valor original
	
	#vou pegar o modulo do elemento
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	move $a0, $v0
	jal modulo
	lw $a0, 0($sp)
	addi $sp, $sp, 4	
	
	add $t7, $t7, $v0 #sope+=valor do elemento de interesse
	addi $t3, $t3, 1 #++iterador
	bne $t3, $v1, soma_peso #se iterador nao for n*n ainda, volto para soma_peso
	
	#determino agora a linha de inicio e a coluna de inicio, que sao iguais ao tamanho das bordas (que eu quero ignorar)
	add $t1, $zero, $t6
	add $t2, $zero, $t6
	
	loop_externo: 
		#determino o endereco do pixel onde vou centrar o nucleo com base nos valores que possuo de linha e coluna e o ponteiro base da imagem
		mul $t0, $t1, $s2 #endereco = linha*width
		add $t0, $t0, $t2 #endereco+= coluna -> endereco = linha*width + coluna
		sll $t0, $t0, 2
		add $t0, $t0, $a0 #endereco+=ptr base da imagem -> endereco = (linha*width + coluna)*4 + ptr base da imagem 
		
		add $t3, $zero, $zero #zero o iterador do nucleo
		add $s0 , $zero, $zero #zero o acumulador R
		add $s1 , $zero, $zero #zero o acumulador G
		add $s5 , $zero, $zero #zero o acumulador B
		
		loop_interno: 
			#calculo linha e coluna no nucleo com base no valor que tenho do iterador
			div $t3, $a3
			mflo $t4 #linha do nucleo = iterador do nucleo/n
			mul $t5, $t4, $a3 #coluna do nucleo = linha do nucleo*n
			sub $t5, $t3, $t5 #coluna do nucleo = iterador - coluna do nucleo -> coluna do nucleo = iterador - (linha do nucleo*n)
			#vou calcular agora as distancias ate o centro do nucleo do elemento atual do nuclei
			sub $t4, $t4, $t6 #linha do nucleo = linha do nucleo - centro do nucleo
			sub $t5, $t5, $t6 #coluna do nucleo = coluna do nucleo - centro do nucleo
			#calculo agora a posicao do pixel correspondente na imagem ao elemento pela sobreposicao da mascara
			add $t8, $t1, $t4 #linha do pixel correspondente = linha do pixel + dist. linha elemento
			add $t9, $t2, $t5 #coluna do pixel correspondente = coluna do pixel + dist. coluna elemento
			#Agora o t8 que armazenava a linha do pixel correspondente vai armazenar a posicao do pixel correspondente
			mul $t8, $t8, $s2 #posicao do pixel correspondente (ppc) = linha do pixel correspondente*width
			add $t8, $t8, $t9 #ppc = ppc + coluna do pixel correspondente -> ppc = linha do pixel correspondente*width + coluna do pixel correspondente
			sll $t8, $t8, 2
			add $t8, $t8, $a0 #ppc = deslocamento na memoria + ptr base da imagem
			
			#obtenho valor do elemento do nucleo
			sll $v0, $t3, 2 # v0 = iterador do nucleo*4
			add $v0, $v0, $a1 #v0 = iterador do nucleo*4 + ptr base da matriz
			lw $v0, 0($v0) #v0 = valor do elemento
			
			#obtenho valor do pixel correspondente, em t8, que deixa de armazenar a posicao para armazenar o valor
			lw $t8, 0($t8) #carrego o valor do pixel correspondente
			
			#Pego o canal R, multiplico pelo valor e coloco no acumulador R
			andi $s7, $t8, 0x000000ff #aplico uma mascara de bits
			srl $s7, $s7, 0 #desloco o quanto for necessario
			mul $s7, $s7, $v0 #multiplico pelo valor do elemento
			add $s0, $s0, $s7 #coloco no acumulador
			
			#Pego o canal G, multiplico pelo valor e coloco no acumulador G
			andi $s7, $t8, 0x0000ff00 #aplico uma mascara de bits
			srl $s7, $s7, 8 #desloco o quanto for necessario
			mul $s7, $s7, $v0 #multiplico pelo valor do elemento
			add $s1, $s1, $s7 #coloco no acumulador
			
			#Pego o canal B, multiplico pelo valor e coloco no acumulador B
			andi $s7, $t8, 0x00ff0000 #aplico uma mascara de bits
			srl $s7, $s7, 16 #desloco o quanto for necessario
			mul $s7, $s7, $v0 #multiplico pelo valor do elemento
			add $s5, $s5, $s7 #coloco no acumulador
			
			#atualizo o iterador do nucleo
			addi $t3, $t3, 1
			#verifico a condicao de parada, se nao e igual a n*n pula para loop interno
			bne $t3, $v1, loop_interno
			
		
		#vou pegar os modulos dos acumuladores, dividir pela sope, montar uma word e escrever no lugar certo
		#vou carregar a0 e v0 na pilha antes de tudo, pq a funcao modulo utiliza essas variaveis
		addi $sp, $sp, -8
		sw $a0, 4($sp)
		sw $v0, 0($sp)
		#Acumulador R
		add $a0, $zero, $s0 #seto a0 = acumulador R
		jal modulo
		add $s0, $zero, $v0
		div $s0, $s0, $t7
		
		#Acumulador G
		add $a0, $zero, $s1 #seto a0 = acumulador G
		jal modulo
		add $s1, $zero, $v0
		div $s1, $s1, $t7
		
		#Acumulador B
		add $a0, $zero, $s5 #seto a0 = acumulador B
		jal modulo
		add $s5, $zero, $v0
		div $s5, $s5, $t7
		
		#descarrego a0 e v0 da pilha
		lw $a0, 4($sp)
		lw $v0, 0($sp)
		addi $sp, $sp, 8
		
	    	#montar uma word
	    	add $s7, $zero, $zero
	    	or $s7, $s7, $s0
	    	sll $s1, $s1, 8
	    	or $s7, $s7, $s1
	    	sll $s5, $s5, 16
	    	or $s7, $s7, $s5
	    	#carrego a word no local certo onde vou escrever a imagem borrada
	    	mul $v0, $t1, $s2
	    	add $v0, $v0, $t2
	    	sll $v0, $v0, 2
	    	add $v0, $v0, $a2
	    	sw $s7, 0($v0)			
			
		#faco coluna da imagem++
		addi $t2, $t2, 1
		#faco s7 virar o limite de coluna
		sub $s7, $s2, $t6
		#comparo
		bne $t2, $s7, facil
		addi $t1, $t1, 1 #se passei, pula uma linha
		add $t2, $zero, $t6 #e a coluna volta a ser a de inicio
		facil: sub $s7, $s3, $t6 #vou gerar o limite de linha
		#e comparar
		bne $t1, $s7, loop_externo #se nao e igual, continuo no loop
	
	#desempilha as variaveis que usei
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	lw $t6, 24($sp)
	lw $t7, 28($sp)
	lw $t8, 32($sp)
	lw $t9, 36($sp)
	lw $v0, 40($sp)
	lw $v1, 44($sp)
	lw $s0, 48($sp)
	lw $s1, 52($sp)
	lw $s5, 56($sp)
	lw $s7, 60($sp)
	lw $ra, 64($sp)
	addi $sp, $sp, 68
	jr $ra
	
	
		
	
		

#*****************************************************************************************************************#
#Abre o arquivo de imagem e carrega para o bitmap display no endereço 0x10040000
#Retorna o endereço do começo da imagem em $v0
loadImage:
    add $s7, $ra, $zero
 
 #   Pega o nome do arquivo (ainda não funciona)  
 #   la $a0, m9
 #   jal printString
 #   la $a0, filename
 #   li $a1, 50
 #   jal scanString
	
    
    la $a0, m17
    jal printString   
    
    li $v0, 13
    la $a0, filename
    li $a1, 0
    li $a2, 0
    syscall
    #abro o arquivo no modo leitura
    
    #blt $v0, $zero, erro
    
    move $s1, $v0 #salvo o descritor do arquivo
     
    move $a0, $v0
    li $v0, 14
    addi $a1, $zero, 0x10010000
    li $a2, 54
    syscall
    #leio o header do arquivo na memoria
    
    move $s0, $a1 #salvo onde comeca o buffer de entrada
    
    addi $a0, $s0, 14
    jal carrega_word

    addi $a0, $s0, 18
    jal carrega_word
    add $s2, $v0, $zero #salvo a largura da imagem
    
    addi $a0, $s0, 22
    jal carrega_word
    add $s3, $v0, $zero #salvo a altura da imagem
    
    addi $a0, $s0, 34 
    jal carrega_word
    add $s4, $v0, $zero #salvo o tamanho da bitmapdata
    
    move $a0, $s1
    li $v0, 14
   
   
    addi $s6, $zero, 0x10040000 #salvo o ponteiro para a imagem certa
        
    mul $t0, $s2, $s3 #t0=width*height
    sll $t0, $t0, 2
    mul $t0, $t0, 3  #t0=4*width*height*3, deixo 3 imagens de distância
    
    
    addi $a1, $t0, 0x10040000
    add $s5, $a1, $zero #salvo o ponteiro para o endereco aonde esta a imagem invertida
    add $a2, $s4, $zero
    syscall
    #leio a imagem de cabeca para baixo e com 3 bytes por pixel, ainda nao e o formato para exibicao
    
    li $v0, 16					
    syscall	
    
    #inicio as variaveis que vao caminhar no algoritmo, "iteradores"
    mul $t0, $s2, $s3 #produto width*height
    add $t1, $zero, $zero #deslocamento da imagem invertida igual a 0
    add $t2, $zero, $zero #coluna da imagem certa = 0
    addi $t3, $s3, -1 #linha da imagem certa = height - 1
    mul $t4, $s2, $t3 #deslocamento da imagem certa = width*linha
    add $t4, $t4, $t2 #deslocamento da imagem certa = deslocamento da imagem certa + coluna
    sll $t4, $t4, 2 #deslocamento da imagem certa = deslocamento da imagem certa*4
    
#escrevo o pixel na imagem certa com base no valor da imagem invertida
    escreve:
    	add $a0, $zero, $t1
   	jal mul3
 	add $t5, $v0, $zero # posic. imagem invertida = desloc. imagem inv.*3
     	add $t5, $t5, $s5 # posic. imagem invertida = posic. imagem invertida + ptr. base da imagem invertida
     	add $a0, $t5, $zero #argumento 0 = posic. imagem invertida
     	jal obtem_pixel #$v0 = pixel que eu quero escrever
    	add $v1, $t4, $s6 #v1 = desloc. imagem certa + ptr. base da imagem certa
    	sw $v0, 0($v1) #salvo o pixel na posicao certa na imagem certa
        
    #atualizo iteradores e verifico condicoes de mudanca e parada
    addi $t1, $t1, 1 #desloc. da imagem invertida ++
    addi $t2, $t2, 1 #coluna da imagem certa ++
    slt $t6, $t2, $s2 #flag=(coluna<width)?1:0
    bne $t6, $zero, normal #enquanto for 1 (nao for 0) ir para normal
    add $t2, $zero, $zero #coluna = 0
    addi $t3, $t3, -1 #linha--
    normal:
        mul $t4, $s2, $t3 #deslocamento da imagem certa = width*linha
        add $t4, $t4, $t2 #deslocamento da imagem certa = deslocamento da imagem certa + coluna
        sll $t4, $t4, 2 #deslocamento da imagem certa = deslocamento da imagem certa*4
    slt $t6, $t1, $t0 #flag=(desloc. imagem invertida < width*height)?1:0
    bne $t6, $zero, escreve #enquanto for 1 ir para escreve   
    
    la $a0, m18
    jal printString  
    
    move $a0, $s1
    add $ra, $s7, $zero
    #add $v0, $s6, $zero
    jr $ra
    
    
    
#*****************************************************************************************************************#  

modulo: #calcula o modulo de um numero $a0 e devolve em $v0
	andi $v0, $a0, 0x80000000
	beq $v0, $zero, direto
	nor $a0, $a0, $zero
	addi $a0, $a0, 1
	direto: add $v0, $a0, $zero
	jr $ra
	      
      
#*****************************************************************************************************************#    
carrega_word: #recebe o endereco do primeiro byte de uma word desalinhada e coloca a word em v0
	addi $sp, $sp, -16
        sw $t0, 12($sp)
        sw $t1, 8($sp)
        sw $t2, 4($sp)
        sw $t3, 0($sp) #guardo os valores originais dos registradores que vou usar
        lbu $t0, 0($a0)
        lbu $t1, 1($a0)
        lbu $t2, 2($a0)
        lbu $t3, 3($a0) #carrego os bytes nos 4 registradores temporarios
        sll $t0, $t0, 0
        sll $t1, $t1, 8
        sll $t2, $t2, 16 
        sll $t3, $t3, 24 #desloco os bytes conforme necessario
        or $t0, $t0, $t1
        or $t0, $t0, $t2
        or $t0, $t0, $t3
        add $v0, $t0, $zero
        lw $t3, 0($sp)
        lw $t2, 4($sp)
        lw $t1, 8($sp)
        lw $t0, 12($sp)
        addi $sp, $sp, 16
        jr $ra
 #*****************************************************************************************************************#
 
        
               
#*****************************************************************************************************************#                             
obtem_pixel: #recebe o endereco do primeiro byte de um pixel e coloca a word correspondente em v0
        addi $sp, $sp, -16
        sw $t0, 12($sp)
        sw $t1, 8($sp)
        sw $t2, 4($sp)
        sw $t3, 0($sp) #guardo os valores originais dos registradores que vou usar
        lbu $t0, 0($a0)
        lbu $t1, 1($a0)
        lbu $t2, 2($a0)
        add $t3, $zero, $zero #carrego os bytes nos 4 registradores temporarios
        sll $t0, $t0, 0
        sll $t1, $t1, 8
        sll $t2, $t2, 16 
        sll $t3, $t3, 24 #desloco os bytes conforme necessario
        or $t0, $t0, $t1
        or $t0, $t0, $t2
        or $t0, $t0, $t3
        add $v0, $t0, $zero
        lw $t3, 0($sp)
        lw $t2, 4($sp)
        lw $t1, 8($sp)
        lw $t0, 12($sp)
        addi $sp, $sp, 16
        jr $ra

#*****************************************************************************************************************#



#*****************************************************************************************************************#
mul3: 
        addi $sp, $sp, -4
        sw $t0, 0($sp)
        addi $t0, $zero, 3
        mul $v0, $a0, $t0
        lw $t0, 0($sp)
        addi $sp, $sp, 4
        jr $ra
             
#*****************************************************************************************************************#


#*****************************************************************************************************************#
printString:
	li $v0, 4
	syscall
	jr $ra
#*****************************************************************************************************************#


#*****************************************************************************************************************#
scanString:
	li $v0, 8
	syscall
	jr $ra
#*****************************************************************************************************************#

erro:
	la $a0, m33
	jal printString

fim:
	la $a0, m16
	jal printString
	
