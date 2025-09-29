function [sig_dwt] = wavecdf97_MD(sig,dwtlevel)

sig_dwt = zeros(size(sig));
for i=1:size(sig,1)
    sig_dwt(i,:) = wavecdf97(sig(i,:),dwtlevel);
end

end