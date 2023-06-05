	.equ SCREEN_WIDTH,   640
	.equ SCREEN_HEIGH,   480
	.equ SCREEN_HEIGH_SH, 1920
	.equ SCREEN_WIDTH_SH, 2560
	.equ DENSITY, 5


//----------------Funciones Matematicas

parabola:
	// Dibuja una parabola en las coordenadas cartesianas evaluando los puntos -50, 50 
	// Utiliza x16, x17, x18 y x19
	// Trabaja con punto punto fijo de DENSITY decimales

	sub sp,sp,32
	str x24, [sp, 24]
	str lr, [sp,16]
	str x22, [sp,8]
	str x23, [sp,0]
	

	mov x18, x22	// Almaceno en x18 el valor "x" del centro
	mov x19, x23	// Almaceno en x19 el valor "y" del centro

	mov x16, 110				// Longitud entera del intervalo de puntos a evaluar
	lsl x16, x16, DENSITY		// Defino los decimales que tendrá la variable a evaluar
	sub x4, xzr, x16		// x4 <-> Primer valor a evaluar

loopparabola:
	asr x17, x4, DENSITY	// x17 = "un múltiplo de x4 pensado como entero entero"
	add x22, x18, x17		// Ubico el valor "x" centro en   centro_originalx + x17    
	bl cuadratica
	asr x17, x0, 11			// x17 = "un múltiplo de x4^2 pensado como entero entero"
	add x23, x17, x19		// Ubico el valor "y" centro en   centro_originaly + x17
	bl cartesianos
	stur w10, [x0]
	mov x24, 198			// Decido la altura hasta la que llegara la parabola
	bl filldowncol
	add x4, x4, 1
	cmp x4, x16
	b.lt loopparabola

	ldr x24, [sp, 24]
	ldr lr, [sp,16]
	ldr x22, [sp, 8]
	ldr x23, [sp, 0]
	add sp,sp,24

	br lr

//

cubica:
	// Retorna en x0 el cubo de x4
	// Trabaja con punto fijo de DENSITY decimales

	mul x0, x4, x4
	mul x0, x0, x4
	asr x0, x0, DENSITY		//
	asr x0, x0, DENSITY		// Shifts aritmético para dejar el punto en su lugar

	br lr

//

cuadratica:
	// Retorna en x0 el cuadrado de x4
	// Trabaja con punto fijo de DENSITY decimales
	
	mul x0, x4, x4
	asr x0, x0, DENSITY		// Shift aritmético para dejar el punto en su lugar
	sub x0, xzr, x0

	br lr
//
circulo:
	// Dibuja un círculo de radio x21 con centro en las coordenadas cartesianas (x22, x23)
	// Utiliza x1, x2, x16 y x17 sin guardarlos

	sub sp,sp,24
	str lr, [sp,16]
	str x22, [sp,8]
	str x23, [sp,0]

	mov x1, x22				// Se almacenan los valolres correspondientes con los centros
	mov x2, x23				//

	// Los próximos valores se utilizarán para las comprobaciones del círculo
	// Se comienza por la esquina inferior izquierda a evaluar si graficar un punto o no

	sub x23, xzr, x21		// Inicializa el valor de la altura máxima

loopCirculo1:
	sub x22, xzr, x21			// Inicializa el valor de la anchura máxima
	add x23, x23, 1
	cmp x23, x21
	b.ge endCirculo
loopCirculo0:
	cmp x22, x21			// Hasta que x22 sea menor que el máximo ancho posible, itera
	b.gt loopCirculo1		
	bl errorCirculo				// Calcula el el error que habría al elegir x22 y x23
	cmp x0, 0					// Si el error es menor que cero, entonces el punto está dentro de la circunferencia y se grafica
	b.gt skipCirculo			// En caso contrario, se saltea la impresión del punto
	bl puntoRelativo			// Se dibuja el punto
skipCirculo:
	add x22, x22, 1
	b loopCirculo0
endCirculo:

	ldr lr, [sp,16]
	ldr x22, [sp, 8]
	ldr x23, [sp, 0]
	add sp,sp,24

	br lr
