.data
	ingreseNumero: .asciiz "Por favor ingrese el entero al que desea calcular su seno hiperbolico: "
	resultado: .asciiz "El resultado del seno hiperbolico calculado es: "
	neutroMulDouble: .double 1.0
	diezDouble: .double 10.0
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
			beq $s7, 8, exitMain
			
			#Se calcula la expresion 2n
			add $a1, $zero, $s7
			addi $a2, $zero, 2
			jal mulInt
			#Se almacena el resultado de 2n y se le suma 1
			addi $s1, $v1, 1
			#Se calcula el numerador x^(2n+1)
			add $a1, $zero, $s0
			add $a2, $zero, $s1
			jal potD
			#Se almacena la expresion x^(2n+1) en f2
			add.d $f2, $f0, $f28
			
			#--------------------------------------------------
			#Se calcula el denominador (2n+1)!
			mtc1.d $s1, $f24
			cvt.d.w $f24, $f24
			jal factD
			#Se guarda el resultado del factorial en f4
			add.d $f4, $f0, $f28
			#--------------------------------------------------
			
			#Se realiza la division entre ambos numeros
			add.d $f24, $f0, $f2
			add.d $f26, $f0, $f4
			jal divD
			
			#Se Suma al acumulado
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
			
#Multiplicacion entre dos double
	mulDD:
		#Se copian los valores de los argumentos
		add.d $f8, $f0, $f24
		add.d $f10, $f0, $f26
		
		#Se comprueba si se esta multiplicando por cero
		c.eq.d $f8, $f0
		bc1t mulDDCero
		c.eq.d $f10, $f0
		bc1t mulDDCero
		
		#Se copia un 1 double para comprobar y actualizar contador
		ldc1 $f12, neutroMulDouble
		
		#Ciclo para calcular el resultado
		whileMulDD:
			#Se comptueba si se debe seguir sumando
			c.eq.d $f10, $f12
			bc1t exitMulDD
			#Se suma el numero a si mismo
			add.d $f8, $f8, $f24
			#Se resta uno al contador
			sub.d $f10, $f10, $f12
			#Se vuele al ciclo
			j whileMulDD
		
		exitMulDD:
			#Se asgina el resultado de la multipliacion en el registro de retorno
			add.d $f28, $f0, $f8
			#Se vuelve al main
			jr $ra
		
		mulDDCero:
			#Se asgina el resultado de la multipliacion en el registro de retorno
			add.d $f28, $f0, $f0
			#Se vuelve al main
			jr $ra
		
#Potencia que retorna double, pero recibe int
	potD:
		#Se guarda el valor de la base
		mtc1.d $a1, $f14
		cvt.d.w $f14, $f14
		#Se guarda el valor del exponente para utilizarlo como contador
		mtc1.d $a2, $f16
		cvt.d.w $f16, $f16
		#Exponente cero
		beqz $a2, exponenteCeroD
		#Exponente uno
		beq $a2, 1, exponenteUnoD
		#Se copia un 1 double para comprobar y actualizar contador
		ldc1 $f18, neutroMulDouble
		#Se guarda el valor para guardar el acumulado
		add.d $f20, $f0, $f18
		#Se guarda la direccion desde donde se realizo el salto
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		#Ciclo
		whilePotD:
			#Se comptueba si se debe seguir sumando
			c.lt.d $f16, $f18
			bc1t exitPotD
			#Se establecen los argumentos de la multiplicacion
			add.d $f24, $f0, $f20
			add.d $f26, $f0, $f14
			#Se multiplica el acumulado con la base
			jal mulDD
			#Se guarda el resultado como nuevo acumulado
			add.d $f20, $f0, $f28
			#Se resta uno al contador
			sub.d $f16, $f16, $f18
			#Se vuelve al ciclo
			j whilePotD
		
		#Termino del caso general
		exitPotD:
			#Se devuelve el valor de ra antiguo que apunta al lugar desde el que se salto
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			#Se asigna el valor del resultado en el registro de retorno
			add.d $f28, $f0, $f20
			#Se retorna
			jr $ra
			
		#Exponente igual a cero
		exponenteCeroD:
			#Se asigna el valor del resultado en el registro de retorno
			ldc1 $f28, neutroMulDouble
			#Se retorna
			jr $ra
			
		#Exponente igual a uno
		exponenteUnoD:
			#Se asigna el valor del resultado en el registro v1
			add.d $f28, $f0, $f14
			#Se retorna
			jr $ra	
		
