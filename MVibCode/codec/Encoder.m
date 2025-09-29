function bitstream = Encoder(sig,bl,dwtlevel,fs,bitbudget,min_corr,settings)

    channels = size(sig,1);
    bl_padding = bl;
    numblocks = ceil(length(sig)/bl_padding);
    sig_padded = zeros(channels,numblocks*bl_padding);
    sig_padded(:,1:length(sig)) = sig;
    
    if(isfield(settings, 'single_channel'))
        if(~settings.single_channel)
            bitstream = EncodeChannelCount(channels,settings);
        else
            bitstream = [];
        end
    else
        bitstream = EncodeChannelCount(channels,settings);
    end
    
    
    blocklengths = ones(1,numblocks) * bl;
    sig_splitted = cell(1,numblocks);
    numblocks = length(blocklengths);
    for b=1:numblocks
        sig_block = sig_padded(:,(bl*(b-1)+1):bl*b);
        sig_splitted{b} = sig_block;
    end
    
    sig_blocks = cell(1,numblocks);
    clusterings = cell(1,numblocks);
    
    counter_arithmetic = [];
    for b=1:numblocks

        sig_blocks{b} = sig_splitted{b};
        settings_temp = settings;
        
        dwtlevel_block = log2(blocklengths(b)/4);
        bitbudget_block = round(bitbudget/(dwtlevel+1)*(dwtlevel_block+1));
        
        if(bitbudget_block>(dwtlevel_block+1)*15)
            bitbudget_block = (dwtlevel_block+1)*15;
        end
        
        min_corr_temp = min_corr;
        
        [bitstream_block,clusterings{b},~,counter_arithmetic] = BlockEncoderClustering(sig_splitted{b},blocklengths(b),dwtlevel_block,fs,bitbudget_block,min_corr_temp,settings_temp,counter_arithmetic);
        
        bitstream = [bitstream,bitstream_block];
        
    end

end