//

elipse:
	// Dibuja un círculo de radio x21 con centro en las coordenadas cartesianas (x22, x23)
	// Utiliza x1, x2, x16 y x17 sin guardarlos

	sub sp,sp,24
	str lr, [sp,16]
	str x22, [sp,8]
	str x23, [sp,0]

	mov x1, x22				// Se almacenan los valolres correspondientes con los centros
	mov x2, x23				//

	// Los próximos valores se utilizarán para las comprobaciones del círculo
	// Se comienza por la esquina inferior izquierda a evaluar si graficar un punto o no

	sub x23, xzr, x21		// Inicializa el valor de la altura máxima

loopElipse1:
	sub x22, xzr, x21			// Inicializa el valor de la anchura máxima
	add x23, x23, 1
	cmp x23, x21
	b.ge endElipse
loopElipse0:
	cmp x22, x21			// Hasta que x22 sea menor que el máximo ancho posible, itera
	b.gt loopElipse1		
	bl errorElipse				// Calcula el el error que habría al elegir x22 y x23
	cmp x0, 0					// Si el error es menor que cero, entonces el punto está dentro de la elipse y se grafica
	b.gt skipElipse				// En caso contrario, se saltea la impresión del punto
	bl puntoRelativo			// Se dibuja el punto
skipElipse:
	add x22, x22, 1
	b loopElipse0
endElipse:

	ldr lr, [sp,16]
	ldr x22, [sp, 8]
	ldr x23, [sp, 0]
	add sp,sp,24

	br lr
//

puntoRelativo:
	// Dibuja el punto relativo al centro (x1, x2) de las coordenadas (x22, x23)
	// Se asume la correspondencia de x1 y x2

	sub sp,sp,24
	str lr, [sp,16]
	str x22, [sp,8]
	str x23, [sp,0]	

	add x22, x22, x1
	add x23, x23, x2
	bl cartesianos
	stur w10, [x0]

	ldr lr, [sp,16]
	ldr x22, [sp, 8]
	ldr x23, [sp, 0]
	add sp,sp,24

	br lr
//

errorCirculo:
	// Retorna en x0 el error total de la discretización de la circunferencia de radio x21: e = x22^2+x23^2-x21^2
	sub sp,sp,24
	str lr, [sp,16]
	str x22, [sp,8]
	str x23, [sp,0]

	mul x22, x22, x22
	mul x23, x23, x23
	add x22, x22, x23
	mul x23, x21, x21
	sub x0, x22, x23

	ldr lr, [sp,16]
	ldr x22, [sp, 8]
	ldr x23, [sp, 0]
	add sp,sp,24

	br lr
//

errorElipse:
	// Retorna en x0 el error total de la discretización de la elipse dada por: e = x22^2+4x23^2-x21^2
	sub sp,sp,24
	str lr, [sp,16]
	str x22, [sp,8]
	str x23, [sp,0]

	mul x22, x22, x22
	mul x23, x23, x23
	lsl x23, x23, 2
	add x22, x22, x23
	mul x23, x21, x21
	sub x0, x22, x23

	ldr lr, [sp,16]
	ldr x22, [sp, 8]
	ldr x23, [sp, 0]
	add sp,sp,24

	br lr
//

reflex:
	// Retorna en x0 la coordenada cartesiana (x23, x22) (al revés de lo habitual)
	// Utiliza x9 sin guardarlo
	sub sp,sp,24
	str lr, [sp,16]
	str x22, [sp,8]
	str x23, [sp,0]

	mov x9, x22
	mov x22, x23
	mov x23, x9
	bl cartesianos

	ldr lr, [sp,16]
	ldr x22, [sp, 8]
	ldr x23, [sp, 0]
	add sp,sp,24

	br lr
//

