/******************************************************************************
*  FileName:systemTimer.s
*  Authors: Stephen Chavez & Joshua Michael Waggoner
*  Source: Baking Pi OS Tutorial - by Alex Chadwick
*  Date: Mar 26, 2014
*  Target: ARMv6 - Application Binary Interface (ABI) Compliant
*
*  Description: systemTime.s contains the code that interacts with the system 
*               timer.
*  
*******************************************************************************/

 /*
 * The system timer runs at 1MHz, and just counts always. Thus we can deduce
 * timings by measuring the difference between two readings.
 */

 /*
 * GetSystemTimerBase returns the base address of the System Timer region as a
 * physical address in register r0.
 * C++ Signature: void* GetSystemTimerBase()
 */

.globl GetSystemTimerBase /*Make this a global function*/

GetSystemTimerBase: 

   ldr r0,=0x20003000 /*Register used to control and clear timer channel*/
   mov pc,lr /*Move the link register into program counter to return*/

/*****************************************************************************/

 /*
 * GetTimeStamp gets the current timestamp of the system timer, and returns it
 * in registers r0 and r1, with r1 being the most significant 32 bits.
 * C++ Signature: u64 GetTimeStamp()
 */

.globl GetTimeStamp	/*Make this a global function*/

GetTimeStamp:

   push {lr} /*Push link register to be able to restore registers*/
   bl GetSystemTimerBase /*Get the timer's base adress*/
   ldrd r0,r1,[r0,#4] /*0x20003004 A counter that increments at 1MHz.*/
   pop {pc} /*Pop the program counter and restore registers*/

 /*
 * Wait waits at least a specified number of microseconds before returning.
 * The duration to wait is given in r0.
 * C++ Signature: void Wait(u32 delayInMicroSeconds)
 */

.globl Wait	/*Make this a global function*/

Wait:

	delay .req r2	/*Alias r2 as "delay"*/
	mov delay,r0    /*Move delay into r2 because we know r1,r0 are used*/
	push {lr}	/*Push link register because we will be braching*/
	bl GetTimeStamp /*Gets the timestamp in r0 and r1 and restores lr*/
	start .req r3	/*Alias r3 as start*/
	mov start,r0	/*Move lower four bytes to "start"*/

	 /*
	 * Next we need to compute the difference between the current counter 		 * value and the reading we just took, and then keep doing so until the 	 * gap between them is at least the size of delay.
         */

	loop$:
	   bl GetTimeStamp	      /*Get the timestamp in r0, r1*/
	   elapsed .req r1	      /*Alias r1 as "elapsed"*/
	   sub elapsed,r0,start       /*Start time - elapsed time*/
	   cmp elapsed,delay	      /*Compare delay to elapsed*/
	   .unreq elapsed	      /*Unalias elapsed*/
	      bls loop$		      /*If elapsed is less than delay, loop*/
		
	.unreq delay	/*Unalias delay*/
	.unreq start	/*Unalias start*/
	pop {pc}	/*Return by popping pc*/

/*****************************************************************************/