#Factorial para un double
	factD:
		#Se transforma el argumento a entero para utilizarlo como multiplicador y contador
		cvt.w.d $f30, $f24
		mfc1 $t1, $f30
		#Se copia el valor del argumento
		add.d $f14, $f0, $f24
		#Se almacena el valor para mantener el acumulado
		ldc1 $f12, neutroMulDouble
		#Se guarda la direccion desde donde se realizo el salto
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		#Se comprueba si se quiere calcular el valor de cero
		beqz $t1, exitFactD
		
		#Ciclo para calcular el factorial
		whileFactD:
			#Se comprueba que si se debe seguir multiplicando
			blt $t1, 2, exitFactD
			#Se asignan los valores para multiplicar
			add.d $f24, $f0, $f12
			add $a2, $zero, $t1
			#Se almacenan los valores en el stack para no perderlos
			addi $sp, $sp, -4
			sw $t1, 0($sp)
			#Se realiza la multiplicacion
			jal mulDouble
			#Se almacena el resultado de la multiplicacion en el registro f12
			add.d $f12, $f0, $f28
			#Se restauran los valores del stack
			lw $t1, 0($sp)
			addi $sp, $sp, 4
			#Se resta uno al numero por el que se debe multiplicar
			addi $t1, $t1, -1
			#Vuelve al ciclo
			j whileFactD
		
		#Retorno del subproceso
		exitFactD:
			#Se devuelve el valor de ra antiguo que apunta al lugar desde el que se salto
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			#Se asgina el resultado de la multipliacion en el registro de retorno
			add.d $f28, $f0, $f12
			#Se vuelve al main
			jr $ra
			
			
			
			
