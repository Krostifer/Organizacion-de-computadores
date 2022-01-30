.data

.text
	#Valor del fibonacci a calcular, si se desea cambiar el fibonacci a calcular, modificar el numero ubicado al final de la siguiente linea
	addi $a1, $zero, 4
	#Se llama la funcion para calcular el fibonacci del numero deseado
	jal fibonacci
	#Se almacena el valor del fibonaccio en s1
	add $s1, $v0, $zero

	#Termino del programa
	li $v0, 10
	syscall


	fibonacci:
		addi $sp, $sp, -12
		#Se almacena la direccion para volver al lugar desde el que se llamo la funcion
		sw $ra, 0($sp)
		#Se almacena el valor del argumento n que entro
		sw $a1, 4($sp)
		#Se almacena el valor acumulado
		sw $s0, 8($sp)
	
		#Casos bases
		#Fibonnaci de cero
		beqz $a1, fiboCero
		#Fibonacci de uno
		beq $a1, 1, fiboUno
	
		#Caso general
		jal casoGeneral
	
		#Fibonnaci de 0
		fiboCero:
			#Se asigna cero como retorno
			add, $v1, $zero, $zero
			#Se restaura la memoria del stack
			addi $sp, $sp, 12
			#Se retornar al lugar del salto
			jr $ra
	
		#Fibonnaci de 1
		fiboUno:
			#Se asigna uno como retorno
			addi $v1, $zero, 1
			#Se restaura la memoria del stack
			addi $sp, $sp, 12
			#Se retornar al lugar del salto
			jr $ra
		
		#Caso general	
		casoGeneral:
			#Se almacena n-1 como argumento
			addi $a1, $a1, -1
			#Se calcula el fibonacci de n-1
			jal fibonacci
			#Se restaura el valor de n como argumento
			lw $a1, 4($sp)
			#Se suma el valor del fibonacci de n-1 con el acumulado
			add $s0, $v1, $zero
			#Se almacena n-2 como argumento
			addi $a1, $a1, -2
			#Se calcula el fibonacci de n-2
			jal fibonacci
			#Se suma el valor del fibonacci de n-2 con el acumulado
			add $v1, $s0, $v1
			#Se retornan los valores guardados en el stack
			lw $ra, 0($sp)
			lw $a1, 4($sp)
			lw $s0, 8($sp)
			#Se restaura la memoria del stack
			addi $sp, $sp, 12
			#Se retorna al lugar desde el que se llamo la funcion
			jr $ra
