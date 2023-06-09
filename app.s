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

.globl init
init:
	movz x24,270 //Llenar el cielo exctamente hasta donde empieza el suelo
	bl skyFill


//ESTRELLAS
	movz x10, 0xFF, lsl 16 //Color blanco
	movk x10, 0xFFFF, lsl 00 

	mov x1,48   //Cantidad de esterellas
	mov x22,2  //x origen
	mov x23,0  //y origen
	add x0,x0,1

loopEstrellas:
	bl drawpixel
	add x22,x22,40 
	add x23,x23,2
	sub x1,x1,1
	cbnz x1,loopEstrellas

//SUELO
	movz x10, 0x09, lsl 16 //Color base del piso
	movk x10, 0x5516, lsl 00

	movz x22 ,0 	//x origen
	movz x23 ,270	//y	origen
	movz x21 ,640	//ancho
	movz x24 ,220   //alto
	bl Rectangle
//
//Cultivo tras la valla
	bl cultivoStatic
//	
//Valla del fondo 
	mov x22,438  //Donde arranca la valla
	mov x23,310 //Donde arranca la valla
 	bl vallaStatic

	movz x10, 0x7A, lsl 16
	movk x10, 0x3F1F, lsl 00
	mov x2,20      //Espacio entre triangulos
	mov x1 ,10   //cant de veces a repetir
	mov x22,436 	//x origen
	mov x23,310	//y	origen
	mov x21,9	//ancho
	bl tringulosrep

//
//Trigo x4 aux
	mov x4,17
	mov x22,450
	mov x23,232
fila1trigo:
	mov x23,232
	bl espiga
	add x22,x22,10
	sub x4,x4,1
	cbnz x4,fila1trigo

	mov x4,16
	mov x22,458
fila2trigo:
	mov x23,210
	bl espiga
	add x22,x22,10
	sub x4,x4,1
	cbnz x4,fila2trigo

	
//
//Cartel
    mov x22,310  //Posicion del cartel (x)
	mov x23,340  //Posicion del cartel (y)
	bl cartelStatic
	movz x10, 0x00, lsl 16
	movk x10, 0x0000, lsl 00
	mov x22,320  //x
	mov x23,350  //y
	mov x21,40
	bl Line
	mov x22,325 
	mov x23,357  
	mov x21,30
	bl Line
//
//TRONCOS DE ARBOLES
	movz x10, 0x81, lsl 16
	movk x10, 0x4929, lsl 00
	mov x22,285   //x //Arbol de la izquierda
	mov x23,250  //y
	mov x21,10	//ancho
	mov x24,40 	//alto
	bl Rectangle
	mov x22,410  // Arbol de la derecha
	bl Rectangle
	movz x10, 0x4a, lsl 16
	movk x10, 0x3819, lsl 00
	mov x22,347  // Arbol centro
	bl Rectangle

//COPA DE ARBOLES
	movz x10, 0x15, lsl 16   //Arbol del fondo
	movk x10, 0x3d12, lsl 00 
	mov x21, 40
	mov x22, 350  //x
	mov x23, 260  //y  
	bl circulo

	movz x10, 0x31, lsl 16 //Arboles del frente
	movk x10, 0x7a2d, lsl 00 
	//Izquierda
	mov x22, 290  //x
	bl circulo
	//Derecha
	mov x22,415  //x
	bl circulo
//


//MONTAÑA
	movz x10, 0x4a, lsl 16
	movk x10, 0x3819, lsl 00 	// Elijo color

	mov x22, 115	// Origen "x" de la parábola
	mov x23, 390	// Origen "y" de la parábola
	bl parabola
//
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
//
//BORDE DEL RIO
	mov x3, 0b00	// Seteo la flag de delay
	mov x24, 200	// Altura hasta la que se grafica
	movz x10, 0x2a, lsl 16
	movk x10, 0x2809, lsl 00 	// Elijo color	
	mov x22, 142	// Origen "x" de la cúbica
	mov x23, 273	// Origen "y" de la cúbica

	mov x21, 25
	bl caida
//LAGUNA
	movz x10, 0x01, lsl 16
	movk x10, 0x5673, lsl 00 	// Elijo color
	mov x21, 70
	mov x22, 200	
	mov x23, 140
	bl elipse
//
//RIO DE LA MONTAÑA
rioClaro:
	mov x3, 0b00	// Seteo la flag de delay
	mov x24, 40		// Altura hasta la que se grafica
	movz x10, 0x11, lsl 16
	movk x10, 0x6673, lsl 00 	// Elijo color
	mov x22, 146	// Origen "x" de la cúbica
	mov x23, 272	// Origen "y" de la cúbica
	
	mov x21, 20  // Ancho del rio
	bl caida
//
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

//Manzana 
	movz x10, 0xB0, lsl 16
    movk x10, 0x1515, lsl 00  
	mov x22, 270  //x
	mov x23, 250  //y


	bl manzana
	
	mov x22, 300  //x
	bl manzana

	mov x22, 400  //x
	bl manzana

	movz x10, 0xB0, lsl 16
    movk x10, 0x1515, lsl 00  
	mov x22, 420  //x
	mov x23, 250  //y
	bl manzana


	movz x10, 0xFA, lsl 16  
    movk x10, 0xF32B, lsl 00  
	mov x22, 440  //x
	mov x23, 250  //y
	bl manzana

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

 //Piedra del caracol
	movz x10, 0x5A, lsl 16
	movk x10, 0x5956, lsl 00 
	mov x21,9	
	mov x22, 125    
	mov x23, 135
	bl elipse

	movz x22, #115
	movz x23, #332
	bl snailAsset
//

	mov x26, GPIO_BASE
	// Setea gpios 0 - 9 como lectura
	str wzr, [x26, GPIO_GPFSEL0]
	// x12 servirá para las comprobaciones de las funcionalidades (para ver si algo ya se llamó, etc)
	mov x12, 0b0000

	mov x26, GPIO_BASE
.globl loopPrincipal
	// Setea gpios 0 - 9 como lectura
	str wzr, [x26, GPIO_GPFSEL0]
	// x12 servirá para las comprobaciones de las funcionalidades (para ver si algo ya se llamó, etc)
	mov x12, 0b0000
	mov x22, 30		// Coordenadas matriciales iniciales del caracol i = SCREEN_HEIGH-x22, j = x23
	mov x23, 450
	bl snailAsset

loopPrincipal:

	// Lee el estado de los GPIO 0 - 31
	ldr w13, [x26, GPIO_GPLEV0]

	// Tecla w
	and w11, w13, 0b00000010
	cbz w11, skipw
	bl aguaLava
	bl delayLargo
	bl delayLargo
skipw:

	// Tecla a
	and w11, w13, 0b00000100
	cbz w11, skipa
skipa:

	// Tecla s
	and w11, w13, 0b0001000
	cbz w11, skips
	bl ufoAsset
	bl delayLargo
	bl delayLargo
skips:

	// Tecla d
	and w11, w13, 0b00010000
	cbz w11, skipd
	bl moveSnail		// Modifica Anim[0], moviendo el caracol
	bl delayLargo
	bl delayLargo
skipd:

	// Tecla espacio
	and w11, w13, 0b00100000
	cbz w11, skipEsp
	bl neonCube
skipEsp:

	b loopPrincipal

//---------FUNCIONES AUXILIARES------------	
	//---------------------------------------------------------------
	// Infinite Loop

.globl InfLoop
InfLoop:
	b InfLoop
