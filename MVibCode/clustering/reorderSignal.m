function reordered = reorderSignal(clusters,cluster_indices,channels,bl,signs)

reordered = zeros(channels,bl);
for c=1:length(clusters)
    for i=1:size(clusters{c},1)
        reordered(cluster_indices{c}(i),:) = clusters{c}(i,:)*signs{c}(i);
    end
end

end
        