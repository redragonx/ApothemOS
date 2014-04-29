/******************************************************************************
*  FileName:terminal.s
*  Authors: Stephen Chavez & Joshua Michael Waggoner
*  Source: Baking Pi OS Tutorial - by Alex Chadwick
*  Date: Mar 26, 2014
*  Target: ARMv6 - Application Binary Interface (ABI) Compliant
*
*  Description: terminal.s contains the code that interacts with the system 
*               terminal.
*  
*******************************************************************************/
/*
* Data section
*/
.section .data

.align 4

/*
* terminalStart is the address in the terminalBuffer of the first valid 
* character.
* C++ Signature: u32 terminalStart;
*/
terminalStart:
	.int terminalBuffer

/*
* terminalStop is the address in the terminalBuffer of the last valid
* character.
* C++ Signature: u32 terminalStop;
*/
terminalStop:
	.int terminalBuffer+128*(768/16-1)*2

/*
* terminalView is the address in the terminalBuffer of the first displayed
* character.
* C++ Signature: u32 terminalView;
*/
terminalView:
	.int terminalBuffer
	
/*
* terminalInput is the address in the terminalBuffer of the first character of
* the text being input.
* C++ Signature: u32 terminalView;
*/
terminalColour:
	.byte 0xf

/*
* terminalBuffer is where all text is stored for the console.
* C++ Signature: u16 terminalBuffer[128*128];
*/
.align 8
terminalBuffer:
	.rept 128*128
	.byte 0x7f
	.byte 0x0
	.endr
	
/*
* terminalScreen stores the text last rendered to the screnn by the console.
* This means when redrawing the screen, only changes need be drawn.
* C++ Signature: u16 terminalScreen[1024/8 * 768/16];
*/
terminalScreen:
	.rept 1024/8 * 768/16
	.byte 0x7f
	.byte 0x0	
	.endr
	

.section .text
	
/*
* Sets the fore colour to the specified terminal colour. The low 4 bits of r0
* contains the terminal colour code.
* C++ Signature: void TerminalColour(u8 colour);
*/
TerminalColour:
	teq r0,#6
	ldreq r0,=0x02B5
	beq SetForeColour

	tst r0,#0b1000
	ldrne r1,=0x52AA
	moveq r1,#0
	tst r0,#0b0100
	addne r1,#0x15
	tst r0,#0b0010
	addne r1,#0x540
	tst r0,#0b0001
	addne r1,#0xA800
	mov r0,r1
	b SetForeColour
		
