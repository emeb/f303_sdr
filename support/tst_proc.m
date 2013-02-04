% tst_proc.m - test SDR processing ideas
% 02-03-2013 E. Brombaugh

%% ADC sampling rate
Fs = 72e6/(12.5+7.5);

%% Test Signal params
Fmodulation = 1e3;
Mod_amp = 0.9;
sz = 2^16;
in_t = (0:(sz-1))/Fs;

%% Front End setup
% params
Ftune = 1.0e6;
Int_Len = 256;
OS = 4;
Dec_Rate = Int_Len/OS;
Fs_dec = Fs/Dec_Rate;
Fs_itg = Fs/Int_Len;
Coarse_Bin = floor(Ftune/Fs_itg);
%Ffine = Ftune - Fs_itg*Coarse_Bin;
Ffine = Ftune - Fs_dec*floor(Ftune/Fs_dec);
Phs_Inc = 2^32*Ffine/Fs_dec;

% build coarse tune table with window
LO = exp(1i*2*pi*Coarse_Bin*(0:(Int_Len-1))/Int_Len);
win = blackmanharris(Int_Len);
%win = hann(Int_Len);
LO = LO .* win;

% Fine tuning
Phs = mod(cumsum(ones(1,sz/Dec_Rate-OS)*Phs_Inc),2^32)/2^32;
FLO = exp(1i*2*pi*Phs);

% IIR filter
Fcutoff = 5e3;
order = 6;
%[b, a] = maxflat(order, order, Fcutoff/(Fs_dec/2));
[b, a] = butter(order, Fcutoff/(Fs_dec/2));

%% Sweep Carrier Frequency
swp_stps = 1024;
freq = 0:Fs/(swp_stps*2):Fs/2;
%freq = 900e3:1e3:1100e3;
%freq = 1.02e6;
amp = zeros(size(freq));
for idx = 1:length(freq);
	%% Test signal
	Fcarrier = freq(idx);
	in_sig = cos(2*pi*Fcarrier*in_t).*(Mod_amp*sin(2*pi*Fmodulation*in_t)+1)/2;

	% Iterate over test signal, tuning & decimating
	dec_sig = zeros(1,ceil(sz/Dec_Rate-OS));
	oidx = 1;
	for iidx = 1:Dec_Rate:(sz-(OS*Dec_Rate))
		dec_sig(oidx) = sum(LO .* in_sig(iidx:(iidx+Int_Len-1)));
		oidx = oidx+1;
	end

	% Fine tuning
	tun_sig = dec_sig .* FLO;
	
	% IIR filter on IF
	if_sig = filter(b, a, tun_sig);
	%if_sig = tun_sig;
	
	% AM Detection
	am_raw = abs(if_sig);

	% IIR filter
	am_filt = filter(b, a, am_raw);
	%am_filt = am_raw;

	% measure
	meas_intvl = floor(length(am_filt)/2):length(am_filt);
	amp(idx) = max(am_filt(meas_intvl)) - min(am_filt(meas_intvl));
end

%% plots

if length(freq) > 1
	% sweep response
	plot(freq/1e3, 20*log10(amp));
	hold on;
	itg_freqs = (0:(Int_Len/2-1))*Fs_itg;
	plot(itg_freqs/1e3, ones(size(itg_freqs))*30, 'g+');
	dec_freqs = (0:(Dec_Rate/2-1))*Fs_dec;
	plot(dec_freqs/1e3, ones(size(dec_freqs))*30, 'r+');
	hold off;
	grid on;
	xlabel('Frequency (kHz)');
	ylabel('Response (dB)');
	xlim([900 1100]);
	ylim([-50 50]);
else
	% single tune
	meas_intvl = floor(length(am_filt)/2):length(am_filt);
	data = if_sig(meas_intvl);
	dsz = length(data);
	
	if 1
		% time domain
		figure(1);
		dtime = 1e6*(0:(dsz-1))/Fs_dec;
		plot(dtime, real(data), 'r');
		hold on;
		plot(dtime, imag(data), 'g');
		hold off;
		grid on;
		title('Tuner - time series');
		xlabel('Time (us)');
		ylabel('Value');
		legend('real', 'imag');
	end
	if 1
		% freq domain
		figure(2);
		dfreq = Fs_dec*(((0:(dsz-1))/dsz)-0.5)/1e3;
		plot(dfreq, 20*log10(abs(fftshift(fft(data)))));
		grid on;
		title('Tuner IF spectrum');
		xlabel('Freq (kHz)');
		ylabel('Mag (dB)');
	end
end