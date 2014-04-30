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
* .global is a directive to our assembler, that tells it to export this symbol
* to the elf file. Convention dictates that the symbol _start is used for the 
* entry point, so this all has the net effect of setting the entry point here.
* Ultimately, this is useless as the elf itself is not used in the final 
* result, and so the entry point really doesn't matter, but it aids clarity,
* allows simulators to run the elf, and also stops us getting a linker warning
* about having no entry point. 
*/
.section .init
.global _start
_start:

/*
* Branch to the actual main code.
*/
b main


/****************************************************************************/
/**********************************Text Section******************************/
/****************************************************************************/

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

/*---------------------------------------------------------------------------*/

/*
* echo returns a sting back to the user
*/
echo:
   cmp r1,#5            /*Compare r1 and 5*/
   movle pc,lr          /*if the whle string is null, return*/

   add r0,#5            /**/
   sub r1,#5            
   b Print

/*****************************************************************************/

/*
* help prints the help menu
*/
help:
   b PrintHelp

/*****************************************************************************/

/*
* batmansay returns a sting back to the user, as said by batman himself
*/
batmansay:
   
   cmp r1,#10          /* Compare r1 and 10 */
   movle pc,lr         /* If the whle string is null, return */
   add r0,#10          /* Add 10 to r0 */
   sub r1,#10          /* Subtract 10 from r1 */             
   b PrintBatman       /* Branch to the print batmansays screen*/


/*****************************************************************************/

/*
* zeldasay returns a sting back to the user, as said by zelda herself
*/
zeldasay:
   
   cmp r1,#9          /* Compare r1 and 10 */
   movle pc,lr        /* If the whle string is null, return */
   add r0,#9          /* Add 10 to r0 */
   sub r1,#9          /* Subtract 10 from r1 */             
   b PrintZelda       /* Branch to the print zeldasays screen*/



/*****************************************************************************/


/****************************************************************************/
/**********************************Data Section******************************/
/****************************************************************************/


/*
* Data section
*/
.section .data

/****************************************************************************/
/**********************************Intro Screen******************************/
/****************************************************************************/

.align 2
welcome:
  .ascii ".__________________________________________________."
  .ascii "\n||////////////////////////////////////////////////||"
  .ascii "\n||//By Stephen @redragonx/////////////////////////||"
  .ascii "\n||////////////and/////////////////////////////////||"
  .ascii "\n||/////////////////Josh @rabbitfighter81//////////||    _____"
  .ascii "\n||//on github.com/////////////////////////////////||   /     |"
  .ascii "\n!__________________________________________________!  |      |"
  .ascii "\n|   __ __ __ __ __ __ __ __ __ _/|\ Apothem OS 1.0 |  |      |"
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
  .ascii "\nApothem OS is a simple operating system written in arm from"
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

/*****************************************************************************/

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
commandStringEcho:       .ascii      "echo"
commandStringHelp:       .ascii      "help"
commandStringBatmansay:  .ascii      "batmansay"
commandStringZeldasay:   .ascii      "zeldasay"
commandStringReset:      .ascii      "reset"
commandStringOk:         .ascii      "ok"
commandStringCls:        .ascii      "cls"
commandStringGpio0:  .ascii "gpio0"
commandStringGpio1:  .ascii "gpio1"
commandStringGpio2:  .ascii "gpio2"
commandStringGpio3:  .ascii "gpio3"
commandStringGpio4:  .ascii "gpio4"
commandStringGpio5:  .ascii "gpio5"
commandStringGpio6:  .ascii "gpio6"
commandStringGpio7:  .ascii "gpio7"
commandStringGpio8:  .ascii "gpio8"
commandStringGpio9:  .ascii "gpio9"
commandStringGpio10: .ascii "gpio10"
commandStringGpio11: .ascii "gpio11"
commandStringGpio12: .ascii "gpio12"
commandStringGpio13: .ascii "gpio13"
commandStringGpio14: .ascii "gpio14"
commandStringGpio15: .ascii "gpio15"
commandStringGpio16: .ascii "gpio16"
commandStringGpio17: .ascii "gpio17"
commandStringGpio18: .ascii "gpio18"
commandStringGpio19: .ascii "gpio19"
commandStringGpio20: .ascii "gpio20"
commandStringGpio21: .ascii "gpio21"
commandStringGpio22: .ascii "gpio22"
commandStringGpio23: .ascii "gpio23"
commandStringGpio24: .ascii "gpio24"
commandStringGpio25: .ascii "gpio25"
commandStringGpio26: .ascii "gpio26"
commandStringGpio27: .ascii "gpio27"
commandStringGpio28: .ascii "gpio28"
commandStringGpio29: .ascii "gpio29"
commandStringGpio30: .ascii "gpio30"
commandStringGpio31: .ascii "gpio31"
commandStringGpio32: .ascii "gpio32"
commandStringGpio33: .ascii "gpio33"
commandStringGpio34: .ascii "gpio34"
commandStringGpio35: .ascii "gpio35"
commandStringGpio36: .ascii "gpio36"
commandStringGpio37: .ascii "gpio37"
commandStringGpio38: .ascii "gpio38"
commandStringGpio39: .ascii "gpio39"
commandStringGpio40: .ascii "gpio40"
commandStringGpio41: .ascii "gpio41"
commandStringGpio42: .ascii "gpio42"
commandStringGpio43: .ascii "gpio43"
commandStringGpio44: .ascii "gpio44"
commandStringGpio45: .ascii "gpio45"
commandStringGpio46: .ascii "gpio46"
commandStringGpio47: .ascii "gpio47"
commandStringGpio48: .ascii "gpio48"
commandStringGpio49: .ascii "gpio49"
commandStringGpio50: .ascii "gpio50"
commandStringGpio51: .ascii "gpio51"
commandStringGpio52: .ascii "gpio52"
commandStringGpio53: .ascii "gpio53"
commandStringEnd:

