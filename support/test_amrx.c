/*
 * test_amrx.c - check out DSP ideas for F303 SDR in a PC environment
 * 01-31-2013 E. Brombaugh
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#include "Sine.h"
#include "Window.h"

/* duplicate of macro in adc.h */
#define ADC_BUFSZ 128
#define DEC_SAMPLES 1024
int16_t ADC_Buffer[ADC_BUFSZ/2*DEC_SAMPLES];

/* coarse tuner array is (I1:I0), (Q1:Q0), (I3:I2), ... */
uint32_t LO[ADC_BUFSZ/2] __attribute__ ((aligned (8)));

#define DEC_SHFT 11
#define DEC_RND (1<<(DEC_SHFT-1))

/* set up high-rate tuner array */
void set_coarse_freq(uint16_t bin)
{
	uint16_t i;
	uint32_t tmp1, tmp2;
	
	/* limit the number of possible frequencies */
	bin &= ((ADC_BUFSZ/4)-1);
	bin = -bin;
	
	/* fill the arrary */
	for(i=0;i<ADC_BUFSZ/2;i+=2)
	{
		/* can scale by window func too for better passband */
		tmp1 = (Sine[(bin*(i<<4)+256)&1023]*Window[i]+1024)>>11;
		tmp2 = (Sine[(bin*((i+1)<<4)+256)&1023]*Window[i]+1024)>>11;
		LO[i+0] = (tmp1 & 0xffff) | (tmp2<<16);
		tmp1 = (Sine[(bin*(i<<4))&1023]*Window[i]+1024)>>11;
		tmp2 = (Sine[(bin*((i+1)<<4))&1023]*Window[i]+1024)>>11;
		LO[i+1] = (tmp1 & 0xffff) | (tmp2<<16);
	}
}

/* uncomment this to enable interior data printint */
//#define DDC_DBG

void ddc_c(int16_t *idx, uint32_t *lo_ptr, int32_t *si, int32_t *sq)
{
	int16_t i1, i2, l1, l2;
	int32_t tmp_lo, sumi = 0, sumq = 0;
	
	/* normal loop */
	uint32_t i;
	for(i=0;i<ADC_BUFSZ/2;i+=2)
	{
		/* Get real input signed */
		i1 = *idx++;
		i2 = *idx++;
#ifdef DDC_DBG
		fprintf(stdout, "% 5d % 5d ", i1, i2);
#endif
		
		/* Unpack I LO components */
		l1 = *lo_ptr & 0xffff;
		l2 = *lo_ptr++ >> 16;
#ifdef DDC_DBG
		fprintf(stdout, "% 5d % 5d ", l1, l2);
#endif
			
		/* Accumulate I */
		sumi += i1 * l1 + i2 * l2;
			
		/* Unpack Q LO components */
		l1 = *lo_ptr & 0xffff;
		l2 = *lo_ptr++ >> 16;
#ifdef DDC_DBG
		fprintf(stdout, "% 5d % 5d ", l1, l2);
#endif
		
		/* Accumulate Q */
		sumq += i1 * l1 + i2 * l2;
#ifdef DDC_DBG
		fprintf(stdout, "% 9d % 9d\n", sumi, sumq);
#endif
	}
	
	/* return results */
	*si = sumi;
	*sq = sumq;
}

int main(int argc, char **argv)
{
	uint32_t i;
	int16_t *idx = ADC_Buffer, bin = 22;
	int32_t sumi, sumq;
	double f = (double)bin/64.0;
	
	/* get args */
	if(argc>1)
		f = atof(argv[1]);
	
	if(argc>2)
		bin = atoi(argv[2]);
	
	/* report args */
	//fprintf(stdout, "%f %d\n", f, bin);
	
	/* init the LO */
	set_coarse_freq(bin);
	
	/* build up an input array */
	for(i=0;i<ADC_BUFSZ/2*DEC_SAMPLES;i++)
	{
		ADC_Buffer[i] = 2048*cos(i*f*6.2832/64);
	}
	
	/* process a buffer at a time */
	for(i=0;i<DEC_SAMPLES;i++)
	{
		ddc_c(idx, LO, &sumi, &sumq);
		idx += ADC_BUFSZ/2;
		sumi = (sumi + DEC_RND)>>DEC_SHFT;
		sumq = (sumq + DEC_RND)>>DEC_SHFT;

		fprintf(stdout, "% 7d % 7d\n", sumi, sumq);
	}
}