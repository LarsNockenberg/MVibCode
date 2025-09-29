function [bitstream,channels] = DecodeChannelCount(bitstream,settings)
    channelBits = 4;
    if(isfield(settings,'channelBits'))
        channelBits = settings.channelBits;
    end
    channels = bi2de(bitstream(1:channelBits));
    bitstream = bitstream(channelBits+1:end);
end