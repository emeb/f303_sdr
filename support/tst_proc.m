% tst_proc.m - test SDR processing ideas
% 02-03-2013 E. Brombaugh

%% ADC sampling rate
Fs = 72e6/(12.5+2.5);

%% Test Signal params
Fmodulation = 1e3;
Mod_amp = 0.9;
sz = 2^14;
in_t = (0:(sz-1))/Fs;

%% Front End setup
% params
Ftune = 1.0e6;
Dec_Rate = 256;
Fs_dec = Fs/Dec_Rate;
Coarse_Bin = floor(Ftune/Fs_dec);
Ffine = Ftune - Fs_dec*Coarse_Bin;
Phs_Inc = 2^32*Ffine/(Fs_dec);

% build coarse tune table with window
LO = exp(1i*2*pi*Coarse_Bin*(0:(Dec_Rate-1))/Dec_Rate);
%win = blackmanharris(Dec_Rate);
%LO = LO .* win';

% Fine tuning
Phs = mod(cumsum(ones(size(1,sz/Dec_Rate))*Phs_Inc),2^32)/2^32;
FLO = exp(1i*2*pi*Phs);

% IIR filter
Fcutoff = 5e3;
order = 6;
[b, a] = maxflat(order, order, Fcutoff/(Fs_dec/2));

%% Sweep Carrier Frequency
swp_stps = 1024;
freq = 0:Fs/(swp_stps*2):Fs/2;
amp = zeros(size(freq));
for idx = 1:length(freq);
	%% Test signal
	Fcarrier = freq(idx);
	in_sig = cos(2*pi*Fcarrier*in_t).*(Mod_amp*sin(2*pi*Fmodulation*in_t)+1)/2;

	% Iterate over test signal, tuning & decimating
	dec_sig = zeros(1,ceil(sz/Dec_Rate));
	oidx = 1;
	for iidx = 1:Dec_Rate:sz
		dec_sig(oidx) = sum(LO .* in_sig(iidx:(iidx+Dec_Rate-1)));
		oidx = oidx+1;
	end

	% Fine tuning
	tun_sig = dec_sig .* FLO;
	
	% IIR filter on IF
	%if_sig = filter(b, a, tun_sig);
	if_sig = tun_sig;
	
	% AM Detection
	am_raw = abs(if_sig);

	% IIR filter
	am_filt = filter(b, a, am_raw);

	% measure
	amp(idx) = max(am_filt(end/2:end)) - min(am_filt(end/2:end));
end

%% plot out response
plot(freq/1e3, 20*log10(amp));
grid on;
xlabel('Frequency (kHz)');
ylabel('Response (dB)');
xlim([900 1100]);