cartesianos:	
	// Retorna en x0 la dirección del framebuffer asociada a la coordenada cartesiana (!=MATRICIAL) (x22, x23)
	// Utiliza los registros x9 y x11

	mov x11, SCREEN_WIDTH
	mov x9, SCREEN_HEIGH	
	sub x9, x9, x23		// Convierte de matricial a cartesiano mediante  x9 = SCREEN_HEIGH - ejey
	mul x9, x9, x11		// Calculo las correspondencias,	x9 = SCREEN_WIDTH * x9
	add x9, x9, x22		// x9 = SCREEN_WIDTH * x9 + x22
	lsl x9, x9, 2		// x9 = (SCREEN_WIDTH * x9 + x22) * 4
	add x0, x20, x9		// x0 = &Framebuffer[i][j]

	br lr

//----------------Assets

drawpixel:
	//dado un pixel en las coordenadas matriciales (x22,x23)
	//									(x , y)
	//Color x10
	//lo pinta en el frame buffer
	//Se usa x1 como variable auxiliar
	sub sp ,sp ,24
	str x22 ,[sp,16]
	str x23 ,[sp,8]
	str x1 ,[sp]

	//calculo de coordenada
	mov x1 ,640
	madd x22,x23,x1,x22
	mov x1,x20
	lsl x22,x22 ,2

	//set en el buffer
	add x1,x1,x22
	str W10,[x1,0]		

	ldr x1,[sp]
	ldr x23 ,[sp,8]
	ldr x22 ,[sp,16]
	add sp,sp,24

	br lr

//



caida:
	// Dibuja una forma de caida a partir de una función cúbica centrada en (x22, x23), hasta la altura x24
	// Utiliza (SIN GUARDAR) los registros x16, x17, x18 y x19
	sub sp, sp, 32
	str x7, [sp, 24]		// ""Variable"" para verificar las flags de funciones
	str lr, [sp,16]
	str x22, [sp,8]
	str x23, [sp,0]

	and x3, x3, 0xfe		// Setea el funcionamiento de LineH
	mov x18, x22			// Almaceno en x18 el valor "x" del centro
	mov x19, x23			// Almaceno en x19 el valor "y" del centro

	mov x16, 39				// Longitud entera del intervalo de puntos a evaluar
	lsl x16, x16, DENSITY	// Defino los decimales que tendrá la variable a evaluar
	mov x4, x16 			// x4 <-> Primer valor a evaluar

loopCaida:
	asr x17, x4, DENSITY	// x17 = "un múltiplo de x4 pensado como entero entero"
	sub x17, xzr, x17		// Reflejo la gráfica
	add x22, x18, x17		// Ubico el valor "x" centro en   centro_originalx + x17    
	bl cubica
	asr x17, x0, 14			// x17 = "un múltiplo de x4^2 pensado como entero entero"
	add x23, x17, x19		// Ubico el valor "y" centro en   centro_originaly + x17
	bl cartesianos			// Devuelve en x0 las coordenadas requeridas
	cmp x23, x24
	b.lt termina			// Si x23 (la altura actual) es más baja que x24 deja de dibujar
	and x7, x3, 0b10
	cbz x7, noDelayCaida
	bl delay				// Delay para generar efecto
noDelayCaida:
	bl LineH				// Ensancha el Caida
	sub x4, x4, 1
	adds xzr, x4, x16		// Verifico si x4 es el opuesto de x16
	b.ne loopCaida			// b.ne "==" true sii la flag "Z == 0" (si la suma anterior no es 0 continua)
termina:

	ldr x7, [sp, 24]
	ldr lr, [sp,16]
	ldr x22, [sp, 8]
	ldr x23, [sp, 0]
	add sp, sp, 32

	br lr

//
bordeRio:
	sub sp, sp, 40
	str lr, [sp, 32]
	str x21, [sp, 24]
	str x22, [sp, 16]
	str x23, [sp, 8]
	str x24, [sp, 0]

	mov x3, 0b00	// Seteo la flag de delay
	mov x24, 200
	movz x10, 0x2a, lsl 16
	movk x10, 0x2809, lsl 00 	// Elijo color	
	mov x22, 140	// Origen "x" de la cúbica
	mov x23, 273	// Origen "y" de la cúbica
	mov x21, 30		// Ancho del borde
	bl caida

	ldr lr, [sp, 32]
	ldr x21, [sp, 24]
	ldr x22, [sp, 16]
	ldr x23, [sp, 8]
	ldr x24, [sp, 0]
	add sp, sp, 40

	br lr
