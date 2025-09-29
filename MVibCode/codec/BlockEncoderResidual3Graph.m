function [FinalBlockBitstream,Block_quant,means,counter_arithmetic] = BlockEncoderResidual3Graph(Block,sig_ref,references,SMR,bandenergy,bl,dwtlevel,budget,settings,counter_arithmetic)

perc_bitalloc = settings.perc_bitalloc;

book = bl./(2.^([dwtlevel,dwtlevel:-1:1]))';
%variable allocation
channels = size(Block,1);
if nargin < 8
    counter_arithmetic = []; %for arithmetic coding
end

dwt_ref = sig_ref;
%DWT
WaveletCoefficients = Block;
bandenergy = zeros(channels,length(book));
noiseenergy = zeros(channels,length(book));
qwavmax = zeros(1,channels);
bitwavmax = zeros(channels,8);
SNR = zeros(channels,length(book));
FinalBlockBitstream = [];
Block_quant = zeros(channels,bl);
diff_signals = zeros(channels,bl);
sig_intquant_all = zeros(channels,bl);
bandenergy_sig = zeros(channels,length(book));
SNR_sig = zeros(channels,length(book));
bitalloc = zeros(channels,length(book));
MNR = zeros(channels,length(book));
dwt_refs = zeros(channels+1,bl);
dwt_refs(1,:) = sig_ref;

SMR_norm = SMR - max(SMR(:));

for i=1:channels

    
    %Bitallocation
    if(~all(WaveletCoefficients(i,:)==0))

        mask = ones(1,length(book));
        diff_sig = WaveletCoefficients(i,:) - dwt_refs(references(i),:);
        diff_signals(i,:) = diff_sig;
        
        m = 0;
        for b = 1:length(book)
            bandenergy(i,b) = sum(abs(diff_sig(m+1:m+book(b))).^2);
            bandenergy_sig(i,b) = sum(abs(WaveletCoefficients(i,m+1:m+book(b))).^2);
            noiseenergy(i,b) = bandenergy(i,b);
            m = m+book(b);
        end

        [qwavmax(i),bitwavmax(i,:)] = MaximumWaveletCoefficient(diff_sig);
        SNR(i,:) = 10.*log10(bandenergy(i,:)./noiseenergy(i,:));
        SNR_sig(i,:) = 10.*log10(bandenergy_sig(i,:)./noiseenergy(i,:));
        MNR(i,:) = SNR_sig(i,:) - SMR(i,:);

        sigma = zeros(1,length(book));
        m=0;
        for b = 1:length(book)
            sigma(b) = var(diff_sig(m+1:m+book(b))/qwavmax(i));
            m = m+book(b);
        end
        weights = ones(size(SMR(i,:)));
        sigma_prod = prod(sigma.*weights);
        
        if(perc_bitalloc==1)
            if(i==1)
                [metric,~,~] = MetricNorm(WaveletCoefficients(i,:),diff_sig,SMR(i,:),SMR(i,:),book);
            else
                [metric,~,~] = MetricNorm(WaveletCoefficients(i,:),diff_sig,SMR(i,:),SMR(i-1,:),book);
            end
        end
        
        m=0;
        for b = 1:length(book)
            
            if(perc_bitalloc==1)
                bitalloc(i,b) = budget + 0.5*log2((sigma(b)*weights(b))/(sigma_prod^(1/length(book)))) - 0.5 * log2(metric);
            else
                bitalloc(i,b) = budget + 0.5*log2((sigma(b)*weights(b))/(sigma_prod^(1/length(book)))) - 0.5 * log2(sum(WaveletCoefficients(i,:).^2)/sum(diff_sig.^2));
            end

            bitalloc(i,b) = round(bitalloc(i,b));
            if(bitalloc(i,b)<0)
                bitalloc(i,b)=0;
            elseif(bitalloc(i,b)>15)
                bitalloc(i,b) = 15;
            end
            m = m+book(b);
        end
        
        m=0;
        for b = 1:length(book)
            quant = UniformQuant(diff_sig(m+1:m+book(b)),(qwavmax(i)),bitalloc(i,b));
            Block_quant(i,m+1:m+book(b)) = quant;
            noiseenergy(i,b) = sum(abs(diff_sig(m+1:m+book(b))-quant).^2);
            m = m+book(b);
        end

        bitmax = max(bitalloc(i,:),[],2);
        intmax = 2.^bitmax;
        rqmax = repmat(qwavmax(i),1,bl);
        sig_intquant = Block_quant(i,:).*intmax./rqmax;
        sig_intquant_all(i,:) = sig_intquant;

        %SPIHT encoding
        [bitblock_SPIHT,context] = SPIHT_1D_Enc(sig_intquant,dwtlevel,bitwavmax(i,:),bitmax,settings);

        %arithmetic encoding
        [bitblock,counter_arithmetic] = RangeEncoder_adaptive(bitblock_SPIHT,context,counter_arithmetic);
        counter_arithmetic = rescaleCounter(counter_arithmetic); 
        
        %header
        [header,bitblock] = HeaderEncoding(bitblock,bl,settings);
        FinalBlockBitstream = [FinalBlockBitstream,header,bitblock];
        
        dwt_refs(i+1,:) = dwt_refs(references(i),:) + Block_quant(i,:);

    else

        bitblock = [];
        Block_quant = zeros(channels,bl);
        %header
        [header,bitblock] = HeaderEncoding(bitblock,bl,settings);
        FinalBlockBitstream = [FinalBlockBitstream,header,bitblock];

    end   
    
end

means = [];
end

