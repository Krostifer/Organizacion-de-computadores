.data
	ingreseNumero: .asciiz "Ingrese el valor al cual desea calcular su coseno: "
	resultado: .asciiz "El resultado del coseno es: "
	neutroMulDouble: .double 1.0
	doubleCero: .double 0.0
	firstDecimal: .double 0.1
	secondDecimal: .double 0.01
.text
	main:
		#Se muestra el mensaje para el primer input
		li $v0, 4
		la $a0, ingreseNumero
		syscall
		#Se obtiene el input del usuario
		li $v0, 5
		syscall
		#Se guarda el input
		add $s0, $zero, $v0
		#Se transforma a un double
		
		#Se establece el orden de la serie para utilizarlo como contador
		addi $s7, $zero, 0
		
		whileMain:
			beq $s7, 7, exitMain
			
			#Se calcula el numerador
			addi $a1, $zero, -1
			add $a2, $zero, $s7
			#Se calcula la potencia
			jal potInt
			#Se guarda el numerador en s1
			add $s1, $zero, $v1
			
			#--------------------------------------------------
			
			#Se calcula el denominador
			#Primero la expresion 2n
			addi $a1, $zero, 2
			add $a2, $zero, $s7
			jal mulInt
			#Se almacena el valor de 2n en s2
			add $s2, $zero, $v1
			
			#Se transforma a un double
			mtc1.d $s2, $f2
			cvt.d.w $f2, $f2			
			
			#Se calcula el factorial
			add.d $f24, $f0, $f2
			jal factorialDouble
			add.d $f2, $f0, $f28
			
			#--------------------------------------------------
			
			#Se dividen ambos numeros
			#Se transforma el numerador a un double
			mtc1.d $s1, $f4
			cvt.d.w $f4, $f4
			#Se asignan como argumentos
			add.d $f24, $f0, $f4
			add.d $f26, $f0, $f2
			#Se llama a la funcion que divide
			jal division
			#Se almacena el resultado
			add.d $f4, $f0, $f28
			
			#--------------------------------------------------
			
			#Se calcula x^2n
			add $a1, $zero, $s0
			add $a2, $zero, $s2 
			jal potInt
			#Se almacena el valor de x^2n en s3
			add $s3, $zero, $v1
			
			#--------------------------------------------------
			
			#Se multiplican ambos numeros
			add.d $f24, $f0, $f4
			add $a2, $zero, $s3
			jal mulDouble
			
			#Se suma el resultado del ciclo actual con el acumulado
			add.d $f22, $f22, $f28
			
			#Se actualiza el contador
			addi $s7, $s7, 1
			#Se vuelve al ciclo
			j whileMain
			
		
	#Termino del programa
	exitMain:
		#Se muestra el resultado
		#Primero se imprime el texto
		li $v0, 4
		la $a0, resultado
		syscall
		#Luego el numero
		li $v0, 3
		add.d $f12, $f0, $f22
		syscall
		
		#Se termina el programa
		li $v0, 10
		syscall
	
	
	
#--------------------------------------------------------------------------------------------------------
#Multiplicacion de enteros

	mulInt:
		#Multiplicacion por cero
		beqz $a1, mulIntCero
		beqz $a2, mulIntCero
			
		#Multiplicación por 1
		beq $a2, 1, mulIntUno
		
		#Multiplicador negativo
		bltz $a2 multiplicadorNegativo
		#Se asgina el valor por el que se desea multiplicar en t0 para utilizarla como contador
		add $t0, $zero, $a2
		#Se asigna el valor a multiplicar en t1
		add $t1, $zero, $a1
		#Se va al caso general
		j casoGeneralMulInt
		
		multiplicadorNegativo:
			#Ambos numeros negativos
			bltz $a1, ambosNegativos
			#Se asgina el valor por el que se desea multiplicar en t0 para utilizarla como contador
			add $t0, $zero, $a1
			#Se asigna el valor a multiplicar en t1
			add $t1, $zero, $a2
			add $a1, $zero, $a2
			#Se va al caso general
			j casoGeneralMulInt
		
		ambosNegativos:
			#Se asgina el valor por el que se desea multiplicar en t0 para utilizarla como contador
			abs $t0, $a1
			#Se asigna el valor a multiplicar en t1
			abs $t1, $a2
			#Se vuelven a asignar los argumentos
			add $a1, $zero, $t0
			add $a2, $zero, $t1
			#Se va al caso general
			j casoGeneralMulInt
		
		casoGeneralMulInt:
			whileMulInt:
				#Se comptueba si se debe seguir sumando
				beq $t0, 1, exitMulInt
				#Se suma el numero a si mismo
				add $t1, $t1, $a1
				#Se resta uno al contador
				addi $t0, $t0, -1
				#Se vuele al ciclo
				j whileMulInt
				
			exitMulInt:
				#Se asgina el resultado de la multipliacion en el registro de retorno
				add $v1, $zero, $t1
				#Se vuelve al main
				jr $ra
		
		#En caso de que se multiplique por cero
		mulIntCero:
			#Se asigna cero en el registro de retorno
			add $v1, $zero, $zero
			jr $ra
		
		mulIntUno:
			#Se asigna cero en el registro de retorno
			add $v1, $zero, $a1
			jr $ra
			
