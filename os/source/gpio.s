/******************************************************************************
*  FileName: gpio.s
*  Authors: Stephen Chavez & Joshua Michael Waggoner
*  Date: Mar 26, 2014
*  Target: ARMv6 - Embedded Application Binary Interface (EABI) Compliant
*
*  Description: A file that holds information
*               pertaining to access and manipulation of
*               GPIO pins in a reusable manner.
*  
******************************************************************************/

/********************Explaination of r0, r1 designations***********************
* r0 will be  for designating the pin we wish to target (0-53)
* r1 will be  for designating the function of the pin we wish to target (0-7)
*******************************************************************************

/*msg to assembler to make the label GetGpioAddress accessible to all files.*/
.globl GetGpioAddress 

/*
* GetGpioAddress returns the base addr of the GPIO region as a 
* physical address in register r0.
* C++ Signature: void* GetGpioAddress()
*/

GetGpioAddress:			/*Label*/
	ldr r0, =0x20200000 	/*Load GPIO controller access address in r0*/ 
	mov pc,lr		/*Move contents of link register into pc*/

/*****************************************************************************/

/*
* SetGpioFunction sets the function of the GPIO register addressed 
* by r0 to the low 3 bits of r1.
*/

/*msg to assembler to make the label SetGPIOFunction accessible to all files*/
.globl SetGpioFunction

/* 
* GetGpioAddress returns the base address of the GPIO region as a physical 
* address in register r0.
* C++ Signature: void* GetGpioAddress()
*/
SetGpioFunction:	/*Label*/

   pinNum  .req r0
   pinFunc .req r1

      cmp pinNum,#53    /*checks if value in r0 is less than 53*/
      cmpls pinFunc,#7	/*checks if value in r0 is less than 7*/
      movhi pc,lr       /*Moves lr into pc if value in cspr is less than #53*/

      push {lr}		/*Puts lr on the top of the stack*/

/*
* The next three statements just makes pinNum an alias for r2 instead of r0,
* and brings it's value with it. 
*/
      mov r2,pinNum           /*Move pinNum into R2*/
      .unreq pinNum	      /*Unalias r2*/
      pinNum .req r2          /*Alias pinNum to r2*/

      bl GetGpioAddress       /*Loads GPIO address into r0*/
      gpioAddr .req r0	      /*Alias ro as gpioAddr*/

/*
* This simple loop code compares the pin number to 9. If it is higher 
* than 9, it subtracts 10 from the pin number, and adds 4 to the GPIO 
* Controller address then runs the check again. This is how we find the 
* GPIO controller address we are looking for.
*/
      functionLoop$:
         cmp pinNum,#9 		/*Compare pin number to 9*/
         subhi pinNum,#10	/*Sub 10 from pin number*/
         addhi gpioAddr,#4 	/*Adds 4 to the GPIO Controller address*/
         bhi functionLoop$

      add pinNum, pinNum,lsl #1 /*Multiplication by 3 in disguise*/
      lsl pinFunc,pinNum	/*Shift pinFunc by value in pinNum*/
      mask .req r3		/*Alias r3 as mask*/
      mov mask, #7              /*r3 = 111 in binary*/

      lsl mask, pinNum          /*
				* r3 (mask) = 11100..00 where the 111 is in 
				* the same position as the function in 
				* r1 (pinFunc).
				*/
     
      .unreq pinNum		/*Unalias pinNum*/

      mvn mask, mask  		/*
				* r3 = 11..1100011..11 where the 000 is in 
				* the same poisiont as the function in r1 
				*/
        
      oldFunc .req r2 		/*Alias oldFunc to r2. It's the old PinNum*/
      ldr oldFunc,[gpioAddr]    /*Load what's in gpioAddr into oldFunc*/
      and oldFunc, mask		/*and r3 and r2*/

      orr pinFunc, oldFunc	/*orr r1 and r2*/
      .unreq oldFunc		/*Unaliass oldFunc*/
	

      str pinFunc,[gpioAddr]	/*Store pinFunc in [gpioAddr] for return*/
      .unreq pinFunc		/*Customary Unaliasing*/
      .unreq gpioAddr		/*...*/
      pop {pc}			/*Pop the stack to restore registers*/

/*****************************************************************************/

/* 
* SetGpio sets the GPIO pin addressed by register r0 high if r1 != 0 and low
* otherwise. 
*/

/*msg to assembler to make the label SetGPIOFunction accessible to all files*/
.globl SetGpio

SetGpio:
   pinNum .req r0	/*Alias pinNum for r0 */
   pinVal .req r1       /*Alias piVal  for r1 */

      cmp pinNum,#53	/*Compare pinNum to #52 I.E. See if we have a valid #*/
      movhi pc,lr	/*Move link register into program counter*/
      push {lr}	        /*Push link register on stack*/
      mov r2,pinNum	/*Move pinNumber to r2*/

   .unreq pinNum	/*Unalias pinNum*/
   pinNum .req r2	/*Alias pinNum to r2*/

      bl GetGpioAddress	/*Method to store GpioAdress in r0*/

   gpioAddr .req r0	/*Alias gpioAddr for r0*/

      pinBank .req r3	      /*Alias for pinBank*/
      lsr pinBank,pinNum,#5   /*lsl pin# by 5 -> store in pinBank. div by 32*/
      lsl pinBank,#2	      /*Multiply this by 4*/

      /****************Note on the above two lines of code:******************
      
	You may wonder if we could just shift it right by 3 places, as we 		went right then left. This won't work , as some of the answer may 	 	 have been rounded when we did ÷ 32 which may not be if we just ÷ 8.
       
      ***********************************************************************/

     /*
      * This means if we add 28 we get the address for turning the pin on,
      * and if we add 40 we get the address for turning the pin off.
      */
      add gpioAddr,pinBank	/*Add pin bank value to gpio addr*/

      .unreq pinBank		/*Unalias pinbank*/

      and pinNum,#31		/*and pinNum with 11111(base2)*/
      setBit .req r3		/*Alias r3 as setBit*/
      mov setBit,#1		/*Move 1 into setBit*/
      lsl setBit,pinNum	        /*lsl setBit by pinNum*/

      .unreq pinNum		/*We don't need pinNum anymore, so unalias it*/

      teq pinVal,#0		/*Test if pinVal is equal to 0*/

      .unreq pinVal		/*Unalias pinVal to be polite*/

      streq setBit,[gpioAddr,#40]   /*If teq = true  turn pin on*/
      strne setBit,[gpioAddr,#28]   /*If teq = false turn pin off*/

      .unreq setBit		    /*Unalias setBit*/
      .unreq gpioAddr		    /*Unalias gpioAddr*/

      pop {pc}		 /*
			 * return by popping the pc, which sets it to the 
			 * value that we stored when we pushed the link 			 * register.
			 */			

/*****************************************************************************/
