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

   //Cultivo tras la valla
	bl cultivoStatic


//Valla del fondo 
	mov x22,438  //Donde arranca la valla
	mov x23,310 //Donde arranca la valla
 	bl vallaStatic
//

//Cartel
    mov x22,310  //Posicion del cartel (x)
	mov x23,340  //Posicion del cartel (y)
	bl cartelStatic

//COPA DE PINOS
	movz x10, 0x15, lsl 16   //Pino del fondo
	movk x10, 0x3d12, lsl 00 
	mov x21,153  //ancho
	mov x22,275  //x
	mov x23,250  //y
	bl triangulo

	movz x10, 0x31, lsl 16 //Pinos del frente
	movk x10, 0x7a2d, lsl 00 
	//Pino izquierda
	mov x21,119  //ancho
	mov x22,225  //x
	mov x23,250  //y
	bl triangulo
	//Pino derecha
	mov x21,119  //ancho 
	mov x22,355  //x
	mov x23,250  //y
	bl triangulo

//TRONCOS DE PINOS
	movz x10, 0x81, lsl 16
	movk x10, 0x4929, lsl 00
	mov x22,285   //x //Pino de la izquierda
	mov x23,250  //y
	mov x21,10	//ancho
	mov x24,40 	//alto
	bl Rectangle
	mov x22,410  // Pino de la derecha
	bl Rectangle
	movz x10, 0x4a, lsl 16
	movk x10, 0x3819, lsl 00
	mov x22,347  // Pino centro
	bl Rectangle


//MONTAÑA
	movz x10, 0x4a, lsl 16
	movk x10, 0x3819, lsl 00 	// Elijo color

	mov x22, 115	// Origen "x" de la parábola
	mov x23, 390	// Origen "y" de la parábola
	bl parabola


//PASTO DECO 
	movz x10, 0x09, lsl 16 //Color un poco más oscuro de la base del piso
	movk x10, 0x5316, lsl 00

	mov x2,8      //Espacio entre triangulos
	mov x1 ,28   //cant de veces a repetir
	mov x22,0 	//x origen
	mov x23,286	//y	origen
	mov x21,15	//ancho
	bl tringulosrep
	mov x1 ,18    	//cant de veces a repetir
	mov x22,272 	//x origen
	mov x23,296	    //y	origen
	mov x21,13		//ancho
	bl tringulosrep

//BORDE DEL RIO
	bl bordeRio

//LAGUNA
	movz x10, 0x01, lsl 16
	movk x10, 0x5673, lsl 00 	// Elijo color
	mov x21, 70
	mov x22, 200
	mov x23, 150

	bl elipse

//RIO DE LA MONTAÑA
	bl rio

//FLORES: Registro x1 usado como auxiliar
	
    mov x22, 370 //x inicial
    mov x23, 380 //y
    mov x21, 7 //ancho
    mov x24, 7  //alto
	mov x1, 0  // Auxiliar para el loop

loopvioleta:  
	add x22,x22,40
    // Centro
	movz x10, 0xFF, lsl 16
    movk x10, 0xFFFF, lsl 00
    bl Rectangle

    // Pétalos
    movz x10, 0x44, lsl 16
    movk x10, 0x0463, lsl 00
    bl Petalos
    add x1, x1, 1
    cmp x1, 6    
    blt loopvioleta

	mov x22,352     //Restablezco/establezco valores convenientes
    mov x23,350 
	mov x1, 0
loopamarilla:
	add x22,x22,38   
    // Centro 
	movz x10, 0x00, lsl 16
    movk x10, 0x00000, lsl 00
    bl Rectangle 

    // Pétalos
    movz x10, 0x96, lsl 16
    movk x10, 0x8200, lsl 00
    bl Petalos

    add x1, x1, 1
    cmp x1, 7    
    blt loopamarilla 

//Caracoles
	movz x22, #20
	movz x23, #420
	bl snailAsset

	movz x22, #50
	movz x23, #430
	bl snailAsset

	movz x22, #400
	movz x23, #416
	bl snailAsset

	movz x22, #440
	movz x23, #420
	bl snailAsset

	mov x26, GPIO_BASE
	// Setea gpios 0 - 9 como lectura
	str wzr, [x26, GPIO_GPFSEL0]
	// x12 servirá para las comprobaciones de las funcionalidades (para ver si algo ya se llamó, etc)
	mov x12, 0b0000
	mov x22, 30		// Coordenadas matriciales del caracol i = SCREEN_HEIGH-x22, j = x23
	mov x23, 420

loopPrincipal:

	// Lee el estado de los GPIO 0 - 31
	ldr w16, [x26, GPIO_GPLEV0]

	// Tecla w
	and w11, w16, 0b00000010
	cbz w11, skipw
	bl aguaLava
skipw:

	// Tecla a
	and w11, w16, 0b00000100
	cbz w11, skipa
skipa:

	// Tecla s
	and w11, w16, 0b00000100
	cbz w11, skips
skips:

	// Tecla d
	and w11, w16, 0b00001000
	cbz w11, skipd
	add x22, x22, 1
	bl snailAsset
	bl delay
skipd:

	// Tecla espacio
	
	and w11, w16, 0b00010000
	cbz w11, skipEsp
	
skipEsp:


	b loopPrincipal

	b InfLoop
//---------FUNCIONES AUXILIARES------------	
	//---------------------------------------------------------------
	// Infinite Loop

InfLoop:
	b InfLoop
