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

	mov x1, x22
	mov x2, x23

	sub x22, xzr, x21
	sub x23, xzr, x21

loopCirculo0:
	cmp x22, x21
	b.gt loopCirculo1
	bl error0
	cmp x0, 0
	b.gt skipCirculo
	bl puntoRelativo
skipCirculo:
	add x22, x22, 1
	b loopCirculo0
loopCirculo1:
	sub x22, xzr, x21
	add x23, x23, 1
	cmp x23, x21
	b.lt loopCirculo0

	ldr lr, [sp,16]
	ldr x22, [sp, 8]
	ldr x23, [sp, 0]
	add sp,sp,24

	br lr
//
puntoRelativo:
	// Dibuja el punto relativo al centro (x1, x2) de las coordenadas (x22, x23)
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

circunferencia:
	// Dibuja una circunferencia de color w10, con centro cartesiano (x22, x23) y radio x21
	// Utiliza a x1, x2, x4 y x9 sin guardarlos

	sub sp,sp,24
	str lr, [sp,16]
	str x22, [sp,8]
	str x23, [sp,0]

	mov x1, x22
	mov x2, x23

	add x23, x23, x21
	sub x23, x23, 1		// Encaja mejor
	bl cartesianos
	stur w10, [x0]			// Grafica el primer punto
	
	mov x22, 0
	mov x23, x21  		// Punto "y" inicial
	sub x23, x23, 1		// Encaja mejor
	bl circExt			// Grafica puntos de cierre (izquierda, arriba, derecha y abajo)
	mul x4, x22, x22
	mul x9, x23, x23
	add x4, x4, x9
	mul x9, x21, x21
	sub x4, x4, x9		// x4 = e0 (Error inicial)

loopCirc:
	cmp x22, x23
	b.ge endCirc
	add x22, x22, 1			// x22 = "xk+1"
	cmp x4, 0
	b.ge circCase2			// Verifica si "se está dentro o fuera de la circunferencia real"
	
	bl error1				// Caso 1. Se desplaza solo el eje x
	mov x4, x0
	bl circExt
	b loopCirc
circCase2:					// Caso 2. Se desplaza también el eje y
	sub x23, x23, 1
	bl error2
	mov x4, x0
	bl circExt
	b loopCirc

endCirc:

	ldr lr, [sp,16]
	ldr x22, [sp, 8]
	ldr x23, [sp, 0]
	add sp,sp,24

	br lr
//

circExt:
	// Extiende el punto (x22, x23) a los demás octantes de la circunferencia, en la posición adecuada.
	// Utiliza (lo guarda) x4. Utiliza x16 y x17 sin guardar
	// Supone que (x1, x2) es el centro de la circunferencia

	sub sp,sp,32
	str x4, [sp, 24]
	str lr, [sp,16]
	str x22, [sp,8]
	str x23, [sp,0]

	mov x16, x22
	mov x17, x23

	mov x4, 0b0
loopCircExt1:
	mov x22, x16
	mov x23, x17
	cmp x4, 0b1000
	b.ge endCircExt1
	bl setOctant			// Determina el signo que tendrá la suma y el orden de las coordenadas
	add x22, x22, x1
	add x23, x23, x2
	bl cartesianos
	stur w10, [x0]
	add x4, x4, 1
	b loopCircExt1
endCircExt1:

	ldr x4, [sp, 24]
	ldr lr, [sp,16]
	ldr x22, [sp, 8]
	ldr x23, [sp, 0]
	add sp,sp,32

	br lr
//

setOctant:
	// Modifica el signo de x22 y x23 dependiendo del valor de x4 ,y cuando x4 >= 0b100 invierte las coordenadas 
	// Utiliza, sin guardar, x9. CUIDADO EN EL LLAMADO DE circunferencia

	and x9, x4, 0b01
	cbz x9, noChangex22
	sub x22, xzr, x22
noChangex22:

	and x9, x4, 0b10
	cbz x9, noChangex23
	sub x23, xzr, x23
noChangex23:

	cmp x4, 0b100
	b.lt noSwap
	mov x9, x22
	mov x22, x23
	mov x23, x9
noSwap:

	br lr
//
error0:
	// Retorna en x0 el error total e = x22^2+x23^2-x21^2
	sub sp,sp,24
	str lr, [sp,16]
	str x22, [sp,8]
	str x23, [sp,0]

	mul x22, x22, x22
	//lsl x22, x22, 1
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
error1:
	// Retorna en x0 el error ek+1=ek+2(x22)+1
	// PRE: ek <-> x4

	sub sp,sp,24
	str lr, [sp,16]
	str x22, [sp,8]
	str x23, [sp,0]

	lsl x22, x22, 1
	add x22, x22, 1
	add x0, x22, x4

	ldr lr, [sp,16]
	ldr x22, [sp, 8]
	ldr x23, [sp, 0]
	add sp,sp,24

	br lr
