/******************************************************************************
*  FileName: main.s
*  Authors: Stephen Chavez & Joshua Michael Waggoner
*  Source: Cambridge University Baking Pi tutorials by Alex Chadwick
*  Date: Mar 26, 2014
*  Target: ARMv6 - Application Binary Interface (ABI) Compliant
*
*  Description: An implimentation of the screen for project
*
******************************************************************************/

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

/* Branch to the actual main code.*/
b main

/*This command tells the assembler to put this code with the rest.*/
.section .text

 /* 
 * main is what we shall call our main operating system method. It never 
 * returns, and takes no parameters.
 * C++ Signature: void main(void)
 */

main:

   mov sp,#0x8000		/*Set the stack point to 0x8000.*/

   mov r0,#1024 		/*Set width, both virtual and physical*/
   mov r1,#768			/*Set width, both virtual and physical*/
   mov r2,#16			/*Set bitDepth*/
   bl InitialiseFrameBuffer	/*Call InitializeFrameBuffer with 
				  these arguments*/

   teq r0,#0			/*Test to see if we have no error*/
   bne noError$			/*If so, branch to no error*/

   mov r0,#16			/*If not, move 16 into r0*/
   mov r1,#1			/*Move 1 into r1*/
   bl SetGpioFunction	/*set the GPIO function to turn on the OK LED*/
  
   mov r0,#16			
   mov r1,#0
   bl SetGpio

   error$:				/*Error loop*/
      b error$

   noError$:				/*Start here for no error*/
      fbInfoAddr .req r4		/*Alias r4 as fbInfoAddr*/
      mov fbInfoAddr,r0			/*move r0 into fbInfoAddr*/

/* NEW
* Let our drawing method know where we are drawing to.
*/
	bl SetGraphicsAddress
	
	lastRandom .req r7
	lastX .req r8
	lastY .req r9
	colour .req r10
	x .req r5
	y .req r6
	mov lastRandom,#0
	mov lastX,#0
	mov r9,#0
	mov r10,#0

   render$:
	mov r0,lastRandom
	bl Random
	mov x,r0
	bl Random
	mov y,r0
	mov lastRandom,r0

	mov r0,colour
	add colour,#1
	lsl colour,#16
	lsr colour,#16
	bl SetForeColour
		
	mov r0,lastX
	mov r1,lastY
	lsr r2,x,#22
	lsr r3,y,#22

	cmp r3,#768
	bhs render$
	
	mov lastX,r2
	mov lastY,r3
	 
	bl DrawLine

	b render$

	.unreq x
	.unreq y
	.unreq lastRandom
	.unreq lastX
	.unreq lastY
	.unreq colour

/*****************************************************************************/