/*
* Copies the currently displayed part of TerminalBuffer to the screen.
* C++ Signature: void TerminalDisplay();
*/
.global TerminalDisplay
TerminalDisplay:
	push {r4,r5,r6,r7,r8,r9,r10,r11,lr}
	x .req r4
	y .req r5
	char .req r6
	col .req r7
	screen .req r8
	taddr .req r9
	view .req r10
	stop .req r11

	ldr taddr,=terminalStart
	ldr view,[taddr,#terminalView - terminalStart]
	ldr stop,[taddr,#terminalStop - terminalStart]
	add taddr,#terminalBuffer - terminalStart
	add taddr,#128*128*2 
	mov screen,taddr
	
	mov y,#0
	yLoop$:
		mov x,#0
		xLoop$:
			teq view,stop
			ldrneh char,[view]
			moveq char,#0x7f
			ldrh col,[screen]

			teq col,char
			beq xLoopContinue$

			strh char,[screen]

			lsr col,char,#8
			and char,#0x7f
			lsr r0,col,#4
			bl TerminalColour

			mov r0,#0x7f
			mov r1,x
			mov r2,y
			bl DrawCharacter
						
			and r0,col,#0xf
			bl TerminalColour

			mov r0,char
			mov r1,x
			mov r2,y
			bl DrawCharacter

		xLoopContinue$:
			add screen,#2
			teq view,stop
			addne view,#2
			teq view,taddr
			subeq view,#128*128*2

			add x,#8
			teq x,#1024
			bne xLoop$
		add y,#16
		teq y,#768
		bne yLoop$
		
	pop {r4,r5,r6,r7,r8,r9,r10,r11,pc}
	.unreq x
	.unreq y
	.unreq char
	.unreq col
	.unreq screen
	.unreq taddr
	.unreq view
	.unreq stop
	
/*
* Clears the terminal to blank.
* C++ Signature: void TerminalClear();
*/
.global TerminalClear
TerminalClear:
	ldr r0,=terminalStart
	add r1,r0,#terminalBuffer-terminalStart
	str r1,[r0]
	str r1,[r0,#terminalStop-terminalStart]	
	str r1,[r0,#terminalView-terminalStart]	
	mov pc,lr
	
	
/*
* Prints a string to the terminal at the current location. r0 contains a 
* pointer to the ASCII encoded string, and r1 contains its length. New lines,
* and null terminators are obeyed.
* C++ Signature: void Print(char* string, u32 length);
*/
.global Print
Print:
	teq r1,#0
	moveq pc,lr

	push {r4,r5,r6,r7,r8,r9,r10,r11,lr}
	bufferStart .req r4
	taddr .req r5
	x .req r6
	string .req r7
	length .req r8
	char .req r9
	bufferStop .req r10
	view .req r11

	mov string,r0
	mov length,r1

	ldr taddr,=terminalStart
	ldr bufferStop,[taddr,#terminalStop-terminalStart]
	ldr view,[taddr,#terminalView-terminalStart]
	ldr bufferStart,[taddr]
	add taddr,#terminalBuffer-terminalStart
	add taddr,#128*128*2
	and x,bufferStop,#0xfe
	lsr x,#1
	
	charLoop$:
		ldrb char,[string]
		and char,#0x7f
		teq char,#0x1b
		beq charEscape$
		teq char,#'\n'
		bne charNormal$

		mov r0,#0x7f
		clearLine$:
			strh r0,[bufferStop]
			add bufferStop,#2
			add x,#1
			cmp x,#128
			blt clearLine$

		b charLoopContinue$

	charEscape$:
		cmp length,#2
		blt charLoopContinue$

		sub length,#1
		add string,#1
		ldrb char,[string]
		cmp char,#'9'
		suble char,#'0'
		subgt char,#'a'-10		
		ldr r0,=terminalColour
		strb char,[r0]
		b charLoopContinue$

	charNormal$:
		teq char,#0
		beq charLoopBreak$

		strb char,[bufferStop]
		ldr r0,=terminalColour
		ldrb r0,[r0]
		strb r0,[bufferStop,#1]
		add bufferStop,#2
		add x,#1
		
	charLoopContinue$:
		cmp x,#128
		blt noScroll$

		mov x,#0
		subs r0,bufferStop,view
		addlt r0,#128*128*2
		cmp r0,#128*(768/16)*2
		addge view,#128*2
		teq view,taddr
		subeq view,taddr,#128*128*2

	noScroll$:
		teq bufferStop,taddr
		subeq bufferStop,taddr,#128*128*2

		teq bufferStop,bufferStart
		addeq bufferStart,#128*2
		teq bufferStart,taddr
		subeq bufferStart,taddr,#128*128*2

		subs length,#1
		add string,#1
		bgt charLoop$

	charLoopBreak$:
	
	sub taddr,#128*128*2
	sub taddr,#terminalBuffer-terminalStart
	str bufferStop,[taddr,#terminalStop-terminalStart]
	str view,[taddr,#terminalView-terminalStart]
	str bufferStart,[taddr]

        .unreq bufferStart 
	.unreq taddr 
	.unreq x 
	.unreq string
	.unreq length
	.unreq char
	.unreq bufferStop
	.unreq view
	pop {r4,r5,r6,r7,r8,r9,r10,r11,pc}
	

/*****************************************************************************/

/*
* Prints a string to the terminal and batman. r0 contains a 
* pointer to the ASCII encoded string, and r1 contains its length. New lines,
* and null terminators are obeyed. then it prints ascii art. lol. 
* C++ Signature: void Print(char* string, u32 length);
*/
.global PrintBatman
PrintBatman:
       
	teq r1,#0
	moveq pc,lr

	push {r4,r5,r6,r7,r8,r9,r10,r11,lr}
	bufferStart .req r4
	taddr .req r5
	x .req r6
	string .req r7
	length .req r8
	char .req r9
	bufferStop .req r10
	view .req r11

	mov string,r0
	mov length,r1

	ldr taddr,=terminalStart
	ldr bufferStop,[taddr,#terminalStop-terminalStart]
	ldr view,[taddr,#terminalView-terminalStart]
	ldr bufferStart,[taddr]
	add taddr,#terminalBuffer-terminalStart
	add taddr,#128*128*2
	and x,bufferStop,#0xfe
	lsr x,#1

	charLoopBatman$:
		ldrb char,[string]
		and char,#0x7f
		teq char,#0x1b
		beq charEscape$
		teq char,#'\n'
		bne charNormalBatman$

		mov r0,#0x7f
		clearLineBatman$:
			strh r0,[bufferStop]
			add bufferStop,#2
			add x,#1
			cmp x,#128
			blt clearLineBatman$

		b charLoopContinueBatman$

	charEscapeBatman$:
		cmp length,#2
		blt charLoopContinueBatman$

		sub length,#1
		add string,#1
		ldrb char,[string]
		cmp char,#'9'
		suble char,#'0'
		subgt char,#'a'-10		
		ldr r0,=terminalColour
		strb char,[r0]
		b charLoopContinueBatman$

	charNormalBatman$:
		teq char,#0
		beq charLoopBreakBatman$

		strb char,[bufferStop]
		ldr r0,=terminalColour
		ldrb r0,[r0]
		strb r0,[bufferStop,#1]
		add bufferStop,#2
		add x,#1

	charLoopContinueBatman$:
		cmp x,#128
		blt noScrollBatman$

		mov x,#0
		subs r0,bufferStop,view
		addlt r0,#128*128*2
		cmp r0,#128*(768/16)*2
		addge view,#128*2
		teq view,taddr
		subeq view,taddr,#128*128*2

	noScrollBatman$:
		teq bufferStop,taddr
		subeq bufferStop,taddr,#128*128*2

		teq bufferStop,bufferStart
		addeq bufferStart,#128*2
		teq bufferStart,taddr
		subeq bufferStart,taddr,#128*128*2

		subs length,#1
		add string,#1
		bgt charLoopBatman$

	charLoopBreakBatman$:

	sub taddr,#128*128*2
	sub taddr,#terminalBuffer-terminalStart
	str bufferStop,[taddr,#terminalStop-terminalStart]
	str view,[taddr,#terminalView-terminalStart]
	str bufferStart,[taddr]

        ldr r0,=batman
        ldr r1,=batmanStringLength
        /*bl should work, cause it should return to here right????*/
        bl Print
   

	.unreq bufferStart                 /*Unalias everything else...*/
	.unreq taddr 
	.unreq x 
	.unreq string
	.unreq length
	.unreq char
	.unreq bufferStop
	.unreq view

<<<<<<< HEAD
	pop {r4,r5,r6,r7,r8,r9,r10,r11,pc}

        



/*************************End Print Batman stuff******************************/

/*
* Prints a string to the terminal and zelda. r0 contains a 
=======
/*****************************************************************************/

/*
* Experimental - Added vers 0.4
*/

/*
* Prints a string to the terminal and batman. r0 contains a 
>>>>>>> 9e432eade76b3a487bf8d5169ffcbf3eb045ac36
* pointer to the ASCII encoded string, and r1 contains its length. New lines,
* and null terminators are obeyed. then it prints ascii art. lol. 
* C++ Signature: void Print(char* string, u32 length);
*/
<<<<<<< HEAD
.global PrintZelda
PrintZelda:
              
=======
.globl PrintBatman
PrintBatman:
>>>>>>> 9e432eade76b3a487bf8d5169ffcbf3eb045ac36
	teq r1,#0
	moveq pc,lr

	push {r4,r5,r6,r7,r8,r9,r10,r11,lr}
	bufferStart .req r4
	taddr .req r5
	x .req r6
	string .req r7
	length .req r8
	char .req r9
	bufferStop .req r10
	view .req r11

	mov string,r0
	mov length,r1

	ldr taddr,=terminalStart
	ldr bufferStop,[taddr,#terminalStop-terminalStart]
	ldr view,[taddr,#terminalView-terminalStart]
	ldr bufferStart,[taddr]
	add taddr,#terminalBuffer-terminalStart
	add taddr,#128*128*2
	and x,bufferStop,#0xfe
	lsr x,#1
<<<<<<< HEAD

	charLoopZelda$:
=======
	
	charLoopBatman$:
>>>>>>> 9e432eade76b3a487bf8d5169ffcbf3eb045ac36
		ldrb char,[string]
		and char,#0x7f
		teq char,#0x1b
		beq charEscape$
		teq char,#'\n'
<<<<<<< HEAD
		bne charNormalZelda$

		mov r0,#0x7f
		clearLineZelda$:
=======
		bne charNormalBatman$

		mov r0,#0x7f
		clearLineBatman$:
>>>>>>> 9e432eade76b3a487bf8d5169ffcbf3eb045ac36
			strh r0,[bufferStop]
			add bufferStop,#2
			add x,#1
			cmp x,#128
<<<<<<< HEAD
			blt clearLineZelda$

		b charLoopContinueZelda$

	charEscapeZelda$:
		cmp length,#2
		blt charLoopContinueZelda$
=======
			blt clearLineBatman$

		b charLoopContinueBatman$

	charEscapeBatman$:
		cmp length,#2
		blt charLoopContinueBatman$
>>>>>>> 9e432eade76b3a487bf8d5169ffcbf3eb045ac36

		sub length,#1
		add string,#1
		ldrb char,[string]
		cmp char,#'9'
		suble char,#'0'
		subgt char,#'a'-10		
		ldr r0,=terminalColour
		strb char,[r0]
<<<<<<< HEAD
		b charLoopContinueZelda$

	charNormalZelda$:
		teq char,#0
		beq charLoopBreakZelda$
=======
		b charLoopContinueBatman$

	charNormalBatman$:
		teq char,#0
		beq charLoopBreak$
>>>>>>> 9e432eade76b3a487bf8d5169ffcbf3eb045ac36

		strb char,[bufferStop]
		ldr r0,=terminalColour
		ldrb r0,[r0]
		strb r0,[bufferStop,#1]
		add bufferStop,#2
		add x,#1
<<<<<<< HEAD

	charLoopContinueZelda$:
		cmp x,#128
		blt noScrollZelda$
=======
		
	charLoopContinueBatman$:
		cmp x,#128
		blt noScrollBatman$
>>>>>>> 9e432eade76b3a487bf8d5169ffcbf3eb045ac36

		mov x,#0
		subs r0,bufferStop,view
		addlt r0,#128*128*2
		cmp r0,#128*(768/16)*2
		addge view,#128*2
		teq view,taddr
		subeq view,taddr,#128*128*2

<<<<<<< HEAD
	noScrollZelda$:
=======
	noScrollBatman$:
>>>>>>> 9e432eade76b3a487bf8d5169ffcbf3eb045ac36
		teq bufferStop,taddr
		subeq bufferStop,taddr,#128*128*2

		teq bufferStop,bufferStart
		addeq bufferStart,#128*2
		teq bufferStart,taddr
		subeq bufferStart,taddr,#128*128*2

		subs length,#1
		add string,#1
<<<<<<< HEAD
		bgt charLoopZelda$

	charLoopBreakZelda$:

=======
		bgt charLoopBatman$

	charLoopBreakBatman$:
	
>>>>>>> 9e432eade76b3a487bf8d5169ffcbf3eb045ac36
	sub taddr,#128*128*2
	sub taddr,#terminalBuffer-terminalStart
	str bufferStop,[taddr,#terminalStop-terminalStart]
	str view,[taddr,#terminalView-terminalStart]
	str bufferStart,[taddr]

<<<<<<< HEAD
        ldr r0,=zelda
        ldr r1,=zeldaStringLength
        /*bl should work, cause it should return to here right????*/
        bl Print

        .unreq bufferStart                 /*Unalias everything else...*/
=======
/*
* Experimaental - Added vers 0.4
*/


        ldr r0,=batman
        ldr r1,=batmanStringLength
        /*bl should work, cause it should return to here right????*/
        bl Print
   

	pop {r4,r5,r6,r7,r8,r9,r10,r11,pc}

        


	.unreq bufferStart                 /*Unalias everything else...*/
>>>>>>> 9e432eade76b3a487bf8d5169ffcbf3eb045ac36
	.unreq taddr 
	.unreq x 
	.unreq string
	.unreq length
	.unreq char
	.unreq bufferStop
	.unreq view
<<<<<<< HEAD
   

	pop {r4,r5,r6,r7,r8,r9,r10,r11,pc}


/*****************************End Print Zelda stuff***************************/
/*****************************************************************************/

/*
* Prints the help screen. 
*/
.global PrintHelp
PrintHelp:
       
=======

/*************************End Print Batman stuff******************************/
>>>>>>> 9e432eade76b3a487bf8d5169ffcbf3eb045ac36
	
	push {r4,r5,r6,r7,r8,r9,r10,r11,lr}
	bufferStart .req r4
	taddr .req r5
	x .req r6
	string .req r7
	length .req r8
	char .req r9
	bufferStop .req r10
	view .req r11

	mov string,r0
	mov length,r1

	ldr taddr,=terminalStart
	ldr bufferStop,[taddr,#terminalStop-terminalStart]
	ldr view,[taddr,#terminalView-terminalStart]
	ldr bufferStart,[taddr]
	add taddr,#terminalBuffer-terminalStart
	add taddr,#128*128*2
	and x,bufferStop,#0xfe
	lsr x,#1

	charLoopHelp$:
		ldrb char,[string]
		and char,#0x7f
		teq char,#0x1b
		beq charEscape$
		teq char,#'\n'
		bne charNormalHelp$

		mov r0,#0x7f
		clearLineHelp$:
			strh r0,[bufferStop]
			add bufferStop,#2
			add x,#1
			cmp x,#128
			blt clearLineHelp$

		b charLoopContinueHelp$

	charEscapeHelp$:
		cmp length,#2
		blt charLoopContinueHelp$

		sub length,#1
		add string,#1
		ldrb char,[string]
		cmp char,#'9'
		suble char,#'0'
		subgt char,#'a'-10		
		ldr r0,=terminalColour
		strb char,[r0]
		b charLoopContinueBatman$

	charNormalHelp$:
		teq char,#0
		beq charLoopBreakHelp$

		strb char,[bufferStop]
		ldr r0,=terminalColour
		ldrb r0,[r0]
		strb r0,[bufferStop,#1]
		add bufferStop,#2
		add x,#1

	charLoopContinueHelp$:
		cmp x,#128
		blt noScrollHelp$

		mov x,#0
		subs r0,bufferStop,view
		addlt r0,#128*128*2
		cmp r0,#128*(768/16)*2
		addge view,#128*2
		teq view,taddr
		subeq view,taddr,#128*128*2

	noScrollHelp$:
		teq bufferStop,taddr
		subeq bufferStop,taddr,#128*128*2

		teq bufferStop,bufferStart
		addeq bufferStart,#128*2
		teq bufferStart,taddr
		subeq bufferStart,taddr,#128*128*2

		subs length,#1
		add string,#1
		bgt charLoopHelp$

	charLoopBreakHelp$:

	sub taddr,#128*128*2
	sub taddr,#terminalBuffer-terminalStart
	str bufferStop,[taddr,#terminalStop-terminalStart]
	str view,[taddr,#terminalView-terminalStart]
	str bufferStart,[taddr]

/*
* Experimaental - Added vers 0.4
*/


        ldr r0,=help
        ldr r1,=helpStringLength
        /*bl should work, cause it should return to here right????*/
        bl Print
   

	.unreq bufferStart                 /*Unalias everything else...*/
	.unreq taddr 
	.unreq x 
	.unreq string
	.unreq length
	.unreq char
	.unreq bufferStop
	.unreq view

	pop {r4,r5,r6,r7,r8,r9,r10,r11,pc}

        



/*************************End Print Batman stuff******************************/
/******************************End print Help stuff***************************/

/*
* Reads the next string a user types in up to r1 bytes and stores it in r0. 
* Characters types after maxLength are ignored. Keeps reading until the user 
* presses enter or return. Length of read string is returned in r0.
* C++ Signature: u32 Print(char* string, u32 maxLength);
*/
.global ReadLine
ReadLine:
	teq r1,#0
	moveq r0,#0
	moveq pc,lr

	string .req r4
	maxLength .req r5
	input .req r6
	taddr .req r7
	length .req r8
	view .req r9

	push {r4,r5,r6,r7,r8,r9,lr}

	mov string,r0
	mov maxLength,r1
	ldr taddr,=terminalStart
	ldr input,[taddr,#terminalStop-terminalStart]
	ldr view,[taddr,#terminalView-terminalStart]
	mov length,#0

	cmp maxLength,#128*64
	movhi maxLength,#128*64
	sub maxLength,#1
	mov r0,#'_'
	strb r0,[string,length]

	readLoop$:		
		str input,[taddr,#terminalStop-terminalStart]
		str view,[taddr,#terminalView-terminalStart]
		mov r0,string
		mov r1,length
		add r1,#1

		bl Print
		bl TerminalDisplay
		
		bl KeyboardUpdate
		bl KeyboardGetChar
		
		teq r0,#0
		beq cursor$
		teq r0,#'\n'	
		beq readLoopBreak$
		teq r0,#'\b'
		bne standard$

	delete$:
		cmp length,#0
		subgt length,#1
		b cursor$
	
	standard$:	
		cmp length,maxLength
		bge cursor$

		strb r0,[string,length]
		add length,#1
				
	cursor$:
		ldrb r0,[string,length]
		teq r0,#'_'
		moveq r0,#' '
		movne r0,#'_'
		strb r0,[string,length]

		cmp length,maxLength
		movge r0,#0x7f
		strgeb r0,[string,length]
		
		b readLoop$

	readLoopBreak$:
	
	mov r0,#'\n'
	strb r0,[string,length]

	str input,[taddr,#terminalStop-terminalStart]
	str view,[taddr,#terminalView-terminalStart]
	mov r0,string
	mov r1,length
	add r1,#1
	bl Print
	bl TerminalDisplay
	
	mov r0,#0
	strb r0,[string,length]

	mov r0,length
	pop {r4,r5,r6,r7,r8,r9,pc}
	.unreq string
	.unreq maxLength
	.unreq input
	.unreq taddr
	.unreq length
	.unreq view

<<<<<<< HEAD
/****************************End Read Line************************************/


/*
* Data section
*/
.section .data

/*
* batmansays ascii definitions
*/
.align 2
batman:

.ascii"\n"                                
.ascii"\n"                                
=======
/*****************************************************************************/

/*
* Data Section
*/

.section .data

/*
* Experimental - batmansays
*/
/*****************************************************************************/

.align 2
batman:
   
>>>>>>> 9e432eade76b3a487bf8d5169ffcbf3eb045ac36
.ascii"\n                     Tb.          Tb."                                
.ascii"\n                     :$$b.        $$$b."                              
.ascii"\n                     :$$$$b.      :$$$$b."                            
.ascii"\n                     :$$$$$$b     :$$$$$$b"                           
.ascii"\n                      $$$$$$$b     $$$$$$$b"                          
.ascii"\n                      $$$$$$$$b    :$$$$$$$b"                         
.ascii"\n                      :$$$$$$$$b---^$$$$$$$$b"                        
.ascii"\n                      :$$$$$$$$$b        ''^Tb"                       
.ascii"\n                       $$$$$$$$$$b    __...__`."                      
.ascii"\n                       $$$$$$$$$$$b.g$$$$$$$$$pb"                     
.ascii"\n                       $$$$$$$$$$$$$$$$$$$$$$$$$b"                    
.ascii"\n                       $$$$$$$$$$$$$$$$$$$$$$$$$$b"                   
.ascii"\n                       :$$$$$$$$$$$$$$$$$$$$$$$$$$;"                  
.ascii"\n                       :$$$$$$$$$$$$$^T$$$$$$$$$$P;"                  
.ascii"\n                       :$$$$$$$$$$$$$b  '^T$$$$P' :"                  
.ascii"\n                       :$$$$$$$$$$$$$$b._.g$$$$$p.db"
.ascii"\n                       :$$$$$$$$$$$$$$$$$$$$$$$$$$$$;"                
.ascii"\n                       :$$$$$$$$'''''T$$$$$$$$$$$$P';"                
.ascii"\n                       :$$$$$$$$       ''^^T$$$P^'  ;"                
.ascii"\n                       :$$$$$$$$    .'       `'     ;"                
.ascii"\n                       $$$$$$$$;   /                :"
.ascii"\n                       $$$$$$$$;           .----,    :"
.ascii"\n                       $$$$$$$$;         ,'          ;"
.ascii"\n                       $$$$$$$$$p.                   |"
.ascii"\n                      :$$$$$$$$$$$$p.                :"
.ascii"\n                      :$$$$$$$$$$$$$$$p.            .'"
.ascii"\n                      :$$$$$$$$$$$$$$$$$$p...___..--"
.ascii"\n                      $$$$$$$$$$$$$$$$$$$$$$$$$;"
.ascii"\n   .db.               $$$$$$$$$$$$$$$$$$$$$$$$$$"
.ascii"\n  d$$$$bp.            $$$$$$$$$$$$$$$$$$$$$$$$$$;"
.ascii"\n d$$$$$$$$$$pp..__..gg$$$$$$$$$$$$$$$$$$$$$$$$$$$"
.ascii"\nd$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$p._            .gp."
.ascii"\n$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$p._.ggp._.d$$$$b"
<<<<<<< HEAD
.ascii"\n©2014 chris.com"   
         
batmanEnd:


/*
* zeldasays ascii definitions
*/
.align 2
zelda:

.ascii"\n" 
.ascii"\n" 
.ascii"\n                          .--¯¯¯¯--."
.ascii"\n                      .''          '."
.ascii"\n                     /  _--_   _--_  }"
.ascii"\n                    / .'####\ /####'. }"
.ascii"\n                   | /###############l }"
.ascii"\n              ¯''..||####--#####--####l..''¯"
.ascii"\n                '._\|##/_'. \#/ .'_ \#|_.'"
.ascii"\n                    |#\ ' ¯.   .¯ ' /#|  |"
.ascii"\n                     \|\ ¯¯  /l ¯¯ /|/    l_"
.ascii"\n        _               '._ /  l_.'         '.    _"
.ascii"\n    .. | |l  /¯/         | /    l|''''..__ l¯l  /| | .."
.ascii"\n    l|'.l| l/¯/    ...''|-/      l|''...    l¯l/ |/.'|/"
.ascii"\n .-.-         |          /        l         |         -.-."
.ascii"\n '-'-     '   |         /__________l        |   '     -'-'"
.ascii"\n             '         /\          /l       '"
.ascii"\n                      /  \        /  l"
.ascii"\n                     /    \      /    l"
.ascii"\n                    /      \    /      l"
.ascii"\n                   /        \  /        l"
.ascii"\n                  /__________\/__________l"
.ascii"\n"    
        
zeldaEnd:

=======
.ascii"\n©2014 chris.com"


batmanEnd:
>>>>>>> 9e432eade76b3a487bf8d5169ffcbf3eb045ac36



/*
<<<<<<< HEAD
* ascii code string length for zelda ascii
*/
.align 2
zeldaStringLength:
   .int zeldaEnd-zelda

/*
* ascii code string length for batman ascii
*/
.align 2
batmanStringLength:
   .int batmanEnd-batman

/*
* ascii code string length for batman ascii
*/
.align 2
helpStringLength:
   .int helpEnd-help



/*
*
*/
.align 2
help: 

.ascii"\n|=============================================================|"                                
.ascii"\n|                            HELP                             |"                                
.ascii"\n|=============================================================|"                                   
.ascii"\n| This help menu is designed to explain some of the commands  |"                                
.ascii"\n| and functionality of this operating system. Below is a      |"                              
.ascii"\n| list, sorted by type, of commands, along with any parameters|"
.ascii"\n| they might take. Have fun in our OS and have a nice day :)  |"
.ascii"\n|=============================================================|"                       
.ascii"\n|                                                             |"                        
.ascii"\n|  GPIO Functions:  Turns on or off specified GPIO pins.      |"                        
.ascii"\n|  ===============  Note: This OS can access all GPIO pins.   |"                      
.ascii"\n|     Commands:                                               |"                
.ascii"\n|        gpioXX on    - Where XX is the pin number (0-53).    |"                 
.ascii"\n|        gpioXX off   - Where XX is the pin number (0-53).    |"                                  
.ascii"\n|           Example: 'gpio16 off' - Turns GPIO pin #16 off.   |"  
.ascii"\n|           Example: 'gpio1 on'   - Turns GPIO pin #1 on.     |"                
.ascii"\n|                                                             |"                  
.ascii"\n|  Echo Functions:  Echo's text back to the user, in a        |"
.ascii"\n|  ===============  variety of forms.                         |"                               
.ascii"\n|     Commands:                                               |"                
.ascii"\n|        echo         - Returns the text input by a user.     |"                
.ascii"\n|           Example: 'echo helloPi' - returns 'helloPi'.      |"
.ascii"\n|        batmansay    - Returns a string input as said by     |"
.ascii"\n|                       batman himself, includeing ascii art. |"
.ascii"\n|        zeldasay     - Returns a string input as said by     |"
.ascii"\n|                       zelda herself, including ascii art.   |"
.ascii"\n|           Example: batmansay helloPi' - returns 'helloPi'   |"
.ascii"\n|                                         along with some     |"
.ascii"\n|                                         radical ascii art.  |"
.ascii"\n|                                                             |"
.ascii"\n|  Help Function: Displays this help menu.                    |"
.ascii"\n|  ==============                                             |"
.ascii"\n|     Commands:                                               |" 
.ascii"\n|        help         - Displays this help menu               |" 
.ascii"\n|           Example: 'help' - returns 'helloPi'               |"
.ascii"\n|                                                             |"
.ascii"\n|  Reset and Clear Screen Coommands:  Resets or clears        |"
.ascii"\n|  =================================  the screen.             |"
.ascii"\n|     Commands:                                               |"
.ascii"\n|        cls          - Clears the screen.                    |"
.ascii"\n|        reset        - Resets the OS.                        |"
.ascii"\n|           Examples:  'cls' - Clears the screen.             |"
.ascii"\n|                      'reset' - Resets the OS.               |"
.ascii"\n|=============================================================|"   
        
helpEnd:

/*****************************************************************************/



/*****************************************************************************/



/*=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=*/
/*------------------------------------EOF------------------------------------*/
/*=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=*/
=======
* Experimental - Version 0.4
*/

.align 2
batmanStringLength:
.int batmanEnd-batman
>>>>>>> 9e432eade76b3a487bf8d5169ffcbf3eb045ac36