#Potencia

	potInt:
		#Exponente cero
		beqz $a2, exponenteCero
		#Exponente uno
		beq $a2, 1, exponenteUno
		#Se guarda el valor de la base
		add $t0, $zero, $a1
		#Se guarda el valor para guardar el acumulado
		add $t1, $zero, $a1
		#Se guarda el valor del exponente para utilizarlo como contador
		add $t2, $zero, $a2
		#Se guarda la direccion desde donde se realizo el salto
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		#Ciclo
		whilePotInt:
			#Se comprueba si se debe salir del ciclo
			ble $t2, 1, exitPotInt
			#Se establecen los argumentos de la multiplicacion
			add $a1, $zero, $t1
			add $a2, $zero, $t0
			#Se guardan los valores en el stack para no perderlos
			addi $sp, $sp, -8
			sw $t0, 4($sp)
			sw $t2, 0($sp)
			#Se multiplica el acumulado con la base
			jal mulInt
			#Se restauran los valores
			lw $t2, 0($sp)
			lw $t0, 4($sp)
			addi $sp, $sp, 8
			#Se guarda el resultado como nuevo acumulado
			add $t1, $zero, $v1
			#Se resta uno al contador
			addi $t2, $t2, -1
			#Se vuelve al ciclo
			j whilePotInt
		
		#Termino del caso general
		exitPotInt:
			#Se devuelve el valor de ra antiguo que apunta al lugar desde el que se salto
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			#Se asigna el valor del resultado en el registro v1
			add $v1, $zero, $t1
			#Se retorna
			jr $ra
			
		#Exponente igual a cero
		exponenteCero:
			#Se asigna el valor del resultado en el registro v1
			addi $v1, $zero, 1
			#Se retorna
			jr $ra
			
		#Exponente igual a uno
		exponenteUno:
			#Se asigna el valor del resultado en el registro v1
			add $v1, $zero, $a1
			#Se retorna
			jr $ra
			
			
#Se utilizara $f0 como el registro $zero
#Se utilizara $f24 y $f26 como argumentos 
#Se utilizara $f28 como retorno

#Multiplicacion entre un double y un entero mayor a cero
	mulDouble:
		#Se copian los valores de los argumentos
		add.d $f20, $f0, $f24
		add $t0, $zero, $a2
		
		#Se comprueba si se esta multiplicando por cero
		#Primer argumento igual a cero
		c.eq.d $f20, $f0
		bc1t mulDoubleCero
		#Segundo argumento igual a cero
		beqz $t0, mulDoubleCero
		
		
		#Ciclo para calcular el resultado
		whileMulDouble:
			#Se comptueba si se debe seguir sumando
			beq $t0, 1, exitMulDouble
			#Se suma el numero a si mismo
			add.d $f20, $f20, $f24
			#Se resta uno al contador
			addi $t0, $t0, -1
			#Se vuele al ciclo
			j whileMulDouble
		
		exitMulDouble:
			#Se asgina el resultado de la multipliacion en el registro de retorno
			add.d $f28, $f0, $f20
			#Se vuelve al main
			jr $ra
		
		mulDoubleCero:
			#Se asgina el resultado de la multipliacion en el registro de retorno
			add.d $f28, $f0, $f0
			#Se vuelve al main
			jr $ra
		
#Factorial para un double
	factorialDouble:
		#Se transforma el argumento a entero para utilizarlo como multiplicador y contador
		cvt.w.d $f30, $f24
		mfc1 $t1, $f30
		
		#Se copia el valor del argumento
		add.d $f14, $f0, $f24
		#Se almacena el valor para mantener el acumulado
		ldc1 $f16, neutroMulDouble
		#Se guarda la direccion desde donde se realizo el salto
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		#Se comprueba si se quiere calcular el valor de cero
		beqz $t1, exitFact
		
		#Ciclo para calcular el factorial
		whileFact:
			#Se comprueba que si se debe seguir multiplicando
			blt $t1, 2, exitFact
			#Se asignan los valores para multiplicar
			add.d $f24, $f0, $f16
			add $a2, $zero, $t1
			#Se almacenan los valores en el stack para no perderlos
			addi $sp, $sp, -4
			sw $t1, 0($sp)
			#Se realiza la multiplicacion
			jal mulDouble
			#Se almacena el resultado de la multiplicacion en el registro s0
			add.d $f16, $f0, $f28
			#Se restauran los valores del stack
			lw $t1, 0($sp)
			addi $sp, $sp, 4
			#Se resta uno al numero por el que se debe multiplicar
			addi $t1, $t1, -1
			#Vuelve al ciclo
			j whileFact
		
		#Retorno del subproceso
		exitFact:
			#Se devuelve el valor de ra antiguo que apunta al lugar desde el que se salto
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			#Se asgina el resultado de la multipliacion en el registro de retorno
			add.d $f28, $f0, $f16
			#Se vuelve al main
			jr $ra
			
			
			
			