//

rio:
	sub sp, sp, 40
	str lr, [sp, 32]
	str x21, [sp, 24]
	str x22, [sp, 16]
	str x23, [sp, 8]
	str x24, [sp, 0]

	mov x3, 0b00	// Seteo la flag de delay
	mov x24, 40
	movz x10, 0x11, lsl 16
	movk x10, 0x6673, lsl 00 	// Elijo color
	mov x22, 146	// Origen "x" de la cúbica
	mov x23, 272	// Origen "y" de la cúbica
	mov x21, 20  // Ancho del rio
	bl caida

	ldr lr, [sp, 32]
	ldr x21, [sp, 24]
	ldr x22, [sp, 16]
	ldr x23, [sp, 8]
	ldr x24, [sp, 0]
	add sp, sp, 40

	br lr
//

filldowncol:
	// Rellena los píxeles desde la coordenada cartesiana (x22, x23) hasta la altura x24, con el color de w10

	sub sp, sp, #16
	str lr ,[sp, 8]
	str x19 ,[sp,0]

	sub x19, x23, x24		// Calculo la cantidad de veces que iterar hasta la altura x24, requiere precisión para correcto funcionamiento

	bl cartesianos
loopfill:
	add x0, x0, SCREEN_WIDTH_SH
	stur w10, [x0]
	sub x19, x19, 1
	cbnz x19, loopfill

	ldr lr, [sp, 8]
	ldr x19, [sp,0]
	add sp,sp , #16

	br lr

//

Petalos:
	//dado un pixel x22
	//Color x10
	//Pinta 4 colores al rededor del centro
	sub sp ,sp ,24
	str lr ,[sp,16]
	str x23 ,[sp,8]
	str x22 ,[sp]

	sub x22,x22,x21
	bl Rectangle
	add x22,x22,x21
	add x22,x22,x21
	bl Rectangle
	ldr x22,[sp] //restablecer valor de 22

	sub x23,x23,x24
	bl Rectangle
	add x23,x23,x24
	add x23,x23,x24
	bl Rectangle
	ldr x23 ,[sp,8] //restablecer valor de 23
	ldr lr ,[sp,16]
	add sp ,sp ,24
	br lr

snailAsset:
	//El punto origen (x,y) del caracol -> (x22,x23) ,Es la superior mas a la izquierda del caracol
	sub sp,sp,#48
	str lr,[sp]	//LINK REGISTER
	str x21,[sp,8] 	//ARGUMENTOS DE LA DIMENSINON
	str x22,[sp,16]
	str x23,[sp,24]
	str x24,[sp,32]
	str x10,[sp,40]	//COLOR

	movz x24,#10,lsl 0
	movz x21,#12,lsl 0

	//Caparazon
	//#0x99835c
	movz w10,0x835C	,lsl 00
	movk w10,0x99, lsl 16
	bl Rectangle

	add x22,x22,#1
	sub x23,x23,#1
	movz x24,1
	movz x21,10
	bl Rectangle

	add x23,x23,#11
	movz x24,1
	movz x21,10
	bl Rectangle

	//Babosa?¿
	add x22,x22,9
	//0x55d47b
	movz w10,0xD47B	,lsl 00
	movk w10,0x55, lsl 16
	movz x21,7,lsl 0
	bl Rectangle

	add x22,x22,5
	sub x23,x23,5

	movz x24,4
	movz x21,2

	bl Rectangle

	movz x24 ,1
	movz x21 ,2

	sub x22,x22,18
	add x23,x23,4
	bl Rectangle

	movz x24 ,1
	movz x21 ,4

	sub x22,x22,2
	add x23,x23,1
	bl Rectangle

	//Caparazon dibujo
	//0xa61635
	movz x10,0x1635	,lsl 00
	movk x10,0xa6, lsl 16

	ldr x22,[sp,16]//Necesito las coordenadas iniciales
	ldr x23,[sp,24]

	add x22,x22,2
	add x23,x23,1

	movz x24,1,lsl 0
	movz x21,7,lsl 0

	bl Rectangle


	add x23,x23,5
	add x22,x22,3
	mov x21,3

	bl Rectangle
	add x22,x22,1

	movz x10,0x1635	,lsl 00
	movk x10,0xa6, lsl 16

	add x23,x23,4
	sub x22,x22,4
	mov x21,5

	bl Rectangle

	sub x23,x23,7
	sub x22,x22,1
	mov x21,1
	mov x24,6
	bl Rectangle

	add x22,x22,8
	mov x24,2

	bl Rectangle

