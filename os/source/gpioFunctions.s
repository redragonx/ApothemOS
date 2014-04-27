/******************************************************************************
*  FileName:gpioFunctions.s
*  Authors: Stephen Chavez & Joshua Michael Waggoner
*  Source: Baking Pi OS Tutorial - by Alex Chadwick
*  Date: Mar 26, 2014
*  Target: ARMv6 - Application Binary Interface (ABI) Compliant
*
*  Description: gpioFunctions.s contains the code that interacts with the system 
*               gpio pins.
*  
*******************************************************************************/

/*-----------------------------------------------------------------------------
*
*                 Beginning of specific gpio on/off commands
*                 __________________________________________
*
* (see http://www.hobbytronics.co.uk/raspberry-pi-gpio-pinout for more info.) 
*
*    Here is a chart of relevant gpio Pins. For our naming
*    conventions, we are going with the actual gpio pin number
*    and not the number in the assembly diagram (the inner numbers):
*
*    | O   3.3V    |1 |  |2 |    5V     O |
*    | O           |3 |  |4 |    5V     O |
*    | O           |5 |  |6 |   Ground  O |
*    | O   gpio4   |7 |  |8 |           O |
*    | O   Ground  |9 |  |10|           O |
*    | O   gpio17  |11|  |12|   gpio18  O |
*    | O   gpio27  |13|  |14|   Ground  O |
*    | O   gpio22  |15|  |16|   gpio23  O |
*    | O   3.3V    |17|  |18|   gpio24  O |
*    | O           |19|  |20|   Ground  O |
*    | O           |21|  |22|   gpio25  O |
*    | O           |23|  |24|           O |
*    | O  Ground   |25|  |26|           O |
*
*-----------------------------------------------------------------------------//*-----------------------------------------------------------------------------
*
*                 Beginning of specific gpio on/off commands
*                 __________________________________________
*
* (see http://www.hobbytronics.co.uk/raspberry-pi-gpio-pinout for more info.) 
*
*    Here is a chart of relevant gpio Pins. For our naming
*    conventions, we are going with the actual gpio pin number
*    and not the number in the assembly diagram (the inner numbers):
*
*    | O   3.3V    |1 |  |2 |    5V     O |
*    | O           |3 |  |4 |    5V     O |
*    | O           |5 |  |6 |   Ground  O |
*    | O   gpio4   |7 |  |8 |           O |
*    | O   Ground  |9 |  |10|           O |
*    | O   gpio17  |11|  |12|   gpio18  O |
*    | O   gpio27  |13|  |14|   Ground  O |
*    | O   gpio22  |15|  |16|   gpio23  O |
*    | O   3.3V    |17|  |18|   gpio24  O |
*    | O           |19|  |20|   Ground  O |
*    | O           |21|  |22|   gpio25  O |
*    | O           |23|  |24|           O |
*    | O  Ground   |25|  |26|           O |
*
*-----------------------------------------------------------------------------/





/*****************************************************************************/
/**************Beginning of gpio functions as of now. Vers 0.3****************/
/*****************************************************************************/

.section .text


