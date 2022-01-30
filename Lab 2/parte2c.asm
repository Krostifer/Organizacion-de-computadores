.data
	resultado: .asciiz "El resultado es: "
	punto: .asciiz "."
	
.text
	main:
		#Numero a multiplicar, modificar el ultimo argumento para cambiar la multiplicacion a realizar
		addi $a1, $zero, -3
		#Numero por el que se multiplica, modificar el ultimo argumento para cambiar la multiplicacion a realizar
		addi $a2, $zero, 1
		#Se llama a la funcion de multiplicacion
		jal division
		#Se muestra el resultado por pantalla
		li $v0, 4
		la $a0, resultado
		syscall
		#Parte entera
		li $v0, 1
		add $a0, $zero, $s0
		syscall
		#Punto
		li $v0, 4
		la $a0, punto
		syscall
		#Primer decimal
		li $v0, 1
		add $a0, $zero, $s1
		syscall
		#Segundo decimal
		li $v0, 1
		add $a0, $zero, $s2
		syscall
		
	#Termino del programa
	li $v0, 10
	syscall
	
	#Funciones
	
	division:
		#Dividendo
		add $t0, $zero, $a1
		#Divisor
		add $t1, $zero, $a2
		#Resultado de la resta entre ambos numeros
		add $t3, $zero, $zero
		#Acumula cuantas veces cabe t1 en t0
		add $t4, $zero, $zero
		#Se comprueba si el divisor es 0
		beqz $t1, divExacta
		
		#Se resta hasta que se llega a un numero menor a cero o cero
		whileDiv:
			#Se restan ambos numeros y se almacena el resultado en t3
			sub $t3, $t0, $t1
			#Si el resultado de la resta es menor a cero, se salta a la etiqueta para divisiones inexactas
			bltz $t3, divInexacta
			#Si el resultado no es menor a cero, se aumenta en 1 el contador de cuantas veces cabe el divisor en el dividendo
			addi $t4, $t4, 1
			#Si el resultado de la resta es cero, se salta a la etiqueta para divisiones exactas
			beqz $t3, divExacta
			#Si el resultado de la resta es mayor a cero, se actualiza el numero al que se le resta el divisor
			add $t0, $zero, $t3
			#Se vuelve al ciclo
			j whileDiv
		
		divExacta:
			#Se guarda el resultado de la division
			add $s0, $zero, $t4
			#Se guarda el primer decimal que sera 0
			addi $s1, $zero, 0
			#Se guarda el segundo decimal que sera 0
			addi $s2, $zero, 0
			#Se vuelve al main
			jr $ra
			
		divInexacta:
			#Se guarda la parte entera de la division
			add $s0, $zero, $t4
			
			#Ahora se calculan los dos decimales
			#Primero se reserva memoria en el stack para guardar el valor de ra que nos devuelve al main y el valor del divisor
			addi $sp, $sp, -8
			sw $ra, 4($sp)
			sw $t1, 0($sp)
			#Se calcula el primer decimal
			add $a1, $zero, $t0		#Se entrega el residuo de la division original como dividendo de la subDivisionInexacta
			jal subDivisionInexacta
			#Se guarda el resultado del primer decimal
			add $s1, $zero, $v1
			#Se carga el valor del divisor y se restaura parte de la memoria del stack
			lw $a2, 4($sp)
			addi $sp, $sp, 4
			#Se calcula el segundo decimal
			jal subDivisionInexacta
			#Se guarda el resultado del segundo decimal
			add $s2, $zero, $v1
			#Se devuelve el valor de ra antiguo que apunta al main
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			#Se vuelve al main
			jr $ra
			
	
	subDivisionInexacta:
		#Dividendo
		add $t0, $zero, $a1
		#Divisor
		add $t1, $zero, $a2
		#Resultado de la resta entre ambos numeros
		add $t3, $zero, $zero
		#Acumula cuantas veces cabe t1 en t0
		add $t4, $zero, $zero
		#Guardamos el antiguo valor del registro ra, el cual apunta a la funcion de division
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		#Se multiplica por 10 para restar
		addi $a2, $zero, 10
		jal multiplicacion
		#Se almacena el resultado de la multiplicacion en t1
		add $t0, $zero, $v1
		#Se resta para obtener uno de los decimales
		whilesubDivInexacta:
			#Se restan ambos numeros y se almacena el resultado en t3
			sub $t3, $t0, $t1
			#Si el resultado de la resta es menor o igual a cero, se sale del ciclo
			bltz $t3, exitSubDiv
			#Si el resultado no es menor a cero, se aumenta en 1 el contador de cuantas veces cabe el divisor en el dividendo
			addi $t4, $t4, 1
			#Si el resultado de la resta es mayor a cero, se actualiza el numero al que se le resta el divisor
			add $t0, $zero, $t3
			#Se vuelve al ciclo
			j whilesubDivInexacta
		
		exitSubDiv:
			#Se asigna el valor del residuo de esta division como argumento de la subDivision del siguiente decimal
			add $a1, $zero, $t0
			#Se asgina el resultado en el registro de retorno
			add $v1, $zero, $t4
			#Se carga el antiguo valor de ra, que apunta a la funcion de division
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			#Se retorna al lugar desde donde se llamo la funcion
			jr $ra
	
	multiplicacion:
		#Multiplicacion por cero
		beq $a2, $zero, multiCero	
		
		#Caso general
		#Se asgina el valor por el que se desea multiplicar en t0 para utilizarla como contador
		add $t6, $zero, $a2
		#Se asigna el valor a multiplicar en t1
		add $t7, $zero, $a1
		
		while:
			#Se comptueba si se debe seguir sumando
			blt $t6, 2, exit
			#Se suma el numero a si mismo
			add $t7, $t7, $a1
			#Se resta uno al contador
			subi $t6, $t6, 1
			#Se vuele al ciclo
			j while
				
		exit:
			#Se asgina el resultado de la multipliacion en el registro de retorno
			add $v1, $zero, $t7
			#Se vuelve al main
			jr $ra
		
		#En caso de que se multiplique por cero
		multiCero:
			#Se asigna cero en el registro de retorno
			add $v1, $zero, $zero
			jr $ra
