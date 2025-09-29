function [cluster_members,clusters_sorted,signs,ref_sorted,ref_remapped] = sortClusters(clusters,signs,ref)

cluster_members = clusters;
ref_sorted = cell(size(clusters));
ref_remapped = cell(size(clusters));
for c=1:length(clusters)
    [cluster_members{c},sorting] = sort(clusters{c});
    signs{c} = signs{c}(sorting);
    %references for each cluster, but original indices
    ref_cluster = zeros(1,length(clusters{c}));
    %new indices
    ref_cluster_remapped = zeros(1,length(clusters{c}));
    mapping = zeros(1,length(clusters{c}));
    
    for i=1:length(clusters{c})
        ref_cluster(i) = ref(cluster_members{c}(i),1);
        if(ref_cluster(i)~=0)
            ref_cluster_remapped(i) = find(cluster_members{c} == ref_cluster(i));
        end
    end
    
    index = find(ref_cluster==0);
    %clusters_sorted{c} = index;
    clusters_sorted{c} = cluster_members{c}(index);
    ref_sorted{c} = [];
    i=1;
    while length(clusters_sorted{c})<length(clusters{c})
        %channels = find(ref_cluster==clusters_sorted{c}(i));
        channels = cluster_members{c}(find(ref_cluster==clusters_sorted{c}(i)));
        if(numel(channels)>0)
            clusters_sorted{c} = [clusters_sorted{c},channels];
            ref_sorted{c} = [ref_sorted{c},i*ones(size(channels))];
        end
        i=i+1;
    end
    ref_remapped{c} = ref_cluster_remapped;
end


end