/*
* ok turns the ok light on or off
*/
.global ok
ok:
	teq r1,#5
	beq okOn$
	teq r1,#6
	beq okOff$
	mov pc,lr

	okOn$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'n'
		movne pc,lr
		mov r1,#0
		b okAct$

	okOff$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'f'
		ldreqb r2,[r0,#5]
		teqeq r2,#'f'
		movne pc,lr
		mov r1,#1

	okAct$:
		mov r0,#16
		b SetGpio

/*****************************************************************************/

/*
* gpio 0
*/
.globl gpio0
gpio0:
        teq r1,#5
	beq gpio0On$
	teq r1,#6
	beq gpio0Off$
	mov pc,lr

	gpio0On$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'n'
		movne pc,lr
		mov r1,#0
		b gpio0Act$

	gpio0Off$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'f'
		ldreqb r2,[r0,#5]
		teqeq r2,#'f'
		movne pc,lr
		mov r1,#1

	gpio0Act$:
		mov r0,#0
		b SetGpio


/*****************************************************************************/

/*
* gpio 1
*/
.globl gpio1
gpio1:
        teq r1,#5
	beq gpio1On$
	teq r1,#6
	beq gpio1Off$
	mov pc,lr

	gpio1On$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'n'
		movne pc,lr
		mov r1,#0
		b gpio1Act$

	gpio1Off$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'f'
		ldreqb r2,[r0,#5]
		teqeq r2,#'f'
		movne pc,lr
		mov r1,#1

	gpio1Act$:
		mov r0,#1
		bl SetGpio


/*****************************************************************************/

/*
* gpio 2 
*/
.globl gpio2
gpio2:
        teq r1,#5
	beq gpio2On$
	teq r1,#6
	beq gpio2Off$
	mov pc,lr

	gpio2On$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'n'
		movne pc,lr
		mov r1,#0
		b gpio2Act$

	gpio2Off$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'f'
		ldreqb r2,[r0,#5]
		teqeq r2,#'f'
		movne pc,lr
		mov r1,#1

	gpio2Act$:
		mov r0,#2
		b SetGpio


/*****************************************************************************/

/*
* gpio 3 
*/
.global gpio3
gpio3:
        teq r1,#5
	beq gpio3On$
	teq r1,#6
	beq gpio3Off$
	mov pc,lr

	gpio3On$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'n'
		movne pc,lr
		mov r1,#0
		b gpio3Act$

	gpio3Off$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'f'
		ldreqb r2,[r0,#5]
		teqeq r2,#'f'
		movne pc,lr
		mov r1,#1

	gpio3Act$:
		mov r0,#3
		b SetGpio


/****************************************************************************/

/*
* gpio 4 
*/
.global gpio4
gpio4:
        teq r1,#5
	beq gpio4On$
	teq r1,#6
	beq gpio4Off$
	mov pc,lr

	gpio4On$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'n'
		movne pc,lr
		mov r1,#0
		b gpio4Act$

	gpio4Off$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'f'
		ldreqb r2,[r0,#5]
		teqeq r2,#'f'
		movne pc,lr
		mov r1,#1

	gpio4Act$:
		mov r0,#4
		b SetGpio


/*****************************************************************************/

/*****************************************************************************/

/*
* gpio 5 
*/
.global gpio5
gpio5:
        teq r1,#5
	beq gpio5On$
	teq r1,#6
	beq gpio5Off$
	mov pc,lr

	gpio5On$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'n'
		movne pc,lr
		mov r1,#0
		b gpio5Act$

	gpio5Off$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'f'
		ldreqb r2,[r0,#5]
		teqeq r2,#'f'
		movne pc,lr
		mov r1,#1

	gpio5Act$:
		mov r0,#5
		b SetGpio


/*****************************************************************************/

/*
/*
* gpio 6 
*/
.global gpio6
gpio6:
        teq r1,#5
	beq gpio6On$
	teq r1,#6
	beq gpio6Off$
	mov pc,lr

	gpio6On$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'n'
		movne pc,lr
		mov r1,#0
		b gpio6Act$

	gpio6Off$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'f'
		ldreqb r2,[r0,#5]
		teqeq r2,#'f'
		movne pc,lr
		mov r1,#1

	gpio6Act$:
		mov r0,#6
		b SetGpio


/*****************************************************************************/

/*
/*
* gpio 7 
*/
.global gpio7
gpio7:
        teq r1,#5
	beq gpio7On$
	teq r1,#6
	beq gpio7Off$
	mov pc,lr

	gpio7On$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'n'
		movne pc,lr
		mov r1,#0
		b gpio7Act$

	gpio7Off$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'f'
		ldreqb r2,[r0,#5]
		teqeq r2,#'f'
		movne pc,lr
		mov r1,#1

	gpio7Act$:
		mov r0,#7
		b SetGpio


/*****************************************************************************/

/*
* gpio 8 
*/
.global gpio8
gpio8:
        teq r1,#5
	beq gpio8On$
	teq r1,#6
	beq gpio8Off$
	mov pc,lr

	gpio8On$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'n'
		movne pc,lr
		mov r1,#0
		b gpio8Act$

	gpio8Off$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'f'
		ldreqb r2,[r0,#5]
		teqeq r2,#'f'
		movne pc,lr
		mov r1,#1

	gpio8Act$:
		mov r0,#8
		b SetGpio


/*****************************************************************************/

/*
* gpio 9 
*/
.global gpio9
gpio9:
        teq r1,#5
	beq gpio9On$
	teq r1,#6
	beq gpio9Off$
	mov pc,lr

	gpio9On$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'n'
		movne pc,lr
		mov r1,#0
		b gpio9Act$

	gpio9Off$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'f'
		ldreqb r2,[r0,#5]
		teqeq r2,#'f'
		movne pc,lr
		mov r1,#1

	gpio9Act$:
		mov r0,#9
		b SetGpio


/*****************************************************************************/

/*
* gpio 10 
*/
.global gpio10
gpio10:
        teq r1,#5
	beq gpio10On$
	teq r1,#6
	beq gpio10Off$
	mov pc,lr

	gpio10On$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'n'
		movne pc,lr
		mov r1,#0
		b gpio10Act$

	gpio10Off$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'f'
		ldreqb r2,[r0,#5]
		teqeq r2,#'f'
		movne pc,lr
		mov r1,#1

	gpio10Act$:
		mov r0,#10
		b SetGpio


/*****************************************************************************/

/*
* gpio 11 
*/
.global gpio11
gpio11:
        teq r1,#5
	beq gpio11On$
	teq r1,#6
	beq gpio11Off$
	mov pc,lr

	gpio11On$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'n'
		movne pc,lr
		mov r1,#0
		b gpio11Act$

	gpio11Off$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'f'
		ldreqb r2,[r0,#5]
		teqeq r2,#'f'
		movne pc,lr
		mov r1,#1

	gpio11Act$:
		mov r0,#11
		b SetGpio


/*****************************************************************************/

/*
* gpio 12 
*/
.global gpio12
gpio12:
        teq r1,#5
	beq gpio12On$
	teq r1,#6
	beq gpio12Off$
	mov pc,lr

	gpio12On$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'n'
		movne pc,lr
		mov r1,#0
		b gpio12Act$

	gpio12Off$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'f'
		ldreqb r2,[r0,#5]
		teqeq r2,#'f'
		movne pc,lr
		mov r1,#1

	gpio12Act$:
		mov r0,#12
		b SetGpio


/*****************************************************************************/

/*
* gpio 13 
*/
.global gpio13
gpio13:
        teq r1,#5
	beq gpio13On$
	teq r1,#6
	beq gpio13Off$
	mov pc,lr

	gpio13On$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'n'
		movne pc,lr
		mov r1,#0
		b gpio13Act$

	gpio13Off$:
		ldrb r2,[r0,#3]
		teq r2,#'o'
		ldreqb r2,[r0,#4]
		teqeq r2,#'f'
		ldreqb r2,[r0,#5]
		teqeq r2,#'f'
		movne pc,lr
		mov r1,#1

	gpio13Act$:
		mov r0,#13
		b SetGpio


/*****************************************************************************/

/*
* gpio 14 
*/
.global gpio14
gpio14:
     teq r1,#5
     beq gpio14On$
     teq r1,#6
     beq gpio14Off$
     mov pc,lr

     gpio14On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio14Act$

     gpio14Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio14Act$:
          mov r0,#14
          b SetGpio

/*****************************************************************************/

/*
* gpio 15 
*/
.global gpio15
gpio15:
     teq r1,#5
     beq gpio15On$
     teq r1,#6
     beq gpio15Off$
     mov pc,lr

     gpio15On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio15Act$

     gpio15Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio15Act$:
          mov r0,#15
          b SetGpio

/*****************************************************************************/

/*
* gpio 16 
*/
.global gpio16
gpio16:
     teq r1,#5
     beq gpio16On$
     teq r1,#6
     beq gpio16Off$
     mov pc,lr

     gpio16On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio16Act$

     gpio16Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio16Act$:
          mov r0,#16
          b SetGpio

/*****************************************************************************/

/*
* gpio 17 
*/
.global gpio17
gpio17:
     teq r1,#5
     beq gpio17On$
     teq r1,#6
     beq gpio17Off$
     mov pc,lr

     gpio17On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio17Act$

     gpio17Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio17Act$:
          mov r0,#17
          b SetGpio

/*****************************************************************************/

/*
* gpio 18 
*/
.global gpio18
gpio18:
     teq r1,#5
     beq gpio18On$
     teq r1,#6
     beq gpio18Off$
     mov pc,lr

     gpio18On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio18Act$

     gpio18Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio18Act$:
          mov r0,#18
          b SetGpio

/*****************************************************************************/

/*
* gpio 19 
*/
.global gpio19
gpio19:
     teq r1,#5
     beq gpio19On$
     teq r1,#6
     beq gpio19Off$
     mov pc,lr

     gpio19On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio19Act$

     gpio19Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio19Act$:
          mov r0,#19
          b SetGpio

/*****************************************************************************/

/*
* gpio 20 
*/
.global gpio20
gpio20:
     teq r1,#5
     beq gpio20On$
     teq r1,#6
     beq gpio20Off$
     mov pc,lr

     gpio20On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio20Act$

     gpio20Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio20Act$:
          mov r0,#20
          b SetGpio

/*****************************************************************************/



/*
* gpio 21 
*/
.global gpio21
gpio21:
     teq r1,#5
     beq gpio21On$
     teq r1,#6
     beq gpio21Off$
     mov pc,lr

     gpio21On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio21Act$

     gpio21Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio21Act$:
          mov r0,#21
          b SetGpio

/*****************************************************************************/

/*
* gpio 22
*/
.global gpio22
gpio22:
     teq r1,#5
     beq gpio22On$
     teq r1,#6
     beq gpio22Off$
     mov pc,lr

     gpio22On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio22Act$

     gpio22Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio22Act$:
          mov r0,#22
          b SetGpio

/*****************************************************************************/

/*
* gpio23 
*/
.global gpio23
gpio23:
     teq r1,#5
     beq gpio23On$
     teq r1,#6
     beq gpio23Off$
     mov pc,lr

     gpio23On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio23Act$

     gpio23Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio23Act$:
          mov r0,#23
          b SetGpio

/*****************************************************************************/

/*
* gpio24 (18 in gpio pin output assembly chart above )
*/
.global gpio24
gpio24: 
     teq r1,#5
     beq gpio24On$
     teq r1,#6
     beq gpio24Off$
     mov pc,lr

     gpio24On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio24Act$

     gpio24Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio24Act$:
          mov r0,#24
          b SetGpio

/*****************************************************************************/

/*
* gpio25 (22 in gpio pin output assembly chart above )
*/
.global gpio25
gpio25:
     teq r1,#5
     beq gpio25On$
     teq r1,#6
     beq gpio25Off$
     mov pc,lr

     gpio25On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio25Act$

     gpio25Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio25Act$:
          mov r0,#25
          b SetGpio

/*****************************************************************************/

/*
* gpio 26 
*/
.global gpio26
gpio26:
     teq r1,#5
     beq gpio26On$
     teq r1,#6
     beq gpio26Off$
     mov pc,lr

     gpio26On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio26Act$

     gpio26Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio26Act$:
          mov r0,#26
          b SetGpio

/*****************************************************************************/

/*****************************************************************************/

/*
* gpio 27 
*/
.global gpio27
gpio27:
     teq r1,#5
     beq gpio27On$
     teq r1,#6
     beq gpio27Off$
     mov pc,lr

     gpio27On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio27Act$

     gpio27Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio27Act$:
          mov r0,#26
          b SetGpio

/*****************************************************************************/


/*
* gpio 28 
*/
.global gpio28
gpio28:
     teq r1,#5
     beq gpio28On$
     teq r1,#6
     beq gpio28Off$
     mov pc,lr

     gpio28On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio28Act$

     gpio28Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio28Act$:
          mov r0,#28
          b SetGpio

/*****************************************************************************/

/*
* gpio 29 
*/
.global gpio29
gpio29:
     teq r1,#5
     beq gpio29On$
     teq r1,#6
     beq gpio29Off$
     mov pc,lr

     gpio29On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio29Act$

     gpio29Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio29Act$:
          mov r0,#29
          b SetGpio

/*****************************************************************************/

/*
* gpio 30 
*/
.global gpio30
gpio30:
     teq r1,#5
     beq gpio30On$
     teq r1,#6
     beq gpio30Off$
     mov pc,lr

     gpio30On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio30Act$

     gpio30Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio30Act$:
          mov r0,#30
          b SetGpio

/*****************************************************************************/

/*
* gpio 31 
*/
.global gpio31
gpio31:
     teq r1,#5
     beq gpio31On$
     teq r1,#6
     beq gpio31Off$
     mov pc,lr

     gpio31On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio31Act$

     gpio31Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio31Act$:
          mov r0,#31
          b SetGpio

/*****************************************************************************/

/*
* gpio 32 
*/
.global gpio32
gpio32:
     teq r1,#5
     beq gpio32On$
     teq r1,#6
     beq gpio32Off$
     mov pc,lr

     gpio32On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio32Act$

     gpio32Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio32Act$:
          mov r0,#32
          b SetGpio

/*****************************************************************************/

/*
* gpio 33 
*/
.global gpio33
gpio33:
     teq r1,#5
     beq gpio33On$
     teq r1,#6
     beq gpio33Off$
     mov pc,lr

     gpio33On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio33Act$

     gpio33Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio33Act$:
          mov r0,#33
          b SetGpio

/*****************************************************************************/

/*
* gpio 34 
*/
.global gpio34
gpio34:
     teq r1,#5
     beq gpio34On$
     teq r1,#6
     beq gpio34Off$
     mov pc,lr

     gpio34On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio34Act$

     gpio34Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio34Act$:
          mov r0,#34
          b SetGpio

/*****************************************************************************/

/*
* gpio 35 
*/
.global gpio35
gpio35:
     teq r1,#5
     beq gpio35On$
     teq r1,#6
     beq gpio35Off$
     mov pc,lr

     gpio35On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio35Act$

     gpio35Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio35Act$:
          mov r0,#35
          b SetGpio

/*****************************************************************************/

/*
* gpio 36 
*/
.global gpio36
gpio36:
     teq r1,#5
     beq gpio36On$
     teq r1,#6
     beq gpio36Off$
     mov pc,lr

     gpio36On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio36Act$

     gpio36Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio36Act$:
          mov r0,#36
          b SetGpio

/*****************************************************************************/

/*
* gpio 37 
*/
.global gpio37
gpio37:
     teq r1,#5
     beq gpio37On$
     teq r1,#6
     beq gpio37Off$
     mov pc,lr

     gpio37On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio37Act$

     gpio37Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio37Act$:
          mov r0,#37
          b SetGpio

/*****************************************************************************/

/*
* gpio 38 
*/
.global gpio38
gpio38:
     teq r1,#5
     beq gpio38On$
     teq r1,#6
     beq gpio38Off$
     mov pc,lr

     gpio38On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio38Act$

     gpio38Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio38Act$:
          mov r0,#38
          b SetGpio

/*****************************************************************************/

/*
* gpio 39 
*/
.global gpio39
gpio39:
     teq r1,#5
     beq gpio39On$
     teq r1,#6
     beq gpio39Off$
     mov pc,lr

     gpio39On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio39Act$

     gpio39Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio39Act$:
          mov r0,#39
          b SetGpio

/*****************************************************************************/

/*
* gpio 40 
*/
.global gpio40
gpio40:
     teq r1,#5
     beq gpio40On$
     teq r1,#6
     beq gpio40Off$
     mov pc,lr

     gpio40On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio40Act$

     gpio40Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio40Act$:
          mov r0,#40
          b SetGpio

/*****************************************************************************/

/*
* gpio 41 
*/
.global gpio41
gpio41:
     teq r1,#5
     beq gpio41On$
     teq r1,#6
     beq gpio41Off$
     mov pc,lr

     gpio41On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio41Act$

     gpio41Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio41Act$:
          mov r0,#41
          b SetGpio

/*****************************************************************************/

/*
* gpio 42 
*/
.global gpio42
gpio42:
     teq r1,#5
     beq gpio42On$
     teq r1,#6
     beq gpio42Off$
     mov pc,lr

     gpio42On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio42Act$

     gpio42Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio42Act$:
          mov r0,#26
          b SetGpio

/*****************************************************************************/

/*
* gpio 43 
*/
.global gpio43
gpio43:
     teq r1,#5
     beq gpio43On$
     teq r1,#6
     beq gpio43Off$
     mov pc,lr

     gpio43On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio43Act$

     gpio43Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio43Act$:
          mov r0,#43
          b SetGpio

/*****************************************************************************/

/*
* gpio 44 
*/
.global gpio44
gpio44:
     teq r1,#5
     beq gpio44On$
     teq r1,#6
     beq gpio44Off$
     mov pc,lr

     gpio44On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio44Act$

     gpio44Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio44Act$:
          mov r0,#44
          b SetGpio

/*****************************************************************************/

/*
* gpio 45 
*/
.global gpio45
gpio45:
     teq r1,#5
     beq gpio45On$
     teq r1,#6
     beq gpio45Off$
     mov pc,lr

     gpio45On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio45Act$

     gpio45Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio45Act$:
          mov r0,#45
          b SetGpio

/*****************************************************************************/

/*
* gpio 46 
*/
.global gpio46
gpio46:
     teq r1,#5
     beq gpio46On$
     teq r1,#6
     beq gpio46Off$
     mov pc,lr

     gpio46On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio46Act$

     gpio46Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio46Act$:
          mov r0,#46
          b SetGpio

/*****************************************************************************/

/*
* gpio 47 
*/
.global gpio47
gpio47:
     teq r1,#5
     beq gpio47On$
     teq r1,#6
     beq gpio47Off$
     mov pc,lr

     gpio47On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio47Act$

     gpio47Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio47Act$:
          mov r0,#47
          b SetGpio

/*****************************************************************************/

/*
* gpio 48 
*/
.global gpio48
gpio48:
     teq r1,#5
     beq gpio48On$
     teq r1,#6
     beq gpio48Off$
     mov pc,lr

     gpio48On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio48Act$

     gpio48Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio48Act$:
          mov r0,#48
          b SetGpio

/*****************************************************************************/

/*
* gpio 49 
*/
.global gpio49
gpio49:
     teq r1,#5
     beq gpio49On$
     teq r1,#6
     beq gpio49Off$
     mov pc,lr

     gpio49On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio49Act$

     gpio49Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio49Act$:
          mov r0,#49
          b SetGpio

/*****************************************************************************/

/*
* gpio 50 
*/
.global gpio50
gpio50:
     teq r1,#5
     beq gpio50On$
     teq r1,#6
     beq gpio50Off$
     mov pc,lr

     gpio50On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio50Act$

     gpio50Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio50Act$:
          mov r0,#50
          b SetGpio

/*****************************************************************************/

/*
* gpio 51 
*/
.global gpio51
gpio51:
     teq r1,#5
     beq gpio51On$
     teq r1,#6
     beq gpio51Off$
     mov pc,lr

     gpio51On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio51Act$

     gpio51Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio51Act$:
          mov r0,#51
          b SetGpio

/*****************************************************************************/

/*
* gpio 52 
*/
.global gpio52
gpio52:
     teq r1,#5
     beq gpio52On$
     teq r1,#6
     beq gpio52Off$
     mov pc,lr

     gpio52On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio52Act$

     gpio52Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio52Act$:
          mov r0,#52
          b SetGpio


/*****************************************************************************/


/*
* gpio 53 
*/
.global gpio53
gpio53:
     teq r1,#5
     beq gpio43On$
     teq r1,#6
     beq gpio53Off$
     mov pc,lr

     gpio53On$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'n'
          movne pc,lr
          mov r1,#0
          b gpio53Act$

     gpio53Off$:
          ldrb r2,[r0,#3]
          teq r2,#'o'
          ldreqb r2,[r0,#4]
          teqeq r2,#'f'
          ldreqb r2,[r0,#5]
          teqeq r2,#'f'
          movne pc,lr
          mov r1,#1

     gpio53Act$:
          mov r0,#53
          b SetGpio

/*****************************************************************************/


