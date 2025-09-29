function [m,n_real,level,wavmax,counter] = SPIHT_1D_Dec_adaptive(in,level,origlength,settings,counter)
%External library, modified for use case. Original:
%Kanchi (2024). SPIHT (https://www.mathworks.com/matlabcentral/fileexchange/4808-spiht), MATLAB Central File Exchange. Visited 16th of Juli 2024. 
% Matlab implementation of SPIHT
% modified: added arithmetic decoding stage
%
% Decoder
%
% input:    in : bit stream
%
% output:   m : reconstructed image in wavelet domain
%

%-----------   Initialization  -----------------
% image size, number of bit plane, wavelet decomposition level should be
% written as bit stream header.

maxallocbits_size = settings.maxallocbits_size;

%arithmetic decoding of SPIHT header
header = zeros(1,maxallocbits_size+8);
[in,in_index,in_leading,range_diff,range,counter,header(1)] = RangeDecoder_adaptive(in,0,counter);

for i=2:maxallocbits_size+8
    [in,in_index,in_leading,range_diff,range,counter,header(i)] = RangeDecoder_adaptive(in,0,counter,in_index,in_leading,range_diff,range);
end


m = zeros(1,origlength);
n_max = bi2de(header(1,1:maxallocbits_size));
n_real = n_max;
mode = header(maxallocbits_size+1);
if mode == 0
    wavmax = bi2de(header(1,maxallocbits_size+2:maxallocbits_size+8))*2^(-7);
else
    wavmax = bi2de(header(1,maxallocbits_size+2:maxallocbits_size+8))*2^(-4)+1;
end


%-----------   Initialize LIP, LSP, LIS   ----------------
temp = [];
bandsize = 2.^(log2(origlength) - level + 1);
temp = 1 : bandsize;
LIP(:, 1) = ones(bandsize,1);
LIP(:, 2) = temp';

LIS(:, 1) = LIP(bandsize/2+1:end, 1);
LIS(:, 2) = LIP(bandsize/2+1:end, 2);
LIS(:, 3) = zeros(length(LIP(bandsize/2+1:end, 1)), 1);
LSP = [];

%-----------   coding   ----------------
n = n_max;
n_coded = -1;
while (n>=0)
    
    LSP_idx = size(LSP,1); % to be used in refinement pas
    
    %Sorting Pass
    LIPtemp = LIP; temp = 0;
    for i = 1:size(LIPtemp,1)
        temp = temp+1;
        if getBit(2) == 1
            if getBit(1) > 0
                m(LIPtemp(i,1),LIPtemp(i,2)) = 2^n;
            else
                m(LIPtemp(i,1),LIPtemp(i,2)) = -2^n;
            end
            LSP = [LSP; LIPtemp(i,:)];
            LIP(temp,:) = []; temp = temp - 1;
        end
    end
    
    LIStemp = LIS; temp = 0; i = 1;
    while ( i <= size(LIStemp,1))
        temp = temp + 1;
        if LIStemp(i,3) == 0
            if getBit(3) == 1
                x = LIStemp(i,1); y = LIStemp(i,2);
                
                if getBit(4) == 1
                    LSP = [LSP; x 2*y-1];
                    if getBit(1) == 1
                        m(x,2*y-1) = 2^n;
                    else
                        m(x,2*y-1) = -2^n;
                    end
                else
                    LIP = [LIP; x 2*y-1];
                end
                
                if getBit(4) == 1
                    LSP = [LSP; x 2*y];
                    if getBit(1) == 1
                        m(x,2*y) = 2^n;
                    else
                        m(x,2*y) = -2^n;
                    end
                else
                    LIP = [LIP; x 2*y];
                end
                if ((2*(2*y)-1) < size(m,2))
                    LIS = [LIS; LIStemp(i,1) LIStemp(i,2) 1];
                    LIStemp = [LIStemp; LIStemp(i,1) LIStemp(i,2) 1];
                end
                LIS(temp,:) = []; temp = temp-1;
                
            else
            end
        else
            if getBit(5) == 1
                x = LIStemp(i,1); y = LIStemp(i,2);
                LIS = [LIS; x 2*y-1 0; x 2*y 0];
                LIStemp = [LIStemp; x 2*y-1 0; x 2*y 0];
                LIS(temp,:) = []; temp = temp - 1;
            end
        end
        i = i+1;
    end
    
    % Refinement Pass
    temp = 1;
    while (temp<=LSP_idx)
        m(LSP(temp,1),LSP(temp,2)) = m(LSP(temp,1),LSP(temp,2)) +sign(m(LSP(temp,1),LSP(temp,2)))*(2^n)*getBit(6);
%         if(in_index>length(in))
%             disp('end reached');
%         end
        temp = temp + 1;
    end
    
    n = n-1;
end

counter = rescaleCounter(counter);

    function out = getBit(context)
        %context = 0; for evaluation without context
        [in,in_index,in_leading,range_diff,range,counter,out] = RangeDecoder_adaptive(in,context,counter,in_index,in_leading,range_diff,range);
    end

end