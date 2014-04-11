/******************************************************************************
*  FileName: random.s
*  Authors: Stephen Chavez & Joshua Michael Waggoner
*  Date: April 7, 2014
*  Target: ARMv6 - Application Binary Interface (ABI) Compliant
*
*  Description: A file that holds information
*               pertaining to the random number generator.
*  
******************************************************************************/

/* 
* Random is a function with an input of the last number it generated, and an 
* output of the next number in a pseduo random number sequence.
* C++ Signature: u32 Random(u32 lastValue);
*/
.globl Random				/*Make this a global method*/
Random:
   xnm .req r0				/*Alias r0 as xnm*/
   a .req r1				/*Alias r1 as a*/

   mov a,#0xef00			/*Move #0xef00*/
   mul a,xnm				/*Multiply a and xnm and store in a*/
   mul a,xnm				/*Again*/
   add a,xnm				/*Add xnm to a and store in a*/
   .unreq xnm				/*Unalias xnm*/
   add r0,a,#73				/*Add a and #73 and put in r0*/

   .unreq a				/*Unalias a*/
   mov pc,lr				/*Return*/

/*****************************************************************************/
