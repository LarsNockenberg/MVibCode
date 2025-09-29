function [percthres] = PerceptualThreshold(bl,fs)
% returns array of perceptual thresholds over frequency
%
% inputs:
% bl - block length
% fs - sampling frequency
%
% output:
% percthres - array of perceptual thresholds

freq = linspace(0,fs,2*bl);

a = 62;
c = 1/550;
b = 1-250*c;
e = 77;


%percthres = abs(a/(log10(b))^2*(log10(c.*freq(1:bl)+b)).^2)-e;
%percthres = abs(62/(log10(4.7/8))^2*(log10(4/(8*300).*freq(1:bl)+4.7/8)).^2)-77;
%percthres = abs(60/(log10(3/7))^3*(log10(3/(7*300).*freq(1:bl)+3/7)).^3)-80;

percthres = abs(a/(log10(b))^2*(log10(c.*freq(1:bl)+b)).^2)-e;
limit = find(percthres>0,1);
%percthres(limit+1:bl) = percthres(limit);
percthres(limit+1:bl) = 0;
percthres(percthres>0) = 0;


end