.data
	Anim: .dword 30, 0, 0, 0, 0, 0
	.equ DENSITY, 5
	.equ GPIO_GPLEV0,  0x34

//DelayLoop
.globl delay
delay:
	sub sp, sp, 16
	str lr, [sp, 8]
	str x1, [sp, 0]
	movz x1, 0x02, lsl 16

delayloop:
	sub x1, x1, 1
	cbnz x1, delayloop

	ldr lr, [sp, 8]
	ldr x1, [sp, 0]
	add sp, sp, 16
	br lr 
//
.globl delayLargo
delayLargo:
	sub sp, sp, 16
	str lr, [sp, 8]
	str x1, [sp, 0]
	movz x1, 0x1F, lsl 16

delayLargoloop:
	sub x1, x1, 1
	cbnz x1, delayloop

	ldr lr, [sp, 8]
	ldr x1, [sp, 0]
	add sp, sp, 16


//Animaciones
.globl moonAnim
moonAnim:
	//LUNA


moonAnimLoop:
	add x27,x27,2
	add x28,x28,1


	cmp x27,230 //Cuantos steps hace la luna ,step = constante - x27 input
	bge	loopPrincipal

	mov x24,180
	mov x0,x20
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

	mov x22,x27  //x origen
	mov x23,x28  //y origen
	mov x21,x29  

	movz x10, 0xFF, lsl 16 //Color blanco
	movk x10, 0xFFFF, lsl 00 
	bl circulo


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
//
//BORDE DEL RIO
	mov x3, 0b00	// Seteo la flag de delay
	mov x24, 200	// Altura hasta la que se grafica
	movz x10, 0x2a, lsl 16
	movk x10, 0x2809, lsl 00 	// Elijo color	
	mov x22, 140	// Origen "x" de la cúbica
	mov x23, 273	// Origen "y" de la cúbica

	mov x21, 25
	bl caida

//RIO

	mov x3, 0b00	// Seteo la flag de delay
	mov x24, 40		// Altura hasta la que se grafica
	movz x10, 0x11, lsl 16
	movk x10, 0x6673, lsl 00 	// Elijo color
	mov x22, 146	// Origen "x" de la cúbica
	mov x23, 272	// Origen "y" de la cúbica
	
	mov x21, 20  // Ancho del rio
	bl rio

	bl delayLargo
	bl delayLargo
	bl delayLargo

//
	b moonAnim


.globl aguaLava
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
	mov x21, 20  	// Ancho del rio

	bl caida

	mov x22, 200
	mov x23, 140
	mov x21, 70

	bl elipseCreciente

	ldr lr, [sp, 32]
	ldr x21, [sp, 24]
	ldr x22, [sp, 16]
	ldr x23, [sp, 8]
	ldr x24, [sp, 0]
	add sp, sp, 40
	br lr
//

.globl caida
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

.globl moveSnail
moveSnail:
	// Mueve la coordenada x del caracol (suma 1 a Anim[0])
	// Utiliza, sin guardarlo, x14

	sub sp, sp, 32
	str x22, [sp, 24]
	str x21, [sp, 16]
	str x24, [sp, 8]
	str lr, [sp, 0]

	ldr x14, =Anim 				// Almaceno las coordenadas iniciales del arreglo
	ldr x22, [x14]				// Almaceno en x22 el valor de Anim[0]

	movz x10, 0x09, lsl 16		//Color base del piso
	movk x10, 0x5516, lsl 00
	mov x21, 25					// Decido el ancho del rectangulo que borrara al caracol anterior	
	mov x24, 20					// Decido el alto del rectangulo que borrara al caracol anterior
	sub x22, x22, 5				// Lo reacomodo a donde corresponde
	sub x23, x23, 5
	bl Rectangle
	add x22, x22, 5				// Devuelvo los valores que tenia antes
	add x23, x23, 5
	add x22, x22, 1				// Muevo la ubicacion del proximo caracol
	bl snailAsset				// Lo grafico

	str x22, [x14]

	ldr x22, [sp, 24]
	ldr x21, [sp, 16]
	ldr x24, [sp, 8]
	ldr lr, [sp, 0]
	add sp, sp, 32

	br lr

.globl neonLine
neonLine:
	// Dibuja una linea psicodelica en las coordenadas cartesianas (x1, x2)

	sub sp, sp, 32
	str x7, [sp, 24]		// ""Variable"" para verificar las flags de funciones
	str lr, [sp,16]
	str x22, [sp,8]
	str x23, [sp,0]

	mov x22, 0
	mov x23, 0

	and x3, x3, 0xfe		// Setea el funcionamiento de LineH para que extienda hacia la derecha
	mov x18, x1				// Almaceno en x18 el valor "x" del centro
	mov x19, x2				// Almaceno en x19 el valor "y" del centro

	mov x4, 0 				// x4 <-> Primer valor a evaluar

loopNeon:
	add x22, x18, x4
	bl lineal
	add x23, x0, x19		// Ubico el valor "y" centro en   centro_originaly + x17
	bl delay				// Delay para generar efecto
	bl LineH
	bl LineD
	add x4, x4, 1
	cmp x4, 30
	b.le loopNeon
endNeon:

	ldr x7, [sp, 24]
	ldr lr, [sp,16]
	ldr x22, [sp, 8]
	ldr x23, [sp, 0]
	add sp, sp, 32

	br lr

.globl neonFace
neonFace:
	sub sp, sp, 40
	str x10, [sp, 24]
	str x22, [sp,16]
	str x23, [sp, 8]
	str lr, [sp, 0]

	mov x1, 0
	mov x2, 0
	mov x22, 150
	mov x23, 120

loopEscalon:
	mov x22, 150
	mov x23, 120
	movz x10, 0x1f, lsl 16 
	cmp x2, 640
	b.le loopFace0
	mov x2, 0
loopFace0:
	bl neonLine
	add x1, x1, 1
	sub x22, x22, 1
	add x10, x10, 0xf
	cbnz x22, loopFace0

loopFace1:
	bl neonLine
	add x10, x10, 0xf
	add x2, x2, 1
	sub x23, x23, 1
	cbnz x23, loopFace1
	ldr w13, [x26, GPIO_GPLEV0]
	and w13, w13, 0b00100000
	cbz w13, loopEscalon

	ldr x10, [sp, 24]
	ldr x22, [sp,16]
	ldr x23, [sp, 8]
	ldr lr, [sp, 0]
	add sp, sp, 40

	br lr

lineal:
	// Retorna en x0 el valor de evaluar la funcion lineal x4
	mov x0, x4
	br lr

