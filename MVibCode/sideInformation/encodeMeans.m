function [bitstream,data] = encodeMeans(data,settings)


%if(size(data,1)==1)
if(0)
    
    bits = 6;
    threshold = 0.02;
    means = mean(data);
    if(means<threshold)
        bitstream = 0;
    else
        means_signs = sign(means);

        signs_enc = means_signs;
        signs_enc(signs_enc==-1) = 0;
        means_quantized = UniformQuant(abs(means),1,bits);
        means_quantized_int = means_quantized * 2^bits;
        bitstream = [1,signs_enc,de2bi(means_quantized_int,bits)];
        data = data - (means_quantized.*means_signs)';
    end
else
    
    bits_max = settings.mean_bits_max;
    bits = settings.mean_bits;

    means = zeros(1,size(data,1));
    for i=1:size(data,1)
        means(i) = mean(data(i,:));
        %means(i) = 0;
        if(means(i)>1)
            means(i)
        end
    end
    
    max_quant = UniformQuant(max(abs(means)),1,bits_max);
    max_quant_int = max_quant * 2^bits_max;
    if(max_quant==0)
        %max_quant = 1; %bug
        max_quant_int = 1; %fix
        max_quant = max_quant_int / (2^bits_max); %fix
    end
    means = means/(max_quant);

    means_signs = sign(means);
    signs_enc = means_signs;
    signs_enc(signs_enc==-1) = 0;
    means_quantized = UniformQuant(abs(means),1,bits);
    means_quantized_int = means_quantized * 2^bits;
    bitstream = de2bi(max_quant_int,bits_max);
    for i=1:size(data,1)
        bitstream = [bitstream,signs_enc(i),de2bi(means_quantized_int(i),bits)];
    end
    data = data - (means_quantized.*means_signs*max_quant)';
    
end

end