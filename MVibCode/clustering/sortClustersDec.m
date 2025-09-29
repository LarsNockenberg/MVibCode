function [clusters_sorted,ref_sorted] = sortClustersDec(cluster_members,ref)

clusters_sorted = cell(size(cluster_members));
ref_sorted = cell(size(cluster_members));
for c=1:length(cluster_members)
    
    index = find(ref{c}==0);
    clusters_sorted{c} = index;
    %clusters_sorted{c} = cluster_members{c}(ref{c}==0);
    ref_sorted{c} = [];
    i=1;
    while length(clusters_sorted{c})<length(cluster_members{c})
        channels = find(ref{c}==clusters_sorted{c}(i));
        %channels = cluster_members{c}(ref{c}==clusters_sorted{c}(i));
        %channels = cluster_members{c}(cluster_members{c}(ref{c})==clusters_sorted{c}(i));
        if(numel(channels)>0)
            clusters_sorted{c} = [clusters_sorted{c},channels];
            ref_sorted{c} = [ref_sorted{c},i*ones(size(channels))];
        end
        i=i+1;
    end
    clusters_sorted{c} = cluster_members{c}(clusters_sorted{c});
end


end