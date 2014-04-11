/******************************************************************************
*  FileName: drawing.s
*  Authors: Stephen Chavez & Joshua Michael Waggoner
*  Date: April 7, 2014
*  Target: ARMv6 - Application Binary Interface (ABI) Compliant
*
*  Description: A file that holds information
*               pertaining to the drawing of 
*               lines and other things to screen.
*  
******************************************************************************/
	

/* 
* The foreColour is the colour which all our methods will draw shapes in.
* C++ Signature: short foreColour;
*/
.section .data				
.align 1				/*Align output? to 1 bit*/
foreColour:				
   .hword 0xFFFF			/*Insert the (16-bit) half-word 
					  value of the expression into the 
					  object file.*/



/* 
* graphicsAddress stores the address of the frame buffer info structure. 
* C++ Signature: FrameBuferDescription* graphicsAddress;
*/
.align 2				/*Align to 2 bytes*/
graphicsAddress:
   .int 0				/**/

/*****************************************************************************/

/* 
* SetForeColour changes the current drawing colour to the 16 bit colour in r0.
* C++ Signature: void SetForeColour(u16 colour);
*/
.section .text				
.globl SetForeColour			/*Make this a global function*/
SetForeColour:		
   cmp r0,#0x10000			/*Compare 0x10000 ro r0*/
   movhi pc,lr
   moveq pc,lr				

   ldr r1,=foreColour			/*Load foreColour into r1*/

   strh r0,[r1]				/*If #0x10000 > r0, store 0xFFFF
					  into r0*/
   mov pc,lr				/*Return*/

/*****************************************************************************/

/* 
* SetGraphicsAddress changes the current frame buffer information to 
* graphicsAddress;
* C++ Signature: void SetGraphicsAddress(FrameBuferDescription* value);
*/
.globl SetGraphicsAddress		/*Make this a global function*/
SetGraphicsAddress:
   ldr r1,=graphicsAddress		/*Load graphics address into r1*/
   str r0,[r1]				/*Store contents into r0 for return*/
   mov pc,lr				/*Return*/

/*****************************************************************************/

/*
* DrawPixel draws a single pixel to the screen at the point in (r0,r1).
* C++ Signature: void DrawPixel(u32x2 point);
*/
.globl DrawPixel			/*Make this a global method*/
DrawPixel:
/*
* 1) Load in the graphicsAddress.
*/
   px .req r0				/*Alias r0 as px*/
   py .req r1				/*Alias r1 as py*/

   addr .req r2				/*Alias r2 as addr*/
   ldr addr,=graphicsAddress		/*Load grpahicsAddress into addr*/
   ldr addr,[addr]			/*Load the address in graphicsAddress
					  into addr*/
/*
* 2) Check that the x and y co-ordinates of the pixel are less than 
*    the width and height.
*/
   height .req r3			/*Alias r3 as height*/
   ldr height,[addr,#4]			/*Load addr + 4 into height*/
   sub height,#1			/*Subtract 1 from height*/
   cmp py,height			/*Compare height to py*/		
   movhi pc,lr				/*If the y pixel height is larger than 						  height, return*/
   .unreq height			/*Unalias height*/

   width .req r3			/*Same as y, but for x...*/
   ldr width,[addr,#0]
   sub width,#1
   cmp px,width
   movhi pc,lr				/*...*/

/*
* 3) Compute the address of the pixel to write. 
     (hint: frameBufferAddress + (x + y * width) * pixel size)
*/
   ldr addr,[addr,#32]			/*Load addr + 32 into addr*/
   add width,#1				/*Add 1 to width*/
   mla px,py,width,px			/*Multiplies py and width, adds px
					  and puts the least significant 32
					  bits into px*/
   .unreq width				/*Unalias width*/
   .unreq py				/*Unalias py*/
   add addr, px,lsl #1			/*Add px, shifted left 1 bit to px,
					  and addr and store in addr*/
   .unreq px				/*Unalias px*/

/*
* 4) Load in the foreColour.
*/

   fore .req r3				/*Alias r3 as fore*/
   ldr fore,=foreColour			/*Load value from foreColour method
					  into fore*/
   ldrh fore,[fore]			/*Load halfword value in fore 
					  into fore*/

/*
* 5) Store it at the address.
*/
   strh fore,[addr]			/*Store halfword fore into address*/
   .unreq fore				/*Unalias fore*/
   .unreq addr				/*Unalias addr*/
   mov pc,lr				/*Return*/

/*****************************************************************************/

/*
The Bresenham line algorithm is an algorithm which determines which points 
in an n-dimensional raster should be plotted in order to form a close 
approximation to a straight line between two given points. It is commonly 
used to draw lines on a computer screen, as it uses only integer addition, subtraction and bit shifting, all of which are very cheap operations in 
standard computer architectures. It is one of the earliest algorithms 
developed in the field of computer graphics. A minor extension to the 
original algorithm also deals with drawing circles. 
*/

/* 
* DrawLine draws a line between two points given in (r0,r1) and (r2,r3).
* Uses Bresenham's Line Algortihm, explained above.
* C++ Signature: void DrawLine(u32x2 p1, u32x2 p2);
*/
.globl DrawLine				/*Make this a global method*/
DrawLine:
   push {r4,r5,r6,r7,r8,r9,r10,r11,r12,lr} /*Push registers onto the stack*/
   x0 .req r9				/*r9  is x0*/
   x1 .req r10				/*r10 is x1*/
   y0 .req r11				/*r11 is y0*/
   y1 .req r12				/*r12 is y1*/

   mov x0,r0				/*Move r0 to x0 (r9)*/
   mov x1,r2				/*Move r2 to x1 (r10)*/
   mov y0,r1				/*Move r1 to y0 (r11)*/
   mov y1,r3				/*Move r3 to y1 (r12)*/

   dx .req r4				/*r4 is aliased as dx*/
   dyn .req r5 				/* Note that we only ever use -deltay, 
					   so I store its negative for speed. 
					   (hence dyn) */
   sx .req r6				/*Alias r6 as sx*/
   sy .req r7				/*Alias r7 as sy*/
   err .req r8				/*Alias r8 as err*/

   cmp x0,x1				/*Compare x0 to x1*/
   subgt dx,x0,x1			/*If > subtract x1 from x0, 
	  				  and store the answer in dx*/
   movgt sx,#-1				/*If >, put #-1 in sx*/
   suble dx,x1,x0			/*If <=, subtract x0 from x1.
					  and store in dx*/
   movle sx,#1				/*If <=, move #1 into sx*/

   cmp y0,y1				/*Same as above, but for y...*/
   subgt dyn,y1,y0
   movgt sy,#-1
   suble dyn,y0,y1
   movle sy,#1				/*...*/

   add err,dx,dyn
   add x1,sx
   add y1,sy

   pixelLoop$:
      teq x0,x1
      teqne y0,y1
      popeq {r4,r5,r6,r7,r8,r9,r10,r11,r12,pc}

      mov r0,x0
      mov r1,y0
         bl DrawPixel

      cmp dyn, err,lsl #1
      addle err,dyn
      addle x0,sx

      cmp dx, err,lsl #1
      addge err,dx
      addge y0,sy

         b pixelLoop$

   .unreq x0				/*Unalias to be thorough*/
   .unreq x1
   .unreq y0
   .unreq y1
   .unreq dx
   .unreq dyn
   .unreq sx
   .unreq sy
   .unreq err

/*****************************************************************************/
