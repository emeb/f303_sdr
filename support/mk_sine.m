% mk_sine.m - build 12-bit Sine LUT, extended for sine/cosine
sz = 1024;
ext = sz/4;
amp = 2047;

ph = 2*pi*(0:sz+ext-1)/sz;

lut = floor(amp*sin(ph) + 0.5);

ofile = fopen('Sine.h', 'w');
fprintf(ofile, '/* Sinewave LUT */\n');
fprintf(ofile, 'const int16_t Sine[%d] = {\n', sz+ext);
for i=1:length(lut)-1
	fprintf(ofile, '\t%4d,\n', lut(i));
end
fprintf(ofile, '\t%4d\n', lut(end));
fprintf(ofile, '};\n');
fclose(ofile);
