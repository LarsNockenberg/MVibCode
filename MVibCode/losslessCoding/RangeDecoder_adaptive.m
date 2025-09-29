function [in_stream, in_index, in_leading, range_diff, range, counter, out] = RangeDecoder_adaptive(in_stream, context, counter, in_index, in_leading, range_diff, range)
% function [in_stream, in_index, in_leading, range_diff, range, counter, out] = RangeDecoder_adaptive(in_stream, context, in_index, in_leading, range_diff, range, counter)
%
% range-decodes binary signals, based on
% VLSI Architecture of Arithmetic Coder Used in SPIHT, Liu et al., 2012
% function only decodes one symbol at a time to work with the SPIHT decoder
% and the state variables have to be stored by the calling function
% the coder is adaptive (probabilities are updated after each symbol)
%
% inputs:
% - in: encoded binary input signal
% - p: probability of zeros
% - l: length of expected output signal
%
% outputs:
% - out: decoded binary signal

range_max = int32(1024);
half = int32(512);
first_qtr = int32(256);
third_qtr = int32(768);
contexts = 8;

if nargin <= 3 %at first function call
    in_index = 1;
    
    %init input for decoding
    in_leading = int32(0);
    multiplier = int32(2^(10-1));
    for i = 1:10
        if(in_index+i-1<=length(in_stream))
            in_leading = in_leading + in_stream(in_index+i-1)*multiplier;
            multiplier = multiplier/2;
        else
            break;
        end
    end
    in_index = in_index+i;
    
    range_diff = range_max;
    range = [0;range_max];
    if isempty(counter)
        counter = [8*ones(1,contexts);16*ones(1,contexts)]; %init with p=0.5
    end
end

boundary = counter(1,context+1)/counter(2,context+1) * range_max;
compare = range_diff * boundary;


%determine next symbol; range is updated
value = floor(in_leading) - range(1);
compare = int32((compare - mod(compare,range_max))/range_max);
if value < compare
    s = 0;
    range(2) = range(1) + compare;
else
    s = 1;
    range(1) = range(1) + compare;
end


%check, if range has to be adjusted
while(1)
    if(range(2)<=half)
        range = 2*range;
        %get new digit
        if in_index <= length(in_stream)
            new_digit = in_stream(in_index);
            in_index = in_index+1;
            in_leading = in_leading * 2 + new_digit;
        else
            in_leading = in_leading*2;
        end
    elseif(range(1)>=half)
        range = 2*(range - half);
        %get new digit
        if in_index <= length(in_stream)
            new_digit = in_stream(in_index);
            in_index = in_index+1;
            in_leading = (in_leading-half) * 2 + new_digit;
        else
            in_leading = (in_leading-half) *2 ;
        end
    elseif(range(1)>=first_qtr && range(2)<=third_qtr)
        range = 2*(range - first_qtr);
        %get new digit
        if in_index <= length(in_stream)
            new_digit = in_stream(in_index);
            in_index = in_index+1;
            in_leading = (in_leading-first_qtr) * 2 + new_digit;
        else
            in_leading = (in_leading-first_qtr) * 2;
        end
    else
        break;
    end
end


range_diff = range(2)-range(1);
out = s;

%update counter for occurence of symbols
if(out==0)
    counter(1,context+1) = counter(1,context+1) + 1;
end
counter(2,context+1) = counter(2,context+1) + 1;


end