function [header] = GlobalHeaderEncoding(bl)
%generates the header for the given blocklength and bitstream

switch bl
    case 32
        bitsize = 1;
    case 64
        bitsize = [0 1];
    case 128
        bitsize = [0 0 1];
    case 256
        bitsize = [0 0 0 1];
    case 512
        bitsize = [0 0 0 0 0];
    case 1024
        bitsize = [0 0 0 0 1];
end

header = bitsize;
    
end