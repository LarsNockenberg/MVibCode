function [q] = UniformQuant(x,max,bits)
% applies Uniform Quantization, mid-tread type
% inputs:
% x - input signal
% max - absolute maximum value of signal
% bits - amount of bits used for quantization
%
% outputs:
% q - quantized signal

delta = max./(2^(bits)); %quantization step
q = sign(x) .* delta .* floor(abs(x)./delta + 0.5);
max_q = delta * (2^(bits) - 1);
q(abs(q)>max_q) = sign(q(abs(q)>max_q)) * max_q; %limit values to quantized max


end

