/*
 * amrx.h - AM receive functions for f303_sdr project
 * 01-31-2013 E. Brombaugh
 */

#ifndef __amrx__
#define __amrx__

void init_amrx(void);
void set_coarse_freq(uint16_t bin);
void amrx(int16_t *idx) __attribute__ ((section (".ccmram")));

#endif
