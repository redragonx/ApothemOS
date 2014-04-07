/******************************************************************************
*  FileName:framebuffer.s
*  Authors: Stephen Chavez & Joshua Michael Waggoner
*  Source: Baking Pi OS Tutorial - by Alex Chadwick
*  Date: Mar 26, 2014
*  Target: ARMv6 - Application Binary Interface (ABI) Compliant
*
*  Description: framebuffer.s contains data about our frame 
*               buffer implementation
*  
*******************************************************************************/

.section .data 			/*Defines this as a data section*/

.align 12			/*this ensures the lowest 4 bits of 
				  the address of the next line are 0. Thus, 
				  we know for sure that FrameBufferInfo will 
				  be placed at an address we can send to the 
				  graphics processor, as our mailbox only sends
                                  values with the low 4 bits all 0.*/

.globl FrameBufferInfo 		/*Makes this a global function*/

FrameBufferInfo:		/*Start of FrameBufferInfo*/

.int 1024 	/* #0 Physical Width */
.int 768 	/* #4 Physical Height */
.int 1024 	/* #8 Virtual Width */
.int 768 	/* #12 Virtual Height */
.int 0 	/* #16 GPU - Pitch */
.int 16 	/* #20 Bit Depth */
.int 0 	/* #24 X */
.int 0 	/* #28 Y */
.int 0 	/* #32 GPU - Pointer */
.int 0 	/* #36 GPU - Size */

/* 
* InitialiseFrameBuffer creates a frame buffer of width and height specified in
* r0 and r1, and bit depth specified in r2, and returns a FrameBuferDescription
* which contains information about the frame buffer returned. This procedure 
* blocks until a frame buffer can be created, and so is inapropriate on real 
* time systems. While blocking, this procedure causes the OK LED to flash.
* If the frame buffer cannot be created, this procedure returns 0.
* 
* C++ Signature: FrameBuferDescription* InitialiseFrameBuffer(u32 width,
*		u32 height, u32 bitDepth)
*/

.section .text				/*Define as text section*/

.globl InitialiseFrameBuffer		/*Make this a global method*/
InitialiseFrameBuffer:

/*
* 1) Validate our inputs.
*/
	width .req r0			/*Alias r0 as width*/
	height .req r1			/*Alias r1 as height*/
	bitDepth .req r2		/*Alias r2 as bitDepth*/
	cmp width,#4096			/*Subtracts # from width*/
	cmpls height,#4096		/*Check height*/
	cmpls bitDepth,#32		/*Check bitDepth is valid*/
	result .req r0			/*Alias r0 as result as */
	movhi result,#0			/*We return 0 to indicate failure.*/
	movhi pc,lr			/*Return, else move on... */

/*
* 2) This code simply writes into our frame buffer structure defined above. 
*    I also take the opportunity to push r4 and the link register onto the
*    stack, as we will need to store the frame buffer address in r4.
*/

	push {r4,lr}			/*push r4 and lr onto the stack*/
	fbInfoAddr .req r4		/*Alias r4 as fbInfoAddr*/	
	ldr fbInfoAddr,=FrameBufferInfo /*Load frame buffer info in r4*/
	str width,[r4,#0]		/*Write width into r4's lowest 4 bits*/
	str height,[r4,#4]		/*Write height into r4's second
					  lowest 4 bits*/
	str width,[r4,#8]		/*Write virtual width into r4's third 
					  lowest 4 bits*/
	str height,[r4,#12]		/*Write virtual width into r4's fourth 						  lowest 4 bits*/
	str bitDepth,[r4,#20]		/*Write bitDepth into r4's fifth 
				          lowest 4 bits*/
	.unreq width			/*Unalias width*/
	.unreq height			/*Unalias height*/
	.unreq bitDepth			/*Unalias bitDepth*/

/*
* 3) The inputs to the MailboxWrite method are the value to write in r0, 
*    and the channel to write to in r1.
*/

	mov r0,fbInfoAddr		/*Move the frame buffer info into r0*/
	add r0,#0x40000000		/*By adding 0x40000000, we tell the GPU
					  not to use its cache for these 
					  writes, which ensures we will be 
			   	  	  able to see the change.*/
	mov r1,#1			/*move 1 into r1*/
	   bl MailboxWrite		/*Write to mailbox the frame buffer 
					  info and the channel and branch 
					  back*/
/*
* 4) The inputs to the MailboxRead method is the channel to write to in r0, 
*    and the output is the value read.
*/	

	mov r0,#1			/*Move 1 into r0*/		
	   bl MailboxRead		/*Branch to MailboxRead and back*/
/*
* 5) This code checks if the result of the MailboxRead method is 0, and 
*    returns 0 if not.
*/	
	
	teq result,#0			/*See if result is 0*/
	movne result,#0			/*Return 0 if not*/
	popne {r4,pc}			/*Pop r4 and pc if not*/

/*
* 5) This code finishes off and returns the frame buffer info address.
*/

	mov result,fbInfoAddr		/*Move frame buffer info into r0*/
	pop {r4,pc}			/*Pop r4 and pc*/
	.unreq result			/*Unalias result*/
	.unreq fbInfoAddr		/*Unalias fbInfoAddr*/

/*****************************************************************************/
