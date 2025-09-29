function [bitstream] = EncodeChannelCount(channels,settings)
    channelBits = 4;
    if(isfield(settings,'channelBits'))
        channelBits = settings.channelBits;
    end
    bitstream = de2bi(channels,channelBits);
end