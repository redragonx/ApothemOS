
/******************************************************************************
*  FileName: main.s
*  Authors: Stephen Chavez & Joshua Michael Waggoner
*  Source: Cambridge University Baking Pi tutorials by Alex Chadwick
*  Date: Mar 26, 2014
*  Target: ARMv6 - Application Binary Interface (ABI) Compliant
*
*  Description: A sample assembly code implementation of the ok03 operating  
*  system, that simply turns the OK LED on and off repeatedly, but now using 
*  the EABI standard, and procedure calls. 
*
*  main.s is likely to change more than anything...
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

/* Set the stack point to 0x8000.*/

mov sp,#0x8000

 /* 
 * Use our new SetGpioFunction function to set the function of GPIO 
 * port 16 (OK LED) to 001 (binary)
 */

mov r0,#16
mov r1,#1

   bl SetGpioFunction

/*New-For S.O.S. Pattern*/

 /*
 *This code loads the pattern into r4, and loads 0 into r5. r5 will be our 
 *sequence position, so we can keep track of how much of the pattern we have 
 *displayed.
 */

ptrn .req r4
ldr ptrn,=pattern
ldr ptrn,[ptrn]
seq .req r5
mov seq,#0

/*Beginning of loop*/
loop$:
 
 /* 
 * Use our new SetGpio makefunction to set GPIO 16 base on the current bit
 * in the pattern causing the LED to turn on if the pattern contains 0, 
 * and off if it contains 1.
 */

mov r0,#16
mov r1,#1
lsl r1,seq
and r1,ptrn

   bl SetGpio

 /* 
 * We wait for 0.25s using our wait method.
 */

ldr r0,=250000

   bl Wait

 /*
 * Loop over this process forevermore, incrementing the sequence counter.
 * When it reaches 32, its bit pattern becomes 100000, and so anding it with 
 * 11111 causes it to return to 0, but has no effect on all patterns less than
 * 32.
 */

add seq,#1
and seq,#0b11111

   b loop$

/*****************************************************************************/
/**********************************Data Section*******************************/
/*****************************************************************************/

.section .data  /*Data section*/

.align 2 	/*.align 2 which means that this data will definitely be 
                   placed at an address which is a multiple of 2*/

		/*It is really important to do this, because the ldr 
		  instruction we used to read memory only works at 
		  addresses that are multiples of 4.*/	

pattern:
.int 0b11111111101010100010001000101010 /*will be placed into the output*/

/*****************************************************************************/