/*********************End Command Strings definitions*************************/



/*****************************************************************************/
/*******************************Command Table*********************************/
/*****************************************************************************/
.align 2
commandTable:
.int commandStringEcho,        echo
.int commandStringHelp,        help
.int commandStringBatmansay,   batmansay
.int commandStringZeldasay,    zeldasay
.int commandStringReset,       reset$
.int commandStringOk,          ok
.int commandStringCls,         TerminalClear
/*GPIO*/
.int commandStringGpio0,  gpio0
.int commandStringGpio1,  gpio1
.int commandStringGpio2,  gpio2
.int commandStringGpio3,  gpio3
.int commandStringGpio4,  gpio4
.int commandStringGpio5,  gpio4
.int commandStringGpio6,  gpio7
.int commandStringGpio7,  gpio4
.int commandStringGpio8,  gpio8
.int commandStringGpio9,  gpio9
.int commandStringGpio10, gpio10
.int commandStringGpio11, gpio11
.int commandStringGpio12, gpio12
.int commandStringGpio13, gpio13
.int commandStringGpio14, gpio14
.int commandStringGpio15, gpio15
.int commandStringGpio16, gpio16
.int commandStringGpio17, gpio17
.int commandStringGpio18, gpio18
.int commandStringGpio19, gpio19
.int commandStringGpio20, gpio20
.int commandStringGpio21, gpio21
.int commandStringGpio22, gpio22
.int commandStringGpio23, gpio23
.int commandStringGpio24, gpio24
.int commandStringGpio25, gpio25
.int commandStringGpio26, gpio26
.int commandStringGpio27, gpio27
.int commandStringGpio28, gpio28
.int commandStringGpio29, gpio29
.int commandStringGpio30, gpio30
.int commandStringGpio31, gpio31
.int commandStringGpio32, gpio32
.int commandStringGpio33, gpio33
.int commandStringGpio34, gpio34
.int commandStringGpio35, gpio35
.int commandStringGpio36, gpio36
.int commandStringGpio37, gpio37
.int commandStringGpio38, gpio38
.int commandStringGpio39, gpio39
.int commandStringGpio40, gpio40
.int commandStringGpio41, gpio41
.int commandStringGpio42, gpio42
.int commandStringGpio43, gpio43
.int commandStringGpio44, gpio44
.int commandStringGpio45, gpio45
.int commandStringGpio46, gpio46
.int commandStringGpio47, gpio47
.int commandStringGpio48, gpio48
.int commandStringGpio49, gpio49
.int commandStringGpio50, gpio50
.int commandStringGpio51, gpio51
.int commandStringGpio52, gpio52
.int commandStringGpio53, gpio53
.int commandStringEnd, 0

/****************************End Command Table********************************/

/*
* Welcome string length definition
*/
.align 2
welcomeStringLength:
.int welcomeEnd-welcome



/*=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=*/
/*------------------------------------EOF------------------------------------*/
/*=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=*/
