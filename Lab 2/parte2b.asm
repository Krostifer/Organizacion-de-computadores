.data
	resultado:	.asciiz "El resultado es: "
	
.text
	main:
		#Factorial a calcular, modificar el ultimo argumento para cambiar el factorial a calcular
		addi $t3, $zero, 12
		#Se asigna 1 en el registro donde se guardara el resultado(neutro multiplicador)
		addi $s0, $zero, 1
		#Se llama a la funcion de multiplicacion
		whileFact:
			#Se comprueba que si se debe seguir multiplicando
			blt $t3, 2, exitFact
			#Se asignan los valores para multiplicar
			add $a1, $zero, $s0
			add $a2, $zero, $t3
			#Se realiza la multiplicacion
			jal multiplicacion
			#Se almacena el resultado de la multiplicacion en el registro s0
			add $s0, $zero, $v1
			#Se resta uno al numero por el que se debe multiplicar
			addi $t3, $t3, -1
			#Vuelve al ciclo
			j whileFact
			
		exitFact:
			#Se muestra el resultado por pantalla
			li $v0, 4
			la $a0, resultado
			syscall
			li $v0, 1
			add $a0, $zero, $s0
			syscall
	
	#Termino del programa
	li $v0, 10
	syscall
	
	multiplicacion:
		#Multiplicacion por cero
		beq $a2, $zero, multiCero	
		
		#Caso general
		#Se asgina el valor por el que se desea multiplicar en t0 para utilizarla como contador
		add $t0, $zero, $a2
		#Se asigna el valor a multiplicar en t1
		add $t1, $zero, $a1
		
		whileMul:
			#Se comptueba si se debe seguir sumando
			blt $t0, 2, exitMul
			#Se suma el numero a si mismo
			add $t1, $t1, $a1
			#Se resta uno al contador
			addi $t0, $t0, -1
			#Se vuele al ciclo
			j whileMul
				
		exitMul:
			#Se asgina el resultado de la multipliacion en el registro de retorno
			add $v1, $zero, $t1
			#Se vuelve al main
			jr $ra
		
		#En caso de que se multiplique por cero
		multiCero:
			#Se asigna cero en el registro de retorno
			add $v1, $zero, $zero
			jr $ra
