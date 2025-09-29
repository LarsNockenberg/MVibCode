function sig_rec = Decoder(bitstream,settings)
    
    channelCount = 1;
    if(isfield(settings, 'single_channel'))
        if(~settings.single_channel)
            [bitstream,channelCount] = DecodeChannelCount(bitstream,settings);
        end
    else
        [bitstream,channelCount] = DecodeChannelCount(bitstream,settings);
    end

    blocks_rec = cell(1);
    sig_rec = [];
    counter_arithmetic = [];
    b = 1;
    while ~isempty(bitstream)
        [bitstream,blocks_rec{b},counter_arithmetic] = BlockDecoderClustering(bitstream,channelCount,settings,counter_arithmetic);
        sig_rec = [sig_rec,blocks_rec{b}];
        b = b + 1;
    end

end