.data
	resultado:	.asciiz "El resultado es: "
	
.text
	main:
		#Numero a multiplicar, modificar el ultimo argumento para cambiar la multiplicacion a realizar
		addi $a1, $zero, 1
		#Numero por el que se multiplica, modificar el ultimo argumento para cambiar la multiplicacion a realizar
		addi $a2, $zero, -3
		#Se llama a la funcion de multiplicacion
		jal multiplicacion
		#Se muestra el resultado por pantalla
		li $v0, 4
		la $a0, resultado
		syscall
		li $v0, 1
		add $a0, $zero, $v1
		syscall
	
	#Termino del programa
	li $v0, 10
	syscall
	
	multiplicacion:
		#Multiplicacion por cero
		beqz $a2, multiCero	
		#Multiplicación por 1
		beq $a2, 1, multiUno
		
		#Caso general
		#Se asgina el valor por el que se desea multiplicar en t0 para utilizarla como contador
		add $t0, $zero, $a2
		#Se asigna el valor a multiplicar en t1
		add $t1, $zero, $a1
		
		while:
			#Se comptueba si se debe seguir sumando
			beq $t0, 1, exit
			#Se suma el numero a si mismo
			add $t1, $t1, $a1
			#Se resta uno al contador
			addi $t0, $t0, -1
			#Se vuele al ciclo
			j while
				
		exit:
			#Se asgina el resultado de la multipliacion en el registro de retorno
			add $v1, $zero, $t1
			#Se vuelve al main
			jr $ra
		
		#En caso de que se multiplique por cero
		multiCero:
			#Se asigna cero en el registro de retorno
			add $v1, $zero, $zero
			jr $ra
		
		multiUno:
			#Se asigna cero en el registro de retorno
			add $v1, $zero, $a1
			jr $ra
