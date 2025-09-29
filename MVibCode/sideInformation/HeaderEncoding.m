function [header,bitblock] = HeaderEncoding(bitblock,bl,settings)
%generates the header for the given blocklength and bitstream

%bits = 15;
bits = log2(bl)+5; %adaptive max bitstream length depending on bl
%bits = settings.bits_streamLength;
maxLength = 2^bits-1;
if(length(bitblock)>maxLength)
    bitblock = bitblock(1:maxLength);
end

header = de2bi(length(bitblock),bits);
    
end