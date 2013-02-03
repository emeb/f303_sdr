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
Int_Len = 256;
OS = 1;
Dec_Rate = Int_Len/OS;
Fs_dec = Fs/Dec_Rate;
Fs_itg = Fs/Int_Len;
Coarse_Bin = floor(Ftune/Fs_itg);
Ffine = Ftune - Fs_itg*Coarse_Bin;
Phs_Inc = 2^32*Ffine/(Fs_dec);

% build coarse tune table with window
LO = exp(1i*2*pi*Coarse_Bin*(0:(Int_Len-1))/Int_Len);
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
	dec_sig = zeros(1,ceil(sz/Dec_Rate-OS));
	oidx = 1;
	for iidx = 1:Dec_Rate:(sz-(OS*Dec_Rate))
		dec_sig(oidx) = sum(LO .* in_sig(iidx:(iidx+Int_Len-1)));
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
	meas_intvl = floor(length(am_filt)/2):length(am_filt);
	amp(idx) = max(am_filt(meas_intvl)) - min(am_filt(meas_intvl));
end

%% plot out response
plot(freq/1e3, 20*log10(amp));
grid on;
xlabel('Frequency (kHz)');
ylabel('Response (dB)');
xlim([900 1100]);