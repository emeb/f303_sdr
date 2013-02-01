/**
  ******************************************************************************
  * @file      sdr.s
  * @author    E. Brombaugh
  * @version   V1.0.0
  * @date      29-January-2013
  * @brief     SDR subroutine to test assembly. 
  ******************************************************************************
  */
    
	.syntax unified
	.cpu cortex-m4
	.fpu softvfp
	.thumb

	.global		sdr_s
	.section	.ccmram, "ax", %progbits
	.type		sdr_s STT_FUNC
	
	/* enter with:
	/* r0 = ptr to RF adc data */
	/* r1 = ptr to LO data */
	/* r2 = ptr to i sum */
	/* r3 = ptr to q sum */
sdr_s:  
	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp}	/* save regs */
	mov		r8, #0				/* init i acc */
	mov		r9, #0				/* init q acc */
	
	/* iterations 0, 1 */
	ldrd   r4, [r1, #0]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #0]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 2, 3 */
	ldrd   r4, [r1, #8]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #4]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 4, 5 */
	ldrd   r4, [r1, #16]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #8]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 6, 7 */
	ldrd   r4, [r1, #24]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #12]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 8, 9 */
	ldrd   r4, [r1, #32]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #16]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 10, 11 */
	ldrd   r4, [r1, #40]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #20]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 12, 13 */
	ldrd   r4, [r1, #48]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #24]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 14, 15 */
	ldrd   r4, [r1, #56]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #28]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 16, 17 */
	ldrd   r4, [r1, #64]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #32]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 18, 19 */
	ldrd   r4, [r1, #72]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #36]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 20, 21 */
	ldrd   r4, [r1, #80]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #40]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 22, 23 */
	ldrd   r4, [r1, #88]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #44]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 24, 25 */
	ldrd   r4, [r1, #96]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #48]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 26, 27 */
	ldrd   r4, [r1, #104]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #52]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 28, 29 */
	ldrd   r4, [r1, #112]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #56]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 30, 31 */
	ldrd   r4, [r1, #120]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #60]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 32, 33 */
	ldrd   r4, [r1, #128]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #64]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 34, 35 */
	ldrd   r4, [r1, #136]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #68]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 36, 37 */
	ldrd   r4, [r1, #144]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #72]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 38, 39 */
	ldrd   r4, [r1, #152]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #76]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 40, 41 */
	ldrd   r4, [r1, #160]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #80]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 42, 43 */
	ldrd   r4, [r1, #168]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #84]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 44, 45 */
	ldrd   r4, [r1, #176]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #88]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 46, 47 */
	ldrd   r4, [r1, #184]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #92]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 48, 49 */
	ldrd   r4, [r1, #192]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #96]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 50, 51 */
	ldrd   r4, [r1, #200]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #100]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 52, 53 */
	ldrd   r4, [r1, #208]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #104]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 54, 55 */
	ldrd   r4, [r1, #216]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #108]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 56, 57 */
	ldrd   r4, [r1, #224]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #112]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 58, 59 */
	ldrd   r4, [r1, #232]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #116]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 60, 61 */
	ldrd   r4, [r1, #240]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #120]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	/* iterations 62, 63 */
	ldrd   r4, [r1, #248]		/* get LO I1,I2,Q1,Q2 */
	ldr    r6, [r0, #124]		/* get RF data 1,2 */
	smlad  r8, r6, r4, r8		/* Dual MAC I */
	smlad  r9, r6, r5, r9		/* Dual MAC Q */

	str		r8, [r2]			/* save I sum */
	str		r9, [r3]			/* save Q sum */
	
	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp}	/* restore regs */
	bx		lr
	nop
		
.size  sdr_s, .-sdr_s
