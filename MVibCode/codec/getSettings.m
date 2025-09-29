function [settings] = getSettings(bl,mean_mode,vc_pwq_mode,single_channel,channelBits)

perc_bitalloc = 0;
maxallocbits_size = 4;
bits_streamLength = log2(bl)+5;
mean_bits_max = 8;
mean_bits = 8;
masking = 1;
bl_min = 128;

settings = struct('old_mode',vc_pwq_mode,'mean_mode',...
    mean_mode,'perc_bitalloc',perc_bitalloc,...
    'maxallocbits_size',maxallocbits_size,'bits_streamLength',bits_streamLength,...
    'mean_bits_max',mean_bits_max,'mean_bits',mean_bits,'masking',masking,...
    'bl_min',bl_min,'single_channel',single_channel,'channelBits',channelBits);

end

