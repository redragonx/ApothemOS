/*****************************************************************************
*  FileName:main.s
*  Authors: Stephen Chavez & Joshua Michael Waggoner
*  Source: Baking Pi OS Tutorial - by Alex Chadwick
*  Date: Mar 26, 2014
*  Target: ARMv6 - Application Binary Interface (ABI) Compliant
*
*  Description: main.s is the main class of our program
*  
*****************************************************************************/

/*
* .globl is a directive to our assembler, that tells it to export this symbol
* to the elf file. Convention dictates that the symbol _start is used for the 
* entry point, so this all has the net effect of setting the entry point here.
* Ultimately, this is useless as the elf itself is not used in the final 
* result, and so the entry point really doesn't matter, but it aids clarity,
* allows simulators to run the elf, and also stops us getting a linker warning
* about having no entry point. 
*/
.section .init
.globl _start
_start:

/*
* Branch to the actual main code.
*/
b main

/*
* This command tells the assembler to put this code with the rest.
*/
.section .text

/*
* main is what we shall call our main operating system method. It never 
* returns, and takes no parameters.
* C++ Signature: void main(void)
*/
main:

/*
* Set the stack point to 0x8000.
*/
	mov sp,#0x8000

/* 
* Setup the screen.
*/

	mov r0,#1024
	mov r1,#768
	mov r2,#16
	bl InitialiseFrameBuffer

/* 
* Check for a failed frame buffer.
*/
	teq r0,#0
	bne noError$
		
	mov r0,#16
	mov r1,#1
	bl SetGpioFunction

	mov r0,#16
	mov r1,#0
	bl SetGpio


	error$:
		b error$

	noError$:

	fbInfoAddr .req r4
	mov fbInfoAddr,r0

/*
* Let our drawing method know where we are drawing to.
*/
	bl SetGraphicsAddress

	bl UsbInitialise

	mov r0,#16
	mov r1,#0
	bl SetGpio
	
reset$:
	mov sp,#0x8000
	bl TerminalClear

	ldr r0,=welcome
	ldr r1,=welcomeStringLength
	bl Print


