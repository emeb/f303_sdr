/*
 * adc.c - adc setup & isr for stm32f303
 * 01-28-2013 E. Brombaugh
 */

#include <stdint.h>
#include <stdlib.h>
#include "arm_math.h"
#include "adc.h"
#include "Sine.h"

#define ADC_BUFSZ 128
__IO int16_t ADC_Buffer[ADC_BUFSZ];
__IO uint16_t calibration_value_1 = 0;
uint32_t phs, frq;

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

void setup_adc(void)
{
	uint16_t i;
	GPIO_InitTypeDef       GPIO_InitStructure;
	DMA_InitTypeDef        DMA_InitStructure;
	ADC_InitTypeDef        ADC_InitStructure;

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
	
	/* Configure the ADC clock */
	RCC_ADCCLKConfig(RCC_ADC12PLLCLK_Div1);  
	
	/* Enable ADC1 clock */
	RCC_AHBPeriphClockCmd(RCC_AHBPeriph_ADC12, ENABLE);
		
	/* Enable GPIOA Periph clock */
	RCC_AHBPeriphClockCmd(RCC_AHBPeriph_GPIOA, ENABLE);

	/* Configure ADC1/2 Channel0 as analog input */
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0 ;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AN;
	GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL ;
	GPIO_Init(GPIOA, &GPIO_InitStructure);

	/* Enable GPIOB Periph clock for diags */
	RCC_AHBPeriphClockCmd(RCC_AHBPeriph_GPIOB, ENABLE);

	/* Configure PB9 as 50MHz pp */
	GPIO_InitStructure.GPIO_Pin =  GPIO_Pin_9;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
	GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL ;
	GPIO_Init(GPIOB, &GPIO_InitStructure);

	/* Enable DMA1 clock */
	RCC_AHBPeriphClockCmd(RCC_AHBPeriph_DMA1, ENABLE);

	/* DMA1 Channel1 Init */
	DMA_InitStructure.DMA_PeripheralBaseAddr = (uint32_t)&ADC1->DR;
	DMA_InitStructure.DMA_MemoryBaseAddr = (uint32_t)&ADC_Buffer;
	DMA_InitStructure.DMA_DIR = DMA_DIR_PeripheralSRC;
	DMA_InitStructure.DMA_BufferSize = ADC_BUFSZ;
	DMA_InitStructure.DMA_PeripheralInc = DMA_PeripheralInc_Disable;
	DMA_InitStructure.DMA_MemoryInc = DMA_MemoryInc_Enable;
	DMA_InitStructure.DMA_PeripheralDataSize = DMA_PeripheralDataSize_HalfWord;
	DMA_InitStructure.DMA_MemoryDataSize = DMA_MemoryDataSize_HalfWord;
	DMA_InitStructure.DMA_Mode = DMA_Mode_Circular;
	DMA_InitStructure.DMA_Priority = DMA_Priority_Medium;
	DMA_InitStructure.DMA_M2M = DMA_M2M_Disable;

	DMA_Init(DMA1_Channel1, &DMA_InitStructure);

	/* DMA interrupts */
	DMA_ITConfig(DMA1_Channel1, DMA_IT_TC | DMA_IT_HT, ENABLE);

	/* enable DMA IRQ */
	NVIC_EnableIRQ(DMA1_Channel1_IRQn);

	/* ADC Calibration procedure */
	ADC_VoltageRegulatorCmd(ADC1, ENABLE);
  
	/* Insert delay equal to 10 ms */
	//Delay(10);
  
	ADC_SelectCalibrationMode(ADC1, ADC_CalibrationMode_Single);

	ADC_SelectCalibrationMode(ADC2, ADC_CalibrationMode_Single);
  
	while(ADC_GetCalibrationStatus(ADC1) != RESET );
	calibration_value_1 = ADC_GetCalibrationValue(ADC1);

	/* ADC setup */  
	ADC_StructInit(&ADC_InitStructure);
	ADC_InitStructure.ADC_ContinuousConvMode = ADC_ContinuousConvMode_Enable;
	ADC_InitStructure.ADC_Resolution = ADC_Resolution_12b; 
	ADC_InitStructure.ADC_ExternalTrigConvEvent = ADC_ExternalTrigConvEvent_0;         
	ADC_InitStructure.ADC_ExternalTrigEventEdge = ADC_ExternalTrigEventEdge_None;
	ADC_InitStructure.ADC_DataAlign = ADC_DataAlign_Right;
	ADC_InitStructure.ADC_OverrunMode = ADC_OverrunMode_Disable;   
	ADC_InitStructure.ADC_AutoInjMode = ADC_AutoInjec_Disable;  
	ADC_InitStructure.ADC_NbrOfRegChannel = 1;
	ADC_Init(ADC1, &ADC_InitStructure);

	/* ADC1 regular channel0 configuration */ 
	ADC_RegularChannelConfig(ADC1, ADC_Channel_1, 1, ADC_SampleTime_2Cycles5);
	ADC_SetChannelOffset1(ADC1, ADC_Channel_1, 2048);
	ADC_ChannelOffset1Cmd(ADC1, ENABLE);
	
	/* Configures the ADC DMA */
	ADC_DMAConfig(ADC1, ADC_DMAMode_Circular);
		
	/* Enable the ADC DMA */
	ADC_DMACmd(ADC1, ENABLE);

	/* Enable ADC1 */
	ADC_Cmd(ADC1, ENABLE);

	/* wait for ADC1 ADRDY */
	while(!ADC_GetFlagStatus(ADC1, ADC_FLAG_RDY));

	/* Enable the DMA channel */
	DMA_Cmd(DMA1_Channel1, ENABLE);

	/* Start ADC1 Software Conversion */ 
	ADC_StartConversion(ADC1);
	
}

