/******************************************************************************
*  FileName: mailbox.s
*  Authors: Stephen Chavez & Joshua Michael Waggoner
*  Source: Cambridge University Baking Pi tutorials by Alex Chadwick
*  Date: April 6, 2014
*  Target: ARMv6 - Application Binary Interface (ABI) Compliant
*
*  Description: The CPU and GPU communicate on the Raspberry Pi by what is 
*  called the 'mailbox'. Each can deposit mail for the other, which will be 
*  collected at some future point and then dealt with. We shall use the mailbox
*  to ask the graphics processor for an address. The address will be a location
*  to which we can write the pixel colour information for the screen, called a 
*  frame buffer, and the graphics card will regularly check this location, and 
*  update the pixels on the screen appropriately.
*
******************************************************************************/

/*                        Table: Mailbox Addresses
                          ========================

Address	  Bytes	 Name	         Description	        	Read / Write
-------   -----   ----            -----------     		------------
2000B880  4	 Read	         Receiving mail.	 	R
2000B890  4	 Poll	 	 Receive without retrieving.	R
2000B894  4	 Sender	 	 Sender information.	 	R
2000B898  4	 Status	 	 Information.	 		R
2000B89C  4	 Configuration	 Settings.	 		RW
2000B8A0  4	 Write	 	 Sending mail.	 		W

*/

/*****************************************************************************/


.globl GetMailboxBase	/*Make this a global function*/

GetMailboxBase:		/*Method to get the address of the mailbox region.*/

ldr r0,=0x2000B880	/*This is the beginning of the mailbox region*/
mov pc,lr		/*Return by moving link register into pc*/

/*****************************************************************************/

/*
-------------------------------------------------------------------------------
 1) Our input will be what to write (r0), and what mailbox to write it to (r1). 
    We must validate this is by checking it is a real mailbox, and that the low 
    4 bits of the value are 0. Never forget to validate inputs.
 2) Use GetMailboxBase to retrieve the address.
 3) Read from the Status field.
 4) Check the top bit is 0. If not, go back to 3.
 5) Combine the value to write and the channel.
 6) Write to the Write.
-------------------------------------------------------------------------------
*/

/* 
* 1) See description above
*/

.globl MailboxWrite	/*Make this a global function*/

MailboxWrite: 		/*Method to implement sending procedure.*/

   tst r0,#0b1111	/*tst reg,#val computes 'and reg,#val' and compares 
			  the result with 0. In this case it checks that the 
			  lowest 4 bits of the input in r0 are all 0.*/

   movne pc,lr		/*Lower bits not equal to zero, not valid, return*/
   cmp r1,#15		/*Compare r1 to #15 */
   movhi pc,lr		/*If r1 is higher than 15, return*/

/*
* 2) This code ensures we will not overwrite our value, or link register and 
* calls GetMailboxBase.
*/

   channel .req r1		/*Alias r1 as channel*/
   value .req r2		/*Alias r2 as value*/
   mov value,r0		/*Move r0 into value (r2)*/
   push {lr}		/*Push the link register onto the stack?*/
      bl GetMailboxBase	/*Get the base address of the mailbox region*/

   mailbox .req r0		/*This will return to r0, and be alised as 					  'mailbox'*/
/*
* 3) This code loads in the current status.
*/

      wait1$:			/*Subroutine to Check the top bit is 0. If not, 
			  	  go back to 3.*/

         status .req r3		/*Alias r3 as status*/

         ldr status,[mailbox,#0x18]	/*Load status with mailbox addr base +
				  	 #0x18 (24) which is the information 
				  	 register*/
/*
* 4) This code checks that the top bit of the status field is 0, and loops 
* back to 3. if it is not.
*/



         tst status,#0x80000000	/*Performs logical 'and' on #val and status
				  and compares the result to zero*/
         .unreq status		/*Unalias to be thorough*/
            bne wait1$		/*if ne, loop back*/

/*
* 5) This code combines the channel and value together.
*/


         add value,channel	/*Adds value and channel and stores in value*/
        .unreq channel		/*Unalias channel*/	

/*
* 6) This code stores the result to the write field.
*/

         str value,[mailbox,#0x20]	/*Store value in mailbox + 0x20*/
         .unreq value			/*Unalias value*/
         .unreq mailbox			/*Unalias mailbox*/
         pop {pc}			/*Pop pc and end method*/

/*****************************************************************************/

/*
-------------------------------------------------------------------------------
  The code for MailboxRead is quite similar.

  1) Our input will be what mailbox to read from (r0). We must validate this 
     by checking it is a real mailbox. Never forget to validate inputs.

  2) Use GetMailboxBase to retrieve the address.
  3) Read from the Status field.
  4) Check the 30th bit is 0. If not, go back to 3.
  5) Read from the Read field.
  6) Check the mailbox is the one we want, if not go back to 3.
  7) Return the result.
-------------------------------------------------------------------------------
*/

/*
* 1) This achieves our validation on r0.
*/

.globl MailboxRead		/*Make this a global function*/

MailboxRead: 			/*Method to implement reading from mailbox*/

   cmp r0,#15			/*Validate r0 is less than 15*/
   movhi pc,lr			/*If not, return*/

/*
* 2) This code ensures we will not overwrite our value, or link 
*    register and calls GetMailboxBase.
*/

   channel .req r1		/*Alias r1 as channel*/
   mov channel,r0		/*movee r0 into channel*/
   push {lr}			/*Push link register onto stack*/
      bl GetMailboxBase		/*Get mailbox base*/
   mailbox .req r0		/*Alias r0 as mailbox*/

/*
* 3) This code loads in the current status.
*/

   rightmail$:				/*Beginning of rightmail loop*/
      wait2$:				/*beginning of wait2 loop*/
         status .req r2			/*Alias r2 as status*/
         ldr status,[mailbox,#0x18]     /*Load status with the mailbox address
					  plus 0x18 (24)*/

/*
* 4) This code checks that the 30th bit of the status field is 0, and loops 
*    back to 3. if it is not.
*/

         tst status,#0x40000000		/*Performs logical and operation on
					  #val and status and compares the 
					  result to 0*/
         .unreq status			/*Unalias status to clean up*/
            bne wait2$			/*If not valid, branch back*/

/*
* 5) This code reads the next item from the mailbox.
*/

         mail .req r2			/*Alias r2 as mail*/
         ldr mail,[mailbox,#0]		/*Read next item from mailbox*/

/*
* 6) This code checks that the channel of the mail we just read is the one 
*    we were supplied. If not it loops back to 3.
*/

         inchan .req r3			/*Alias r3 as inchan*/
         and inchan,mail,#0b1111	/*Make sure last four bits are*/
         teq inchan,channel		/*Test to see that inchan and channel
					  are equal*/
         .unreq inchan			/*Unalias inchan*/
            bne rightmail$		/*If not equal, branch to beginning
					  of loop*/
         .unreq mailbox			/*Unalias mailbox*/
         .unreq channel			/*Unalias channel*/

/*
* 7) This code moves the answer (the top 28 bits of mail) to r0.
*/

         and r0,mail,#0xfffffff0	/*and mail and #val and store in r0
				 	  for return*/
         .unreq mail			/*Unalias mail*/
         pop {pc}			/*Return from method*/

/*****************************************************************************/