loop$:		
	ldr r0,=prompt
	mov r1,#promptEnd-prompt
	bl Print

	ldr r0,=command
	mov r1,#commandEnd-command
	bl ReadLine

	teq r0,#0
	beq loopContinue$

	mov r4,r0
	
	ldr r0,=white
	mov r1,#whiteEnd-white
	bl Print

	ldr r5,=command
	ldr r6,=commandTable
	
	ldr r7,[r6,#0]
	ldr r9,[r6,#4]
	commandLoop$:
		ldr r8,[r6,#8]
		sub r1,r8,r7

		cmp r1,r4
		bgt commandLoopContinue$

		mov r0,#0	
		commandName$:
			ldrb r2,[r5,r0]
			ldrb r3,[r7,r0]
			teq r2,r3			
			bne commandLoopContinue$
			add r0,#1
			teq r0,r1
			bne commandName$

		ldrb r2,[r5,r0]
		teq r2,#0
		teqne r2,#' '
		bne commandLoopContinue$

		mov r0,r5
		mov r1,r4
		mov lr,pc
		mov pc,r9
		b loopContinue$

	commandLoopContinue$:
		add r6,#8
		mov r7,r8
		ldr r9,[r6,#4]
		teq r9,#0
		bne commandLoop$	

	ldr r0,=commandUnknown
	mov r1,#commandUnknownEnd-commandUnknown
	ldr r2,=formatBuffer
	ldr r3,=command
	bl FormatString

	mov r1,r0
	ldr r0,=formatBuffer
	bl Print

loopContinue$:
	bl TerminalDisplay
	b loop$


                             /* Need help here --> */


/*---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------*/


echo:
	cmp r1,#5
	movle pc,lr

	add r0,#5
	sub r1,#5 
	b Print

ok:
	teq r1,#5
	beq okOn$
	teq r1,#6
	beq okOff$
	mov pc,lr

	okOn$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'n'
		movne pc,lr
		mov r1,#0
		b okAct$

	okOff$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'f'
		ldreqb r2,[r0,#5]
		teqeq r2,#'f'
		movne pc,lr
		mov r1,#1

	okAct$:
		mov r0,#16
		b SetGpio

/*-----------------------------------------------------------------------------
*
*                 Beginning of specific GPIO on/off commands
*                 __________________________________________
*
* (see http://www.hobbytronics.co.uk/raspberry-pi-gpio-pinout for more info.) 
*
*    Here is a chart of relevant GPIO Pins. For our naming
*    conventions, we are going with the actual GPIO pin number
*    and not the number in the assembly diagram (the inner numbers):
*
*    | O   3.3V    |1 |  |2 |    5V     O |
*    | O           |3 |  |4 |    5V     O |
*    | O           |5 |  |6 |   Ground  O |
*    | O   GPIO4   |7 |  |8 |           O |
*    | O   Ground  |9 |  |10|           O |
*    | O   GPIO17  |11|  |12|   GPIO18  O |
*    | O   GPIO27  |13|  |14|   Ground  O |
*    | O   GPIO22  |15|  |16|   GPIO23  O |
*    | O   3.3V    |17|  |18|   GPIO24  O |
*    | O           |19|  |20|   Ground  O |
*    | O           |21|  |22|   GPIO25  O |
*    | O           |23|  |24|           O |
*    | O  Ground   |25|  |26|           O |
*
*-----------------------------------------------------------------------------/

/* 
* Left Side of GPIO pin output assembly chart above:
*/

/*
* GPIO 4 (7 in GPIO pin output assembly chart above )
*/
gpio4:
        teq r1,#5
	beq gpio4On$
	teq r1,#6
	beq gpio4Off$
	mov pc,lr

	gpio4On$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'n'
		movne pc,lr
		mov r1,#0
		b gpio4Act$

	gpio4Off$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'f'
		ldreqb r2,[r0,#5]
		teqeq r2,#'f'
		movne pc,lr
		mov r1,#1

	gpio4Act$:
		mov r0,#4
		b SetGpio


/*****************************************************************************/


/*
* GPIO17 (11 in GPIO pin output assembly chart above )
*/

gpio17:
     teq r1,#5
     beq gpio17On$
     teq r1,#6
     beq gpio17Off$
     mov pc,lr

     gpio17On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio17Act$

     gpio17Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio17Act$:
          mov r0,#17
          b SetGpio

/*****************************************************************************/


/*
* GPIO 27 (13 in GPIO pin output assembly chart above )
*/
gpio27:
     teq r1,#5
     beq gpio27On$
     teq r1,#6
     beq gpio27Off$
     mov pc,lr

     gpio27On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio27Act$

     gpio27Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio27Act$:
          mov r0,#27
          b SetGpio

gpio22:
     teq r1,#5
     beq gpio22On$
     teq r1,#6
     beq gpio22Off$
     mov pc,lr

     gpio22On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio22Act$

     gpio22Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio22Act$:
          mov r0,#22
          b SetGpio

/*****************************************************************************/

/*
* Right side in GPIO pin output assembly chart above:
*/

/*
* GPIO18 (24 in GPIO pin output assembly chart above )
*/
gpio18:
     teq r1,#5
     beq gpio18On$
     teq r1,#6
     beq gpio18Off$
     mov pc,lr

     gpio18On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio18Act$

     gpio18Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio18Act$:
          mov r0,#18
          b SetGpio

/*****************************************************************************/

/*
* GPIO23 (16 in GPIO pin output assembly chart above )
*/
gpio23:
     teq r1,#5
     beq gpio23On$
     teq r1,#6
     beq gpio23Off$
     mov pc,lr

     gpio23On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio23Act$

     gpio23Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio23Act$:
          mov r0,#23
          b SetGpio

/*****************************************************************************/

/*
* GPIO24 (18 in GPIO pin output assembly chart above )
*/

gpio24: 
     teq r1,#5
     beq gpio24On$
     teq r1,#6
     beq gpio24Off$
     mov pc,lr

     gpio24On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio24Act$

     gpio24Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio24Act$:
          mov r0,#24
          b SetGpio

/*****************************************************************************/

/*
* GPIO25 (22 in GPIO pin output assembly chart above )
*/
gpio25:
     teq r1,#5
     beq gpio25On$
     teq r1,#6
     beq gpio25Off$
     mov pc,lr

     gpio25On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio25Act$

     gpio25Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio25Act$:
          mov r0,#25
          b SetGpio

/*
* End of GPIO functions as of now. Vers 0.3
*/

/****************************************************************************/
/**********************************Intro Screen******************************/
/****************************************************************************/

.section .data
.align 2
welcome:
  .ascii ".__________________________________________________."
  .ascii "\n||////////////////////////////////////////////////||"
  .ascii "\n||//By Stephen @redragonx/////////////////////////||"
  .ascii "\n||////////////and/////////////////////////////////||"
  .ascii "\n||/////////////////Josh @rabbitfighter81//////////||    _____"
  .ascii "\n||////////////////////////////////////////////////||   /     |"
  .ascii "\n!__________________________________________________!  |      |"
  .ascii "\n|   __ __ __ __ __ __ __ __ __ __ /|\ Super Pi 1.0 |  |      |"
  .ascii "\n|__/_//_//_//_//_//_//_//_//_//_/____________--____|  |  .---|---."
  .ascii "\n| ______________________________________________   |  |  |   |   |"
  .ascii "\n| [][][][][][][][][][][][][][][__] [_][_] [][][][] |  |  |---'---|"
  .ascii "\n| [_][][][][][][][][][][][][]| |[] [][][] [][][][] |  |  |       |"
  .ascii "\n| [__][][][][][][][][][][][][__|[] [][][] [][][][] |  |  |       |"
  .ascii "\n| [_][][][][][][][][][][][][_]            [][][]|| |  |  |  /|\  |"
  .ascii "\n|    [_][________________][_]             [__][]LI |  |   \_____/"
  .ascii "\n|__________________________________________________|  |"
  .ascii "\n                                                  \___/"
  .ascii "\n"
  .ascii "\nSuperPi OS is a simple operating system written in arm from"
  .ascii "\nusing the Baking Pi tutorials written by Alex Chadwick as a basis"
  .ascii "\nand then embellishing upon it making this an experimental OS"
  .ascii "\n"
  .ascii "\nBaking Pi: Operating Systems Development by Alex Chadwick is"
  .ascii "\nlicensed under a Creative Commons Attribution-ShareAlike 3.0"
  .ascii "\nUnported License."
  .ascii "\n"
  .ascii "\nThis program is free software: you can redistribute it and or"
  .ascii "\nmodify it under the terms of the GNU General Public License as"
  .ascii "\npublished by the Free Software Foundation, either version 3 of"
  .ascii "\nthe License, or (at your option) any later version."
  .ascii "\n"
  .ascii "\nThis program is distributed in the hope that it will be useful,"
  .ascii "\nbut WITHOUT ANY WARRANTY; without even the implied warranty of"
  .ascii "\nMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the"
  .ascii "\nGNU General Public License for more details."
  .ascii "\n"
  .ascii "\nYou should have received a copy of the GNU General Public License"
  .ascii "\nwith this program. If not, see <http://www.gnu.org/licenses/>."
  .ascii "\n"
  .ascii "\nFor a list of commands, simply type 'help' into the terminal"
  .ascii "\n"

welcomeEnd:


/****************************************************************************/
/******************************End New Intro Screen**************************/
/****************************************************************************/


.align 2
prompt:
	.ascii "\n\033f> \0332"
promptEnd:
.align 2
white:
	.ascii "\033f"
whiteEnd:
.align 2
command:
	.rept 128
		.byte 0
	.endr
commandEnd:
.byte 0
.align 2
commandUnknown:
	.ascii "\0339\Command `\0332%s\0339' was not recognised.\n"
commandUnknownEnd:
.align 2
formatBuffer:
	.rept 256
	.byte 0
	.endr
formatEnd:

/*****************************************************************************/
/************************Command Strings definitions**************************/
/*****************************************************************************/
.align 2
commandStringEcho: .ascii "echo"
commandStringReset: .ascii "reset"
commandStringOk: .ascii "ok"
commandStringCls: .ascii "cls"

/*
*Begin - Experimental section. Proceed with caution. Vers 0.3
*/
commandStringGpio4:  .ascii "gpio4"
commandStringGpio17: .ascii "gpio17"
commandStringGpio27: .ascii "gpio27"
commandStringGpio22: .ascii "gpio22"
commandStringGpio18: .ascii "gpio18"
commandStringGpio23: .ascii "gpio23"
commandStringGpio24: .ascii "gpio24"
commandStringGpio25: .ascii "gpio25"

commandStringEnd:


/*****************************************************************************/
/*********************End Command Strings definitions*************************/
/*****************************************************************************/


/*****************************************************************************/
/*******************************Command Table*********************************/
/*****************************************************************************/
.align 2
commandTable:
.int commandStringEcho, echo
.int commandStringReset, reset$
.int commandStringOk, ok
.int commandStringCls, TerminalClear

/*
* Begin - Experimental section. Added Vers 0.3
*/
.int commandStringGpio4,  gpio4
.int commandStringGpio17, gpio17
.int commandStringGpio27, gpio27
.int commandStringGpio22, gpio22
.int commandStringGpio18, gpio18
.int commandStringGpio23, gpio23
.int commandStringGpio24, gpio24
.int commandStringGpio25, gpio25
.int commandStringEnd, 0

/*
* End - Experimental section. Added Vers 0.3
*/

/*****************************************************************************/
/****************************End Command Table********************************/
/*****************************************************************************/

.align 2
welcomeStringLength:
.int welcomeEnd-welcome
