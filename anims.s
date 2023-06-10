.data
	snailAnimNeeds: .dword 30, 450
	blackHoleSize: .dword 5
	.equ DENSITY, 5
	.equ GPIO_GPLEV0,  0x34
	.equ DELAYCONSTRAINT, 0x9
	moonAnimNeeds: .dword 130,345,32,0


//DelayLoop
.globl delay
delay:
	sub sp, sp, 16
	str lr, [sp, 8]
	str x1, [sp, 0]
	mov x1, DELAYCONSTRAINT
	lsl x1,x1,#16

delayloop:
	sub x1, x1, 1
	cbnz x1, delayloop

	ldr lr, [sp, 8]
	ldr x1, [sp, 0]
	add sp, sp, 16
	br lr 
//

.globl delayMedio
delayMedio:
	sub sp, sp, 16
	str lr, [sp, 8]
	str x1, [sp, 0]
	mov x1,DELAYCONSTRAINT
	lsl x1,x1,#18

delayMedioloop:
	sub x1, x1, 1
	cbnz x1, delayMedioloop

	ldr lr, [sp, 8]
	ldr x1, [sp, 0]
	add sp, sp, 16
	br lr 

.globl delayLargo
delayLargo:
	sub sp, sp, 16
	str lr, [sp, 8]
	str x1, [sp, 0]
	mov x1, DELAYCONSTRAINT
	lsl x1,x1,#19

delayLargoloop:
	sub x1, x1, 1
	cbnz x1, delayLargoloop

	ldr lr, [sp, 8]
	ldr x1, [sp, 0]
	add sp, sp, 16
	br lr 


//Animaciones

.globl moonAnim
moonAnim:
	sub sp,sp,32
	str lr,[sp]
	str x19,[sp,8]
	str x27,[sp,16]
	str x28,[sp,24]

	ldr x19, =moonAnimNeeds
	ldr x27,[x19,0]
	ldr x28,[x19,8]

moonAnimLoop:
	add x27,x27,2
	add x28,x28,1

	cmp x27,230 //Cuantos steps hace la luna ,step = constante - x27 input
	bge	moonAnimEnd

//Redibujar lo necesario para salvar esta compañia
	mov x0,x20
	movz x24,480
	sub x24,x24,x28
	add x24,x24,33

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


//Luna
	mov x22,x27  				//x origen
	mov x23,x28  				//y origen
	mov x21,x29  				//y origen

	ldr x21,=moonAnimNeeds
	add x21,x21,16
	ldr x21,[x21]
	movz x10, 0xFA, lsl 16 		//Color blanco
	movk x10, 0xFAFA, lsl 00 
	bl circulo

	//MONTAÑA
	movz x10, 0x4a, lsl 16
	movk x10, 0x3819, lsl 00 	// Elijo color

	mov x22, 115				// Origen "x" de la parábola
	mov x23, 390				// Origen "y" de la parábola
	bl parabola

	//PASTO DECO 
	movz x10, 0x09, lsl 16 		//Color un poco más oscuro de la base del piso
	movk x10, 0x5316, lsl 00

	mov x2,8   					//Espacio entre triangulos
	mov x1 ,28 					//cant de veces a repetir
	mov x22,0 					//x origen
	mov x23,286					//y	origen
	mov x21,15					//ancho
	bl tringulosrep
	mov x1 ,18    				//cant de veces a repetir
	mov x22,272 				//x origen
	mov x23,296	    			//y	origen
	mov x21,13					//ancho
	bl tringulosrep

	//BORDE DEL RIO
	mov x3, 0b00				// Seteo la flag de delay
	mov x24, 200
	movz x10, 0x2a, lsl 16
	movk x10, 0x2809, lsl 00 	// Elijo color	
	mov x22, 142				// Origen "x" de la cúbica
	mov x23, 273				// Origen "y" de la cúbica

	mov x21, 25
	bl caida

	//Rio
	mov x3, 0b00				// Seteo la flag de delay
	mov x24, 40
	mov x22, 146				// Origen "x" de la cúbica
	mov x23, 272				// Origen "y" de la cúbica
	mov x21, 20  				// Ancho del rio

	movz x10, 0xf1, lsl 16
	movk x10, 0x0613, lsl 00 	// Seteo a color rojo

	//Reciclo la logica de agualava
	ldr x9,moonAnimNeeds
	add x9,x9,24
	ldr x9,[x9]

	cbnz x9, lavaColorMoon
	movz x10, 0x11, lsl 16
	movk x10, 0x6673, lsl 00 	// Seteo a color celeste