#Division		
	divD:
		#Se copian los valores de los argumentos
		add.d $f14, $f0, $f24
		add.d $f16, $f0, $f26
		#Se copia el valor del numerador para saber al final si era negativo
		add.d $f30, $f0, $f26
		#Se toma el numerador como positivo
		abs.d $f14, $f14
		#Se copia un uno para restar y sumar 1
		ldc1 $f12, neutroMulDouble
		
		#Resultado de la resta entre ambos numeros
		add.d $f18, $f0, $f0
		#Acumula cuantas veces cabe t1 en t0
		add.d $f20, $f0, $f0
		#Se comprueba si el numerador es 0
		c.eq.d $f14, $f0
		bc1t divDCero
		#Se compueba si el dividendo es cero
		c.eq.d $f16, $f0
		bc1t divDCero
		
		#Se resta hasta que se llega a un numero menor a cero o cero
		whileDivD:
			#Se restan ambos numeros y se almacena el resultado en t3
			sub.d $f18, $f14, $f16
			#Si el resultado de la resta es menor a cero, se salta a la etiqueta para divisiones inexactas
			c.lt.d $f18, $f0
			bc1t divDInex
			#Si el resultado no es menor a cero, se aumenta en 1 el contador de cuantas veces cabe el divisor en el dividendo
			add.d $f20, $f20, $f12
			#Si el resultado de la resta es cero, se salta a la etiqueta para divisiones exactas
			c.eq.d $f18, $f0
			bc1t divDEx
			#Si el resultado de la resta es mayor a cero, se actualiza el numero al que se le resta el divisor
			add.d $f14, $f0, $f18
			#Se vuelve al ciclo
			j whileDivD
		
		divDCero:
			#Se retorna cero
			add.d $f28, $f0, $f0
			#Se vuelve al main
			jr $ra
		
		divDEx:
			add.d $f28, $f0, $f20
			#Se comprueba si era una division negativa
			c.lt.d $f30, $f0
			bc1t divNegativa
			
			#Se vuelve al main si no era negativa
			jr $ra
			
		divDInex:
			#Ahora se calculan los dos decimales
			#Primero se reserva memoria en el stack para guardar el valor de ra que nos devuelve al main y el valor del divisor
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			#Se calcula el primer decimal
			add.d $f24, $f0, $f14		#Se entrega el residuo de la division original como dividendo de la subDivisionInexacta
			add.d $f26, $f0, $f16
			jal subDivisionInexacta
			#Se guarda el resultado del primer decimal como argumento de la multiplicacion
			add.d $f26, $f0, $f28
			#Se transforma el primer decimal a double
			ldc1 $f24, firstDecimal
			jal mulDD
			#Se suma a la parte entera
			add.d $f20, $f20, $f28
						
			
			#Se calcula el segundo decimal
			add.d $f24, $f0, $f14		#Registro donde quedo el residuo de la subDiv anterior
			add.d $f26, $f0, $f16
			jal subDivisionInexacta
			#Se guarda el resultado del segundo decimal como argumento de la multiplicacion
			add.d $f26, $f0, $f28
			#Se transforma el primer decimal a double
			ldc1 $f24, secondDecimal
			jal mulDD
			#Se suma a la parte entera
			add.d $f20, $f20, $f28
			#Se devuelve el valor de ra antiguo que apunta al main
			lw $ra, 0($sp)
			addi $sp, $sp, 4
		
			#Se comprueba si era una division negativa
			c.lt.d $f30, $f0
			bc1t divNegativa
			
			#Se vuelve al main si no era negativa
			add.d $f28, $f0, $f20
			jr $ra
			
		divNegativa:
			#Se guarda la direccion desde donde se realizo el salto anteriormente
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			#Se copia el resultado de la division
			add.d $f30, $f0, $f20
			#Se entrega el resultado como argumento
			add.d $f24, $f0, $f20
			#Se multiplica por 2
			addi $a2, $zero, 2
			jal mulDouble
			add.d $f18, $f0, $f20
			#Se consigue el valor negativo del resultado de la division
			sub.d $f28, $f22, $f18
			
			#Se restaura la direccion de ra y se vuelve
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra
			 
	
	subDivisionInexacta:
		#Numerador
		add.d $f14, $f0, $f24
		#Denominador
		add.d $f18, $f0, $f26
		
		#Guardamos el antiguo valor del registro ra, el cual apunta a la funcion de division
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		#Se multiplica por 10 para restar
		ldc1 $f26, diezDouble
		jal mulDD
		#Se almacena el resultado de la multiplicacion en t0
		add.d $f14, $f0, $f28
		#Resultado de la resta entre ambos numeros
		add.d $f8, $f0, $f0
		#Acumula cuantas veces cabe t1 en t0
		add.d $f10, $f0, $f0
		
		#Se resta para obtener uno de los decimales
		whileSubDivDInex:
			#Se restan ambos numeros y se almacena el resultado en f
			sub.d $f8, $f14, $f18
			#Si el resultado de la resta es menor o igual a cero, se sale del ciclo
			c.lt.d $f8, $f0
			bc1t exitSubDDiv
			#Si el resultado no es menor a cero, se aumenta en 1 el contador de cuantas veces cabe el divisor en el dividendo
			add.d $f10, $f10, $f12
			#Si el resultado de la resta es mayor a cero, se actualiza el numero al que se le resta el divisor
			add.d $f14, $f0, $f8
			#Se vuelve al ciclo
			j whileSubDivDInex
		
		exitSubDDiv:
			#Se asigna el valor del residuo de esta division como argumento de la subDivision del siguiente decimal
			add.d $f24, $f0, $f14
			#Se asgina el resultado en el registro de retorno
			add.d $f28, $f0, $f10
			#Se carga el antiguo valor de ra, que apunta a la funcion de division
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			#Se retorna al lugar desde donde se llamo la funcion
			jr $ra
			
			
			
			
		
	
