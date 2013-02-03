% mk_iir.m - dump out IIR coefficients in a format suitable for the
% CMSIS arm_biquad_cascade_df1_f32() filter routine
% 02-01-2013 E. Brombaugh

% 64 samples in 6.6 * 2e-6 us => Fs = 4.85MHz sample rate
% Decimated rate is 75.76kHz

Fs = 75.76e3;
Fc = 5e3;
order = 6;

% Butterworth filter
[b, a] = maxflat(order, order, Fc/(Fs/2));

% plot response
figure(1);
freqz(b,a);

% convert to 2nd order sections
[sos,g] = tf2sos(b,a);
[sections, dummy] = size(sos);

% invert a coefs
for m=1:sections
	for n=5:6
		sos(m,n) = -sos(m,n);
	end
end

% generate an impulse response to check
sz = 1024;
x = zeros(1,sz);
y=x;
x(4) = 1;
for m=1:sections
	for n=3:sz
		y(n) = sos(m,1) * x(n) + sos(m,2) * x(n-1) + sos(m,3) * x(n-2) + sos(m,5) * y(n-1) + sos(m,6) * y(n-2);
	end
	x = y;
end
y = g*y;

% plot response
figure(2);
freqz(y,1);

% spit out to a file
ofile = fopen('iir_coeffs.h', 'w');
fprintf(ofile, '/* iir filter coefficients */\n')
fprintf(ofile, '#define NUM_IIRS %d\n', sections);
fprintf(ofile, '#define IIR_GAIN %dF\n', g);
fprintf(ofile, 'float32_t pCoeffs[NUM_IIRS*5] = {\n');
for m=1:sections
	fprintf(ofile, '\t %d, %d, %d, %d, %d,\n', sos(m,1), sos(m,2), sos(m,3), sos(m,5), sos(m,6));
end
fprintf(ofile, '};\n');
