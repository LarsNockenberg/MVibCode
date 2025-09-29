add_paths;

%generate a random signal with value range [-3,3]
sig_in = randn(5,1000);
sig_in = sig_in / max(max(sig_in)) * 3;

%settings used for the MVibCode paper, with parametrization function for
%g_{thr}
bl = 512; %block length
fs = 2500; %sampling frequency

mean_mode = 1; %1 activates mean encoding module; can be deactivated if not beneficial for signals at hand
vc_pwq_mode = 0; %1 removes additional coding methods of the MVibCode, it behaves like the VC-PWQ then
single_channel = 0; %1 if you only process single-channel signals (the codec behaves like the VC-PWQ then)
channelBits = 4; %Increase this if you have more than 15 channels
settings = getSettings(bl,mean_mode,vc_pwq_mode,single_channel,channelBits); %this calls a function to prepare the settings for the codec

%parametrization from MVibCode paper
dwtlevel = log2(bl/4);
bit_budget = round([4 8 12 16 20 24 28 32 36 40 44 48 52 56 65 75 85 95 105 115 120]/8*(dwtlevel+1)); %120 is the maximum bit budget for bl=512 samples
load('data/parametrization.mat');
F = @(p,x)-p(1)*(x/p(3)*120).^2+p(2);
params(end) = (dwtlevel+1)*15;
g_thr = F(params,bit_budget);
g_thr(g_thr < 0) = 0;

%encode and decode random signal with a range of settings for bit budget and g_{thr} (for bitrate scaling)
for i = 1:length(bit_budget)

    bitstream = Encoder(sig_in,bl,dwtlevel,fs,bit_budget(i),g_thr(i),settings);

    sig_rec = Decoder(bitstream,settings); %obtain recovered signal (with padding to full blocks)

end
