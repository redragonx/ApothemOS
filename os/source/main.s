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
      bne noError$		/*If so, branch to no error*/

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

/*
  This is quite a large chunk of code, and has a loop within a loop within a 
  loop. To help get your head around the looping, I've indented the code which 
  is looped, depending on which loop it is in. This is quite common in most 
  high level programming languages, and the assembler simply ignores the tabs. 
  We see here that I load in the frame buffer address from the frame buffer 
  information structure, and then loop over every row, then every pixel on the 
  row. At each pixel, I use an strh (store half word) command to store the 
  current colour, then increment the address we're writing to. After drawing 
  each row, we increment the colour that we are drawing. After drawing the 
  full screen, we branch back to the beginning.
*/
   render$:				/*Render subroutine*/
      fbAddr .req r3			/*Alias r3 as fbAddr*/
      ldr fbAddr,[fbInfoAddr,#32]	/*load what's in fbInfoAddr plus 32
					  into fbAddr*/

      color .req r0			/*Alias r0 as color*/
      y .req r1				/*Alias r1 as y*/
      mov y,#768			/*Move 68 into y*/

      drawRow$:				/*Draw row subroutine*/
         x .req r2			/*Alias r2 as x*/
         mov x,#1024			/*Move 1024 into x*/

            drawPixel$:			/*drawPixel subroutine*/
               strh color,[fbAddr]	/*store what's in fbAddr's address in
				  	  color as unsigned Halfword 
					  (Zero extend to 32 bits on loads.)*/
               add fbAddr,#2		/*Add 2 to fbAddr*/
               sub x,#1			/*Subtract 1 from x*/
               teq x,#0			/*If x is not at 0, repeat*/
               bne drawPixel$		/*If != branch back to drawPixel*/

            sub y,#1			/*Subtract 1 from y*/
            add color,#1		/*Add 1 to color*/
            teq y,#0			/*If x is not at 0, repeat*/
            bne drawRow$		/*If != branch back to drawRow*/

         b render$			/*Branch back to render*/

   .unreq fbAddr			/*Unalias fbAddr*/
   .unreq fbInfoAddr			/*Unalias fbInfoAddr*/

/*****************************************************************************/
