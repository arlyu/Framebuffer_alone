	.equ SCREEN_WIDTH,   640
	.equ SCREEN_HEIGH,   480
	.equ BITS_PER_PIXEL, 32

	.equ GPIO_BASE,    0x3f200000
	.equ GPIO_GPFSEL0, 0x00
	.equ GPIO_GPLEV0,  0x34
	.equ DENSITY, 5

	.globl main

main:
	// x0 contiene la direccion base del framebuffer
	mov x20, x0 // Guarda la dirección base del framebuffer en x20
	//---------------- CODE HERE ------------------------------------

	//CIELO
	movz x10, 0x00, lsl 16 //Color azul base para el cielo
	movk x10, 0x55FF, lsl 00
	mov x2, SCREEN_HEIGH
loop1:
	mov x1, 700
	sub x10, x10, #1 //Lo decremento al valor en hexa para q se acerque a verde (se aclare)
loop0:	
	stur w10,[x0]
	add x0, x0,#4
	sub x1, x1, 1
	cbnz x1, loop0
	sub x2, x2, 1
	cbnz x2, loop1

	mov x0, x20 //Restablezco el puntero para poder volverlo a usar


//ESTRELLAS
	movz x10, 0xFF, lsl 16 //Color blanco
	movk x10, 0xFFFF, lsl 00 

	mov x1,48   //Cantidad de esterellas
	mov x22,2  //x origen
	mov x23,0  //y origen

subloopcielo:
	bl drawpixel
	add x22,x22,40 
	add x23,x23,2
	sub x1,x1,1
	cbnz x1,subloopcielo

//SUELO
	movz x10, 0x09, lsl 16 //Color base del piso
	movk x10, 0x5516, lsl 00

	movz x22 ,0 	//x origen
	movz x23 ,270	//y	origen
	movz x21 ,640	//ancho
	movz x24 ,220   //alto

	bl Rectangle

   //Cultivo
	movz x10, 0x1c, lsl 16 //Color base del piso
	movk x10, 0x4d32, lsl 00

	movz x22 ,440 	//x origen
	movz x23 ,270	//y	origen
	movz x21 ,198	//ancho
	movz x24 ,50   //alto

	bl Rectangle


//Vallas
	movz x10, 0x81, lsl 16
	movk x10, 0x4929, lsl 00
	mov x1,2 		// Cuantas veces debo dibujar la tabla horizontal de una valla
	
	mov x23,310 //y
loopvalla:
	mov x22,438  //x	
	movz x21 ,200	//ancho
	movz x24 ,3 	//alto
	bl Rectangle
	sub x1,x1,1  //Descuento el contador
	add x23,x23,10 //Espacio de vallas
	cbnz x1,loopvalla

//TRONCOS
	mov x22,420   //x
	mov x23,308  //y
	movz x21 ,4	//ancho
	movz x24 ,18 	//alto
	mov x1,620 //Cant de troncos 

makelogs:
 	add x22,x22,20 //Espacio estre troncos
 	bl Rectangle
 	cmp x22,x1 
 	bne makelogs

//CARTEL
	movz x10, 0x4a, lsl 16
	movk x10, 0x3819, lsl 00
    mov x22,315   //x
	mov x23,340  //y
	movz x21 ,60	//ancho
	movz x24 ,30 	//alto
	bl Rectangle
	mov x22,340   //x
	mov x23,370  //y
	movz x21 ,8	//ancho
	movz x24 ,30 	//alto
	bl Rectangle


//MONTAÑA
	mov x22, 115
	mov x23, 390
	bl parabola

// VER BIEN QUE REGISTRO USAR, CAMBIAR x24
	mov x24, 22		// Ancho del borde
loopmontaña:
	sub x23, x23, 1
	bl parabola
	sub x24, x24, 1
	cbnz x24, loopmontaña

	b InfLoop


/*
//CASA
	//Base
	mov x22,330  //x
	mov x23,290  //y
	movz x21 ,120	//ancho
	movz x24 ,120 	//alto
	bl Rectangle 

	//Entrada 
	movz x10, 0x55, lsl 16   //Puerta
	movk x10, 0x4215, lsl 00
	mov x22,355  //x
	mov x23,378  //y
	movz x21 ,26	//ancho
	movz x24 ,32 	//alto
	bl Rectangle
	
	movz x10, 0x29, lsl 16   //Entrada
	movk x10, 0x2009, lsl 00  
	movz x24 ,22 	//alto
	mov x22,382  //x
	mov x23,388  //y
	bl Rectangle
	mov x22,360  //x  //Pixel de pomo de la puerta
	mov x23,395  //y
	bl drawpixel
	
	//Ventana
	movz x10, 0x00, lsl 16  
	movk x10, 0x0000, lsl 00
	mov x22,375 //x
	mov x23,300  //y
	movz x21 ,30	//ancho
	movz x24 ,30 	//alto
	bl Rectangle

*/

//---------FUNCIONES AUXILIARES------------	


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
	str x10,[x1,0]

	ldr x1,[sp]
	ldr x23 ,[sp,8]
	ldr x22 ,[sp,16]
	add sp,sp,24

	br x30

//

parabola:
	// Dibuja una parabola en las coordenadas cartesianas evaluando los puntos -50, 50 
	// Utiliza x16, x17, x18 y x19

	sub sp,sp,24
	str lr, [sp,16]
	str x22,[sp,8]
	str x23,[sp,0]

	mov x18, x22	// Almaceno en x18 el valor "x" del centro
	mov x19, x23	// Almaceno en x19 el valor "y" del centro

	mov x16, 110				// Longitud entera del intervalo de puntos a evaluar
	lsl x16, x16, DENSITY
	sub x4, xzr, x16		// x4 <-> Primer valor a evaluar

loopparabola:
	asr x17, x4, DENSITY	// x17 = "un múltiplo de x4 pensado como entero entero"
	add x22, x18, x17		// Ubico el valor "x" centro en   centro_originalx + x17    
	bl cuadratica
	asr x17, x0, 11			// x17 = "un múltiplo de x4^2 pensado como entero entero"
	add x23, x17, x19		// Ubico el valor "y" centro en   centro_originaly + x17
	bl cartesianos
	stur w10, [x0]
	bl filldowncol
	add x4, x4, 1
	cmp x4, x16
	b.lt loopparabola

	ldr lr, [sp,16]
	ldr x22, [sp, 8]
	ldr x23, [sp, 0]
	add sp,sp,16

	br lr

//

filldowncol:
	// Rellena los píxeles desde la coordenada cartesiana (x22, x23) hasta la altura 30, con el color de w10

	sub sp,sp,#40
	str lr ,[sp, 32]
	str x19 ,[sp,24]
	str x22 ,[sp,16]
	str x23 ,[sp,8]
	str x24 ,[sp,0]

	sub x19, x23, 199		// Calculo la cantidad de veces que iterar hasta la altura 30

loopfill:
	bl cartesianos
	sub x23, x23, 1
	stur w10, [x0]
	sub x19, x19, 1
	cbnz x19, loopfill


	ldr lr ,[sp, 32]
	ldr x19 ,[sp,24]
	ldr x22 ,[sp,16]
	ldr x23 ,[sp,8]
	ldr x24 ,[sp,0]
	add sp,sp,#40

	br lr

//
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

	//---------------------------------------------------------------
	// Infinite Loop

InfLoop:
	b InfLoop