endSnail:
	
	ldr lr ,[sp]
	ldr x21 ,[sp,8]
	ldr x22 ,[sp,16]
	ldr x23 ,[sp,24]
	ldr x24 ,[sp,32]
	ldr x10 ,[sp,40]
	add sp,sp,#48
	br lr

vallaStatic://El punto origen de la valla es el origen del rectangulo de la tabla transversal de arriba
	sub sp,sp,#56
	str lr,[sp]		//STACK POINTER

	str x21,[sp,8] 	//ARGUMENTOS DE LA DIMENSINON
	str x22,[sp,16]
	str x23,[sp,24]
	str x24,[sp,32]

	str x10,[sp,40]	//COLOR
	str x1,[sp,48]	//AUXILIAR

	//0x814929

	//Primer transversal
	movz x10, 0x81, lsl 16
	movk x10, 0x4929, lsl 00

	movz x21,202
	movz x24,3

	bl Rectangle
	//Segundo transversal
	add x23,x23,10
	bl Rectangle


	//Logs
	movz x10, 0x7A, lsl 16
	movk x10, 0x3F1F, lsl 00

	add x22,x22,1
	sub x23,x23,12
	mov x21,5
	mov x24,18

	mov x1,10

vallaLogLoop:
	bl Rectangle
	add x22,x22,20
	sub x1,x1,1
	cbnz x1 ,vallaLogLoop

endValla:
	ldr lr ,[sp]
	ldr x21 ,[sp,8]
	ldr x22 ,[sp,16]
	ldr x23 ,[sp,24]
	ldr x24 ,[sp,32]
	ldr x10 ,[sp,40]
	add sp,sp,#48
	br lr

cultivoStatic:
	sub sp,sp,#40
	str lr,[sp]		//STACK POINTER

	str x21,[sp,8] 	//ARGUMENTOS DE LA DIMENSINON
	str x22,[sp,16]
	str x23,[sp,24]
	str x24,[sp,32]

	movz x10, 0x1c, lsl 16 //Color base del piso
	movk x10, 0x4d32, lsl 00

	movz x22 ,440 	//x origen
	movz x23 ,270	//y	origen
	movz x21 ,198	//ancho
	movz x24 ,50   //alto

	bl Rectangle

	ldr lr,[sp]		//STACK POINTER

	ldr x21,[sp,8] 	//ARGUMENTOS DE LA DIMENSINON
	ldr x22,[sp,16]
	ldr x23,[sp,24]
	ldr x24,[sp,32]

	add sp,sp,#40

	br lr

cartelStatic:
	sub sp,sp,#48
	str lr ,[sp]
	str x21 ,[sp,8]
	str x22 ,[sp,16]
	str x23 ,[sp,24]
	str x24 ,[sp,32]
	str x10 ,[sp,40]
	
	movz x10, 0x4a, lsl 16
	movk x10, 0x3819, lsl 00

	movz x21 ,60	//ancho
	movz x24 ,30 	//alto
	bl Rectangle

	//Estaca
	add x22,x22,25
	add x23,x23,30
	movz x21 ,8	
	movz x24 ,30 

	bl Rectangle


	ldr lr ,[sp]
	ldr x21 ,[sp,8]
	ldr x22 ,[sp,16]
	ldr x23 ,[sp,24]
	ldr x24 ,[sp,32]
	ldr x10 ,[sp,40]
	add sp,sp,#48
	br lr

