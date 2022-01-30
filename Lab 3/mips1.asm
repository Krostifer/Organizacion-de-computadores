.data
	n1: .double 3.5
	n2: .double 4.0
	
.text

	ldc1 $f0, n1
	ldc1 $f2, n2
	sub.d $f30, $f0, $f2