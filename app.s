.include "figures.s"

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
	movz x10, 0x4a, lsl 16
	movk x10, 0x3819, lsl 00 	// Elijo color

	mov x22, 115	// Origen "x" de la parábola
	mov x23, 390	// Origen "y" de la parábola
	bl parabola


//BORDE DEL RIO
	mov x24, 200
	movz x10, 0x2a, lsl 16
	movk x10, 0x2809, lsl 00 	// Elijo color	
	mov x22, 142	// Origen "x" de la cúbica
	mov x23, 273	// Origen "y" de la cúbica

	mov x21, 25
	bl rio

//RIO DE LA MONTAÑA
	mov x24, 40
	movz x10, 0x11, lsl 16
	movk x10, 0x6673, lsl 00 	// Elijo color
	mov x22, 146	// Origen "x" de la cúbica
	mov x23, 272	// Origen "y" de la cúbica
	
	mov x21, 20  // Ancho del rio
	bl rio

//CIRCULO
	mov x10, 0
	mov x21, 220
	mov x22, 320
	mov x23, 240

	bl circunferencia


	b InfLoop

//---------FUNCIONES AUXILIARES------------	
	//---------------------------------------------------------------
	// Infinite Loop

InfLoop:
	b InfLoop
