/*
 * adc.h - adc setup & isr for stm32f303
 * 01-28-2013 E. Brombaugh
 */

#ifndef __adc__
#define __adc__

#include "stm32f30x.h"

#define ADC_BUFSZ 128

void setup_adc(void);

#endif
