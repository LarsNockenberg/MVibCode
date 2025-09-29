function [FinalBlockBitstream,Block_quant,counter_arithmetic,globalmask] = BlockEncoderMD(Block_diffs,Block_orig,SMR,bandenergy,bl,dwtlevel,BitBudget,fs,settings,counter_arithmetic)

if(BitBudget > (dwtlevel+1) * 15)
    BitBudget = (dwtlevel+1) * 15;
end

book = bl./(2.^([dwtlevel,dwtlevel:-1:1]))';
%variable allocation
channels = size(Block_diffs,1);
bitalloc = zeros(channels,length(book));
if nargin < 10
    counter_arithmetic = []; %for arithmetic coding
end
if(numel(Block_orig)==0)
    Block_orig = Block_diffs;
end

%DWT, Psychohaptic Model
WaveletCoefficients = Block_diffs;


%Bitallocation
if(~all(WaveletCoefficients(:)==0))

    qwavmax = zeros(1,channels);
    bitwavmax = zeros(channels,8);
    noiseenergy = zeros(channels,length(book));
    Block_quant = zeros(channels,bl);
    for i=1:channels
        [qwavmax(i),bitwavmax(i,:)] = MaximumWaveletCoefficient(WaveletCoefficients(i,:));
        m = 0;
        for b = 1:length(book)
            Block_quant(i,m+1:m+book(b)) = UniformQuant(WaveletCoefficients(i,m+1:m+book(b)),(qwavmax(i)),bitalloc(i,b));
            noiseenergy(i,b) = sum(abs(WaveletCoefficients(i,m+1:m+book(b))-Block_quant(i,m+1:m+book(b))).^2);
            m = m+book(b);
        end
    end

    for i=1:channels
        BitBudget_channel = BitBudget;
        while sum(bitalloc(i,:)) < BitBudget_channel
        %while sum(bitalloc(i,:) .* book') < BitBudget_channel
            SNR = 10.*log10(bandenergy./noiseenergy);
            MNR = SNR-SMR;

            %MNR = MNR + 10*(book ./bl)';

            MNR(bitalloc>=15) = Inf;
            [~,MinInd] = min(MNR(i,:));


            bitalloc(i,MinInd) = bitalloc(i,MinInd) + 1;
    %         if sum(bitalloc(r_min,1:end-1)) >= 15*(dwtlevel)
    %             bitalloc(r_min,end) = BitBudget-15*dwtlevel;
    %         else
    %             bitalloc(r_min,c_min) = bitalloc(r_min,c_min) + 1;
    %         end
            %quantization of only the changed component
            m = sum(book(1:MinInd-1));
            %Block_quant(r_min,m+1:m+book(c_min)) = DeadzoneQuant(WaveletCoefficients(r_min,m+1:m+book(c_min)),(qwavmax(r_min)),bitalloc(r_min,c_min));
            temp_quant = UniformQuant(WaveletCoefficients(i,m+1:m+book(MinInd)),qwavmax(i),bitalloc(i,MinInd));
            if(all(temp_quant==0))
                %BitBudget_channel = BitBudget_channel + 1;
            end
            Block_quant(i,m+1:m+book(MinInd)) = temp_quant;
            noiseenergy(i,MinInd) = sum(abs(WaveletCoefficients(i,m+1:m+book(MinInd))-Block_quant(i,m+1:m+book(MinInd))).^2);
            
            if(BitBudget_channel>15*length(book))
                BitBudget_channel = 15*length(book);
            end
        end
    end

    for i=1:channels
        m=0;
        for b = 1:length(book)
            Block_quant(i,m+1:m+book(b)) = UniformQuant(WaveletCoefficients(i,m+1:m+book(b)),(qwavmax(i)),bitalloc(i,b));
            noiseenergy(i,b) = sum(abs(WaveletCoefficients(i,m+1:m+book(b))-Block_quant(i,m+1:m+book(b))).^2);
            m = m+book(b);
        end
    end

    bitmax = max(bitalloc,[],2);
    intmax = 2.^bitmax;
    rqmax = repmat((qwavmax'),1,bl);
    Block_intquant = Block_quant.*intmax./rqmax;

    FinalBlockBitstream = GlobalHeaderEncoding(bl);
    for i=1:channels

        %SPIHT encoding
        if(bitmax(i,:)==16)
            disp('error in bit allocation')
        end
        [bitblock_SPIHT,context] = SPIHT_1D_Enc(Block_intquant(i,:),dwtlevel,bitwavmax(i,:),bitmax(i),settings);

        %arithmetic encoding
        [bitblock,counter_arithmetic] = RangeEncoder_adaptive(bitblock_SPIHT,context,counter_arithmetic);
        counter_arithmetic = rescaleCounter(counter_arithmetic);

        %header
        [header,bitblock] = HeaderEncoding(bitblock,bl,settings);
        FinalBlockBitstream = [FinalBlockBitstream,header,bitblock];

    end

else

    bitblock = [];
    Block_quant = zeros(channels,bl);
    %header
    FinalBlockBitstream = GlobalHeaderEncoding(bl);
    [header,bitblock] = HeaderEncoding(bitblock,bl,settings);
    FinalBlockBitstream = [FinalBlockBitstream,header,bitblock];

end
    


end



