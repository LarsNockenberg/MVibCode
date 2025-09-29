function [qwavmax,bitwavmax] = MaximumWaveletCoefficient(wavcoeff)
wavmax = max(abs(wavcoeff));
if wavmax < 1
    integerpart = 0;
    integerbits = 0;
    fractionbits = 7;
    mode = 0;
else
    integerpart = 1;
    integerbits = 3;
    fractionbits = 4;
    mode = 1;
end
qwavmax = MaxQuant(wavmax-integerpart,integerbits,fractionbits) + integerpart;
bitwavmax = [mode,de2bi((qwavmax-integerpart).*2^fractionbits,integerbits+fractionbits)];
end

