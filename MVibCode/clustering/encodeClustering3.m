function bitstream = encodeClustering3(clustering,references,channels)

if(channels==1)
    bitstream = [];
    return;
end

clusters = length(clustering);
bitstream = [];
channels_left = 1:channels;
for c=1:clusters
    if(length(channels_left) == (length(clustering) -c+1))
        bitstream = [bitstream,zeros(size(channels_left))];
        break;
    end
    grouping = ismember(channels_left,clustering{c});
    bitstream = [bitstream,grouping];
    channels_left(grouping) = [];
    if(length(channels_left)<=1)
        break;
    end
end

for c=1:clusters
    channels_cluster = length(clustering{c});
    if(channels_cluster>1)
        for i=1:channels_cluster
            index = references{c}(i);
            bitstream = [bitstream,de2bi(index,ceil(log2(channels_cluster+1)))];
        end
    end
end

end