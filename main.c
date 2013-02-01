/*
	main.c
	
	Part of f303_sdr - an experimental project to test SDR on an stm32f303
	Copyright 01-31-2013 E. Brombaugh
	
	This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
    MA 02110-1301 USA.
*/

#include "stm32f30x.h"

/* zyp's cycle count delay routines */
volatile uint32_t* demcr = (uint32_t*)0xE000EDFC;
volatile uint32_t* dwt_ctrl = (uint32_t*)0xe0001000;
volatile uint32_t* dwt_cyccnt = (uint32_t*)0xe0001004;

void cyccnt_enable() {
	*demcr |= (1<<24);
    *dwt_ctrl |= 1;
}

void cyclesleep(uint32_t cycles) {
    uint32_t start = *dwt_cyccnt;
    
    while(*dwt_cyccnt - start < cycles);
}

int main(void)
{
	GPIO_InitTypeDef GPIO_InitStructure;
		
	/* init the adc */
	setup_adc();		

	/* Enable GPIO B Clock */
	RCC_AHBPeriphClockCmd(RCC_AHBPeriph_GPIOB, ENABLE);
	
	/* Enable PB8 for output */
	GPIO_InitStructure.GPIO_Pin =  GPIO_Pin_8;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
	GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL ;
	GPIO_Init(GPIOB, &GPIO_InitStructure);
	
#if 0
	/* Enable MCO output on PA8 */
	GPIO_InitStructure.GPIO_Pin =  GPIO_Pin_8;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
	GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL ;
	GPIO_Init(GPIOA, &GPIO_InitStructure);
	//GPIO_PinAFConfig(GPIOA, GPIO_Pin_8, GPIO_AF_0);
	
	/* turn on MCO */
	RCC_MCOConfig(RCC_MCOSource_PLLCLK_Div2);
#endif
	
	/* start cycle counter */
	cyccnt_enable();
	
	/* loop forever */
	while(1)
	{
		/* LED on */
		GPIOB->BSRR = (1<<8);

		cyclesleep(0x044aa20);
		
		/* LED off */
		GPIOB->BRR = (1<<8);

		cyclesleep(0x044aa20);
	}
}

#ifdef  USE_FULL_ASSERT

/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t* file, uint32_t line)
{ 
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */

  /* Infinite loop */
  while (1)
  {
  }
}
#endif
