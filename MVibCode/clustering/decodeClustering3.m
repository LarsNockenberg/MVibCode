function [clustering,references,bitstream] = decodeClustering3(bitstream,channels)

if(channels==1)
    clustering = {1};
    references = {0};
    return;
end

size_next = channels;
groupings = cell(0);
channels_left = 1:channels;
while(1)
    mask = bitstream(1:size_next);
    bitstream = bitstream(size_next+1:end);
    if(all(mask==0))
        for i=1:length(channels_left)
            groupings{end+1} = channels_left(i);
            size_next = 0;
        end
        break;
    end
    grouping = channels_left(mask==1);
    channels_left = channels_left(mask==0);
    size_next = size_next - sum(mask);
    groupings{end+1} = grouping;
    if(size_next<=1)
        break;
    end
end

if(size_next==1)
    groupings{end+1} = channels_left;
end

clustering = groupings;
references = cell(size(groupings));

for c=1:length(groupings)
    l = length(groupings{c});
    references{c} = zeros(1,l);
    if(l>1)
        for i=1:l
            bits = ceil(log2(l+1));
            references{c}(i) = bi2de(bitstream(1:bits));
            bitstream = bitstream(bits+1:end);

        end
    end
end

end