/*
 * amrx.c - AM receive functions
 * 01-31-2013 E. Brombaugh
 */

#include <stdint.h>
#include <stdlib.h>
#include "arm_math.h"
#include "amrx.h"
#include "Sine.h"

// uncomment this line to use optimized assembly for ddc function
//#define USE_DDC_ASSY
#ifdef USE_DDC_ASSY
#include "ddc.h"
#endif

uint32_t phs, frq;

/* duplicate of macro in adc.h */
#define ADC_BUFSZ 128

/* coarse tuner array is (I1:I0), (Q1:Q0), (I3:I2), ... */
uint32_t LO[ADC_BUFSZ/2] __attribute__ ((aligned (8)));

#define DEC_SHFT 11
#define DEC_RND (1<<(DEC_SHFT-1))

#define IIR_BUFSZ 4
#define IIR_MASK (IIR_BUFSZ-1)
float32_t iir_inbuf[IIR_BUFSZ], iir_outbuf[IIR_BUFSZ];
int16_t iir_wptr;

/* IIR filter state */
#define NUM_IIRS 3
arm_biquad_casd_df1_inst_f32 S;
float32_t pCoeffs[NUM_IIRS*5], pState[NUM_IIRS*4];

/* initialize the amrx functions */
void init_amrx(void)
{
	uint16_t i;

	/* set up high rate tuner */
	set_coarse_freq(22);	/* arbitrary tuner bin for testing */

	/* set up low-rate NCO */
	phs = 0;
	frq = (1<<21);
	
	/* init decimation buffer */
	for(i=0;i<IIR_BUFSZ;i++)
	{
		iir_inbuf[i] = 0.0F;
	}
	iir_wptr = 0;
	
	/* init filter state */
	arm_biquad_cascade_df1_init_f32(&S, NUM_IIRS, pCoeffs, pState);

}

/* set up high-rate tuner array */
void set_coarse_freq(uint16_t bin)
{
	uint16_t i;
	uint32_t tmp;
	
	/* limit the number of possible frequencies */
	bin &= ((ADC_BUFSZ/4)-1);
	
	/* fill the arrary */
	for(i=0;i<ADC_BUFSZ/2;i+=2)
	{
		/* can scale by window func too for better passband */
		tmp = Sine[(bin*(i<<4)+256)&1023];
		LO[i+0] = tmp | (Sine[(bin*((i+1)<<4)+256)&1023]<<16);
		tmp = Sine[(bin*(i<<4))&1023];
		LO[i+1] = tmp | (Sine[(bin*((i+1)<<4))&1023]<<16);
	}
}

#ifndef USE_DDC_ASSY
/* tune & integrate - C version of what assembly routine does */
void ddc_c(int16_t *idx, int16_t *lo_ptr, int32_t *si, int32_t *sq)
 __attribute__ ((section (".ccmram")));
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
			
		/* Unpack I LO components */
		l1 = *lo_ptr & 0xffff;
		l2 = *lo_ptr++ >> 16;
			
		/* Accumulate I */
		sumi += i1 * l1 + i2 * l2;
			
		/* Unpack Q LO components */
		l1 = *lo_ptr & 0xffff;
		l2 = *lo_ptr++ >> 16;
		
		/* Accumulate Q */
		sumq += i1 * l1 + i2 * l2;
	}
	
	/* return results */
	*si = sumi;
	*sq = sumq;
}
#endif

void amrx(int16_t *idx)
{
	uint16_t ftidx;
	int32_t sumi, sumq, fti, ftq, bbi, bbq, mag;
	
	/* Coarse Tune and Filter RF data */
#ifdef USE_DDC_ASSY
	ddc_c(idx, LO, &sumi, &sumq);
#else		
	ddc(idx, LO, &sumi, &sumq);
#endif
		
	/* Scale & Round off to make room for fine tune */
	sumi = (sumi + DEC_RND)>>DEC_SHFT;
	sumq = (sumq + DEC_RND)>>DEC_SHFT;
	
	/* Fine tune with low-rate NCO */
	ftidx = phs>>22;
	fti = Sine[ftidx+256];
	ftq = Sine[ftidx];
	bbi = sumi*fti - sumq*ftq;
	bbq = sumi*ftq + sumq*fti;
	phs += frq;
	
	/* compute magnitude of baseband */
	bbi = abs(bbi);
	bbq = abs(bbq);
	if(bbi > bbq)
		mag = bbi + (bbq>>1);
	else
		mag = bbq + (bbi>>1);
	
	/* save magnitude as float in filter buffer */
	iir_inbuf[iir_wptr] = mag;
	iir_wptr = (iir_wptr+1)&IIR_MASK;
	
	/* run filter when we have 4 samples */
	if(iir_wptr == 0)
		arm_biquad_cascade_df1_f32(&S, iir_inbuf, iir_outbuf, 4);
	

}