function [SMR,bandenergy,globalmask] = PsychohapticModel(block,bl,book,fs,settings)

spect = 20*log10(abs(dct(block)));
globalmask = GlobalMaskingThreshold(spect,bl,fs,settings);
bandenergy = zeros(1,length(book));
maskenergy = zeros(1,length(book));
m = 0;
for i = 1:length(book)
    bandenergy(i) = sum(10.^(spect(m+1:m+book(i))./10));
    maskenergy(i) = sum(globalmask(m+1:m+book(i)));
    m = m+book(i);
end

SMR = 10.*log10(bandenergy./maskenergy);
globalmask = 10*log10(globalmask); %output of globalmask in dB
    
end

function [globalmask] = GlobalMaskingThreshold(spect,bl,fs,settings)

freq = linspace(0,fs,2*bl);

percthres = PerceptualThreshold(bl,fs);

masking = 1;

if isfield(settings,'masking')
    masking = settings.masking;
end

if(masking)
    [pks,ploc] = findpeaks(spect,'MinPeakProminence',12,'MinPeakHeight',max(spect)-45);
    %pks
    %ploc-1
    if isempty(pks)
        globalmask = 10.^(percthres./10);
        return
    end
    masks = zeros(length(pks),bl);
    for i = 1:length(pks)
        masks(i,:) = pks(i) - 5 + 5/1400*freq(ploc(i)) - 30/freq(ploc(i))^2.*(freq(1:bl)-freq(ploc(i))).^2;
    end
    mask = max(masks,[],1);
    globalmask = 10.^(mask./10)+10.^(percthres./10);
else
    globalmask = 10.^(percthres./10);

end

end