function [out,counter] = RangeEncoder_adaptive(in,context,counter)
% function [out,ranges,counters,boundaries] = RangeEncoder_adaptive(in,context)
%
% range-encodes binary signals, based on
% VLSI Architecture of Arithmetic Coder Used in SPIHT, Liu et al., 2012
%
% inputs:
% - in: binary input signal
% - p: probability of zeros
%
% outputs:
% - out: encoded binary signal

contexts = 8;
range_max = int32(1024);
half = int32(512);
first_qtr = int32(256);
third_qtr = int32(768);

%context = zeros(size(context)); %for test without context

if nargin<3
    counter = [8*ones(1,contexts);16*ones(1,contexts)]; %init with p=0.5
elseif isempty(counter)
    counter = [8*ones(1,contexts);16*ones(1,contexts)]; %init with p=0.5
end

out = zeros([1,length(in)*2],'int32'); %allocate memory, definitely too large, since output should be compressed
index_out = 1;
range = [0;range_max];
bits_to_follow = 0;

for i =1:length(in)
    
    %calculate range; mod function is used to force the calculation to be
    %rounded downwards without using slow matlab division functions
    s = range(2) - range(1);
    new_symbol = in(i);
    %range_add = s*symbol_boundary(context(i)+1);
    boundary = counter(1,context(i)+1)/counter(2,context(i)+1)*range_max;
    range_add = s * boundary;
    if(new_symbol==0)
        %adjust upper boundary of range
        range(2) = range(1) + int32((range_add-mod(range_add,range_max))/range_max);
    else
        %adjust lower boundary of range
        range(1) = range(1) + int32((range_add-mod(range_add,range_max))/range_max);
    end
        
    %adjust range to prevent underflow and set output
    while(1)
        if(range(2)<=half)
            if(bits_to_follow>0)
                %line not really necessary since output is initialized with
                %zeros
                %out(index_out) = 0;
                out(index_out+1:index_out+bits_to_follow) = 1;
                index_out = index_out+bits_to_follow+1;
                bits_to_follow = 0;
            else
                %line not really necessary since output is initialized with
                %zeros
                %out(index_out) = 0;
                index_out = index_out+1;
            end
        elseif(range(1)>=half)
            if(bits_to_follow>0)
                out(index_out) = 1;
                %line not really necessary since output is initialized with
                %zeros
                %out(index_out+1:index_out+bits_to_follow) = zeros(1,bits_to_follow);
                index_out = index_out+bits_to_follow+1;
                bits_to_follow = 0;
            else
                out(index_out) = 1;
                index_out = index_out+1;
            end
            range = range - half;
        elseif(range(1)>=first_qtr && range(2)<=third_qtr)
            bits_to_follow = bits_to_follow + 1;
            range = range - first_qtr;
        else
            break;
        end
        range = range * 2;
    end
    
    %update counter for probabilities;
    if(in(i)==0)
        counter(1,context(i)+1) = counter(1,context(i)+1) + 1;
    end
    counter(2,context(i)+1) = counter(2,context(i)+1) + 1;
    
end


%set remainder to output
if(bits_to_follow>0)
    %if bits_to_follow is not reset to 0, setting the LSB of the output to 1
    %is the shortest encoded number in the correct range
    out(index_out) = 1;
    index_out = index_out+1;
else
    %find shortest representation of a value in the correct range
    val = half;
    while(range(1)>0)
        if(val<range(2))
            out(index_out) = 1;
            index_out = index_out+1;
            range = range-val;
        else
            out(index_out) = 0;
            index_out = index_out+1;
        end
        val = val/2;
    end
end
   
%cut off unnecessary zeros at end
index_out = index_out-1;
% while(index_out>0)
%     if out(index_out)
%         break;
%     else
%         index_out = index_out-1;
%     end
% end
out = out(1:index_out);

end