#Division		
	division:
		#Se transforma el primer argumento (dividendo) a entero
		cvt.w.d $f30, $f24
		mfc1 $t0, $f30
		#Se transforma el segundo argumento (divisor) a entero
		cvt.w.d $f30, $f26
		mfc1 $t1, $f30
		
		#Se copia el valor del dividendo para comprobar si el numero era negativo al final
		add $t7, $zero, $t0
		#Se toma el dividendo como positivo
		abs $t0, $t0
		
		#Resultado de la resta entre ambos numeros
		add $t3, $zero, $zero
		#Acumula cuantas veces cabe t1 en t0
		add $t4, $zero, $zero
		#Se comprueba si el divisor es 0
		beqz $t1, divCero
		#Se compueba si el dividendo es cero
		beqz $t0, divCero
		
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
			
		divCero:
			#Se retorna cero
			add.d $f28, $f0, $f0
			#Se vuelve al main
			jr $ra
		
		divExacta:
			mtc1.d $t4, $f28
			cvt.d.w $f28, $f28
			#Se comprueba si era una division negativa
			bltz $t7, divNegativa
			
			#Se vuelve al main si no era negativa
			jr $ra
			
		divInexacta:
			#Se guarda la parte entera de la division
			mtc1.d $t4, $f8
			cvt.d.w $f8, $f8
			
			#Ahora se calculan los dos decimales
			#Primero se reserva memoria en el stack para guardar el valor de ra que nos devuelve al main y el valor del divisor
			addi $sp, $sp, -8
			sw $ra, 4($sp)
			sw $t1, 0($sp)
			#Se calcula el primer decimal
			add $a1, $zero, $t0		#Se entrega el residuo de la division original como dividendo de la subDivisionInexacta
			add $a2, $zero, $t1
			jal subDivisionInexacta
			#Se guarda el resultado del primer decimal
			add $t6, $zero, $v1
			#Se transforma el primer decimal a double
			ldc1 $f24, firstDecimal
			add $a2, $zero, $t6
			jal mulDouble
			#Se suma a la parte entera
			add.d $f8, $f8, $f28
			
			#Se carga el valor del divisor y se restaura parte de la memoria del stack
			lw $a2, 0($sp)
			addi $sp, $sp, 4
			
			
			#Se calcula el segundo decimal
			jal subDivisionInexacta
			#Se guarda el resultado del primer decimal
			add $t6, $zero, $v1
			#Se transforma el primer decimal a double
			ldc1 $f24, secondDecimal
			add $a2, $zero, $t6
			jal mulDouble
			#Se suma a la parte entera
			add.d $f8, $f8, $f28
			#Se devuelve el valor de ra antiguo que apunta al main
			lw $ra, 0($sp)
			addi $sp, $sp, 4
		
			#Se comprueba si era una division negativa
			bltz $t7, divNegativa
			
			#Se vuelve al main si no era negativa
			add.d $f28, $f0, $f8
			jr $ra
			
		divNegativa:
			#Se guarda la direccion desde donde se realizo el salto anteriormente
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			#Se copia el resultado de la division
			add.d $f10, $f0, $f28
			#Se entrega el resultado como argumento
			add.d $f24, $f0, $f28
			#Se multiplica por 2
			addi $a2, $zero, 2
			jal mulDouble
			add.d $f12, $f0, $f8
			#Se consigue el valor negativo del resultado de la division
			sub.d $f28, $f10, $f12
			
			#Se restaura la direccion de ra y se vuelve
			lw $ra, 0($sp)
			addi $sp, $sp, 4
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
		addi $sp, $sp, -8
		sw $ra, 4($sp)
		sw $t1, 0($sp)
		#Se multiplica por 10 para restar
		addi $a2, $zero, 10
		jal mulInt
		#Se almacena el resultado de la multiplicacion en t0
		add $t0, $zero, $v1
		#Se restaura el valor del divisor
		lw $t1, 0($sp)
		addi $sp, $sp, 4
		
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