tringulosrep:
// Usa x22 y x23 como coordenadas (x,y) de origen, x21 para el ancho de la base de los triángulos 
// Como auxiliares: estàn x1 que es la cant de trangulos que se van a hacer 
//x2 que es la distancia entre tringulos
	sub sp,sp,32
	str lr ,[sp,24]
tringulosreploop:
	str x21 ,[sp,16]
	str x23 ,[sp,8]
	str x22 ,[sp]
	bl triangulo
	ldr x22 ,[sp] 
	ldr x23 ,[sp,8] 
	ldr x21 ,[sp,16]
	//add x22,x22,8
	add x22,x22,x2
	sub x1,x1,1
	cbnz x1,tringulosreploop
	ldr lr ,[sp,24]
	add sp ,sp ,32
	br lr
//

//---------------Formas geometricas

LineH:
	// Dibuja una linea de ancho x21 y color x10, desde la coordenada cartesiana (x22, x23)
	// Si el bit 0 de x3 es igual a uno, dibuja la linea hacia la derecha, y en caso contrario hacia la izquierda.

	sub sp, sp, #32
	str x3, [sp, 24]
	str x16, [sp, 16]
	str lr ,[sp, 8]
	str x21 ,[sp,0]

	mov x16, 4			// Valor por defecto para sumar a x0
	bl cartesianos
	and x3, x3, 0b01
	cbz x3, loopLineH	// Si el bit está activo, saltea la resta
	sub x16, xzr, x16	// En caso contrario, invierte "la dirección"

loopLineH:
	add x0, x0, x16
	stur w10, [x0]
	sub x21, x21, 1
	cbnz x21, loopLineH

	ldr x3, [sp, 24]
	ldr x16, [sp, 16]
	ldr lr, [sp, 8]
	ldr x21, [sp,0]
	add sp, sp , #32

	br lr
//

LineD:
	// Dibuja hacia abajo una linea de altura x24 y color x10, desde la coordenada cartesiana (x22, x23)

	sub sp, sp, #16
	str lr ,[sp, 8]
	str x21 ,[sp,0]

	bl cartesianos
loopLineD:
	add x0, x0, SCREEN_WIDTH_SH
	stur w10, [x0]
	sub x21, x21, 1
	cbnz x21, loopLineD

	ldr lr, [sp, 8]
	ldr x21, [sp,0]
	add sp, sp , #16

	br lr

//

Line:
	//Dibuja una linea desde la coordenada (x22,x23) que mida ancho x21
	//										(x , y)
	//Usando el color guardado en x10

	//Usa los registros x1,x2

	sub sp,sp,48 //reservando para salvar los regs que vamos a usar
	str x21 ,[sp,40]
	str x22 ,[sp,32]
	str x23 ,[sp,24]
	str x2 ,[sp,16]
	str x1 ,[sp,8]
	str lr ,[sp] //pointer para salir
	add x21 ,x21, x22

Lineloop:
	bl drawpixel
	add x22,x22,#1
	add x2,x2,#1
	cmp x22,x21
	b.le Lineloop
	B endLine

endLine:
	//Habiendo terminado la linea se devuelven los valores a los regs usados
	ldr lr ,[sp]
	ldr x1 ,[sp,8]
	ldr x2 ,[sp,16]
	ldr x23 ,[sp,24]
	ldr x22 ,[sp,32]
	ldr x21 ,[sp,40]
	add sp,sp,48

	br lr

Rectangle:
	//							alto  ancho                           x    y
	//Crea un rectangulo tamaño x24 * x21 , desde el vertice origen (x22,x23) , siendo el vertice superior izquierdo
	//FLAG X2:ON/OFF degradado
	//x1 es una variable auxiliar
	sub sp,sp,#40
	str lr ,[sp]
	str x21 ,[sp,8]
	str x22 ,[sp,16]
	str x23 ,[sp,24]
	str x24 ,[sp,32]

	add x24, x24 ,x23

