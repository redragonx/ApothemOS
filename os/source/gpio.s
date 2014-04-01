/******************************************************************************
*  FileName:gpio.s
*  Authors: Stephen Chavez & Joshua Michael Waggoner
*  Date: Mar 26, 2014
*  Target: ARMv6 - Application Binary Interface (ABI) Compliant
*
*  Description: A file that holds information
*  pertaining to access and manipulation of
*  GPIO pins in a reusable manner.
*  
*******************************************************************************/

/****************Explaination of r0, r1 designations****************************
*r0 will be  for designating the pin we wish to target (0-53)
*r1 will be  for designating the function of the pin we wish to target (0-7)
*******************************************************************************


/*-------------------*/
/*-----Function------*/
/*-------------------*/



/*msg to assembler to make the label GetGpioAddress accessible to all files.*/
.globl GetGpioAddress 

/* NEW
* GetGpioAddress returns the base addr of the GPIO region as a physical address
* in register r0.
* C++ Signature: void* GetGpioAddress()
*/

GetGpioAddress:		/*Label*/
	ldr r0, =0x20200000 	/*Load GPIO controller access address in r0*/ 
	mov pc,lr		/*Move contents of link register into pc*/



/******************************************************************************/
		

/*-------------------*/
/*-----Function------*/
/*-------------------*/

/*SetGpioFunction sets the function of the GPIO register addressed by r0 to the
* low 3 bits of r1.*/


/*msg to assembler to make the label SetGPIOFunction accessible to all files*/
.globl SetGpioFunction


/* NEW
* GetGpioAddress returns the base address of the GPIO region as a physical 
* address in register r0.
* C++ Signature: void* GetGpioAddress()
*/
SetGpioFunction:	/*Label*/
   pinNum  .req r0
   pinFunc .req r1
      cmp pinNum,#53   /*checks if value in r0 is less than 53: Will Skip */
      cmpls pinFunc,#7	/*checks if value in r0 is less than 7*/
      movhi pc,lr   /*Executes if value stored in cspr is less than #53*/

      push {lr}		/*Puts lr on the top of the stack*/
      mov r2,pinNum     /*Move pinNum into R2*/
      .unreq pinNum
      pinNum .req r2    /*Alias pinNum to r2*/
      bl GetGpioAddress       /*Loads GPIO address into r0*/
      gpioAddr .req r0

	/*This simple loop code compares the pin number to 9. If it is higher 		* than 9, it subtracts 10 from the pin number, and adds 4 to the GPIO 		* Controller address then runs the check again.*/
      functionLoop$:
         cmp pinNum,#9 /*compare pin number to 9*/
         subhi pinNum,#10/*sub 10 from pin number*/
         addhi gpioAddr,#4 /*adds 4 to the GPIO Controller address*/
         bhi functionLoop$

      add pinNum, pinNum,lsl #1 /*multiplication by 3 in disguise*/
      lsl pinFunc,pinNum	/*shift  r1 (function code) by the amt in r2*/
      mask .req r3
      mov mask, #7            /* r3 = 111 in binary */

      lsl mask, pinNum /* r3 = 11100..00 where the 111 is in the same position
			  * as the function in r1 */
      .unreq pinNum
      mvn mask, mask  /* r3 = 11..1100011..11 where the 000 is in the same 				 * poisiont as the function in r1 */
        
      oldFunc .req r2 /*Alias oldFunc to r2*/
      ldr oldFunc,[gpioAddr]
      and oldFunc, mask

      orr pinFunc, oldFunc
      .unreq oldFunc
	

      str pinFunc,[gpioAddr]	/*Store what's in the address in r0 in r1*/
      .unreq pinFunc
      .unreq gpioAddr
      pop {pc}		/*Pop the stack to restore registers*/

/******************************************************************************/
	
/*-------------------*/
/*-----Function------*/
/*-------------------*/

/* SetGpio sets the GPIO pin addressed by register r0 high if r1 != 0 and low
*  otherwise. */

.globl SetGpio
SetGpio:
   pinNum .req r0	/*Alias pinNum for r0 */
   pinVal .req r1  /*Alias piVal  for r1 */

      cmp pinNum,#53	/*Compare pinNum to #52 I.E. See if we have a valid #*/
      movhi pc,lr	/*Move link register into program counter*/
      push {lr}	/*Push link register on stack*/
      mov r2,pinNum	/*Move pinNumber to r2*/
   .unreq pinNum	/*Unalias pinNum*/
   pinNum .req r2	/*Alias pinNum to r2*/

      bl GetGpioAddress	/*Method to store GpioAdress in r0*/

   gpioAddr .req r0	/*Alias gpioAddr for r0*/

      pinBank .req r3		/*Alias for pinBank*/
      lsr pinBank,pinNum,#5   /*lsl pin# by 5 -> store in pinBank. div by 32*/
      lsl pinBank,#2		/*Multiply this by 4*/

      /****************Note on the above two lines of code:******************/
      /*You may wonder if we could just shift it right by 3 places, as we 		went right then left. This won't work , as some of the answer may 	 	 have been rounded when we did ÷ 32 which may not be if we just ÷ 8.*/
      /**********************************************************************/

      /*This means if we add 28 we get the address for turning the pin on, 		and if we add 40 we get the address for turning the pin off.*/
      add gpioAddr,pinBank	/*Add pin bank value to gpio addr*/

      .unreq pinBank		/*Unalias pinbank*/

      and pinNum,#31		/*and pinNum with 11111(base2)*/
      setBit .req r3		/*Alias r3 as setBit*/
      mov setBit,#1		/*Move 1 into setBit*/
      lsl setBit,pinNum	/*lsl setBit by pinNum*/
      .unreq pinNum		/*We don't need pin num anymore, so unalias it*/

      teq pinVal,#0		/*Test if inVal is equal to 0*/

      .unreq pinVal
      streq setBit,[gpioAddr,#40] /*If teq = true  turn pin on*/
      strne setBit,[gpioAddr,#28] /*If teq = false turn pin off*/
      .unreq setBit		    /*Unalias setBit to be proper*/
      .unreq gpioAddr
      pop {pc}/*return by popping the pc, which sets it to the value that we 			 *stored when we pushed the link register.*/			

/******************************************************************************/