//
error2:
	// Retorna en x0 el error ek+1=ek+2(x22)+1-2(x23)
	// PRE: ek <-> x4

	sub sp,sp,24
	str lr, [sp,16]
	str x22, [sp,8]
	str x23, [sp,0]

	lsl x22, x22, 1
	add x22, x22, 1
	add x0, x22, x4		// x0 = ek+2(x22)+1

	lsl x23, x23, 1
	sub x0, x0, x23

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
	str x10,[x1,0]		// x10 y no w10 para que deje sombreado

	ldr x1,[sp]
	ldr x23 ,[sp,8]
	ldr x22 ,[sp,16]
	add sp,sp,24

	br x30

//

rio:
	// Dibuja una forma de rio a partir de una función cúbica centrada en (x22, x23), hasta la altura x24
	// Utiliza (SIN GUARDAR) los registros x16, x17, x18 y x19
	sub sp,sp,24
	str lr, [sp,16]
	str x22, [sp,8]
	str x23, [sp,0]

	mov x3, 0		// Setea el funcionamiento de LineH
	mov x18, x22	// Almaceno en x18 el valor "x" del centro
	mov x19, x23	// Almaceno en x19 el valor "y" del centro

	mov x16, 39				// Longitud entera del intervalo de puntos a evaluar
	lsl x16, x16, DENSITY	// Defino los decimales que tendrá la variable a evaluar
	mov x4, x16 			// x4 <-> Primer valor a evaluar

looprio:
	asr x17, x4, DENSITY	// x17 = "un múltiplo de x4 pensado como entero entero"
	sub x17, xzr, x17		// Reflejo la gráfica
	add x22, x18, x17		// Ubico el valor "x" centro en   centro_originalx + x17    
	bl cubica
	asr x17, x0, 14			// x17 = "un múltiplo de x4^2 pensado como entero entero"
	add x23, x17, x19		// Ubico el valor "y" centro en   centro_originaly + x17
	bl cartesianos			// Devuelve en x0 las coordenadas requeridas
	cmp x23, x24
	b.lt termina			// Si x23 (la altura actual) es más baja que x24 deja de dibujar
	stur w10, [x0]
	cbz x7, noDelayRio
	bl delay				// Delay para generar efecto
noDelayRio:
	bl LineH				// Ensancha el rio
	sub x4, x4, 1
	adds xzr, x4, x16		// Verifico si x4 es el opuesto de x16
	b.ne looprio			// b.ne "==" true sii la flag "Z == 0" (si la suma anterior no es 0 continua)
termina:

	ldr lr, [sp,16]
	ldr x22, [sp, 8]
	ldr x23, [sp, 0]
	add sp,sp,24

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

//---------------Formas geometricas

LineH:
	// Dibuja una linea de ancho x21 y color x10, desde la coordenada cartesiana (x22, x23)
	// Si x3 == 0, dibuja la linea hacia la derecha, y en caso contrario hacia la izquierda.

	sub sp, sp, #24
	str x16, [sp, 16]
	str lr ,[sp, 8]
	str x21 ,[sp,0]

	mov x16, 4			// Valor por defecto para sumar a x0
	bl cartesianos
	cbz x3, loopLineH
	sub x16, xzr, x16

loopLineH:
	add x0, x0, x16
	stur w10, [x0]
	sub x21, x21, 1
	cbnz x21, loopLineH

	ldr x16, [sp, 16]
	ldr lr, [sp, 8]
	ldr x21, [sp,0]
	add sp, sp , #24

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
	str x30 ,[sp] //pointer para salir
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
	ldr x30 ,[sp]
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
	str x30 ,[sp]
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
	ldr x30 ,[sp]
	ldr x21 ,[sp,8]
	ldr x22 ,[sp,16]
	ldr x23 ,[sp,24]
	ldr x24 ,[sp,32]
	add sp,sp,#40
	br x30

delay:
	sub sp, sp, 16
	str lr, [sp, 8]
	str x1, [sp, 0]


	movz x1, 0x01, lsl 16

delayloop:
	sub x1, x1, 1
	cbnz x1, delayloop

	ldr lr, [sp, 8]
	ldr x1, [sp, 0]
	add sp, sp, 16
	br lr 
