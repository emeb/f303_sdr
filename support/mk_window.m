% mk_window.m - build 12-bit Window LUT
sz = 64;
amp = 2047;

wind = hann(sz);

lut = floor(amp*wind + 0.5);

ofile = fopen('Window.h', 'w');
fprintf(ofile, '/* Window LUT */\n');
fprintf(ofile, 'const int16_t Window[%d] = {\n', sz);
for i=1:length(lut)-1
	fprintf(ofile, '\t%4d,\n', lut(i));
end
fprintf(ofile, '\t%4d\n', lut(end));
fprintf(ofile, '};\n');
fclose(ofile);