/* disabled for now since I cba to do dual implementation */
#if 0
/* tune & integrate - C version of what assembly routine does */
void sdr_c(int16_t *idx, int16_t *lo_ptr, int32_t *si, int32_t *sq)
 __attribute__ ((section (".ccmram")));
void sdr_c(int16_t *idx, int16_t *lo_ptr, int32_t *si, int32_t *sq)
{
	int32_t tmp_if, sumi = 0, sumq = 0;
	
	/* normal loop */
	uint32_t i;
	for(i=0;i<ADC_BUFSZ/2;i++)
	{
		/* Get real input signed */
		tmp_if = *idx++;
		
		/* Accumulate */
		sumi += tmp_if * *lo_ptr++;
		sumq += tmp_if * *lo_ptr++;
	}
	
	/* return results */
	*si = sumi;
	*sq = sumq;
}
#endif

/* Handles DMA1_Channel1 (ADC Buffer) interrupt request */
void DMA1_Channel1_IRQHandler(void) __attribute__ ((section (".ccmram")));
void DMA1_Channel1_IRQHandler(void)
{
	__IO int16_t *idx;
	uint16_t ftidx;
	int32_t sumi, sumq, fti, ftq, bbi, bbq, mag;
	
	/* Active ISR */
	GPIOB->BSRR |= (1<<9);

	/* which interrupt? */
	if(DMA1->ISR&0x04)
	{
		/* Half transfer - 1st half buffer has data */
		idx = &ADC_Buffer[0];
	}
	else
	{
		/* Transfer complete - 2nd half buffer has data */
		idx = &ADC_Buffer[ADC_BUFSZ/2];
	}

	/* Clear DMA1_Channel1 interrupt */
	DMA1->IFCR = DMA_IFCR_CGIF1;

	/* Coarse Tune and Filter RF data */
	//sdr_c(idx, LO, &sumi, &sumq);
	sdr_s(idx, LO, &sumi, &sumq);
	
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
	
	/* Inactive ISR */
	GPIOB->BRR |= (1<<9);
}

