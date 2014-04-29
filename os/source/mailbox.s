/*****************************************************************************
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
*****************************************************************************/

/*                        Table: Mailbox Addresses
                          ========================

Address	  Bytes	 Name           Description                 Read / Write
-------   -----  ----           -----------                 ------------
2000B880  4	 Read	        Receiving mail.             R
2000B890  4	 Poll           Receive without retrieving. R
2000B894  4	 Sender         Sender information.         R
2000B898  4	 Status         Information.                R
2000B89C  4      Configuration	Settings.                   RW
2000B8A0  4      Write          Sending mail.               W

*/

/****************************************************************************/

/*
* GetMailboxBase returns the base address of the mailbox region as a physical
* address in register r0.
* C++ Signature: void* GetMailboxBase()
*/
.global GetMailboxBase
GetMailboxBase: 
	ldr r0,=0x2000B880
	mov pc,lr

/*
* MailboxRead returns the current value in the mailbox addressed to a channel
* given in the low 4 bits of r0, as the top 28 bits of r0.
* C++ Signature: u32 MailboxRead(u8 channel)
*/
.global MailboxRead
MailboxRead: 
	and r3,r0,#0xf
	mov r2,lr
	bl GetMailboxBase
	mov lr,r2
	
	rightmail$:
		wait1$: 
			ldr r2,[r0,#24]
			tst r2,#0x40000000
			bne wait1$
			
		ldr r1,[r0,#0]
		and r2,r1,#0xf
		teq r2,r3
		bne rightmail$

	and r0,r1,#0xfffffff0
	mov pc,lr

/*
* MailboxWrite writes the value given in the top 28 bits of r0 to the channel
* given in the low 4 bits of r1.
* C++ Signature: void MailboxWrite(u32 value, u8 channel)
*/
.global MailboxWrite
MailboxWrite: 
	and r2,r1,#0xf
	and r1,r0,#0xfffffff0
	orr r1,r2
	mov r2,lr
	bl GetMailboxBase
	mov lr,r2

	wait2$: 
		ldr r2,[r0,#24]
		tst r2,#0x80000000
		bne wait2$

	str r1,[r0,#32]
	mov pc,lr


/*=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=*/
/*------------------------------------EOF------------------------------------*/
/*=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=*/
