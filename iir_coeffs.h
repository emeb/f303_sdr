/* iir filter coefficients */
#define NUM_IIRS 3
#define IIR_GAIN 3.860867e-05F
float32_t pCoeffs[NUM_IIRS*5] = {
	 1, 2.000006e+00, 9.999833e-01, 1.317692e+00, -4.397127e-01,
	 1, 2.004794e+00, 1.004817e+00, 1.424631e+00, -5.565543e-01,
	 1, 1.995200e+00, 9.952230e-01, 1.657640e+00, -8.111402e-01,
};
