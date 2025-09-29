function [stream,recsignal,counter,origlength,dwtlevel] = DecoderMD(stream,channels,settings,counter,dwt,bl,dwtlevel)
% decoding of the compressed bitstream; can handle multiple blocks
%
% input:
% stream - encoded bitstream array
%
% output:
% recsignal - 2D array of decoded signal blocks (1st dim: blocks)

if(nargin<5)
    dwt = 0;
    bl_decode = 1;
else
    if(bl~=0)
        origlength = bl;
        bl_decode = 0;
    else
        bl_decode = 1;
    end
end

%separate stream into blocks
if(bl_decode)
    [stream,origlength,dwtlevel] = GlobalHeaderDecoding(stream);
end
m = 1;
for c=1:channels
    %get header data
    [stream,segmentlength] = HeaderDecoding(stream,origlength,settings);
    %get encoded signal
    recbitblocks{m} = stream(1:segmentlength);
    stream = stream(segmentlength+1:end);
    m = m+1;
end

%init
numsignals = length(recbitblocks);
intrecblocks = cell(numsignals,1);
recwav = cell(numsignals,1);
recbitmax = zeros(1,numsignals);
recwavmax = zeros(1,numsignals);

%SPIHT decoding
for j = 1:numsignals
    if ~isempty(recbitblocks{j})
        [intrecblocks{j},recbitmax(j),recdwtlevel,recwavmax(j),counter] = SPIHT_1D_Dec_adaptive(recbitblocks{j},dwtlevel,origlength,settings,counter);
        recwav{j} = intrecblocks{j}.*recwavmax(j)./2^(recbitmax(j));
    else
        recwav{j} = zeros(1,origlength);
    end
end

bl = length(recwav{1});

%inverse DWT
recblocks = zeros(numsignals,bl);
for j = 1:numsignals
    if(dwt)
        recblocks(j,:) = wavecdf97(recwav{j},-dwtlevel);
    else
        recblocks(j,:) = recwav{j};
    end
end
%recsignal = reshape(recblocks',[],1)';
recsignal = recblocks;
end

