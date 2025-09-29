function [bitstream,means] = decodeMeans(bitstream,channels,settings)

%if(channels ==1)
if(0)
    
    bits = 6;
    
    means = zeros(1,channels);
    mode = bitstream(1);
    bitstream = bitstream(2:end);
    if(mode)
        multiplicator = 2^bits;
        for i=1:channels
            sign_mean = bitstream(1);
            if(sign_mean == 0)
                sign_mean = -1;
            end
            means(i) = double(bi2de(bitstream(2:1+bits))) / double(multiplicator * sign_mean);
            bitstream = bitstream(1+1+bits:end);
        end
    end
    
else

    bits_max = settings.mean_bits_max;
    bits = settings.mean_bits;
    
    max_quant = double(bi2de(bitstream(1:bits_max)))/(2^bits_max);
    bitstream = bitstream(bits_max+1:end);
    
    means = zeros(1,channels);
    multiplicator = 2^bits;
    for i=1:channels
        sign_mean = bitstream(1);
        if(sign_mean == 0)
            sign_mean = -1;
        end
        means(i) = double(bi2de(bitstream(2:1+bits))) / double(multiplicator * sign_mean);
        bitstream = bitstream(1+1+bits:end);
    end
    means = means * max_quant;
    %means
    
end

end