Rectangleloop:
	bl Line
	add x23 ,x23 ,#1
	cmp x24 ,x23
	bge Rectangleloop

endRectangle:
	ldr lr ,[sp]
	ldr x21 ,[sp,8]
	ldr x22 ,[sp,16]
	ldr x23 ,[sp,24]
	ldr x24 ,[sp,32]
	add sp,sp,#40
	br lr

//
delay:
	sub sp, sp, 16
	str lr, [sp, 8]
	str x1, [sp, 0]
	movz x1, 0x06, lsl 16

delayloop:
	sub x1, x1, 1
	cbnz x1, delayloop

	ldr lr, [sp, 8]
	ldr x1, [sp, 0]
	add sp, sp, 16
	br lr 
//
delayLargo:
	sub sp, sp, 16
	str lr, [sp, 8]
	str x1, [sp, 0]
	movz x1, 0x46, lsl 16

delayLargoloop:
	sub x1, x1, 1
	cbnz x1, delayloop

	ldr lr, [sp, 8]
	ldr x1, [sp, 0]
	add sp, sp, 16
	br lr 

//
triangulo:  
//Usa x22 y x23 como coordenadas (x,y), por otra parte el x21 determina el ancho de la base (tamaño). 
//El x21 solo pueden ser números impares.
	sub sp ,sp ,8
	str lr ,[sp]
	add x22,x22,1
	sub x23,x23,1
	bl Line
	sub x21,x21,2
	cmp x21,1
	bge triangulo

	ldr lr ,[sp]
	add sp,sp,8
	br lr

trianguloinvert:  
//Usa x22 y x23 como coordenadas (x,y), por otra parte el x21 determina el ancho de la base (tamaño). 
//El x21 solo pueden ser números impares.
	sub sp ,sp ,8
	str lr ,[sp]
	add x22,x22,1
	add x23,x23,1
	bl Line
	sub x21,x21,2
	cmp x21,1
	bge trianguloinvert

	ldr lr ,[sp]
	add sp,sp,8
	br lr

//

elipseCreciente:
	sub sp, sp, 40
	str lr, [sp, 32]
	str x21, [sp, 24]
	str x22, [sp, 16]
	str x23, [sp, 8]
	str x24, [sp, 0]

	mov x22, 200
	mov x23, 150
	mov x21, 5

loopCreciente:
	add x21, x21, 1 
	bl elipse
	bl delayLargo
	cmp x21, 70
	b.lt loopCreciente

	ldr lr, [sp, 32]
	ldr x21, [sp, 24]
	ldr x22, [sp, 16]
	ldr x23, [sp, 8]
	ldr x24, [sp, 0]

	br lr
//---------------Acciones GPIO
aguaLava:
	// Convierte el agua en lava y viceversa, dependiendo del bit 0 de x12.
	// Utiliza (SIN GUARDAR) x9

	sub sp, sp, 40
	str lr, [sp, 32]
	str x21, [sp, 24]
	str x22, [sp, 16]
	str x23, [sp, 8]
	str x24, [sp, 0]

	movz x10, 0xf1, lsl 16
	movk x10, 0x0613, lsl 00 	// Seteo a color rojo

	eor x12, x12, 0b01		// Invierto el bit 0
	and x9, x12, 0b01
	cbnz x9, lavaColor
	movz x10, 0x11, lsl 16
	movk x10, 0x6673, lsl 00 	// Seteo a color celeste
lavaColor:

	mov x3, 0b10	// Seteo la flag de delay
	mov x24, 40
	mov x22, 146	// Origen "x" de la cúbica
	mov x23, 272	// Origen "y" de la cúbica
	mov x21, 20  // Ancho del rio
	bl caida
	//bl delay
	bl elipseCreciente

	ldr lr, [sp, 32]
	ldr x21, [sp, 24]
	ldr x22, [sp, 16]
	ldr x23, [sp, 8]
	ldr x24, [sp, 0]
	add sp, sp, 40
	br lr
//