lavaColorMoon:
	bl caida
	bl delayLargo
	b moonAnimLoop

moonAnimEnd:
	ldr lr, [sp]
	ldr x19, [sp,8]
	ldr x27, [sp,16]
	ldr x28, [sp,24]
	add sp, sp, 32
	b loopPrincipal

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
	movk x10, 0x0613, lsl 00		// Seteo a color rojo

	eor x12, x12, 0b01				// Invierto el bit 0
	and x9, x12, 0b01
	//Guardar la evaluacion logica para redibujar en moonAnim
	ldr x19,moonAnimNeeds
	str x9,[x19,24]
	//
	cbnz x9, lavaColor				
	movz x10, 0x11, lsl 16
	movk x10, 0x6673, lsl 00 		// Si x9 == 0, seteo a color celeste
lavaColor:

	mov x3, 0b10					// Seteo la flag de delay
	mov x24, 40
	mov x22, 146					// Origen "x" de la cúbica
	mov x23, 272					// Origen "y" de la cúbica
	mov x21, 20  					// Ancho del rio

	bl caida

	mov x22, 200
	mov x23, 150
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
	// Mueve la coordenada x del caracol (suma 1 a snailAnimNeeds[0])
	// Utiliza, sin guardarlo, x14

	sub sp, sp, 32
	str x22, [sp, 24]
	str x21, [sp, 16]
	str x24, [sp, 8]
	str lr, [sp, 0]

	ldr x14, =snailAnimNeeds 	// Almaceno las coordenadas iniciales del arreglo
	ldr x22, [x14]				// Almaceno en x22 el valor de snailAnimNeeds[0]
	ldr x23, [x14,8]

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

.globl newUFO
newUFO:
	sub sp, sp, 8
	str lr, [sp]

	bl spaceTravel

	ldr lr, [sp]
	br lr

//
spaceTravel:
	sub sp, sp, 32
	str x22, [sp, 24]
	str x21, [sp, 16]
	str x24, [sp, 8]
	str lr, [sp, 0]

	mov x22, 420
	mov x23, 390
	
	ldr x14, =blackHoleSize
	ldr w21, [x14]
	add w21, w21, 10
	str w21, [x14]

	movz x10, 0xff, lsl 16
	movk x10, 0xffff, lsl 00

	bl blackHole

	movz x10, 0x44, lsl 16
	movk x10, 0x11aa, lsl 00

	bl blackHole

	mov x10, 0

	bl blackHole

	ldr x22, [sp, 24]
	ldr x21, [sp, 16]
	ldr x24, [sp, 8]
	ldr lr, [sp, 0]
	add sp, sp, 32

	br lr
//

blackHole:
	sub sp, sp, 32
	str x22, [sp, 24]
	str x21, [sp, 16]
	str x24, [sp, 8]
	str lr, [sp, 0]

	ldr x14, =blackHoleSize
	ldr x14, [x14]

	mov x21, 5
loopBlackHole0:
	add x21, x21, 1 
	bl elipse
	bl delayMedio
	cmp x21, x14
	b.lt loopBlackHole0

	cmp x14, 120
	b.le noEyes
loopBlackHole1:
	mov x21, 5
	mov x10, 0xff
	add x21, x21, 1 
	bl circulo
	bl delayMedio
	cmp x21, x14
	b.lt loopBlackHole1	
noEyes:

	ldr x22, [sp, 24]
	ldr x21, [sp, 16]
	ldr x24, [sp, 8]
	ldr lr, [sp, 0]
	add sp, sp, 32

	br lr

eyes:
	sub sp, sp, 32
	str x22, [sp, 24]
	str x21, [sp, 16]
	str x24, [sp, 8]
	str lr, [sp, 0]

	mov x21, 25
	mov x22, 420
	mov x23, 390

	movz x10, 0x44, lsl 16
	movk x10, 0x11aa, lsl 00
	
	bl circulo

	movz x10, 0xff, lsl 16
	movk x10, 0xffff, lsl 00

	bl circulo

	mov x10, 0

	ldr x22, [sp, 24]
	ldr x21, [sp, 16]
	ldr x24, [sp, 8]
	ldr lr, [sp, 0]
	add sp, sp, 32

	br lr

