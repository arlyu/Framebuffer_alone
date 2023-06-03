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

cubica:
	// Retorna en x0 el cubo de x4
	// Trabaja con punto fijo de DENSITY decimales

	mul x0, x4, x4
	mul x0, x0, x4
	asr x0, x0, DENSITY		//
	asr x0, x0, DENSITY		// Shifts aritmético para dejar el punto en su lugar

	br lr

cuadratica:
	// Retorna en x0 el cuadrado de x4
	// Trabaja con punto fijo de DENSITY decimales
	
	mul x0, x4, x4
	asr x0, x0, DENSITY		// Shift aritmético para dejar el punto en su lugar
	sub x0, xzr, x0

	br lr

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

rio:
	// Dibuja un rio a partir de una función cúbica centrada en (x22, x23)
	// Utiliza (SIN GUARDAR) los registros x16, x17, x18 y x19
	sub sp,sp,24
	str lr, [sp,16]
	str x22, [sp,8]
	str x23, [sp,0]

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
	stur w10, [x0]
	//bl delay				// Delay para generar efecto
	bl LineR				// Ensancha el rio
	sub x4, x4, 1
	adds xzr, x4, x16		// Verifico si x4 es el opuesto de x16
	b.ne looprio			// b.ne "==" true sii la flag "Z == 0" (si la suma anterior no es 0 continua)

	ldr lr, [sp,16]
	ldr x22, [sp, 8]
	ldr x23, [sp, 0]
	add sp,sp,24

	br lr

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

LineR:
	// Dibuja una linea de ancho x21 y color x10, desde la coordenada cartesiana (x22, x23)

	sub sp, sp, #16
	str lr ,[sp, 8]
	str x21 ,[sp,0]

	bl cartesianos
loopLineR:
	add x0, x0, 4
	stur w10, [x0]
	sub x21, x21, 1
	cbnz x21, loopLineR

	ldr lr, [sp, 8]
	ldr x21, [sp,0]
	add sp, sp , #16

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


	movz x1, 0x0f, lsl 16

delayloop:
	sub x1, x1, 1
	cbnz x1, delayloop

	ldr lr, [sp, 8]
	ldr x1, [sp, 0]
	add sp, sp, 16
	br lr 
