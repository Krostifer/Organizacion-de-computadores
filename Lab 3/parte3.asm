.data

.text
	#Dirección de memoria donde comienza el arreglo que almacena los fibonaccis calculados
	addi $s7, $zero 0x10000000
	#Se establece el valor del fibonacci de 0 y 1 
	add $t7, $zero, $zero
	sw $t7, 0($s7)
	addi $t7, $zero, 1
	sw $t7, 4($s7)
	#Valor del fibonacci a calcular, si se desea cambiar el fibonacci a calcular, modificar el numero ubicado al final de la siguiente linea
	addi $a0, $zero, 8
	#Se llama la funcion para calcular el fibonacci del numero deseado
	jal fibonacci
	#Se almacena el valor del fibonaccio en s1
	add $s1, $v1, $zero
	
	#Se muestra el resultado
	#Luego el numero
	li $v0, 1
	add $a0, $zero, $s1
	syscall
	

	#Termino del programa
	li $v0, 10
	syscall


	fibonacci:
		addi $sp, $sp, -12
		#Se almacena la direccion para volver al lugar desde el que se llamo la funcion
		sw $ra, 0($sp)
		#Se almacena el valor del argumento n que entro
		sw $a0, 4($sp)
		#Se almacena el valor acumulado
		sw $s0, 8($sp)
	
		#Casos bases
		#Fibonnaci de cero
		beqz $a0, fiboCero
		
		#Indice en el que se debería encontrar el resultado de este fibonacci
		mul $t0, $a0, 4
		#Direccion dentro del arreglo
		add $t1, $s7, $t0
		#Se carga el valor del fibonacci
		lw $t2, 0($t1)
			
		#Se comprueba si es un valor diferente de cero, osea si ya se calculo
		bgtz $t2, fibCalculado
	
		#Caso general
		beqz $t2 casoGeneral
	
		#Fibonnaci de 0
		fiboCero:
			#Se asigna cero como retorno
			add, $v1, $zero, $zero
			#Se restaura la memoria del stack
			addi $sp, $sp, 12
			#Se retornar al lugar del salto
			jr $ra
			
		fibCalculado:
			#Se retorna el valor que se obtuvo del arreglo
			add $v1, $zero, $t2
			#Se restaura la memoria del stack
			addi $sp, $sp, 12
			#Se retorna al lugar desde el que se llamo la funcion
			jr $ra
	
		#Caso general	
		casoGeneral:
			#Se guarda la direccion donde se almacenara el fibonacci una vez calculado
			addi $sp, $sp, -4
			sw $t1, 0($sp)
			#Se almacena n-1 como argumento
			addi $a0, $a0, -1
			#Se calcula el fibonacci de n-1
			jal fibonacci
			#Se restaura el valor de n como argumento
			lw $a0, 8($sp)
			#Se suma el valor del fibonacci de n-1 con el acumulado
			add $s0, $v1, $zero
			#Se almacena n-2 como argumento
			addi $a0, $a0, -2
			#Se calcula el fibonacci de n-2
			jal fibonacci
			#Se suma el valor del fibonacci de n-2 con el acumulado
			add $v1, $s0, $v1
			#Se retorna el valor de la direccion donde se guarda el fibonacci
			lw $t1, 0($sp)
			#Se almacena el fibonacci calculado
			sw $v1, 0($t1)
			#Se retornan los valores guardados en el stack
			lw $ra, 4($sp)
			lw $a0, 8($sp)
			lw $s0, 12($sp)
			#Se restaura la memoria del stack
			addi $sp, $sp, 16
			#Se retorna al lugar desde el que se llamo la funcion
			jr $ra
			
		
				
