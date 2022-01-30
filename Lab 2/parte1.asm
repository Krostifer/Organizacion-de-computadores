.data
	primerNumero: .asciiz "Por favor ingrese el primer entero: "
	segundoNumero: .asciiz "\nPor favor ingrese el segundo entero: "
	resultado: .asciiz "\nEl maximo es: "
	
.text
	main:
		#Se muestra el mensaje para el primer input
		li $v0, 4
		la $a0, primerNumero
		syscall
		#Se obtiene el input del usuario
		li $v0, 5
		syscall
		#Se guarda el primer input
		add $s0, $zero, $v0
		
		#Se muestra el mensaje para el segundo input
		li $v0, 4
		la $a0, segundoNumero
		syscall
		#Se obtiene el input del usuario
		li $v0, 5
		syscall
		#Se guarda el primer input
		add $s1, $zero, $v0
		
		#Se asigna el valor de ambos enteros como argumentos de la funcion
		add $a1, $zero, $s0
		add $a2, $zero, $s1
		
		#Se llama la funcion para calcular el maximo
		jal maximo
		
		#Se muestra el resultado
		#Primero se imprime el texto
		li $v0, 4
		la $a0, resultado
		syscall
		#Luego el numero
		li $v0, 1
		add $a0, $zero, $v1
		syscall
		
	#Termino del programa
	li $v0, 10
	syscall
	
	#Funciones
	
	maximo:
		#Se guardan los valores de los argumetos en registros temporales
		add $t0, $zero, $a1
		add $t1, $zero, $a2
		
		#Se comprueba si el primer numero es mayor al segundo, si lo es se salta a la etiqueta para retornar el primer numero como maximo
		bge $t0, $t1, primeroMayor
		#Si el primero no es mayor, significa que el segundo lo es o son iguales, por lo que se retorna el segundo numero como maximo
		add $v1, $zero, $t1
		#Se vuelve al main
		jr $ra
		
		primeroMayor:
			#Se asigna el primer numero en registro de retorno
			add $v1, $zero, $t0
			#Se vuelve al main
			jr $ra
		
