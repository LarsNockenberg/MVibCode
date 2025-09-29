function [SMR,bandenergy,globalmask] = PsychohapticModel_MD(Block,bl,book,fs,settings)

channels = size(Block,1);

SMR = zeros(channels,length(book));
bandenergy = zeros(channels,length(book));
globalmask = zeros(channels,bl);

for i=1:channels

    [SMR(i,:),bandenergy(i,:),globalmask(i,:)] = PsychohapticModel(Block(i,:),bl,book,fs,settings);

end

end